# Laravel Production Deployment Script for Windows/Domainesia
# This PowerShell script helps prepare your Laravel application for Domainesia hosting

Write-Host "=== LARAVEL PRODUCTION DEPLOYMENT ===" -ForegroundColor Green
Write-Host

# Navigate to backend directory
$backendPath = ".\backend"
if (Test-Path $backendPath) {
    Set-Location $backendPath
} else {
    Write-Host "Backend directory not found!" -ForegroundColor Red
    exit 1
}

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "Copying .env.example to .env..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
}

# Install dependencies
Write-Host "Installing Composer dependencies..." -ForegroundColor Cyan
composer install --optimize-autoloader --no-dev

# Generate application key if not set
$envContent = Get-Content ".env" -Raw
if ($envContent -match "APP_KEY=$") {
    Write-Host "Generating application key..." -ForegroundColor Cyan
    php artisan key:generate --force
}

# Generate JWT secret if not set
if ($envContent -match "JWT_SECRET=$") {
    Write-Host "Generating JWT secret..." -ForegroundColor Cyan
    php artisan jwt:secret --force
}

# Clear and optimize caches
Write-Host "Clearing caches..." -ForegroundColor Cyan
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

Write-Host "Optimizing for production..." -ForegroundColor Cyan
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set proper permissions (Windows-style)
Write-Host "Setting file permissions..." -ForegroundColor Cyan
if (Test-Path "storage") {
    icacls "storage" /grant "Everyone:(OI)(CI)F" /T
}
if (Test-Path "bootstrap\cache") {
    icacls "bootstrap\cache" /grant "Everyone:(OI)(CI)F" /T
}

# Create deployment package
Write-Host "Creating deployment package..." -ForegroundColor Cyan
$deploymentPath = "..\deployment\backend_production"
if (Test-Path $deploymentPath) {
    Remove-Item $deploymentPath -Recurse -Force
}
New-Item -ItemType Directory -Path $deploymentPath -Force

# Copy necessary files and folders
$itemsToCopy = @(
    "app",
    "bootstrap",
    "config", 
    "database",
    "public",
    "resources",
    "routes",
    "storage",
    "vendor",
    "artisan",
    "composer.json",
    "composer.lock"
)

foreach ($item in $itemsToCopy) {
    if (Test-Path $item) {
        Write-Host "Copying $item..." -ForegroundColor Yellow
        if ((Get-Item $item) -is [System.IO.DirectoryInfo]) {
            robocopy $item "$deploymentPath\$item" /E /XD node_modules .git /NFL /NDL /NJH /NJS
        } else {
            Copy-Item $item "$deploymentPath\$item"
        }
    }
}

# Copy production .env template
Copy-Item "..\deployment\.env.production" "$deploymentPath\.env"

# Create .htaccess for security
$htaccessContent = @'
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
'@

$htaccessPath = "$deploymentPath\public\.htaccess"
if (-not (Test-Path $htaccessPath)) {
    Write-Host "Creating .htaccess file..." -ForegroundColor Yellow
    Set-Content -Path $htaccessPath -Value $htaccessContent
}

# Create deployment instructions
$instructions = @"
DOMAINESIA HOSTING DEPLOYMENT INSTRUCTIONS
==========================================

1. UPLOAD FILES:
   - Upload the contents of 'backend_production' folder to your public_html directory
   - Make sure the 'public' folder content goes to public_html root
   - Other Laravel files (app, config, etc.) should be in public_html

2. DATABASE SETUP:
   - Create a MySQL database in cPanel
   - Note the database name, username, and password
   - Update .env file with your database credentials

3. ENVIRONMENT CONFIGURATION:
   - Edit .env file with your production settings:
     * APP_URL=https://yourdomain.com
     * DB_DATABASE=your_database_name
     * DB_USERNAME=your_db_username
     * DB_PASSWORD=your_db_password
   
4. FINAL STEPS:
   - Run: php artisan migrate --force (via terminal if available)
   - Run: php artisan db:seed --force
   - Test your application
   
5. IMPORTANT SECURITY:
   - Ensure APP_DEBUG=false in production
   - Keep your .env file secure
   - Regularly backup your database

Your Laravel backend is ready for Domainesia hosting!
"@

Set-Content -Path "..\deployment\DEPLOYMENT_INSTRUCTIONS.txt" -Value $instructions

Write-Host
Write-Host "=== DEPLOYMENT PREPARATION COMPLETE ===" -ForegroundColor Green
Write-Host "Backend production files created in: $deploymentPath" -ForegroundColor Cyan
Write-Host "Please read DEPLOYMENT_INSTRUCTIONS.txt for next steps" -ForegroundColor Yellow
Write-Host

# Return to original directory
Set-Location ".."