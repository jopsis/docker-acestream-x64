# Configuración Avanzada de Acestream

Esta guía detalla todos los parámetros disponibles para configurar Acestream Engine y proporciona configuraciones recomendadas según el hardware disponible.

## Índice

- [Configuración de Red y Puertos](#configuración-de-red-y-puertos)
- [Parámetros Disponibles](#parámetros-disponibles)
- [Configuraciones Recomendadas](#configuraciones-recomendadas)
  - [Dispositivos de Baja Potencia](#dispositivos-de-baja-potencia)
  - [Dispositivos de Alta Potencia](#dispositivos-de-alta-potencia)

---

## Configuración de Red y Puertos

Acestream utiliza dos puertos principales:

- **Puerto 6878 (HTTP API)**: Obligatorio para controlar y reproducir streams
- **Puerto 8621 (P2P BitTorrent)**: Recomendado para mejorar el rendimiento P2P

⚠️ **Importante**: Para obtener el mejor rendimiento de streaming, es fundamental que el **puerto 8621 esté abierto** y accesible. Esto permite que Acestream reciba conexiones entrantes de otros peers, mejorando significativamente la velocidad y estabilidad del streaming.

📖 **Para más información detallada sobre:**
- Configuración de puertos y UPNP
- Network modes en Docker (host vs bridge)
- Firewall y port forwarding
- Solución de problemas de conectividad P2P

👉 **Consulta la [Guía Completa de Configuración de Red](REDES.md)**

---

## Parámetros Disponibles

### Parámetros Básicos

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `--client-console` | Flag | Ejecuta el motor en modo consola |
| `--bind-all` | Flag | Escucha en todas las interfaces de red (0.0.0.0) |
| `--help` | Flag | Muestra ayuda sobre los parámetros disponibles |
| `--version` | Flag | Muestra la versión de Acestream |

### Acceso y Seguridad

| Parámetro | Tipo | Valor por defecto | Descripción |
|-----------|------|-------------------|-------------|
| `--service-remote-access` | Flag | - | Habilita el acceso remoto al servicio |
| `--access-token` | String | - | Token de acceso público para la API |
| `--service-access-token` | String | - | Token de acceso administrativo para el servicio |
| `--allow-user-config` | Flag | - | Permite configuración personalizada por usuario |

### Cache y Almacenamiento

| Parámetro | Tipo | Valor por defecto | Descripción |
|-----------|------|-------------------|-------------|
| `--cache-dir` | Path | ~/.ACEStream | Directorio para almacenar cache |
| `--live-cache-type` | String | disk | Tipo de cache para streams en vivo (memory/disk/hybrid) |
| `--live-cache-size` | Bytes | 268435456 | Tamaño de cache para live (256MB por defecto) |
| `--vod-cache-type` | String | disk | Tipo de cache para VOD (memory/disk/hybrid) |
| `--vod-cache-size` | Bytes | 536870912 | Tamaño de cache para VOD (512MB por defecto) |
| `--vod-drop-max-age` | Integer | 0 | Edad máxima (segundos) antes de descartar cache VOD |
| `--max-file-size` | Bytes | 2147483648 | Tamaño máximo de archivo a cachear (2GB por defecto) |

### Buffers

| Parámetro | Tipo | Valor por defecto | Descripción |
|-----------|------|-------------------|-------------|
| `--live-buffer` | Integer | 10 | Buffer para streams en vivo (segundos) |
| `--vod-buffer` | Integer | 5 | Buffer para contenido VOD (segundos) |
| `--refill-buffer-interval` | Integer | 5 | Intervalo de rellenado del buffer (segundos) |

### Conexiones y Red

| Parámetro | Tipo | Valor por defecto | Descripción |
|-----------|------|-------------------|-------------|
| `--max-connections` | Integer | 200 | Número máximo de conexiones simultáneas |
| `--max-peers` | Integer | 40 | Número máximo de peers por torrent |
| `--max-upload-slots` | Integer | 4 | Número de slots de subida simultáneos |
| `--auto-slots` | Integer | 1 | Ajuste automático de slots (0=deshabilitado, 1=habilitado) |
| `--download-limit` | Integer | 0 | Límite de velocidad de descarga (KB/s, 0=ilimitado) |
| `--upload-limit` | Integer | 0 | Límite de velocidad de subida (KB/s, 0=ilimitado) |
| `--port` | Integer | 8621 | Puerto para conexiones P2P |

### WebRTC

| Parámetro | Tipo | Valor por defecto | Descripción |
|-----------|------|-------------------|-------------|
| `--webrtc-allow-outgoing-connections` | Integer | 0 | Permite conexiones WebRTC salientes |
| `--webrtc-allow-incoming-connections` | Integer | 0 | Permite conexiones WebRTC entrantes |

### Estadísticas y Reportes

| Parámetro | Tipo | Valor por defecto | Descripción |
|-----------|------|-------------------|-------------|
| `--stats-report-interval` | Integer | 60 | Intervalo de reporte de estadísticas (segundos) |
| `--stats-report-peers` | Flag | - | Incluye información de peers en estadísticas |

### Optimización del Motor

| Parámetro | Tipo | Valor por defecto | Descripción |
|-----------|------|-------------------|-------------|
| `--slots-manager-use-cpu-limit` | Integer | 0 | Usa límite de CPU para gestión de slots |
| `--core-skip-have-before-playback-pos` | Integer | 0 | Salta piezas que ya están descargadas antes de la posición de reproducción |
| `--core-dlr-periodic-check-interval` | Integer | 10 | Intervalo de verificación periódica (segundos) |
| `--check-live-pos-interval` | Integer | 10 | Intervalo de verificación de posición en live (segundos) |

### Logs y Debug

| Parámetro | Tipo | Valor por defecto | Descripción |
|-----------|------|-------------------|-------------|
| `--log-debug` | Integer | 0 | Nivel de debug (0=normal, 1=verbose, 2=muy verbose) |
| `--log-file` | Path | - | Archivo para guardar logs |
| `--log-max-size` | Bytes | 10485760 | Tamaño máximo del archivo de log (10MB por defecto) |
| `--log-backup-count` | Integer | 3 | Número de archivos de backup para logs |

### HTTP API

| Parámetro | Tipo | Valor por defecto | Descripción |
|-----------|------|-------------------|-------------|
| `--http-port` | Integer | 6878 | Puerto para la API HTTP |
| `--http-bind` | String | 127.0.0.1 | Dirección de escucha para HTTP API |

---

## Configuraciones Recomendadas

### Dispositivos de Baja Potencia

Configuración optimizada para dispositivos con recursos limitados (ej: Raspberry Pi, servidores con poca RAM, VPS básicas):

**Características:**
- Cache en memoria reducida
- Menos conexiones simultáneas
- Buffers más pequeños
- Menor uso de CPU

**Configuración Docker Compose:**

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

**Valores clave:**
- Cache live/VOD: 50MB cada uno
- Máx. conexiones: 100
- Máx. peers: 20
- Upload límite: 512 KB/s
- Buffer live: 10s
- Límite RAM: 512MB
- Límite CPU: 1 core

**Comando Docker directo:**

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

### Dispositivos de Alta Potencia

Configuración optimizada para servidores con buenos recursos (ej: servidores dedicados, VPS potentes, estaciones de trabajo):

**Características:**
- Cache en memoria amplia
- Máximo de conexiones y peers
- Buffers más grandes
- Sin límites de ancho de banda
- Optimizaciones de rendimiento activadas

**Configuración Docker Compose:**

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

**Valores clave:**
- Cache live/VOD: 500MB cada uno
- Máx. conexiones: 1000
- Máx. peers: 100
- Upload/Download: Sin límite
- Buffer live: 30s
- Buffer VOD: 15s
- Límite RAM: 2GB
- Límite CPU: 4 cores
- Optimizaciones de CPU activadas

**Comando Docker directo:**

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

## Consejos de Optimización

### Para mejorar el rendimiento de streaming:

1. **Aumenta el buffer live** si experimentas cortes frecuentes
2. **Reduce max-peers y max-connections** si tu ancho de banda es limitado
3. **Usa cache en memoria** siempre que sea posible para mejor rendimiento
4. **Limita el upload** si necesitas priorizar el download para reproducción

### Para reducir el uso de recursos:

1. **Reduce live-cache-size y vod-cache-size**
2. **Disminuye max-connections y max-peers**
3. **Aumenta los intervalos de verificación** (check-live-pos-interval, core-dlr-periodic-check-interval)
4. **Reduce log-max-size y log-backup-count**

### Para máxima estabilidad:

1. **Monta un volumen persistente** para el directorio de cache
2. **Establece restart: unless-stopped** en docker-compose
3. **Configura límites de recursos** apropiados (mem_limit, cpus)
4. **Monitorea los logs** regularmente para detectar problemas

---

## Volver a la Documentación Principal

- [README Principal](README_es.md)
- [README en Inglés](README.md)
