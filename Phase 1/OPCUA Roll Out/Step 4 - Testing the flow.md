# Terminal 1: Start Python OPC UA Server
python3 opcua_server.py

# Terminal 2: Check Ignition Edge is running
./ignition.sh status

# Terminal 3: Monitor logs
tail -f /var/log/ignition/wrapper.log