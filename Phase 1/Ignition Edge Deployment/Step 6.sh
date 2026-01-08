#!/bin/bash
#
# Manage all LXC containers for Ignition Edge deployment
#

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

CONTAINERS="ignition-edge opcua-server"

show_status() {
    echo -e "${BLUE}Container Status:${NC}"
    lxc list
    echo ""
    
    echo -e "${BLUE}Service Status:${NC}"
    for container in $CONTAINERS; do
        if lxc info "$container" &> /dev/null; then
            echo -e "${GREEN}$container:${NC}"
            if [ "$container" = "ignition-edge" ]; then
                lxc exec "$container" -- systemctl status ignition --no-pager -l || true
            elif [ "$container" = "opcua-server" ]; then
                lxc exec "$container" -- systemctl status opcua-server --no-pager -l || true
            fi
            echo ""
        fi
    done
}

start_all() {
    echo -e "${GREEN}Starting all containers...${NC}"
    for container in $CONTAINERS; do
        if lxc info "$container" &> /dev/null; then
            echo "Starting $container..."
            lxc start "$container" || echo "$container already running"
        fi
    done
    sleep 5
    echo -e "${GREEN}All containers started${NC}"
    lxc list
}

stop_all() {
    echo -e "${YELLOW}Stopping all containers...${NC}"
    for container in $CONTAINERS; do
        if lxc info "$container" &> /dev/null; then
            echo "Stopping $container..."
            lxc stop "$container" || true
        fi
    done
    echo -e "${GREEN}All containers stopped${NC}"
    lxc list
}

restart_all() {
    echo -e "${YELLOW}Restarting all containers...${NC}"
    stop_all
    sleep 2
    start_all
}

show_logs() {
    container=$1
    if [ -z "$container" ]; then
        echo "Available containers:"
        echo "  ignition-edge"
        echo "  opcua-server"
        echo ""
        echo "Usage: $0 logs <container-name>"
        exit 1
    fi
    
    if [ "$container" = "ignition-edge" ]; then
        lxc exec "$container" -- journalctl -u ignition -f
    elif [ "$container" = "opcua-server" ]; then
        lxc exec "$container" -- journalctl -u opcua-server -f
    else
        echo -e "${RED}Unknown container: $container${NC}"
        exit 1
    fi
}

shell_access() {
    container=$1
    if [ -z "$container" ]; then
        echo "Available containers:"
        echo "  ignition-edge"
        echo "  opcua-server"
        echo ""
        echo "Usage: $0 shell <container-name>"
        exit 1
    fi
    
    lxc exec "$container" -- bash
}

show_network() {
    echo -e "${BLUE}Network Configuration:${NC}"
    echo ""
    
    echo "Bridge Information:"
    lxc network show lxdbr0
    echo ""
    
    echo "Container IPs:"
    for container in $CONTAINERS; do
        if lxc info "$container" &> /dev/null; then
            ip=$(lxc list "$container" -c 4 --format csv | cut -d' ' -f1)
            echo "  $container: $ip"
        fi
    done
    echo ""
    
    echo "Connectivity Tests:"
    IGNITION_IP=$(lxc list ignition-edge -c 4 --format csv | cut -d' ' -f1)
    OPCUA_IP=$(lxc list opcua-server -c 4 --format csv | cut -d' ' -f1)
    
    if [ -n "$IGNITION_IP" ] && [ -n "$OPCUA_IP" ]; then
        echo -n "  Ignition -> OPC UA: "
        if lxc exec ignition-edge -- ping -c 1 -W 2 "$OPCUA_IP" &> /dev/null; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗${NC}"
        fi
        
        echo -n "  Ignition -> Internet: "
        if lxc exec ignition-edge -- ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗${NC}"
        fi
        
        echo -n "  OPC UA -> Internet: "
        if lxc exec opcua-server -- ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗${NC}"
        fi
    fi
    echo ""
}

backup_all() {
    backup_dir="./backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    echo -e "${GREEN}Creating backups in $backup_dir${NC}"
    
    for container in $CONTAINERS; do
        if lxc info "$container" &> /dev/null; then
            echo "Snapshotting $container..."
            snapshot_name="backup-$(date +%Y%m%d-%H%M%S)"
            lxc snapshot "$container" "$snapshot_name"
            echo "  Created snapshot: $snapshot_name"
        fi
    done
    
    echo ""
    echo -e "${GREEN}Backup complete!${NC}"
    echo ""
    echo "Snapshots created.  To restore:"
    echo "  lxc restore <container> <snapshot-name>"
}

list_snapshots() {
    echo -e "${BLUE}Available Snapshots:${NC}"
    echo ""
    
    for container in $CONTAINERS; do
        if lxc info "$container" &> /dev/null; then
            echo -e "${GREEN}$container:${NC}"
            lxc info "$container" | grep -A 100 "Snapshots:" || echo "  No snapshots"
            echo ""
        fi
    done
}

delete_all() {
    echo -e "${RED}WARNING: This will delete all containers and their data!${NC}"
    read -p "Are you sure?  Type 'yes' to confirm: " -r
    echo
    if [ "$REPLY" = "yes" ]; then
        for container in $CONTAINERS; do
            if lxc info "$container" &> /dev/null; then
                echo "Deleting $container..."
                lxc stop "$container" --force || true
                lxc delete "$container"
            fi
        done
        echo -e "${GREEN}All containers deleted${NC}"
    else
        echo "Cancelled"
    fi
}

case "$1" in
    start)
        start_all
        ;;
    stop)
        stop_all
        ;;
    restart)
        restart_all
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "$2"
        ;;
    shell)
        shell_access "$2"
        ;;
    network)
        show_network
        ;;
    backup)
        backup_all
        ;;
    snapshots)
        list_snapshots
        ;;
    delete)
        delete_all
        ;;
    *)
        echo "Ignition Edge LXC Container Management"
        echo ""
        echo "Usage: $0 {command} [options]"
        echo ""
        echo "Commands:"
        echo "  start           - Start all containers"
        echo "  stop            - Stop all containers"
        echo "  restart         - Restart all containers"
        echo "  status          - Show container and service status"
        echo "  logs <name>     - Show logs for a container"
        echo "  shell <name>    - Open shell in container"
        echo "  network         - Show network information and test connectivity"
        echo "  backup          - Create snapshots of all containers"
        echo "  snapshots       - List all snapshots"
        echo "  delete          - Delete all containers (WARNING: destructive! )"
        echo ""
        echo "Examples:"
        echo "  $0 start"
        echo "  $0 logs ignition-edge"
        echo "  $0 shell opcua-server"
        echo "  $0 network"
        echo ""
        exit 1
        ;;
esac