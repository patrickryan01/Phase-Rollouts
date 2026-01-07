# Quick Summary Commands
(Because who has the attention span for the full documentation anyway?)

## 1. Install dependencies
Convince the environment to cooperate. It's high maintenance, just like us.

```bash
sudo apt-get update
sudo apt-get install python3-pip
pip3 install opcua
```

## 2. Run the server
Fire it up. If it crashes, just remember: everything is temporary.

```bash
python3 opcua_server.py
```

## 3. Check if OPC UA server is listening
Verify port 4840 is open. At least *something* is listening to you today.

```bash
netstat -tuln | grep 4840
```