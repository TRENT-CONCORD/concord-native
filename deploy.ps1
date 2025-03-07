# Get the current branch
$branch = git rev-parse --abbrev-ref HEAD

# Create deployment package
Write-Host "Creating deployment package..."
if (!(Test-Path -Path backend)) {
    Write-Host "Backend directory not found. Make sure you're running this from the repository root."
    exit 1
}

# Navigate to backend directory and create deployment package
Push-Location backend
Compress-Archive -Path *.js, *.json, web.config, .deployment, .env -DestinationPath backend-deploy.zip -Force
$zipPath = Resolve-Path backend-deploy.zip
Pop-Location
 
# Deploy based on branch
if ($branch -eq "sandbox") {
    Write-Host "Deploying to development environment (concord-api-dev)..."
    az account set --subscription "Microsoft Azure Sponsorship (sandbox)"
    az webapp deploy --resource-group concord-dev --name concord-api-dev --src-path $zipPath
    
    # Verify deployment
    $apiUrl = "https://api-dev.concord.digital/"
    Write-Host "Verifying deployment at $apiUrl..."
    Start-Sleep -Seconds 5  # Give it a moment to initialize
    Invoke-RestMethod -Uri $apiUrl
}
elseif ($branch -eq "main") {
    Write-Host "Deploying to production environment (concord-api)..."
    az account set --subscription "Microsoft Azure Sponsorship (main)"
    az webapp deploy --resource-group concord-prod --name concord-api --src-path $zipPath
    
    # Verify deployment
    $apiUrl = "https://api.concord.digital/"
    Write-Host "Verifying deployment at $apiUrl..."
    Start-Sleep -Seconds 5  # Give it a moment to initialize
    Invoke-RestMethod -Uri $apiUrl
}
else {
    Write-Host "Not on a deployable branch. No deployment triggered."
    Write-Host "Please checkout either 'sandbox' or 'main' branch to deploy."
} 