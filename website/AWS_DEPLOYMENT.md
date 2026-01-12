# MacCleanup Website - AWS EC2 Deployment

This guide explains how to deploy the MacCleanup download website to your AWS EC2 server with Route53.

## Prerequisites

- AWS EC2 instance running (IP: 3.14.156.143)
- EC2 key file (.pem)
- Route53 hosted zone for toddponskymd.com
- SSH access to EC2 instance

## Quick Deployment

### Option 1: Automated Script (Recommended)

1. **Navigate to website directory:**
   ```bash
   cd ~/CursorProjects/MacCleanup/website
   ```

2. **Make sure DMG is in parent directory:**
   ```bash
   ls ../MacCleanup-1.0.dmg
   ```

3. **Run deployment script:**
   ```bash
   ./deploy-to-ec2.sh
   ```

   The script will:
   - Find your EC2 key file
   - Copy website files to EC2
   - Copy DMG file to EC2
   - Set up nginx web server
   - Configure nginx for the website

4. **Set up DNS (see below)**

---

### Option 2: Manual Deployment

#### Step 1: Copy Files to EC2

```bash
# Find your key file
KEY_FILE="~/Desktop/AWS/EmpowerAI.pem"  # Adjust path as needed

# Copy website files
scp -i "$KEY_FILE" index.html ec2-user@3.14.156.143:/tmp/
scp -i "$KEY_FILE" ../MacCleanup-1.0.dmg ec2-user@3.14.156.143:/tmp/
```

#### Step 2: SSH into EC2

```bash
ssh -i "$KEY_FILE" ec2-user@3.14.156.143
```

#### Step 3: Set Up Website Directory

```bash
# Create web directory
sudo mkdir -p /var/www/maccleanup
sudo chown ec2-user:ec2-user /var/www/maccleanup

# Move files
sudo mv /tmp/index.html /var/www/maccleanup/
sudo mv /tmp/MacCleanup-1.0.dmg /var/www/maccleanup/

# Set permissions
sudo chmod -R 755 /var/www/maccleanup
```

#### Step 4: Install and Configure Nginx

```bash
# Install nginx (if not installed)
sudo yum update -y
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Create nginx config
sudo nano /etc/nginx/conf.d/maccleanup.conf
```

Add this configuration:

```nginx
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
```

Save and exit (Ctrl+X, Y, Enter).

#### Step 5: Test and Reload Nginx

```bash
# Test configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

---

## DNS Setup with Route53

### Option 1: Subdomain (Recommended)

Create a subdomain: `maccleanup.toddponskymd.com`

1. **Using AWS CLI:**
   ```bash
   # Get hosted zone ID
   aws route53 list-hosted-zones --query "HostedZones[?Name=='toddponskymd.com.']" --output json

   # Create A record (replace ZONE_ID with your hosted zone ID)
   aws route53 change-resource-record-sets \
     --hosted-zone-id ZONE_ID \
     --change-batch '{
       "Changes": [{
         "Action": "CREATE",
         "ResourceRecordSet": {
           "Name": "maccleanup.toddponskymd.com",
           "Type": "A",
           "TTL": 300,
           "ResourceRecords": [{"Value": "3.14.156.143"}]
         }
       }]
     }'
   ```

2. **Using AWS Console:**
   - Go to: https://console.aws.amazon.com/route53/
   - Click on hosted zone: `toddponskymd.com`
   - Click "Create record"
   - Name: `maccleanup`
   - Type: `A`
   - Value: `3.14.156.143`
   - TTL: `300` (or default)
   - Click "Create records"

### Option 2: Path on Main Domain

If you want to use `toddponskymd.com/maccleanup` instead:

1. Update nginx config on EC2:
   ```bash
   sudo nano /etc/nginx/conf.d/maccleanup.conf
   ```

   Change to:
   ```nginx
   location /maccleanup {
       alias /var/www/maccleanup;
       index index.html;
       
       location ~* \.(dmg)$ {
           add_header Content-Disposition 'attachment';
       }
   }
   ```

2. Reload nginx:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

---

## SSL/HTTPS Setup (Optional but Recommended)

### Using Let's Encrypt (Free SSL)

```bash
# SSH into EC2
ssh -i "$KEY_FILE" ec2-user@3.14.156.143

# Install certbot
sudo yum install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d maccleanup.toddponskymd.com

# Follow prompts (enter email, agree to terms)
# Certbot will automatically update nginx config
```

---

## Verify Deployment

1. **Check website is accessible:**
   ```bash
   curl http://maccleanup.toddponskymd.com
   # Or visit in browser: http://maccleanup.toddponskymd.com
   ```

2. **Check DMG download:**
   ```bash
   curl -I http://maccleanup.toddponskymd.com/MacCleanup-1.0.dmg
   # Should see Content-Type: application/octet-stream
   ```

3. **Check DNS:**
   ```bash
   nslookup maccleanup.toddponskymd.com
   # Should return: 3.14.156.143
   ```

---

## Updating the Website

When you update the DMG file:

1. **Generate new DMG:**
   ```bash
   cd ~/CursorProjects/MacCleanup
   ./create_dmg.sh
   ```

2. **Deploy updated files:**
   ```bash
   cd website
   ./deploy-to-ec2.sh
   ```

Or manually:
```bash
scp -i "$KEY_FILE" ../MacCleanup-1.0.dmg ec2-user@3.14.156.143:/tmp/
ssh -i "$KEY_FILE" ec2-user@3.14.156.143 "sudo mv /tmp/MacCleanup-1.0.dmg /var/www/maccleanup/ && sudo chmod 644 /var/www/maccleanup/MacCleanup-1.0.dmg"
```

---

## Troubleshooting

### "Permission denied" error
```bash
chmod 400 /path/to/your/key.pem
```

### "Connection timeout"
- Check EC2 instance is running
- Check Security Group allows SSH (port 22) and HTTP (port 80)
- Verify IP address: 3.14.156.143

### Nginx not starting
```bash
sudo nginx -t  # Check for syntax errors
sudo systemctl status nginx  # Check status
sudo journalctl -u nginx  # Check logs
```

### Website not accessible
- Check nginx is running: `sudo systemctl status nginx`
- Check firewall: `sudo systemctl status firewalld`
- Check DNS propagation (can take a few minutes)
- Try accessing via IP: `http://3.14.156.143` (if nginx default config allows)

### DMG download not working
- Check file exists: `ls -lh /var/www/maccleanup/MacCleanup-1.0.dmg`
- Check permissions: `sudo chmod 644 /var/www/maccleanup/MacCleanup-1.0.dmg`
- Check nginx config has DMG location block

---

## Configuration Reference

**EC2 Details:**
- IP: 3.14.156.143
- User: ec2-user
- Web Root: /var/www/maccleanup

**Recommended Domain:**
- maccleanup.toddponskymd.com

**Files:**
- Website: /var/www/maccleanup/index.html
- DMG: /var/www/maccleanup/MacCleanup-1.0.dmg
- Nginx Config: /etc/nginx/conf.d/maccleanup.conf

---

**Need Help?** Check your EC2 deployment scripts in `toddponskymd.com` folder for reference patterns.
