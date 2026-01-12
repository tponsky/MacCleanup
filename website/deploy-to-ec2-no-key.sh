#!/bin/bash
# Deploy MacCleanup website to EC2 server (without .pem file)
# Uses SSH keys if available

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== MacCleanup Website Deployment (SSH Keys) ===${NC}\n"

# Configuration
EC2_IP="3.14.156.143"
EC2_USER="ec2-user"
WEB_ROOT="/var/www/maccleanup"

# Check if we can SSH without password
echo -e "${YELLOW}Checking SSH connection...${NC}"
if ssh -o BatchMode=yes -o ConnectTimeout=5 ec2-user@3.14.156.143 "echo 'SSH OK'" 2>/dev/null; then
    echo -e "${GREEN}✓ SSH connection works without password${NC}\n"
    USE_KEY_FILE=""
else
    echo -e "${RED}SSH connection failed. You may need to set up SSH keys or provide a .pem file.${NC}"
    exit 1
fi

# Check if DMG file exists
DMG_FILE="MacCleanup-1.0.dmg"
if [ ! -f "$DMG_FILE" ]; then
    echo -e "${YELLOW}Warning: DMG file not found at $DMG_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}Deploying to EC2 server...${NC}\n"

# Create web directory on EC2
echo -e "${GREEN}Creating web directory...${NC}"
ssh ec2-user@3.14.156.143 << 'ENDSSH'
sudo mkdir -p /var/www/maccleanup
sudo chown ec2-user:ec2-user /var/www/maccleanup
ENDSSH

# Copy files to EC2
echo -e "${GREEN}Copying files to EC2...${NC}"
scp index.html ec2-user@3.14.156.143:/tmp/maccleanup-index.html
scp MacCleanup-1.0.dmg ec2-user@3.14.156.143:/tmp/MacCleanup-1.0.dmg

# Set up website on EC2
echo -e "${GREEN}Setting up website on EC2...${NC}"
ssh ec2-user@3.14.156.143 << 'ENDSSH'
# Move files to web root
sudo mv /tmp/maccleanup-index.html /var/www/maccleanup/index.html
sudo mv /tmp/MacCleanup-1.0.dmg /var/www/maccleanup/MacCleanup-1.0.dmg

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
echo "2. Visit your website: http://maccleanup.toddponskymd.com"
echo "   Or via IP: http://$EC2_IP/maccleanup"
echo ""
