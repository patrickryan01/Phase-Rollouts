# Step 1: Prepare the Environment
*Because we can't have nice things without installing them first.*

## Context
We are prepping an Ubuntu LTS box to host our Python OPC UA server. This server will eventually broadcast tags for Ignition Edge, assuming we ever get that far.

## The Setup

### 1. Update the system
Update the package list. It gives you a false sense of progress.

```bash
sudo apt-get update
```

### 2. Install Python Pip
We need `pip` to install the libraries. It's the middleman we can't cut out.

```bash
sudo apt-get install python3-pip
```
