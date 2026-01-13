#!/bin/bash
echo "🔍 Checking computercleanup.staycurrentai.com..."
echo ""

echo "1. DNS Resolution:"
dig computercleanup.staycurrentai.com +short
echo ""

echo "2. Apache Virtual Host:"
ssh ec2-user@3.14.156.143 "sudo apachectl -S 2>&1 | grep -i computercleanup || echo 'Not found in virtual hosts'"
echo ""

echo "3. Test HTTP Access:"
curl -I http://computercleanup.staycurrentai.com/maccleanup 2>&1 | head -5
echo ""

echo "4. Apache Config Check:"
ssh ec2-user@3.14.156.143 "sudo grep -i computercleanup /etc/httpd/conf.d/toddponskymd.com.conf || echo 'Not found in config'"
