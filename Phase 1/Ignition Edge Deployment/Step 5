#!/bin/bash
#
# Complete deployment script - deploys all containers
#

set -e

# Configuration
IGNITION_ZIP="${IGNITION_ZIP}"
REPO_DIR="${REPO_DIR:-/Downloads/opcua-edge-deployment/Small-Application}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Ignition Edge Complete Deployment${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Step 1: Setup LXD
echo -e "${GREEN}Step 1: Setting up LXD... ${NC}"
if [ -f "./scripts/setup_lxd.sh" ]; then
    bash ./scripts/setup_lxd. sh
else
    echo -e "${YELLOW}LXD setup script not found, assuming LXD is configured${NC}"
fi
echo ""

# Step 2: Create OPC UA Server container
echo -e "${GREEN}Step 2: Creating OPC UA Server container...${NC}"
if [ -f "./scripts/create_opcua_container.sh" ]; then
    REPO_DIR="$REPO_DIR" bash ./scripts/create_opcua_container.sh
else
    echo -e "${RED}OPC UA container creation script not found${NC}"
    exit 1
fi
echo ""

# Step 3: Create Ignition Edge container
echo -e "${GREEN}Step 3: Creating Ignition Edge container...${NC}"
if [ -z "$IGNITION_ZIP" ]; then
    echo -e "${RED}Error:  IGNITION_ZIP not set${NC}"
    echo "Please set the path to your downloaded Ignition zip file:"
    echo "  export IGNITION_ZIP=/path/to/Ignition-linux-64-8.1.44.zip"
    echo "  bash $0"
    exit 1
fi

if [ -f "./scripts/create_ignition_container.sh" ]; then
    IGNITION_ZIP="$IGNITION_ZIP" bash ./scripts/create_ignition_container.sh
else
    echo -e "${RED}Ignition container creation script not found${NC}"
    exit 1
fi
echo ""

# Step 4: Display network information
echo -e "${GREEN}Step 4: Network configuration...${NC}"
sleep 5  # Wait for containers to fully initialize

IGNITION_IP=$(lxc list ignition-edge -c 4 --format csv | cut -d' ' -f1)
OPCUA_IP=$(lxc list opcua-server -c 4 --format csv | cut -d' ' -f1)
HOST_IP=$(hostname -I | awk '{print $1}')

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Deployment Complete!${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "${GREEN}Container Status:${NC}"
lxc list
echo ""

echo -e "${GREEN}Network Information:${NC}"
echo "  Ignition Edge IP: $IGNITION_IP"
echo "  OPC UA Server IP: $OPCUA_IP"
echo "  Host IP: $HOST_IP"
echo "  Network: lxdbr0 (NAT enabled)"
echo ""

echo -e "${GREEN}Access URLs:${NC}"
echo "  Ignition Gateway (Host):    http://localhost:8088"
echo "  Ignition Gateway (Network): http://$HOST_IP:8088"
echo ""

echo -e "${GREEN}OPC UA Connection:${NC}"
echo "  From Ignition Edge: opc.tcp://$OPCUA_IP:4840/freeopcua/server/"
echo "  From Host:          opc.tcp://localhost:4840/freeopcua/server/"
echo ""

echo -e "${GREEN}Next Steps:${NC}"
echo "  1. Open http://localhost:8088 in your browser"
echo "  2. Complete Ignition commissioning wizard"
echo "  3. Select 'Edge' edition when prompted"
echo "  4. Configure OPC UA connection:"
echo "     - Go to Config → OPC UA → Connections"
echo "     - Add connection: opc.tcp://$OPCUA_IP:4840/freeopcua/server/"
echo "  5. Browse and add tags from OPC UA server"
echo ""

echo -e "${GREEN}Management Commands:${NC}"
echo "  View all containers:     lxc list"
echo "  Stop all:                lxc stop ignition-edge opcua-server"
echo "  Start all:              lxc start ignition-edge opcua-server"
echo "  Ignition logs:          lxc exec ignition-edge -- journalctl -u ignition -f"
echo "  OPC UA logs:            lxc exec opcua-server -- journalctl -u opcua-server -f"
echo "  Network info:           bash ./scripts/network_info.sh"
echo ""

# Test connectivity
echo -e "${GREEN}Testing connectivity...${NC}"
if lxc exec ignition-edge -- ping -c 2 "$OPCUA_IP" &> /dev/null; then
    echo -e "${GREEN}✓ Ignition Edge can reach OPC UA Server${NC}"
else
    echo -e "${RED}✗ Connectivity test failed${NC}"
fi

if lxc exec ignition-edge -- ping -c 2 8.8.8.8 &> /dev/null; then
    echo -e "${GREEN}✓ Ignition Edge has internet access (NAT working)${NC}"
else
    echo -e "${RED}✗ Internet connectivity test failed${NC}"
fi

if lxc exec opcua-server -- ping -c 2 8.8.8.8 &> /dev/null; then
    echo -e "${GREEN}✓ OPC UA Server has internet access (NAT working)${NC}"
else
    echo -e "${RED}✗ Internet connectivity test failed${NC}"
fi

echo ""
echo -e "${BLUE}=========================================${NC}"
echo ""