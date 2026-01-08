#!/bin/bash
#
# Setup LXD with NAT networking for Ignition Edge deployment
#

set -e

echo "========================================="
echo "  LXD Setup for Ignition Edge"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please run as normal user, not root${NC}"
    exit 1
fi

# Install LXD if not present
if ! command -v lxc &> /dev/null; then
    echo -e "${YELLOW}LXD not found. Installing...${NC}"
    sudo apt update
    sudo apt install -y lxd lxd-client snapd
    
    # Add user to lxd group
    sudo usermod -a -G lxd $USER
    
    echo -e "${GREEN}LXD installed${NC}"
    echo -e "${YELLOW}Please log out and log back in, then run this script again${NC}"
    exit 0
fi

# Check if user is in lxd group
if ! groups | grep -q lxd; then
    echo -e "${YELLOW}Adding user to lxd group...${NC}"
    sudo usermod -a -G lxd $USER
    echo -e "${YELLOW}Please log out and log back in, then run this script again${NC}"
    exit 0
fi

# Initialize LXD with NAT network
echo "Initializing LXD..."
echo ""
echo "Recommended configuration:"
echo "  - Storage backend: dir (simple) or zfs (better performance)"
echo "  - Network bridge: lxdbr0 with NAT"
echo "  - IPv4 address: auto (creates 10.x.x.x network)"
echo "  - IPv6:  auto or none"
echo ""

read -p "Use automatic LXD initialization? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    # Manual initialization
    sudo lxd init
else
    # Automatic initialization with NAT
    cat << 'EOF' | sudo lxd init --preseed
config:  {}
networks:
- config: 
    ipv4.address: 10.100.100.1/24
    ipv4.nat: "true"
    ipv6.address: none
  description: "NAT network for Ignition Edge"
  name: lxdbr0
  type: bridge
storage_pools:
- config:
    size: 50GB
  description: "Default storage pool"
  name: default
  driver: dir
profiles:
- config:  {}
  description: "Default LXD profile"
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
EOF
fi

echo ""
echo -e "${GREEN}LXD initialized successfully${NC}"
echo ""

# Verify network configuration
echo "Verifying network configuration..."
lxc network show lxdbr0

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  LXD Setup Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Network Details:"
lxc network list
echo ""
echo "Next steps:"
echo "  1. Run the Ignition Edge installation script"
echo "  2. Create additional containers for OPC UA, databases, etc."
echo ""