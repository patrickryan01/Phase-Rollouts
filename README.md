# OPC UA Server for People Who Have Given Up on Proprietary Everything

> *"Because spending $50k on a PLC simulator wasn't in the budget, and neither was your sanity."*

## What Fresh Hell Is This?

Welcome to the **Python OPC UA Server** – your new best friend in the dystopian nightmare of industrial automation.  This little beauty generates fake (but convincing!) sensor data and serves it up via OPC UA, because apparently in 2026 we're still using protocols from the early 2000s.  

But hey, at least it's open source and won't require you to sell a kidney for licensing fees.

## The Existential Crisis (aka "What Does This Thing Actually Do?")

This application is a **configurable OPC UA server** that: 

1. **Pretends to be industrial equipment** – Simulates sensors, counters, status flags, and whatever other tags your Ignition Edge instance is desperately craving
2. **Lies convincingly with data** – Generates realistic random values, increments counters, and generally makes it look like something is actually happening
3. **Doesn't judge your life choices** – Works in LXC containers because your client won't pay for Docker (we've all been there)
4. **Speaks OPC UA** – Because apparently MQTT was too mainstream and Modbus too retro

### In Less Snarky Terms

This is a lightweight, Python-based OPC UA server that allows you to:
- Define custom tags via a simple JSON configuration file
- Simulate sensor data with configurable ranges and update patterns
- Expose data to Ignition Edge (or any OPC UA client) without needing actual hardware
- Test your SCADA system before plugging in the $100k equipment that will definitely break everything

## Why Does This Exist?

Because you need to: 
- ✅ Test Ignition Edge without physical hardware (because shipping delays are a thing)
- ✅ Demo your HMI to clients without admitting the actual sensors don't exist yet
- ✅ Simulate production data for development (production is on fire and you can't touch it)
- ✅ Prove to management that yes, this whole OPC UA thing actually works
- ✅ Avoid the "works on my machine" problem (it's in a container, baby!)

## Features (That Might Actually Save Your Project)

### 🎯 Configurable Tag Hell
Define your tags in `tags_config.json` and watch them spring to life like industrial Frankensteins:

```json
{
  "Temperature":  {
    "type": "float",
    "initial_value": 20.0,
    "simulate":  true,
    "simulation_type": "random",
    "min":  15.0,
    "max":  25.0
  }
}