# Configuración de Red y P2P en Acestream

Esta guía explica la configuración de puertos, UPNP y opciones de red para optimizar la conectividad P2P de Acestream.

## Índice

- [Puertos Utilizados](#puertos-utilizados)
- [Puerto P2P 8621](#puerto-p2p-8621)
- [UPNP (Universal Plug and Play)](#upnp-universal-plug-and-play)
- [Configuraciones de Red en Docker](#configuraciones-de-red-en-docker)
- [Firewall y Port Forwarding](#firewall-y-port-forwarding)

---

## Puertos Utilizados

Acestream utiliza dos puertos principales:

| Puerto | Protocolo | Propósito | Necesario |
|--------|-----------|-----------|-----------|
| **6878** | TCP/HTTP | API HTTP para control y reproducción | ✅ Obligatorio |
| **8621** | TCP/UDP | Conexiones P2P BitTorrent | ⚠️ Recomendado |

---

## Puerto P2P 8621

### ¿Qué es?

El puerto **8621** es el puerto por defecto que usa Acestream para las **conexiones peer-to-peer (P2P)** del protocolo BitTorrent. Es diferente del puerto 6878 que es únicamente para la API HTTP.

### ¿Por qué es importante?

| Puerto 8621 CERRADO | Puerto 8621 ABIERTO |
|---------------------|---------------------|
| ❌ Solo conexiones salientes (outgoing) | ✅ Conexiones entrantes y salientes |
| ❌ Menos peers disponibles | ✅ Más peers disponibles |
| ❌ Rendimiento reducido | ✅ Mejor rendimiento |
| ❌ Actúas solo como "leecher" | ✅ Actúas como "seeder" completo |
| ❌ Streams lentos o con cortes | ✅ Streams fluidos |

### Parámetro relacionado

```bash
--port 8621  # Define el puerto P2P (8621 es el valor por defecto)
```

---

## UPNP (Universal Plug and Play)

### ¿Qué es UPNP?

UPNP es un protocolo que permite a las aplicaciones **abrir puertos automáticamente** en tu router sin necesidad de configuración manual.

### Cómo funciona

1. ✅ Acestream detecta tu router compatible con UPNP
2. ✅ Solicita al router que abra el puerto 8621 automáticamente
3. ✅ El router crea una regla de port forwarding temporal
4. ✅ Ahora puedes recibir conexiones P2P entrantes

### Problema con Docker

⚠️ **UPNP NO funciona dentro de contenedores Docker** por defecto porque:

- El contenedor está en una red virtual aislada (bridge)
- UPNP necesita acceso directo a la interfaz de red del host
- El contenedor no puede "ver" tu router físico
- Los paquetes UPNP no atraviesan el bridge de Docker

### Solución: Network Mode Host

Para que UPNP funcione, debes usar `network_mode: host`:

```yaml
services:
  acestream:
    image: jopsis/acestream:x64
    network_mode: host  # Usa la red del host directamente
    restart: unless-stopped
    environment:
      - ACESTREAM_ARGS=--client-console --bind-all --port 8621
    volumes:
      - acestream-data:/acestream/.ACEStream

volumes:
  acestream-data:
```

**Ventajas:**
- ✅ UPNP funciona automáticamente
- ✅ Mejor rendimiento de red
- ✅ No necesitas mapear puertos manualmente

**Desventajas:**
- ⚠️ El contenedor comparte toda la red del host
- ⚠️ Menos aislamiento de red
- ⚠️ No puedes cambiar los puertos (siempre serán 6878 y 8621)

---

## Configuraciones de Red en Docker

### Opción 1: Network Host (Recomendado para UPNP)

**Mejor para:** Servidores dedicados, VPS, home servers con router UPNP

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

**Comando Docker:**
```bash
docker run -d \
  --name acestream \
  --network host \
  -v acestream-data:/acestream/.ACEStream \
  -e ACESTREAM_ARGS="--client-console --bind-all --port 8621" \
  jopsis/acestream:x64
```

---

### Opción 2: Port Mapping + Port Forwarding Manual (Recomendado por defecto)

**Mejor para:** Máxima compatibilidad y control

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

**Pasos adicionales:**
1. Configura port forwarding en tu router: `8621 → IP_de_tu_servidor`
2. Verifica que el firewall permita el puerto 8621

**Comando Docker:**
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

### Opción 3: Solo API HTTP (Sin P2P entrante)

**Mejor para:** Testing, uso simple, recursos limitados

```yaml
version: '3.8'

services:
  acestream:
    image: jopsis/acestream:x64
    container_name: acestream
    ports:
      - "6878:6878"  # Solo API HTTP
    restart: unless-stopped
    volumes:
      - acestream-data:/acestream/.ACEStream

volumes:
  acestream-data:
```

**Características:**
- ⚠️ Solo conexiones P2P salientes
- ⚠️ Rendimiento reducido
- ✅ Más simple de configurar
- ✅ Funciona detrás de NAT sin configuración

---

## Firewall y Port Forwarding

### Configurar Firewall (Linux/VPS)

**UFW (Ubuntu/Debian):**
```bash
# Permitir puerto API HTTP
sudo ufw allow 6878/tcp

# Permitir puerto P2P
sudo ufw allow 8621/tcp
sudo ufw allow 8621/udp

# Verificar reglas
sudo ufw status
```

**Firewalld (RHEL/CentOS):**
```bash
# Permitir puertos
sudo firewall-cmd --permanent --add-port=6878/tcp
sudo firewall-cmd --permanent --add-port=8621/tcp
sudo firewall-cmd --permanent --add-port=8621/udp

# Recargar firewall
sudo firewall-cmd --reload
```

**iptables:**
```bash
# API HTTP
sudo iptables -A INPUT -p tcp --dport 6878 -j ACCEPT

# P2P
sudo iptables -A INPUT -p tcp --dport 8621 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 8621 -j ACCEPT

# Guardar reglas
sudo iptables-save > /etc/iptables/rules.v4
```

### Port Forwarding en Router (Uso doméstico)

Para mejorar el rendimiento P2P, configura port forwarding en tu router:

1. Accede a la interfaz web de tu router (usualmente `192.168.1.1` o `192.168.0.1`)
2. Busca la sección de "Port Forwarding" o "Virtual Server"
3. Crea una nueva regla:
   - **Puerto externo:** 8621
   - **Puerto interno:** 8621
   - **Protocolo:** TCP y UDP
   - **IP destino:** IP local de tu servidor (ej: 192.168.1.100)
4. Guarda y aplica los cambios

### Verificar conectividad P2P

**Desde dentro del contenedor:**
```bash
docker exec -it acestream netstat -tuln | grep 8621
```

**Desde otro equipo en tu red local:**
```bash
# Verificar si el puerto está abierto
nc -zv IP_DEL_SERVIDOR 8621

# O con telnet
telnet IP_DEL_SERVIDOR 8621
```

**Desde Internet (si tienes IP pública):**
- Usa herramientas online como: https://www.yougetsignal.com/tools/open-ports/
- Ingresa tu IP pública y el puerto 8621

---

## Comparativa de Configuraciones

| Configuración | UPNP | P2P Entrante | Complejidad | Rendimiento | Recomendado para |
|---------------|------|--------------|-------------|-------------|------------------|
| **Network Host** | ✅ Sí | ✅ Sí | ⭐ Baja | ⭐⭐⭐ Alto | Servidores dedicados, VPS |
| **Port Mapping + Manual Forwarding** | ❌ No | ✅ Sí | ⭐⭐ Media | ⭐⭐⭐ Alto | Uso doméstico, control total |
| **Solo API HTTP** | ❌ No | ❌ No | ⭐ Muy baja | ⭐ Básico | Testing, recursos limitados |

---

## Parámetros de Red en Acestream

Parámetros relacionados con la configuración de red:

```bash
--port 8621                              # Puerto P2P (por defecto 8621)
--http-port 6878                         # Puerto API HTTP (por defecto 6878)
--bind-all                               # Escucha en todas las interfaces (0.0.0.0)
--max-connections 500                    # Máximo de conexiones simultáneas
--max-peers 50                           # Máximo de peers por torrent
--download-limit 0                       # Límite de descarga (0=ilimitado)
--upload-limit 0                         # Límite de subida (0=ilimitado)
--webrtc-allow-outgoing-connections 1    # Conexiones WebRTC salientes
```

---

## Solución de Problemas

### Problema: "No hay peers disponibles"

**Posibles causas:**
1. Puerto 8621 bloqueado por firewall
2. Port forwarding no configurado en router
3. ISP bloqueando tráfico P2P

**Solución:**
```bash
# Verificar que el puerto está expuesto en Docker
docker port acestream

# Verificar firewall
sudo ufw status

# Probar con network_mode: host
```

### Problema: "Streaming lento con muchos cortes"

**Solución:**
1. Abre el puerto 8621 en firewall y router
2. Aumenta `--max-peers` y `--max-connections`
3. Aumenta el buffer: `--live-buffer 30`
4. Usa configuración de red host si es posible

### Problema: "UPNP no funciona"

**Solución:**
1. Verifica que tu router tenga UPNP habilitado
2. Usa `network_mode: host` en docker-compose
3. Alternativamente, configura port forwarding manual

---

## Volver a la Documentación Principal

- [Configuración Avanzada](CONFIGURACION.md)
- [README Principal](README_es.md)
- [English Network Documentation](NETWORK.md)
