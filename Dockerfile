FROM python:3.10-bookworm

# Instalar dependencias del sistema necesarias para Acestream
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio para Acestream
RUN mkdir -p /acestream

# Descargar y descomprimir Acestream
RUN wget -O /tmp/acestream.tar.gz https://download.acestream.media/linux/acestream_3.2.11_ubuntu_22.04_x86_64_py3.10.tar.gz && \
    tar -xzf /tmp/acestream.tar.gz -C /acestream && \
    rm /tmp/acestream.tar.gz

# Instalar dependencias de Python desde requirements.txt
WORKDIR /acestream
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

# Crear directorio de cache
RUN mkdir -p /acestream/.ACEStream

# Exponer puertos de Acestream
EXPOSE 6878  # API HTTP
EXPOSE 8621  # P2P BitTorrent

# Healthcheck para verificar que el servicio está funcionando
HEALTHCHECK CMD wget -q -t1 -O- 'http://127.0.0.1:6878/webui/api/service?method=get_version' | grep '"error": null'

# Definir los parámetros de inicio como variable de entorno
# ENV ACESTREAM_ARGS="--client-console --bind-all --service-remote-access --access-token acestream --service-access-token root --stats-report-peers --live-cache-type memory --live-cache-size 209715200 --vod-cache-type memory --cache-dir /acestream/.ACEStream --vod-drop-max-age 120 --max-file-size 2147483648 --live-buffer 25 --vod-buffer 10 --max-connections 500 --max-peers 50 --max-upload-slots 50 --auto-slots 0 --download-limit 0 --upload-limit 0 --stats-report-interval 2 --stats-report-peers --slots-manager-use-cpu-limit 1 --core-skip-have-before-playback-pos 1 --core-dlr-periodic-check-interval 5 --check-live-pos-interval 5 --refill-buffer-interval 1 --webrtc-allow-outgoing-connections 1 --allow-user-config --log-debug 0 --log-max-size 15000000 --log-backup-count 1"

ENV ACESTREAM_ARGS="--client-console --bind-all "

# Comando para iniciar el motor de Acestream con los parámetros
CMD /bin/sh -c "/acestream/start-engine ${ACESTREAM_ARGS}"
