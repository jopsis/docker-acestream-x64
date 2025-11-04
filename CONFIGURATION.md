# Advanced Acestream Configuration

This guide details all available parameters for configuring Acestream Engine and provides recommended configurations based on available hardware.

## Table of Contents

- [Network and Port Configuration](#network-and-port-configuration)
- [Available Parameters](#available-parameters)
- [Recommended Configurations](#recommended-configurations)
  - [Low-Spec Devices](#low-spec-devices)
  - [High-Spec Devices](#high-spec-devices)

---

## Network and Port Configuration

Acestream uses two main ports:

- **Port 6878 (HTTP API)**: Required to control and play streams
- **Port 8621 (P2P BitTorrent)**: Recommended to improve P2P performance

⚠️ **Important**: For optimal streaming performance, it's essential that **port 8621 is open** and accessible. This allows Acestream to receive incoming connections from other peers, significantly improving streaming speed and stability.

📖 **For detailed information about:**
- Port configuration and UPNP
- Docker network modes (host vs bridge)
- Firewall and port forwarding
- P2P connectivity troubleshooting

👉 **See the [Complete Network Configuration Guide](NETWORK.md)**

---

## Available Parameters

### Basic Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `--client-console` | Flag | Run engine in console mode |
| `--bind-all` | Flag | Listen on all network interfaces (0.0.0.0) |
| `--help` | Flag | Show help for available parameters |
| `--version` | Flag | Show Acestream version |

### Access and Security

| Parameter | Type | Default Value | Description |
|-----------|------|---------------|-------------|
| `--service-remote-access` | Flag | - | Enable remote access to service |
| `--access-token` | String | - | Public access token for API |
| `--service-access-token` | String | - | Administrative access token for service |
| `--allow-user-config` | Flag | - | Allow per-user custom configuration |

### Cache and Storage

| Parameter | Type | Default Value | Description |
|-----------|------|---------------|-------------|
| `--cache-dir` | Path | ~/.ACEStream | Directory for storing cache |
| `--live-cache-type` | String | disk | Cache type for live streams (memory/disk/hybrid) |
| `--live-cache-size` | Bytes | 268435456 | Live cache size (256MB by default) |
| `--vod-cache-type` | String | disk | Cache type for VOD (memory/disk/hybrid) |
| `--vod-cache-size` | Bytes | 536870912 | VOD cache size (512MB by default) |
| `--vod-drop-max-age` | Integer | 0 | Maximum age (seconds) before dropping VOD cache |
| `--max-file-size` | Bytes | 2147483648 | Maximum file size to cache (2GB by default) |

### Buffers

| Parameter | Type | Default Value | Description |
|-----------|------|---------------|-------------|
| `--live-buffer` | Integer | 10 | Buffer for live streams (seconds) |
| `--vod-buffer` | Integer | 5 | Buffer for VOD content (seconds) |
| `--refill-buffer-interval` | Integer | 5 | Buffer refill interval (seconds) |

### Connections and Network

| Parameter | Type | Default Value | Description |
|-----------|------|---------------|-------------|
| `--max-connections` | Integer | 200 | Maximum simultaneous connections |
| `--max-peers` | Integer | 40 | Maximum peers per torrent |
| `--max-upload-slots` | Integer | 4 | Number of simultaneous upload slots |
| `--auto-slots` | Integer | 1 | Automatic slot adjustment (0=disabled, 1=enabled) |
| `--download-limit` | Integer | 0 | Download speed limit (KB/s, 0=unlimited) |
| `--upload-limit` | Integer | 0 | Upload speed limit (KB/s, 0=unlimited) |
| `--port` | Integer | 8621 | Port for P2P connections |

### WebRTC

| Parameter | Type | Default Value | Description |
|-----------|------|---------------|-------------|
| `--webrtc-allow-outgoing-connections` | Integer | 0 | Allow outgoing WebRTC connections |
| `--webrtc-allow-incoming-connections` | Integer | 0 | Allow incoming WebRTC connections |

### Statistics and Reports

| Parameter | Type | Default Value | Description |
|-----------|------|---------------|-------------|
| `--stats-report-interval` | Integer | 60 | Statistics report interval (seconds) |
| `--stats-report-peers` | Flag | - | Include peer information in statistics |

### Engine Optimization

| Parameter | Type | Default Value | Description |
|-----------|------|---------------|-------------|
| `--slots-manager-use-cpu-limit` | Integer | 0 | Use CPU limit for slot management |
| `--core-skip-have-before-playback-pos` | Integer | 0 | Skip already downloaded pieces before playback position |
| `--core-dlr-periodic-check-interval` | Integer | 10 | Periodic check interval (seconds) |
| `--check-live-pos-interval` | Integer | 10 | Live position check interval (seconds) |

### Logs and Debug

| Parameter | Type | Default Value | Description |
|-----------|------|---------------|-------------|
| `--log-debug` | Integer | 0 | Debug level (0=normal, 1=verbose, 2=very verbose) |
| `--log-file` | Path | - | File for saving logs |
| `--log-max-size` | Bytes | 10485760 | Maximum log file size (10MB by default) |
| `--log-backup-count` | Integer | 3 | Number of backup files for logs |

### HTTP API

| Parameter | Type | Default Value | Description |
|-----------|------|---------------|-------------|
| `--http-port` | Integer | 6878 | Port for HTTP API |
| `--http-bind` | String | 127.0.0.1 | Listen address for HTTP API |

---

## Recommended Configurations

### Low-Spec Devices

Optimized configuration for devices with limited resources (e.g., Raspberry Pi, low RAM servers, basic VPS):

**Features:**
- Reduced memory cache
- Fewer simultaneous connections
- Smaller buffers
- Lower CPU usage

**Docker Compose Configuration:**

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
      - ACESTREAM_ARGS=--client-console --bind-all --service-remote-access --access-token acestream --service-access-token root --live-cache-type memory --live-cache-size 52428800 --vod-cache-type memory --vod-cache-size 52428800 --cache-dir /acestream/.ACEStream --max-connections 100 --max-peers 20 --max-upload-slots 10 --live-buffer 10 --vod-buffer 5 --download-limit 0 --upload-limit 512 --log-max-size 5000000 --log-backup-count 1 --refill-buffer-interval 3 --check-live-pos-interval 15
    volumes:
      - acestream-data:/acestream/.ACEStream
    mem_limit: 512m
    cpus: 1.0

volumes:
  acestream-data:
```

**Key Values:**
- Live/VOD cache: 50MB each
- Max connections: 100
- Max peers: 20
- Upload limit: 512 KB/s
- Live buffer: 10s
- RAM limit: 512MB
- CPU limit: 1 core

**Direct Docker Command:**

```bash
docker run -d \
  --name acestream \
  -p 6878:6878 \
  -p 8621:8621 \
  -m 512m \
  --cpus=1.0 \
  -v acestream-data:/acestream/.ACEStream \
  -e ACESTREAM_ARGS="--client-console --bind-all --service-remote-access --access-token acestream --service-access-token root --live-cache-type memory --live-cache-size 52428800 --vod-cache-type memory --vod-cache-size 52428800 --cache-dir /acestream/.ACEStream --max-connections 100 --max-peers 20 --max-upload-slots 10 --live-buffer 10 --vod-buffer 5 --upload-limit 512 --log-max-size 5000000 --log-backup-count 1" \
  jopsis/acestream:x64
```

---

### High-Spec Devices

Optimized configuration for servers with good resources (e.g., dedicated servers, powerful VPS, workstations):

**Features:**
- Large memory cache
- Maximum connections and peers
- Larger buffers
- No bandwidth limits
- Performance optimizations enabled

**Docker Compose Configuration:**

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
      - ACESTREAM_ARGS=--client-console --bind-all --service-remote-access --access-token acestream --service-access-token root --live-cache-type memory --live-cache-size 524288000 --vod-cache-type memory --vod-cache-size 524288000 --cache-dir /acestream/.ACEStream --vod-drop-max-age 300 --max-file-size 4294967296 --live-buffer 30 --vod-buffer 15 --max-connections 1000 --max-peers 100 --max-upload-slots 100 --auto-slots 0 --download-limit 0 --upload-limit 0 --stats-report-interval 2 --stats-report-peers --slots-manager-use-cpu-limit 1 --core-skip-have-before-playback-pos 1 --core-dlr-periodic-check-interval 3 --check-live-pos-interval 3 --refill-buffer-interval 1 --webrtc-allow-outgoing-connections 1 --allow-user-config --log-debug 0 --log-max-size 20000000 --log-backup-count 3
    volumes:
      - acestream-data:/acestream/.ACEStream
    mem_limit: 2g
    cpus: 4.0

volumes:
  acestream-data:
```

**Key Values:**
- Live/VOD cache: 500MB each
- Max connections: 1000
- Max peers: 100
- Upload/Download: Unlimited
- Live buffer: 30s
- VOD buffer: 15s
- RAM limit: 2GB
- CPU limit: 4 cores
- CPU optimizations enabled

**Direct Docker Command:**

```bash
docker run -d \
  --name acestream \
  -p 6878:6878 \
  -p 8621:8621 \
  -m 2g \
  --cpus=4.0 \
  -v acestream-data:/acestream/.ACEStream \
  -e ACESTREAM_ARGS="--client-console --bind-all --service-remote-access --access-token acestream --service-access-token root --live-cache-type memory --live-cache-size 524288000 --vod-cache-type memory --vod-cache-size 524288000 --cache-dir /acestream/.ACEStream --vod-drop-max-age 300 --max-file-size 4294967296 --live-buffer 30 --vod-buffer 15 --max-connections 1000 --max-peers 100 --max-upload-slots 100 --download-limit 0 --upload-limit 0 --stats-report-interval 2 --stats-report-peers --slots-manager-use-cpu-limit 1 --core-skip-have-before-playback-pos 1 --refill-buffer-interval 1 --webrtc-allow-outgoing-connections 1 --log-max-size 20000000 --log-backup-count 3" \
  jopsis/acestream:x64
```

---

## Optimization Tips

### To improve streaming performance:

1. **Increase live buffer** if you experience frequent cuts
2. **Reduce max-peers and max-connections** if your bandwidth is limited
3. **Use memory cache** whenever possible for better performance
4. **Limit upload** if you need to prioritize download for playback

### To reduce resource usage:

1. **Reduce live-cache-size and vod-cache-size**
2. **Decrease max-connections and max-peers**
3. **Increase check intervals** (check-live-pos-interval, core-dlr-periodic-check-interval)
4. **Reduce log-max-size and log-backup-count**

### For maximum stability:

1. **Mount a persistent volume** for cache directory
2. **Set restart: unless-stopped** in docker-compose
3. **Configure appropriate resource limits** (mem_limit, cpus)
4. **Monitor logs** regularly to detect issues

---

## Back to Main Documentation

- [Main README](README.md)
- [Spanish README](README_es.md)
