#!/bin/bash
# Deploy MacCleanup website to EC2 server
# Based on toddponskymd.com deployment pattern

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== MacCleanup Website Deployment ===${NC}\n"

# Configuration
EC2_IP="3.14.156.143"
EC2_USER="ec2-user"
DOMAIN="maccleanup.toddponskymd.com"  # Or use a subdomain
WEB_ROOT="/var/www/maccleanup"
APP_NAME="maccleanup"

# Find key file
KEY_FILE=""
if [ -f ~/Desktop/AWS/EmpowerAI.pem ]; then
    KEY_FILE=~/Desktop/AWS/EmpowerAI.pem
elif [ -f ~/Desktop/Cursor\ Projects/AWS/EmpowerAI.pem ]; then
    KEY_FILE=~/Desktop/Cursor\ Projects/AWS/EmpowerAI.pem
else
    echo -e "${YELLOW}Looking for EC2 key file...${NC}"
    KEY_FILE=$(find ~/Desktop ~/Downloads -name "*.pem" -type f 2>/dev/null | head -1)
fi

if [ -z "$KEY_FILE" ] || [ ! -f "$KEY_FILE" ]; then
    echo -e "${RED}Error: EC2 key file (.pem) not found${NC}"
    echo "Please provide the path to your EC2 key file:"
    read -p "Key file path: " KEY_FILE
    if [ ! -f "$KEY_FILE" ]; then
        echo -e "${RED}Error: Key file not found: $KEY_FILE${NC}"
        exit 1
    fi
fi

# Set correct permissions on key file
chmod 400 "$KEY_FILE" 2>/dev/null || true

echo -e "${GREEN}Using key file: $KEY_FILE${NC}\n"

# Check if DMG file exists
DMG_FILE="../MacCleanup-1.0.dmg"
if [ ! -f "$DMG_FILE" ]; then
    echo -e "${YELLOW}Warning: DMG file not found at $DMG_FILE${NC}"
    echo "Please make sure MacCleanup-1.0.dmg exists in the parent directory"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${YELLOW}Deploying to EC2 server...${NC}\n"

# Create web directory on EC2
echo -e "${GREEN}Creating web directory...${NC}"
ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" << 'ENDSSH'
sudo mkdir -p /var/www/maccleanup
sudo chown ec2-user:ec2-user /var/www/maccleanup
ENDSSH

# Copy files to EC2
echo -e "${GREEN}Copying files to EC2...${NC}"
scp -i "$KEY_FILE" index.html "$EC2_USER@$EC2_IP:/tmp/maccleanup-index.html"

if [ -f "$DMG_FILE" ]; then
    echo -e "${GREEN}Copying DMG file (this may take a moment)...${NC}"
    scp -i "$KEY_FILE" "$DMG_FILE" "$EC2_USER@$EC2_IP:/tmp/MacCleanup-1.0.dmg"
fi

# Set up website on EC2
echo -e "${GREEN}Setting up website on EC2...${NC}"
ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" << 'ENDSSH'
# Move files to web root
sudo mv /tmp/maccleanup-index.html /var/www/maccleanup/index.html

if [ -f /tmp/MacCleanup-1.0.dmg ]; then
    sudo mv /tmp/MacCleanup-1.0.dmg /var/www/maccleanup/MacCleanup-1.0.dmg
fi

# Set permissions
sudo chown -R ec2-user:ec2-user /var/www/maccleanup
sudo chmod -R 755 /var/www/maccleanup

# Check if nginx is installed
if ! command -v nginx &> /dev/null; then
    echo "Installing nginx..."
    sudo yum update -y
    sudo yum install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
fi

# Create nginx config
sudo tee /etc/nginx/conf.d/maccleanup.conf > /dev/null << 'NGINXCONF'
server {
    listen 80;
    server_name maccleanup.toddponskymd.com;
    
    root /var/www/maccleanup;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # Enable download of DMG files
    location ~* \.(dmg)$ {
        add_header Content-Disposition 'attachment';
        add_header Content-Type application/octet-stream;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
NGINXCONF

# Test nginx config
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx

echo "Website deployed successfully!"
ENDSSH

echo -e "\n${GREEN}✅ Deployment complete!${NC}\n"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Set up DNS in Route53:"
echo "   - Create A record: maccleanup.toddponskymd.com → $EC2_IP"
echo ""
echo "2. Or access via IP: http://$EC2_IP/maccleanup (if using default nginx setup)"
echo ""
echo "3. Visit your website: http://maccleanup.toddponskymd.com"
echo ""
