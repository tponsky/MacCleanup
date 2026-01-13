# Route53 Domain Setup: computercleanup.staycurrentai.com

## Overview

This guide will help you set up the Route53 domain `computercleanup.staycurrentai.com` to point to your MacCleanup website.

## Prerequisites

- AWS Account with Route53 access
- Hosted zone for `staycurrentai.com` already exists

## Steps

### 1. Create Route53 A Record

1. Go to AWS Route53 Console: https://console.aws.amazon.com/route53/

2. Click "Hosted zones" in the left menu

3. Select the hosted zone for: `staycurrentai.com`

4. Click "Create record" button

5. Fill in the record details:
   - **Record name**: `computercleanup`
   - **Record type**: `A`
   - **Value**: `3.14.156.143`
   - **TTL**: `300` (or use default)
   - **Routing policy**: `Simple routing`

6. Click "Create record"

### 2. Wait for DNS Propagation

- DNS changes typically take 2-5 minutes to propagate
- You can check DNS propagation using: https://www.whatsmydns.net/

### 3. Verify Apache Configuration

The Apache configuration has been updated to handle `computercleanup.staycurrentai.com`.

You can verify it's working:
```bash
ssh ec2-user@3.14.156.143 "sudo apachectl -S | grep computercleanup"
```

### 4. Test the Domain

Once DNS has propagated, visit:
- **HTTP**: http://computercleanup.staycurrentai.com/maccleanup
- **Direct IP** (for testing): http://3.14.156.143/maccleanup

## Current Configuration

- **Server IP**: 3.14.156.143
- **Apache Virtual Host**: Already configured to serve `/maccleanup`
- **Domain**: computercleanup.staycurrentai.com → 3.14.156.143

## Notes

- The domain points to the same server and location as the IP-based access
- Both `computercleanup.staycurrentai.com/maccleanup` and `3.14.156.143/maccleanup` will work
- The Apache configuration has been updated to accept the new domain name

## Troubleshooting

If the domain doesn't work after DNS propagation:

1. Check DNS resolution:
   ```bash
   dig computercleanup.staycurrentai.com
   # Should return: 3.14.156.143
   ```

2. Check Apache virtual host:
   ```bash
   ssh ec2-user@3.14.156.143 "sudo apachectl -S | grep computercleanup"
   ```

3. Check Apache error logs:
   ```bash
   ssh ec2-user@3.14.156.143 "sudo tail -20 /var/log/httpd/toddponskymd.com_error.log"
   ```

4. Restart Apache if needed:
   ```bash
   ssh ec2-user@3.14.156.143 "sudo systemctl restart httpd"
   ```
