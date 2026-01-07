# Troubleshooting
*When things inevitably fall apart (and they will).*

## Common Issues & Solutions
Because Murphy's Law is more reliable than your infrastructure.

### Issue: Can't Connect to OPC UA Server
**Symptoms:** Connection timeout, sad error messages, general despair.

**Fix:** It's probably the firewall. It's always the firewall.

```bash
sudo ufw allow 4840/tcp
```

### Issue: Ignition Edge Can't Reach Main Gateway
**Symptoms:** Edge sitting alone in the corner, unable to phone home.

**Fix:** Check that port `8060` is open on your main gateway. Firewalls strike again.

```bash
# On the main gateway, verify port 8060 is listening
sudo netstat -tuln | grep 8060
```

### Issue: Tags Not Updating
**Symptoms:** Stale data. Values frozen in time like your career prospects.

**Fix:** Verify the OPC connection status in Ignition Edge Config.
- Go to **Config** → **OPC UA** → **Connections**
- Check if status shows "Connected" (green is good, red is bad)
- If disconnected, try restarting the OPC UA server or crying into your coffee

### Issue: Everything is Broken and I Don't Know Why
**Symptoms:** Existential dread. Questioning your career choices.

**Fix:** 
1. Check the logs (they probably won't help, but at least you tried)
2. Restart everything
3. Make sure services are actually running
4. Google the error message and pretend to understand Stack Overflow answers
5. Accept that some mysteries remain unsolved