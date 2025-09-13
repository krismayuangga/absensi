#!/bin/bash

# Laravel Production Deployment Script for Domainesia
# This script helps deploy your Laravel application to Domainesia hosting

echo "=== LARAVEL PRODUCTION DEPLOYMENT ==="
echo

# Set permissions for storage and cache directories
echo "Setting correct permissions..."
find storage -type f -exec chmod 644 {} \;
find storage -type d -exec chmod 755 {} \;
find bootstrap/cache -type f -exec chmod 644 {} \;
find bootstrap/cache -type d -exec chmod 755 {} \;

# Create .htaccess for security if not exists
if [ ! -f "public/.htaccess" ]; then
    echo "Creating security .htaccess..."
    cat > public/.htaccess << 'EOF'
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
EOF
fi

# Generate application key if not set
if grep -q "APP_KEY=$" .env; then
    echo "Generating application key..."
    php artisan key:generate --force
fi

# Generate JWT secret if not set
if grep -q "JWT_SECRET=$" .env; then
    echo "Generating JWT secret..."
    php artisan jwt:secret --force
fi

# Clear and optimize caches
echo "Clearing caches..."
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

echo "Optimizing for production..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations (in production, be careful with this)
echo "Running database migrations..."
php artisan migrate --force

# Seed database with essential data
echo "Seeding database..."
php artisan db:seed --class=RoleSeeder --force
php artisan db:seed --class=CompanySeeder --force

# Create symbolic link for storage (if not exists)
if [ ! -L "public/storage" ]; then
    echo "Creating storage symbolic link..."
    php artisan storage:link
fi

echo
echo "=== DEPLOYMENT COMPLETE ==="
echo "Your Laravel application is ready for production!"
echo
echo "Next steps:"
echo "1. Upload all files to your Domainesia hosting public_html folder"
echo "2. Update your .env file with production database credentials"
echo "3. Point your domain to the 'public' folder"
echo "4. Test the application"
echo
echo "Important: Make sure to:"
echo "- Keep your .env file secure and never commit it to version control"
echo "- Regularly backup your database"
echo "- Monitor your application logs in storage/logs/"