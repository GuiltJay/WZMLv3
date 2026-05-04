# syntax=docker/dockerfile:1.5

FROM mysterysd/wzmlx:latest

# ---- Env (clean + fast pip) ----
ENV PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /usr/src/app

# ---- Copy only requirements first (cache layer) ----
COPY requirements.txt .

# ---- System dependencies (rarely changes → cached) ----
RUN apt-get update && apt-get install -y \
    mediainfo \
    libmediainfo-dev \
    ffmpeg \
    aria2 \
    git \
    curl \
    libmagic1 \
    libxml2-dev \
    libxslt1-dev \
    gcc \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ---- Upgrade pip tools ----
RUN pip3 install --upgrade pip setuptools wheel

# ---- Install heavy deps first (better caching) ----
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install lxml cryptography uvloop yt-dlp

# ---- Install remaining deps (cached) ----
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# ---- Copy app (only this layer rebuilds frequently) ----
COPY . .

# ---- Create non-root user ----
RUN useradd -m appuser && chown -R appuser:appuser /usr/src/app
USER appuser

# ---- Ports ----
EXPOSE 80 8080

# ---- Healthcheck ----
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD pgrep -f "python|gunicorn" || exit 1

# ---- Start ----
CMD ["bash", "start.sh"]
