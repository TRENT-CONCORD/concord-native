# Get the current branch
$branch = git rev-parse --abbrev-ref HEAD

# Deploy based on branch
if ($branch -eq "sandbox") {
    Write-Host "Deploying to development environment (concord-api-dev)..."
    git push azure-dev HEAD:master -f
}
elseif ($branch -eq "main") {
    Write-Host "Deploying to production environment (concord-api)..."
    git push azure-prod HEAD:master -f
}
else {
    Write-Host "Not on a deployable branch. No deployment triggered."
    Write-Host "Please checkout either 'sandbox' or 'main' branch to deploy."
} 