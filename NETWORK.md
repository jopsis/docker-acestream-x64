# Network and P2P Configuration in Acestream

This guide explains port configuration, UPNP, and network options to optimize Acestream P2P connectivity.

## Table of Contents

- [Ports Used](#ports-used)
- [P2P Port 8621](#p2p-port-8621)
- [UPNP (Universal Plug and Play)](#upnp-universal-plug-and-play)
- [Docker Network Configurations](#docker-network-configurations)
- [Firewall and Port Forwarding](#firewall-and-port-forwarding)

---

## Ports Used

Acestream uses two main ports:

| Port | Protocol | Purpose | Required |
|------|----------|---------|----------|
| **6878** | TCP/HTTP | HTTP API for control and playback | ✅ Mandatory |
| **8621** | TCP/UDP | P2P BitTorrent connections | ⚠️ Recommended |

---

## P2P Port 8621

### What is it?

Port **8621** is the default port used by Acestream for **peer-to-peer (P2P)** connections in the BitTorrent protocol. It's different from port 6878 which is only for the HTTP API.

### Why is it important?

| Port 8621 CLOSED | Port 8621 OPEN |
|------------------|----------------|
| ❌ Only outgoing connections | ✅ Incoming and outgoing connections |
| ❌ Fewer peers available | ✅ More peers available |
| ❌ Reduced performance | ✅ Better performance |
| ❌ Act only as "leecher" | ✅ Act as full "seeder" |
| ❌ Slow or choppy streams | ✅ Smooth streams |

### Related parameter

```bash
--port 8621  # Defines P2P port (8621 is the default value)
```

---

## UPNP (Universal Plug and Play)

### What is UPNP?

UPNP is a protocol that allows applications to **automatically open ports** on your router without manual configuration.

### How it works

1. ✅ Acestream detects your UPNP-compatible router
2. ✅ Requests the router to automatically open port 8621
3. ✅ Router creates a temporary port forwarding rule
4. ✅ Now you can receive incoming P2P connections

### Problem with Docker

⚠️ **UPNP does NOT work inside Docker containers** by default because:

- The container is on an isolated virtual network (bridge)
- UPNP needs direct access to the host network interface
- The container cannot "see" your physical router
- UPNP packets do not traverse the Docker bridge

### Solution: Network Mode Host

For UPNP to work, you must use `network_mode: host`:

```yaml
services:
  acestream:
    image: jopsis/acestream:x64
    network_mode: host  # Use host network directly
    restart: unless-stopped
    environment:
      - ACESTREAM_ARGS=--client-console --bind-all --port 8621
    volumes:
      - acestream-data:/acestream/.ACEStream

volumes:
  acestream-data:
```

**Advantages:**
- ✅ UPNP works automatically
- ✅ Better network performance
- ✅ No need to manually map ports

**Disadvantages:**
- ⚠️ Container shares entire host network
- ⚠️ Less network isolation
- ⚠️ Cannot change ports (will always be 6878 and 8621)

---

## Docker Network Configurations

### Option 1: Network Host (Recommended for UPNP)

**Best for:** Dedicated servers, VPS, home servers with UPNP router

```yaml
version: '3.8'

services:
  acestream:
    image: jopsis/acestream:x64
    container_name: acestream
    network_mode: host
    restart: unless-stopped
    environment:
      - ACESTREAM_ARGS=--client-console --bind-all --port 8621
    volumes:
      - acestream-data:/acestream/.ACEStream

volumes:
  acestream-data:
```

**Docker Command:**
```bash
docker run -d \
  --name acestream \
  --network host \
  -v acestream-data:/acestream/.ACEStream \
  -e ACESTREAM_ARGS="--client-console --bind-all --port 8621" \
  jopsis/acestream:x64
```

---

### Option 2: Port Mapping + Manual Port Forwarding (Default Recommended)

**Best for:** Maximum compatibility and control

```yaml
version: '3.8'

services:
  acestream:
    image: jopsis/acestream:x64
    container_name: acestream
    ports:
      - "6878:6878"  # API HTTP
      - "8621:8621"  # P2P BitTorrent
    restart: unless-stopped
    environment:
      - ACESTREAM_ARGS=--client-console --bind-all --port 8621
    volumes:
      - acestream-data:/acestream/.ACEStream

volumes:
  acestream-data:
```

**Additional steps:**
1. Configure port forwarding on your router: `8621 → Your_server_IP`
2. Verify that firewall allows port 8621

**Docker Command:**
```bash
docker run -d \
  --name acestream \
  -p 6878:6878 \
  -p 8621:8621 \
  -v acestream-data:/acestream/.ACEStream \
  -e ACESTREAM_ARGS="--client-console --bind-all --port 8621" \
  jopsis/acestream:x64
```

---

### Option 3: HTTP API Only (No incoming P2P)

**Best for:** Testing, simple use, limited resources

```yaml
version: '3.8'

services:
  acestream:
    image: jopsis/acestream:x64
    container_name: acestream
    ports:
      - "6878:6878"  # HTTP API only
    restart: unless-stopped
    volumes:
      - acestream-data:/acestream/.ACEStream

volumes:
  acestream-data:
```

**Features:**
- ⚠️ Only outgoing P2P connections
- ⚠️ Reduced performance
- ✅ Simpler to configure
- ✅ Works behind NAT without configuration

---

## Firewall and Port Forwarding

### Configure Firewall (Linux/VPS)

**UFW (Ubuntu/Debian):**
```bash
# Allow HTTP API port
sudo ufw allow 6878/tcp

# Allow P2P port
sudo ufw allow 8621/tcp
sudo ufw allow 8621/udp

# Verify rules
sudo ufw status
```

**Firewalld (RHEL/CentOS):**
```bash
# Allow ports
sudo firewall-cmd --permanent --add-port=6878/tcp
sudo firewall-cmd --permanent --add-port=8621/tcp
sudo firewall-cmd --permanent --add-port=8621/udp

# Reload firewall
sudo firewall-cmd --reload
```

**iptables:**
```bash
# HTTP API
sudo iptables -A INPUT -p tcp --dport 6878 -j ACCEPT

# P2P
sudo iptables -A INPUT -p tcp --dport 8621 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 8621 -j ACCEPT

# Save rules
sudo iptables-save > /etc/iptables/rules.v4
```

### Port Forwarding on Router (Home use)

To improve P2P performance, configure port forwarding on your router:

1. Access your router's web interface (usually `192.168.1.1` or `192.168.0.1`)
2. Find the "Port Forwarding" or "Virtual Server" section
3. Create a new rule:
   - **External port:** 8621
   - **Internal port:** 8621
   - **Protocol:** TCP and UDP
   - **Destination IP:** Your server's local IP (e.g., 192.168.1.100)
4. Save and apply changes

### Verify P2P connectivity

**From inside the container:**
```bash
docker exec -it acestream netstat -tuln | grep 8621
```

**From another device on your local network:**
```bash
# Check if port is open
nc -zv SERVER_IP 8621

# Or with telnet
telnet SERVER_IP 8621
```

**From the Internet (if you have a public IP):**
- Use online tools like: https://www.yougetsignal.com/tools/open-ports/
- Enter your public IP and port 8621

---

## Configuration Comparison

| Configuration | UPNP | Incoming P2P | Complexity | Performance | Recommended for |
|---------------|------|--------------|------------|-------------|-----------------|
| **Network Host** | ✅ Yes | ✅ Yes | ⭐ Low | ⭐⭐⭐ High | Dedicated servers, VPS |
| **Port Mapping + Manual Forwarding** | ❌ No | ✅ Yes | ⭐⭐ Medium | ⭐⭐⭐ High | Home use, full control |
| **HTTP API Only** | ❌ No | ❌ No | ⭐ Very low | ⭐ Basic | Testing, limited resources |

---

## Network Parameters in Acestream

Parameters related to network configuration:

```bash
--port 8621                              # P2P port (default 8621)
--http-port 6878                         # HTTP API port (default 6878)
--bind-all                               # Listen on all interfaces (0.0.0.0)
--max-connections 500                    # Maximum simultaneous connections
--max-peers 50                           # Maximum peers per torrent
--download-limit 0                       # Download limit (0=unlimited)
--upload-limit 0                         # Upload limit (0=unlimited)
--webrtc-allow-outgoing-connections 1    # Outgoing WebRTC connections
```

---

## Troubleshooting

### Problem: "No peers available"

**Possible causes:**
1. Port 8621 blocked by firewall
2. Port forwarding not configured on router
3. ISP blocking P2P traffic

**Solution:**
```bash
# Verify port is exposed in Docker
docker port acestream

# Check firewall
sudo ufw status

# Try with network_mode: host
```

### Problem: "Slow streaming with frequent cuts"

**Solution:**
1. Open port 8621 on firewall and router
2. Increase `--max-peers` and `--max-connections`
3. Increase buffer: `--live-buffer 30`
4. Use host network configuration if possible

### Problem: "UPNP not working"

**Solution:**
1. Verify your router has UPNP enabled
2. Use `network_mode: host` in docker-compose
3. Alternatively, configure manual port forwarding

---

## Back to Main Documentation

- [Advanced Configuration](CONFIGURATION.md)
- [Main README](README.md)
- [Spanish Network Documentation](REDES.md)
