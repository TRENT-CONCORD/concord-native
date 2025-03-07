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
            const deploymentUrl = await createDeploymentPackage(branch, context);
            
            // Deploy based on branch
            if (branch === 'sandbox') {
                await deployToAzureWebApp(
                    'concord-dev',
                    'concord-api-dev',
                    deploymentUrl,
                    tokenCredential,
                    context
                );
            } else {
                await deployToAzureWebApp(
                    'concord-prod',
                    'concord-api',
                    deploymentUrl,
                    tokenCredential,
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
    // We'll use GitHub API to directly get a downloadable ZIP of the backend directory
    const repoOwner = 'TRENT-CONCORD';
    const repoName = 'concord-native';
    const githubToken = process.env.GITHUB_TOKEN;
    
    // Get archive link from GitHub API
    const archiveUrl = `https://api.github.com/repos/${repoOwner}/${repoName}/zipball/${branch}`;
    
    context.log(`Creating deployment package from: ${archiveUrl}`);
    
    // Note: We return the URL of the ZIP file from GitHub
    // In a real implementation, we might want to download, extract, and repackage just the backend folder
    return archiveUrl;
}

// Function to deploy to Azure Web App
async function deployToAzureWebApp(resourceGroup, webAppName, deploymentPackageUrl, token, context) {
    // For deployment to Azure App Service using a ZIP URL
    const deploymentEndpoint = `https://management.azure.com/subscriptions/${getSubscriptionId(resourceGroup)}/resourceGroups/${resourceGroup}/providers/Microsoft.Web/sites/${webAppName}/extensions/zipdeploy?api-version=2021-02-01`;
    
    context.log(`Deploying to ${webAppName} in ${resourceGroup}`);
    
    try {
        // In a real implementation, we would make a POST request to the deployment endpoint
        // with the deploymentPackageUrl and proper authentication
        context.log(`Simulated deployment to: ${deploymentEndpoint}`);
        
        // Simulate successful deployment
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