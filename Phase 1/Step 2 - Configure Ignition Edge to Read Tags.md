# Step 2: Configure Ignition Edge to Read Tags
*Because connecting systems shouldn't be this hard, yet here we are.*

## 1. Install Ignition Edge on Ubuntu
Download the thing. Unzip the thing. Run the thing. It's Java, so expect it to eat all your RAM.

`ash
# Replace '8.1.x' with an actual version number unless you like 404 errors.
wget https://files.inductiveautomation.com/release/ia/8.1.x/Ignition-Edge-linux-64-8.1.x.zip
unzip Ignition-Edge-linux-64-8.1.x.zip
cd ignition
./ignition.sh start
`

## 2. Access Ignition Edge Gateway
Open your browser and navigate to http://localhost:8088 (or the device's IP if you're feeling fancy).
- Complete the initial setup.
- Select **"Ignition Edge"** edition. Do not pass Go, do not collect .

## 3. Add OPC UA Connection
Time to make friends with the Python server.
- Navigate to **Config**  **OPC UA**  **Connections**.
- Click **"Create new OPC-UA Connection"**.

**Use these settings:**
- **Name:** LocalPythonServer
- **Enabled:** Checked (obviously)
- **Endpoint URL:** opc.tcp://localhost:4840/freeopcua/server/
- **Security Policy:** None
    *Note: We use 'None' for testing. We promise to add security in production. (We are lying).*

Save it. If it says "Connected", take a victory sip of coffee.

## 4. Browse and Create Tags
If the connection is alive, let's steal some data.
- Go to **Config**  **Tags**.
- Right-click on your tag provider  **OPC Browser**.
- Browse to your Python server tags.
- Select the tags you want and drag them to your tag provider like you're shopping online for things you don't need.
- Alternatively, use the **Quick Client** to verify you aren't hallucinating the data.
