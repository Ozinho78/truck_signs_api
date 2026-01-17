FROM python:3.10-slim

# Dependencies installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    libpq-dev \
    python3-dev \
    libffi-dev \
    libssl-dev \
    libjpeg-dev \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    libtiff5-dev \
    libopenjp2-7-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Non-root User
RUN groupadd -r django && useradd -r -g django django

WORKDIR /app

# Python Dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Application Code kopieren
COPY . /app/

# Permissions
RUN chown -R django:django /app && \
    mkdir -p /app/staticfiles && \
    chown -R django:django /app/staticfiles && \
    chmod +x /app/entrypoint.sh

USER django

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/admin/', timeout=5)" || exit 1

# Nur ENTRYPOINT, kein CMD - alles im entrypoint.sh!
ENTRYPOINT ["/app/entrypoint.sh"]
