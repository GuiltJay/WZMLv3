FROM mysterysd/wzmlx:latest

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

COPY requirements.txt .

RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install "setuptools_scm<9"
RUN pip3 install flit_core build

RUN apt-get update && apt-get install -y \
    mediainfo libmediainfo-dev \
    ffmpeg \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --no-build-isolation -r requirements.txt

COPY . .

CMD ["bash", "start.deps
