FROM alpine:3.14 AS dl
WORKDIR /tmp
ARG COMMIT="139f8c2fb348a7028a9bac5474ca20ea00b13543"
ARG FILENAME="${COMMIT}.tar.gz"
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

WORKDIR /app

COPY --from=dl /app/etc/ /app/etc
COPY --from=dl /app/lib/ /app/lib
COPY --from=dl /app/bin/ /app/bin
COPY --from=dl /app/share/ /app/share
COPY --from=dl /app/requirements.txt /app/requirements.txt
COPY entrypoint.sh .
COPY requirements-mod.txt /app/requirements-mod.txt

RUN \
  echo "**** update source files ****" && \
    sed -i 's/python-Levenshtein/python-Levenshtein==0.12.2/g' ./requirements.txt && \
    cat ./requirements-mod.txt >> ./requirements.txt && \
  echo "**** install packages ****" && \
  apk add --update --no-cache \
    git=2.32.7-r0 \
    sed=4.8-r0 \
    libstdc++=10.3.1_git20210424-r2 \
    pkgconf=1.7.4-r1 \
    py3-icu=2.6-r1 \
    py3-six=1.15.0-r1 \
    py3-pygments=2.9.0-r0 \
    py3-yaml=5.4.1.1-r1 \
    py3-gevent=21.1.2-r1 \
    py3-requests=2.25.1-r4 \
    py3-redis=3.2.1-r3 \
    py3-colorama=0.4.4-r1 && \
  echo "**** install server dependencies ****" && \
  apk add --update --no-cache \
    py3-jinja2=3.0.1-r0 \
    py3-flask=2.0.1-r0 \
    bash=5.1.16-r0 \
    gawk=5.1.0-r0 && \
  echo "**** build missing python packages ****" && \
  apk add --no-cache --virtual \
    build-deps \
    py3-pip \
    g++ \
    python3-dev \
    libffi-dev && \
  pip3 install --no-cache-dir --upgrade pygments && \
  pip3 install --no-cache-dir -r requirements.txt && \
  mkdir -p /root/.cheat.sh/log/ && \
  echo "**** cleanup ****" && \
    apk del build-deps g++ && \
  rm -rf /var/cache/apk/* && \
  rm -rf /tmp/*

# VOLUME ["/app/etc/"]
VOLUME ["/root/.cheat.sh/"]
RUN chmod 755 /app/entrypoint.sh
ENTRYPOINT ["sh", "/app/entrypoint.sh"]
CMD [""]
