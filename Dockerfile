FROM alpine:3.14 AS dl
WORKDIR /tmp
ARG FILENAME="139f8c2fb348a7028a9bac5474ca20ea00b13543.tar.gz"
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    wget=1.21.1-r1 && \
  echo "**** download cheat.sh ****" && \
  mkdir /app && \
  wget "https://github.com/chubin/cheat.sh/archive/${FILENAME}" && \
  tar -xvf "${FILENAME}" -C /app --strip-components 1
WORKDIR /app

FROM alpine:3.14 AS builder
# https://rodneyosodo.medium.com/minimizing-python-docker-images-cf99f4468d39
RUN \
  echo "**** install packages ****" && \
  apk add --update --no-cache \
    git=2.32.7-r0 \
    sed=4.8-r0 \
    libstdc++ \
    pkgconf \
    py3-icu \
    py3-six \
    py3-pygments \
    py3-yaml \
    py3-gevent \
    py3-colorama \
    py3-requests \
    py3-redis

WORKDIR /app

# COPY . /app

COPY --from=dl /app /app
COPY ./entrypoint.sh /app/entrypoint.sh
COPY ./requirements-mod.txt /app/requirements-mod.txt

RUN \
  echo "**** update source files ****" && \
  sed -i 's/python-Levenshtein/python-Levenshtein==0.12.2/g' ./requirements.txt && \
  cat ./requirements-mod.txt >> ./requirements.txt

RUN \
  echo "**** build missing python packages ****" && \
  apk add --no-cache --virtual \
    build-deps \
    py3-pip \
    g++ \
    python3-dev \
    libffi-dev && \
  pip3 install --no-cache-dir --upgrade pygments && \
  pip3 install --no-cache-dir -r requirements.txt && \
  pip3 install --no-cache-dir git+https://github.com/aboSamoor/pycld2.git && \
  mkdir -p /root/.cheat.sh/log/

RUN \
  echo "**** install server dependencies ****" && \
  apk add --update --no-cache \
    py3-jinja2 \
    py3-flask \
    bash \
    gawk && \
  echo "**** cleanup ****" && \
  apk del build-deps g++ && \
  rm -rf \
    /app/Dockerfile \
    /app/requirements-mod.txt &&\
  rm -rf /var/cache/apk/* * && \
  rm -rf /tmp/*

VOLUME ["/app/etc/"]
VOLUME ["/root/.cheat.sh/"]

ENTRYPOINT ["/app/entrypoint.sh"]
CMD [""]
