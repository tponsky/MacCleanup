#!/bin/bash
echo "🔍 Verifying computercleanup.staycurrentai.com setup..."
echo ""

echo "1. DNS Resolution (Route53):"
dig computercleanup.staycurrentai.com +short
if [ -z "$(dig computercleanup.staycurrentai.com +short)" ]; then
    echo "   ❌ DNS record NOT found - Route53 A record needs to be created!"
else
    echo "   ✅ DNS record exists"
fi
echo ""

echo "2. Apache Config Check:"
ssh ec2-user@3.14.156.143 "sudo apachectl -S 2>&1 | grep -A 3 computercleanup || echo '   ❌ Not found in Apache virtual hosts'"
echo ""

echo "3. Test with Host Header (bypass DNS):"
curl -I -H "Host: computercleanup.staycurrentai.com" http://3.14.156.143/ 2>&1 | head -5
echo ""

echo "4. Apache Config File:"
ssh ec2-user@3.14.156.143 "if [ -f /etc/httpd/conf.d/computercleanup.conf ]; then echo '   ✅ Config file exists'; else echo '   ❌ Config file NOT found'; fi"
