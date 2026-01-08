#!/bin/bash
#
# Create and configure LXC container for Ignition Edge
#

set -e

# Configuration
CONTAINER_NAME="${CONTAINER_NAME:-ignition-edge}"
UBUNTU_VERSION="${UBUNTU_VERSION:-22.04}"
IGNITION_ZIP="${IGNITION_ZIP:-$HOME/Downloads/Ignition-Edge-linux-x86-64-8.3.2.zip}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================="
echo "  Ignition Edge LXC Container Setup"
echo "========================================="
echo ""

# Check if Ignition zip file is provided
if [ -z "$IGNITION_ZIP" ]; then
    echo -e "${RED}Error: IGNITION_ZIP environment variable not set${NC}"
    echo ""
    echo "Usage:"
    echo "  IGNITION_ZIP=/path/to/Ignition-linux-64-8.1.44.zip $0"
    echo ""
    echo "Or download from:"
    echo "  https://inductiveautomation.com/downloads/"
    exit 1
fi

if [ ! -f "$IGNITION_ZIP" ]; then
    echo -e "${RED}Error:  Ignition zip file not found:  $IGNITION_ZIP${NC}"
    exit 1
fi

echo "Using Ignition package: $IGNITION_ZIP"
echo ""

# Check if container already exists
if lxc info "$CONTAINER_NAME" &> /dev/null; then
    echo -e "${YELLOW}Container $CONTAINER_NAME already exists${NC}"
    read -p "Delete and recreate? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Stopping and deleting container..."
        lxc stop "$CONTAINER_NAME" --force || true
        lxc delete "$CONTAINER_NAME"
    else
        echo "Using existing container"
        exit 0
    fi
fi

# Launch Ubuntu container
echo -e "${GREEN}Creating LXC container:  $CONTAINER_NAME${NC}"
lxc launch ubuntu:$UBUNTU_VERSION "$CONTAINER_NAME"

# Configure container resources
echo "Configuring container resources..."
lxc config set "$CONTAINER_NAME" limits.cpu 4
lxc config set "$CONTAINER_NAME" limits.memory 4GB
lxc config set "$CONTAINER_NAME" limits.memory.swap false

# Wait for container to be ready
echo "Waiting for container to start..."
sleep 10

# Wait for network
echo "Waiting for network..."
for i in {1..30}; do
    if lxc exec "$CONTAINER_NAME" -- ping -c 1 8.8.8.8 &> /dev/null; then
        echo -e "${GREEN}Network is ready${NC}"
        break
    fi
    echo "Waiting for network...  ($i/30)"
    sleep 2
done

# Update container
echo "Updating container..."
lxc exec "$CONTAINER_NAME" -- bash << 'EOF'
apt update
DEBIAN_FRONTEND=noninteractive apt upgrade -y
EOF

# Install dependencies
echo "Installing dependencies..."
lxc exec "$CONTAINER_NAME" -- bash << 'EOF'
DEBIAN_FRONTEND=noninteractive apt install -y \
    openjdk-11-jdk \
    unzip \
    wget \
    curl \
    net-tools \
    iputils-ping \
    nano \
    htop \
    tzdata

# Set timezone
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
EOF

# Create Ignition directory
echo "Creating Ignition directory..."
lxc exec "$CONTAINER_NAME" -- mkdir -p /opt/ignition

# Copy Ignition zip to container
echo "Copying Ignition installation files..."
lxc file push "$IGNITION_ZIP" "$CONTAINER_NAME/tmp/"

# Extract Ignition
IGNITION_ZIP_NAME=$(basename "$IGNITION_ZIP")
echo "Extracting Ignition..."
lxc exec "$CONTAINER_NAME" -- bash << EOF
cd /tmp
unzip -q "$IGNITION_ZIP_NAME" -d /opt/ignition
rm "$IGNITION_ZIP_NAME"
EOF

# Set execute permissions on all shell scripts
lxc exec "$CONTAINER_NAME" -- bash -c 'chmod +x /opt/ignition/*.sh'

# Create Ignition data directory
echo "Setting up Ignition data directory..."
lxc exec "$CONTAINER_NAME" -- mkdir -p /opt/ignition/data

# Configure Ignition for Edge edition
echo "Configuring Ignition Edge..."
lxc exec "$CONTAINER_NAME" -- bash << 'EOF'
cat > /opt/ignition/data/ignition.conf << 'CONF_EOF'
#
# Ignition Edge Configuration
#
wrapper.java.additional.1=-Dignition.edition=edge
wrapper.java.additional.2=-Xmx2048m
wrapper.java.maxmemory=2048
CONF_EOF
EOF

# Create systemd service
echo "Creating systemd service..."
lxc exec "$CONTAINER_NAME" -- bash << 'EOF'
cat > /etc/systemd/system/ignition.service << 'SERVICE_EOF'
[Unit]
Description=Ignition Edge Gateway
Documentation=https://docs.inductiveautomation.com/
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
User=root
WorkingDirectory=/opt/ignition
ExecStart=/opt/ignition/ignition.sh start
ExecStop=/opt/ignition/ignition.sh stop
ExecReload=/opt/ignition/ignition.sh restart
Restart=on-failure
RestartSec=10
TimeoutStartSec=300
TimeoutStopSec=60

# Security
NoNewPrivileges=false
PrivateTmp=false

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=ignition

[Install]
WantedBy=multi-user.target
SERVICE_EOF

systemctl daemon-reload
systemctl enable ignition.service
EOF

# Configure port forwarding
echo "Configuring port forwarding..."

# HTTP (8088)
lxc config device add "$CONTAINER_NAME" http-port proxy \
    listen=tcp:0.0.0.0:8088 \
    connect=tcp:127.0.0.1:8088 \
    bind=host || echo "HTTP port already configured"

# HTTPS (8043)
lxc config device add "$CONTAINER_NAME" https-port proxy \
    listen=tcp:0.0.0.0:8043 \
    connect=tcp:127.0.0.1:8043 \
    bind=host || echo "HTTPS port already configured"

# Gateway Network (8060)
lxc config device add "$CONTAINER_NAME" gateway-network-port proxy \
    listen=tcp:0.0.0.0:8060 \
    connect=tcp:127.0.0.1:8060 \
    bind=host || echo "Gateway Network port already configured"

# Start Ignition
echo "Starting Ignition..."
lxc exec "$CONTAINER_NAME" -- systemctl start ignition

# Wait for Ignition to start
echo "Waiting for Ignition to start..."
sleep 15

# Get container IP
CONTAINER_IP=$(lxc list "$CONTAINER_NAME" -c 4 --format csv | cut -d' ' -f1)

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Ignition Edge Container Created! ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Container Name: $CONTAINER_NAME"
echo "Container IP:  $CONTAINER_IP"
echo "Network:  lxdbr0 (NAT)"
echo ""
echo "Access Ignition Gateway:"
echo "  From Host:       http://localhost:8088"
echo "  From Network:   http://$(hostname -I | awk '{print $1}'):8088"
echo "  From Container: http://$CONTAINER_IP:8088"
echo ""
echo "Exposed Ports:"
echo "  8088 - HTTP Gateway"
echo "  8043 - HTTPS Gateway"
echo "  8060 - Gateway Network"
echo ""
echo "Container Management:"
echo "  Status:   lxc list"
echo "  Shell:   lxc exec $CONTAINER_NAME -- bash"
echo "  Logs:    lxc exec $CONTAINER_NAME -- journalctl -u ignition -f"
echo "  Stop:    lxc stop $CONTAINER_NAME"
echo "  Start:   lxc start $CONTAINER_NAME"
echo ""
echo "Next Steps:"
echo "  1. Open http://localhost:8088 in your browser"
echo "  2. Complete Ignition commissioning"
echo "  3. Select 'Edge' edition"
echo "  4. Activate license or start trial"
echo ""