# Docker Acestream x64

Imagen Docker de Acestream Engine para arquitectura x64, basada en Python 3.10 y Debian Bookworm.

## Descripción

Este contenedor ejecuta Acestream Engine 3.2.11 con configuración optimizada para streaming, incluyendo cache en memoria, límites de conexiones configurables y acceso remoto habilitado.

## Características

- **Base**: Python 3.10 en Debian Bookworm
- **Versión Acestream**: 3.2.11 (Ubuntu 22.04 x86_64)
- **Cache**: Configurado en memoria (200MB)
- **Acceso remoto**: Habilitado con tokens de acceso
- **Buffers optimizados**: 25s para live, 10s para VOD
- **Arquitectura**: linux/amd64

## Uso Rápido

### Desde Docker Hub

```bash
docker run -d \
  --name acestream \
  -p 6878:6878 \
  jopsis/acestream:x64
```

### Construir localmente

```bash
docker build -t acestream .
docker run -d -p 6878:6878 acestream
```

## Configuración

### Puertos

- **6878**: Puerto HTTP API de Acestream Engine

### Tokens de Acceso

Los tokens por defecto configurados son:

- **Access Token**: `acestream`
- **Service Access Token**: `root`

### Parámetros Configurados

El motor arranca con los siguientes parámetros:

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| `--client-console` | - | Modo consola |
| `--bind-all` | - | Escucha en todas las interfaces |
| `--service-remote-access` | - | Habilita acceso remoto |
| `--access-token` | acestream | Token de acceso público |
| `--service-access-token` | root | Token de acceso de servicio |
| `--live-cache-type` | memory | Cache en memoria para streams live |
| `--live-cache-size` | 209715200 | 200MB de cache live |
| `--vod-cache-type` | memory | Cache en memoria para VOD |
| `--cache-dir` | /acestream/.ACEStream | Directorio de cache |
| `--max-connections` | 500 | Máximo de conexiones |
| `--max-peers` | 50 | Máximo de peers |
| `--max-upload-slots` | 50 | Slots de upload |
| `--live-buffer` | 25 | Buffer live (segundos) |
| `--vod-buffer` | 10 | Buffer VOD (segundos) |
| `--log-max-size` | 15000000 | Tamaño máximo de log (15MB) |

### Personalizar Parámetros

Puedes sobrescribir los parámetros de inicio usando la variable de entorno `ACESTREAM_ARGS`:

```bash
docker run -d \
  --name acestream \
  -p 6878:6878 \
  -e ACESTREAM_ARGS="--client-console --bind-all --access-token mitoken" \
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
      - "6878:6878"
    restart: unless-stopped
    environment:
      - ACESTREAM_ARGS=--client-console --bind-all --service-remote-access --access-token acestream --service-access-token root --live-cache-type memory --live-cache-size 209715200
```

## Uso de la API

Una vez en ejecución, puedes acceder a la API HTTP de Acestream:

### Reproducir un stream

```bash
curl "http://localhost:6878/ace/getstream?id=CONTENT_ID&format=json"
```

### Ejemplo con VLC

```bash
vlc http://localhost:6878/ace/getstream?id=CONTENT_ID
```

## Volúmenes

Opcionalmente, puedes montar un volumen para persistir la cache y logs:

```bash
docker run -d \
  --name acestream \
  -p 6878:6878 \
  -v acestream-data:/acestream/.ACEStream \
  jopsis/acestream:x64
```

## CI/CD

El proyecto incluye un workflow de GitHub Actions que construye y publica automáticamente la imagen en Docker Hub cuando se hace push a las ramas `main` o `master`.

### Configuración del Workflow

Se requieren los siguientes secrets en el repositorio de GitHub:

- `DOCKERHUB_USERNAME`: Usuario de Docker Hub
- `DOCKERHUB_TOKEN`: Token de acceso de Docker Hub

## Troubleshooting

### Ver logs del contenedor

```bash
docker logs -f acestream
```

### Reiniciar el servicio

```bash
docker restart acestream
```

### Verificar que el servicio está activo

```bash
curl http://localhost:6878/webui/api/service?method=get_version
```

## Licencia

Este proyecto es un wrapper de Docker para Acestream Engine. Acestream es propiedad de Acestream Media Ltd.

## Recursos

- [Acestream Official](https://acestream.media/)
- [Docker Hub](https://hub.docker.com/r/jopsis/acestream)
- [GitHub Repository](https://github.com/jopsis/docker-acestream-x64)
