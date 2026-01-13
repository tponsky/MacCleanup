#!/bin/bash
# Configure Apache for computercleanup.staycurrentai.com

echo "🔧 Configuring Apache for computercleanup.staycurrentai.com..."

# Update toddponskymd.com.conf to add computercleanup subdomain
ssh ec2-user@3.14.156.143 << 'ENDSSH'
# Backup current config
sudo cp /etc/httpd/conf.d/toddponskymd.com.conf /etc/httpd/conf.d/toddponskymd.com.conf.backup

# Read current config
sudo cat /etc/httpd/conf.d/toddponskymd.com.conf > /tmp/todd_config.txt

# Check if computercleanup is already in ServerAlias
if grep -q "computercleanup.staycurrentai.com" /tmp/todd_config.txt; then
    echo "✅ computercleanup.staycurrentai.com already configured"
else
    # Add computercleanup to ServerAlias (will need to update the config file)
    echo "Adding computercleanup.staycurrentai.com to ServerAlias..."
    
    # Create updated config
    sudo tee /etc/httpd/conf.d/toddponskymd.com.conf > /dev/null << 'APACHECONF'
# Apache Virtual Host Configuration for toddponskymd.com
<VirtualHost *:80>
    ServerName toddponskymd.com
    ServerAlias www.toddponskymd.com
    ServerAlias 3.14.156.143
    ServerAlias computercleanup.staycurrentai.com
    
    # Serve /maccleanup from filesystem (BEFORE proxying)
    ProxyPass /maccleanup !
    Alias /maccleanup /var/www/maccleanup
    <Directory /var/www/maccleanup>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    
    # Serve /uploads directly from filesystem (before proxying)
    Alias /uploads /var/www/toddponskymd.com/public/uploads
    <Directory "/var/www/toddponskymd.com/public/uploads">
        Options -Indexes
        AllowOverride None
        Require all granted
    </Directory>
    
    # Proxy all other requests to Next.js
    ProxyPreserveHost On
    ProxyPass /uploads !
    ProxyPass / http://localhost:3003/
    ProxyPassReverse / http://localhost:3003/
    
    # Security headers (allow SAMEORIGIN for /tap route for preview)
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    
    # Logging
    ErrorLog /var/log/httpd/toddponskymd.com_error.log
    CustomLog /var/log/httpd/toddponskymd.com_access.log combined
</VirtualHost>
APACHECONF
fi

# Test Apache config
sudo apachectl configtest

# Restart Apache
sudo systemctl restart httpd

echo "✅ Apache configured for computercleanup.staycurrentai.com"
ENDSSH

echo ""
echo "✅ Configuration complete!"
echo ""
echo "Next steps:"
echo "1. Create Route53 A record: computercleanup.staycurrentai.com → 3.14.156.143"
echo "2. Wait 2-5 minutes for DNS to propagate"
echo "3. Visit: http://computercleanup.staycurrentai.com/maccleanup"
