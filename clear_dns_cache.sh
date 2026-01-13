#!/bin/bash
echo "Clearing DNS cache..."
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
echo "✅ DNS cache cleared!"
echo ""
echo "Now try accessing: http://computercleanup.staycurrentai.com"
