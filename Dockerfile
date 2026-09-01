FROM eclipse-temurin:21-jdk-jammy

# Install everything start.sh needs: curl (jar/node download), git (webpo-generator
# clone), and Node.js/npm (webpo-generator runtime). Installing node here means
# start.sh's own "node not found, download a portable runtime" fallback block
# is skipped entirely, since it checks `command -v node` first.
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl \
      git \
      ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
RUN chmod +x start.sh

# Railway assigns a dynamic port via $PORT; Spring Boot (Lavalink) reads
# SERVER_PORT automatically, so we forward it. Falls back to 2333 if unset
# (e.g. running this image outside Railway).
ENV PORT=2333
EXPOSE 2333

CMD ["sh", "-c", "SERVER_PORT=${PORT:-2333} sh start.sh"]
