# syntax=docker/dockerfile:1.5

FROM mysterysd/wzmlx:latest

ENV PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /usr/src/app

# ---- Copy only requirements first (cache layer) ----
COPY requirements.txt .

# ---- Minimal system deps (FAST) ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    mediainfo \
    ffmpeg \
    aria2 \
    libmagic1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ---- Upgrade pip ----
RUN pip install --upgrade pip setuptools wheel

# ---- Use pip cache (HUGE speed boost) ----
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# ---- Copy app last (avoids reinstalling deps) ----
COPY . .

# ---- Non-root user ----
RUN useradd -m appuser && chown -R appuser:appuser /usr/src/app
USER appuser

EXPOSE 80 8080

CMD ["bash", "start.sh"]
