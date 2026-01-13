#!/bin/bash
# Fix Apache to serve MacCleanup at root of computercleanup.staycurrentai.com

echo "🔧 Configuring computercleanup.staycurrentai.com to serve at root..."

ssh ec2-user@3.14.156.143 << 'ENDSSH'
# Create separate virtual host for computercleanup.staycurrentai.com
sudo tee /etc/httpd/conf.d/computercleanup.conf > /dev/null << 'APACHECONF'
<VirtualHost *:80>
    ServerName computercleanup.staycurrentai.com
    
    DocumentRoot /var/www/maccleanup
    DirectoryIndex index.html
    
    <Directory /var/www/maccleanup>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    
    # Enable download of DMG files
    <FilesMatch "\.(dmg)$">
        Header set Content-Disposition "attachment"
        Header set Content-Type "application/octet-stream"
    </FilesMatch>
    
    # Logging
    ErrorLog /var/log/httpd/computercleanup_error.log
    CustomLog /var/log/httpd/computercleanup_access.log combined
</VirtualHost>
APACHECONF

# Test Apache config
sudo apachectl configtest

# Restart Apache
sudo systemctl restart httpd

echo "✅ Apache configured for computercleanup.staycurrentai.com at root"
ENDSSH

echo ""
echo "✅ Configuration complete!"
echo ""
echo "Now computercleanup.staycurrentai.com will serve the website at root!"
echo "Visit: http://computercleanup.staycurrentai.com"
