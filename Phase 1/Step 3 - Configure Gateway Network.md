# Step 3: Configure Gateway Network
*AKA: Making two systems talk to each other like they're on a blind date.*

## Overview
We're connecting Ignition Edge to your Main Gateway so data can flow like your tears during a production outage. Get ready for some networking "fun."

## 1. Configure the Main Ignition Gateway
First, let's prep the main gateway to accept incoming connections. It's clingy by default, so this should be easy.

**On your Main Ignition Gateway:**
- Navigate to **Config** → **Gateway Network** → **Settings**
- Enable **"Gateway Network"** (toggle that checkbox like your mental health depends on it)
- Note the connection info (you'll need this later, so screenshot it or write it down like it's 2005)

## 2. Configure Ignition Edge
Now we tell Edge where its parent gateway lives. It's like setting up Find My Friends, but sadder.

**On Ignition Edge:**
- Go to **Config** → **Gateway Network** → **Outgoing Connections**
- Click **Add Connection** to your main gateway
- Enter the main gateway's **IP address** and **port** (default is `8060`, because nothing can be simple)

If it connects, great. If not, check your firewall rules and question your life choices.

## 3. Configure Tag Sync (Edge → Main)
Time to make the data actually flow. We're using MQTT because apparently protocols are like coffee orders—needlessly complicated.

**On the Main Gateway:**
- Install **MQTT Engine** module (if you haven't already)

**On Ignition Edge:**
- Install **MQTT Transmission** module
- Configure your MQTT broker (pray it's already set up)

Once configured, tags will automatically publish via **Sparkplug B**. 
*Sparkplug B: Because regular MQTT wasn't confusing enough.*

## Verification
If everything worked, your tags should appear on the main gateway. If they don't, welcome to troubleshooting hell. Population: you.