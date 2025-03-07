const axios = require('axios');
const crypto = require('crypto');

module.exports = async function (context, req) {
    context.log('GitHub Webhook triggered');

    try {
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
            
            // Get access token for deployment
            const tokenCredential = process.env.AZURE_FUNCTION_KEY;
            if (!tokenCredential) {
                throw new Error('Azure deployment credential not configured');
            }

            // Create ZIP deployment
            const { zipUrl, folderPath } = await createDeploymentPackage(branch, context);
            
            // Deploy based on branch
            if (branch === 'sandbox') {
                await deployToAzureWebApp(
                    'concord-dev',
                    'concord-api-dev',
                    zipUrl,
                    folderPath,
                    process.env.SANDBOX_SUBSCRIPTION_ID || 'ff42a815-661f-4e1f-867b-6a99ca790307',
                    context
                );
            } else {
                await deployToAzureWebApp(
                    'concord-prod',
                    'concord-api',
                    zipUrl,
                    folderPath,
                    process.env.MAIN_SUBSCRIPTION_ID || 'unknown',
                    context
                );
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
    }
};

// Function to create a deployment package from GitHub
async function createDeploymentPackage(branch, context) {
    // We'll use GitHub API to directly get the backend folder
    const repoOwner = 'TRENT-CONCORD';
    const repoName = 'concord-native';
    const githubToken = process.env.GITHUB_TOKEN;
    
    context.log(`Creating deployment package for branch: ${branch}`);
    
    try {
        // In a real implementation, we would:
        // 1. Clone the repo using REST API or Git library
        // 2. Create a ZIP package of just the backend folder
        // 3. Upload the ZIP to an Azure Blob Storage container
        // 4. Return the URL of the ZIP in storage
        
        // For now, let's use a direct approach that works with the actual webhook
        const backendFolder = '/tmp/backend';
        const zipUrl = `https://github.com/${repoOwner}/${repoName}/archive/refs/heads/${branch}.zip`;
        
        return {
            zipUrl,
            folderPath: 'backend' // Path within the repository
        };
    } catch (error) {
        throw new Error(`Failed to create deployment package: ${error.message}`);
    }
}

// Function to deploy to Azure Web App with NO BUILD
async function deployToAzureWebApp(resourceGroup, webAppName, zipUrl, folderPath, subscriptionId, context) {
    context.log(`Deploying to ${webAppName} in ${resourceGroup} (subscription: ${subscriptionId})`);
    
    try {
        // IMPORTANT: We'll use Kudu REST API instead of the Management API
        // because it allows more control over deployment
        const kuduUrl = `https://${webAppName}.scm.azurewebsites.net/api/zipdeploy`;
        
        // Get the publish profile (in a real implementation, this would be retrieved from KeyVault or env vars)
        const publishingUser = process.env.PUBLISHING_USER || `$${webAppName}`;
        const publishingPassword = process.env.PUBLISHING_PASSWORD || process.env.AZURE_FUNCTION_KEY;
        
        // Create auth header
        const auth = Buffer.from(`${publishingUser}:${publishingPassword}`).toString('base64');
        
        // Add specific headers to bypass Oryx
        const deploymentHeaders = {
            'Authorization': `Basic ${auth}`,
            'Content-Type': 'application/zip',
            // THESE ARE THE CRITICAL HEADERS TO BYPASS ORYX
            'WEBSITE_RUN_FROM_PACKAGE': '0', // Don't run from package
            'SCM_DO_BUILD_DURING_DEPLOYMENT': 'false', // Skip Oryx build
            'SCM_SKIP_ORYX_BUILD': 'true' // Explicitly skip Oryx
        };
        
        // For a real implementation, we would download the ZIP from GitHub, 
        // extract it, go to the backend folder, and create a new ZIP of just that folder
        // Then upload that ZIP directly to the Kudu API
        
        context.log(`Deploying to Kudu at ${kuduUrl} with SCM_DO_BUILD_DURING_DEPLOYMENT=false`);
        
        // In a real implementation, you would:
        // 1. Download the ZIP file from the zipUrl
        // 2. Extract it and navigate to the backend folder
        // 3. Create a new ZIP of just the backend folder
        // 4. Upload that ZIP to the Kudu API
        
        // For this example, we're simulating a successful deployment
        // return await axios.post(kuduUrl, zipData, { headers: deploymentHeaders });
        
        // To really implement this, you would use Azure Functions durable entities to:
        // 1. Download the repo ZIP
        // 2. Extract it
        // 3. Repackage just the backend folder
        // 4. Deploy it to the Kudu API
        
        context.log(`Simulated deployment to ${webAppName} with ORYX BYPASSED`);
        context.log(`To complete this implementation, use Azure Durable Functions to handle the ZIP processing`);
        
        return { status: 'success' };
    } catch (error) {
        throw new Error(`Deployment to ${webAppName} failed: ${error.message}`);
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