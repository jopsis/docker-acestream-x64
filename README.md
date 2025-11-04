# Docker Acestream x64

Docker image for Acestream Engine on x64 architecture, based on Python 3.10 and Debian Bookworm.

## Documentation

- **[Advanced Configuration](CONFIGURATION.md)** - Complete guide to parameters and recommended configurations
- **[Network & P2P Configuration](NETWORK.md)** - Port configuration, UPNP, and network optimization
- [Documentación en Español](README_es.md)

## Description

This container runs Acestream Engine 3.2.11 with optimized configuration for streaming, including memory cache, configurable connection limits, and remote access enabled.

## Features

- **Base**: Python 3.10 on Debian Bookworm
- **Acestream Version**: 3.2.11 (Ubuntu 22.04 x86_64)
- **Cache**: Configured in memory (200MB)
- **Remote access**: Enabled with access tokens
- **Optimized buffers**: 25s for live, 10s for VOD
- **Architecture**: linux/amd64

## Quick Start

### From Docker Hub

```bash
docker run -d \
  --name acestream \
  -p 6878:6878 \
  -p 8621:8621 \
  jopsis/acestream:x64
```

### Build Locally

```bash
docker build -t acestream .
docker run -d -p 6878:6878 acestream
```

## Configuration

### Ports

- **6878**: Acestream Engine HTTP API port
- **8621**: P2P BitTorrent port (recommended for better performance)

> **Note:** For optimal P2P performance, ensure port 8621 is accessible. See [Network Configuration](NETWORK.md) for details on UPNP and port forwarding.

### Access Tokens

Default configured tokens:

- **Access Token**: `acestream`
- **Service Access Token**: `root`

### Configured Parameters

The engine starts with the following parameters:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `--client-console` | - | Console mode |
| `--bind-all` | - | Listen on all interfaces |
| `--service-remote-access` | - | Enable remote access |
| `--access-token` | acestream | Public access token |
| `--service-access-token` | root | Service access token |
| `--live-cache-type` | memory | Memory cache for live streams |
| `--live-cache-size` | 209715200 | 200MB live cache |
| `--vod-cache-type` | memory | Memory cache for VOD |
| `--cache-dir` | /acestream/.ACEStream | Cache directory |
| `--max-connections` | 500 | Maximum connections |
| `--max-peers` | 50 | Maximum peers |
| `--max-upload-slots` | 50 | Upload slots |
| `--live-buffer` | 25 | Live buffer (seconds) |
| `--vod-buffer` | 10 | VOD buffer (seconds) |
| `--log-max-size` | 15000000 | Maximum log size (15MB) |

### Customize Parameters

You can override startup parameters using the `ACESTREAM_ARGS` environment variable:

```bash
docker run -d \
  --name acestream \
  -p 6878:6878 \
  -e ACESTREAM_ARGS="--client-console --bind-all --access-token mytoken" \
  jopsis/acestream:x64
```

## Docker Compose

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
      - ACESTREAM_ARGS=--client-console --bind-all --service-remote-access --access-token acestream --service-access-token root --live-cache-type memory --live-cache-size 209715200
    volumes:
      - acestream-data:/acestream/.ACEStream

volumes:
  acestream-data:
```

## API Usage

Once running, you can access the Acestream HTTP API:

### Play a stream

```bash
curl "http://localhost:6878/ace/getstream?id=CONTENT_ID&format=json"
```

### Example with VLC

```bash
vlc http://localhost:6878/ace/getstream?id=CONTENT_ID
```

## Volumes

Optionally, you can mount a volume to persist cache and logs:

```bash
docker run -d \
  --name acestream \
  -p 6878:6878 \
  -p 8621:8621 \
  -v acestream-data:/acestream/.ACEStream \
  jopsis/acestream:x64
```

## CI/CD

The project includes a GitHub Actions workflow that automatically builds and publishes the image to Docker Hub when pushing to `main` or `master` branches.

### Workflow Configuration

The following secrets are required in the GitHub repository:

- `DOCKERHUB_USERNAME`: Docker Hub username
- `DOCKERHUB_TOKEN`: Docker Hub access token

## Troubleshooting

### View container logs

```bash
docker logs -f acestream
```

### Restart the service

```bash
docker restart acestream
```

### Check if service is active

```bash
curl http://localhost:6878/webui/api/service?method=get_version
```

## License

This project is a Docker wrapper for Acestream Engine. Acestream is owned by Acestream Media Ltd.

## Resources

- [Acestream Official](https://acestream.media/)
- [Docker Hub](https://hub.docker.com/r/jopsis/acestream)
- [GitHub Repository](https://github.com/jopsis/docker-acestream-x64)
