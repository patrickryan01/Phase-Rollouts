#!/bin/bash
#
# Display network information for all containers
#

echo "========================================="
echo "  LXC Container Network Information"
echo "========================================="
echo ""

echo "Network Bridge Configuration:"
echo "-----------------------------"
lxc network show lxdbr0
echo ""

echo "All Containers:"
echo "---------------"
lxc list
echo ""

echo "Container IP Addresses:"
echo "-----------------------"
for container in $(lxc list -c n --format csv); do
    ip=$(lxc list "$container" -c 4 --format csv | cut -d' ' -f1)
    echo "$container: $ip"
done
echo ""

echo "NAT Configuration:"
echo "------------------"
echo "Containers can access internet via NAT"
echo "Host IP: $(hostname -I | awk '{print $1}')"
echo ""

echo "Container Communication:"
echo "------------------------"
IGNITION_IP=$(lxc list ignition-edge -c 4 --format csv | cut -d' ' -f1)
OPCUA_IP=$(lxc list opcua-server -c 4 --format csv | cut -d' ' -f1)

if [ -n "$IGNITION_IP" ] && [ -n "$OPCUA_IP" ]; then
    echo "To connect Ignition to OPC UA Server:"
    echo "  OPC UA Endpoint: opc.tcp://$OPCUA_IP:4840/freeopcua/server/"
    echo ""
    echo "Test connectivity:"
    echo "  lxc exec ignition-edge -- ping -c 3 $OPCUA_IP"
fi
echo ""

echo "Port Forwarding (Host -> Container):"
echo "------------------------------------"
echo "Host: 8088  -> ignition-edge:8088  (Ignition HTTP)"
echo "Host:8043  -> ignition-edge:8043  (Ignition HTTPS)"
echo "Host:8060  -> ignition-edge:8060  (Gateway Network)"
echo "Host:4840  -> opcua-server: 4840   (OPC UA)"
echo ""