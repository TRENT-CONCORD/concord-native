const axios = require('axios');
const crypto = require('crypto');
const fs = require('fs-extra');
const path = require('path');
const AdmZip = require('adm-zip');
const tmp = require('tmp');
const FormData = require('form-data');

module.exports = async function (context, req) {
    // Create temporary directory that will be cleaned up when done
    const tmpDir = tmp.dirSync({ unsafeCleanup: true });
    
    try {
        context.log('GitHub Webhook triggered');

        // Verify GitHub signature
        const signature = req.headers['x-hub-signature-256'];
        const webhookSecret = process.env.GITHUB_WEBHOOK_SECRET;
        
        // Skip validation when secret is not configured (for testing)
        if (webhookSecret) {
            if (!signature) {
                context.log.error('No signature provided');
                context.res = {
                    status: 401,
                    body: "Signature missing"
                };
                return;
            }

            const hmac = crypto.createHmac('sha256', webhookSecret);
            const digest = 'sha256=' + hmac.update(JSON.stringify(req.body)).digest('hex');
            
            if (signature !== digest) {
                context.log.error('Invalid signature');
                context.res = {
                    status: 401,
                    body: "Invalid signature"
                };
                return;
            }
        }

        // Get branch name
        const branch = req.body.ref?.replace('refs/heads/', '');
        const repositoryName = req.body.repository?.name;
        
        if (!branch) {
            context.log.error('No branch info found in webhook payload');
            context.res = {
                status: 400,
                body: "Missing branch information"
            };
            return;
        }

        context.log(`Webhook received for branch: ${branch} in repo: ${repositoryName}`);

        // Only deploy for specified branches and repository
        if ((branch === 'sandbox' || branch === 'main') && 
            repositoryName === 'concord-native') {
            
            // Process and deploy the backend code
            if (branch === 'sandbox') {
                // DEVELOPMENT ENVIRONMENT
                const zipPath = await createDeploymentPackage(branch, tmpDir.name, context);
                await deployToAzureWebApp(
                    'concord-dev',
                    'concord-api-dev',
                    zipPath,
                    process.env.SANDBOX_SUBSCRIPTION_ID || 'ff42a815-661f-4e1f-867b-6a99ca790307',
                    'development',
                    context
                );
                context.log('Development deployment completed successfully');
            } else {
                // PRODUCTION ENVIRONMENT
                const zipPath = await createDeploymentPackage(branch, tmpDir.name, context);
                await deployToAzureWebApp(
                    'concord-prod',
                    'concord-api',
                    zipPath,
                    process.env.MAIN_SUBSCRIPTION_ID,
                    'production',
                    context
                );
                context.log('Production deployment completed successfully');
            }
            
            context.res = {
                status: 200,
                body: `Deployed ${branch} branch successfully!`
            };
        } else {
            context.log(`No deployment needed for ${branch} branch.`);
            context.res = {
                status: 200,
                body: `No deployment needed for ${branch} branch.`
            };
        }
    } catch (error) {
        context.log.error(`Deployment failed: ${error.message}`);
        context.res = {
            status: 500,
            body: `Deployment failed: ${error.message}`
        };
    } finally {
        // Clean up temporary files
        try {
            tmpDir.removeCallback();
            context.log('Temporary files cleaned up');
        } catch (cleanupError) {
            context.log.error(`Error cleaning up temporary files: ${cleanupError.message}`);
        }
    }
};

// Function to create a deployment package from GitHub
async function createDeploymentPackage(branch, tempDir, context) {
    // We'll use GitHub API to get the repo archive
    const repoOwner = 'TRENT-CONCORD';
    const repoName = 'concord-native';
    const githubToken = process.env.GITHUB_TOKEN;
    
    context.log(`Creating deployment package for branch: ${branch}`);
    
    try {
        // 1. Download the repository archive
        const zipUrl = `https://github.com/${repoOwner}/${repoName}/archive/refs/heads/${branch}.zip`;
        const zipFilePath = path.join(tempDir, 'repo.zip');
        
        context.log(`Downloading repository from ${zipUrl}`);
        const response = await axios({
            method: 'get',
            url: zipUrl,
            responseType: 'arraybuffer',
            headers: githubToken ? { 'Authorization': `token ${githubToken}` } : {}
        });
        
        // Save the downloaded zip
        await fs.writeFile(zipFilePath, response.data);
        context.log(`Repository download complete: ${zipFilePath}`);
        
        // 2. Extract the archive
        const extractPath = path.join(tempDir, 'extracted');
        await fs.ensureDir(extractPath);
        
        const zip = new AdmZip(zipFilePath);
        zip.extractAllTo(extractPath, true);
        context.log(`Repository extracted to: ${extractPath}`);
        
        // 3. Find the backend directory
        const extractedDirs = await fs.readdir(extractPath);
        const repoDir = path.join(extractPath, extractedDirs[0]); // The repo is usually in a single subdirectory
        const backendDir = path.join(repoDir, 'backend');
        
        context.log(`Looking for backend directory at: ${backendDir}`);
        if (!await fs.pathExists(backendDir)) {
            throw new Error(`Backend directory not found at ${backendDir}`);
        }
        
        // 4. Create a new ZIP with just the backend directory
        const deployZipPath = path.join(tempDir, 'backend-deploy.zip');
        const deployZip = new AdmZip();
        
        // Add all files from the backend directory to the ZIP
        const backendFiles = await fs.readdir(backendDir);
        for (const file of backendFiles) {
            const filePath = path.join(backendDir, file);
            const stats = await fs.stat(filePath);
            
            if (stats.isDirectory()) {
                // Add directory recursively
                deployZip.addLocalFolder(filePath, file);
            } else {
                // Add file
                deployZip.addLocalFile(filePath, ''); // Add to root of ZIP
            }
        }
        
        // Write the deployment ZIP
        deployZip.writeZip(deployZipPath);
        context.log(`Created deployment package: ${deployZipPath}`);
        
        return deployZipPath;
    } catch (error) {
        context.log.error(`Error creating deployment package: ${error.message}`);
        throw new Error(`Failed to create deployment package: ${error.message}`);
    }
}

// Function to deploy to Azure Web App with NO BUILD
async function deployToAzureWebApp(resourceGroup, webAppName, zipPath, subscriptionId, environment, context) {
    context.log(`Deploying to ${webAppName} in ${resourceGroup} (subscription: ${subscriptionId}, environment: ${environment})`);
    
    if (!subscriptionId && environment === 'production') {
        throw new Error('Production subscription ID is not configured. Please set MAIN_SUBSCRIPTION_ID in the function app settings.');
    }
    
    try {
        // Use Kudu REST API for deployment with better control
        const kuduUrl = `https://${webAppName}.scm.azurewebsites.net/api/zipdeploy`;
        
        // Get publishing credentials based on environment
        let publishingUser, publishingPassword;
        
        if (environment === 'production') {
            // Use production-specific credentials
            publishingUser = process.env.PROD_PUBLISHING_USER || `$${webAppName}`;
            publishingPassword = process.env.PROD_PUBLISHING_PASSWORD;
            
            if (!publishingPassword) {
                context.log.error('Production publishing password is not configured. Please set PROD_PUBLISHING_PASSWORD in the function app settings.');
                throw new Error('Production publishing credentials not configured');
            }
        } else {
            // Use development credentials
            publishingUser = process.env.DEV_PUBLISHING_USER || process.env.PUBLISHING_USER || `$${webAppName}`;
            publishingPassword = process.env.DEV_PUBLISHING_PASSWORD || process.env.PUBLISHING_PASSWORD;
            
            if (!publishingPassword) {
                // Try to get credentials from a secure source
                const credentials = await getPublishingCredentials(webAppName, resourceGroup, subscriptionId, environment, context);
                publishingPassword = credentials.publishingPassword;
            }
        }
        
        // Create auth header for Basic Auth
        const auth = Buffer.from(`${publishingUser}:${publishingPassword}`).toString('base64');
        
        // Read the ZIP file
        const zipFileContent = await fs.readFile(zipPath);
        
        // Add specific headers to bypass Oryx
        const deploymentHeaders = {
            'Authorization': `Basic ${auth}`,
            'Content-Type': 'application/zip',
            // Critical headers to bypass Oryx
            'WEBSITE_RUN_FROM_PACKAGE': '0',
            'SCM_DO_BUILD_DURING_DEPLOYMENT': 'false',
            'SCM_SKIP_ORYX_BUILD': 'true'
        };
        
        context.log(`Deploying to Kudu at ${kuduUrl} with SCM_DO_BUILD_DURING_DEPLOYMENT=false`);
        
        // Actually deploy the ZIP file to Kudu
        const deployResponse = await axios.post(kuduUrl, zipFileContent, { 
            headers: deploymentHeaders,
            maxContentLength: Infinity, // Allow large uploads
            maxBodyLength: Infinity
        });
        
        context.log(`Deployment response: ${JSON.stringify(deployResponse.data)}`);
        return deployResponse.data;
    } catch (error) {
        context.log.error(`Deployment error: ${error.message}`);
        if (error.response) {
            context.log.error(`Response status: ${error.response.status}`);
            context.log.error(`Response data: ${JSON.stringify(error.response.data)}`);
        }
        throw new Error(`Deployment to ${webAppName} failed: ${error.message}`);
    }
}

// Helper function to get publishing credentials for an App Service
async function getPublishingCredentials(webAppName, resourceGroup, subscriptionId, environment, context) {
    try {
        // Note: This approach requires the Azure Function to have an MSI (Managed Service Identity)
        // with appropriate permissions to read the publishing credentials
        
        context.log(`Getting publishing credentials for ${webAppName} (${environment})`);
        
        // For testing purposes, we'll use environment-specific fallback passwords
        if (environment === 'production') {
            return {
                publishingUser: `$${webAppName}`,
                publishingPassword: process.env.DEFAULT_PROD_PASSWORD || process.env.DEFAULT_PUBLISHING_PASSWORD || 'dummy-prod-password'
            };
        } else {
            return {
                publishingUser: `$${webAppName}`,
                publishingPassword: process.env.DEFAULT_DEV_PASSWORD || process.env.DEFAULT_PUBLISHING_PASSWORD || 'dummy-dev-password'
            };
        }
    } catch (error) {
        context.log.error(`Failed to get publishing credentials: ${error.message}`);
        throw error;
    }
}

// Helper function to get subscription ID based on resource group
function getSubscriptionId(resourceGroup) {
    // This would be better stored as environment variables
    if (resourceGroup === 'concord-dev') {
        return process.env.SANDBOX_SUBSCRIPTION_ID || 'ff42a815-661f-4e1f-867b-6a99ca790307'; // Sandbox subscription
    } else {
        return process.env.MAIN_SUBSCRIPTION_ID || 'unknown'; // Main subscription
    }
} 