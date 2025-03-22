# Docker cheat.sh
[![docker](https://img.shields.io/static/v1.svg?color=384d54&labelColor=0db7ed&logoColor=ffffff&label=Docker%20Hub&message=cheat.sh&logo=docker&style=for-the-badge)](https://hub.docker.com/r/nicholaswilde/cheat.sh)
[![task](https://img.shields.io/badge/Task-Enabled-brightgreen?style=for-the-badge&logo=task&logoColor=white)](https://taskfile.dev/#/)
[![ci](https://img.shields.io/github/actions/workflow/status/nicholaswilde/docker-cheat.sh/ci.yaml?label=ci&style=for-the-badge&branch=main)](https://github.com/nicholaswilde/docker-cheat.sh/actions/workflows/ci.yaml)

A repository for creating a Docker image for [cheat.sh][1]

---

## :framed_picture: Background

At the time of the creation of this repository, a Docker image did not exists for `cheat.sh` and so this repo pulls the
`cheat.sh` repo at a certain commit and builds a multi-platform Docker image.

The adapters are fetched on every run of the container, but because they're saved in a persistent volume, they don't
need to be updated every time.

---

## :classical_building: Architectures

* [x] `armv7`
* [x] `arm64`
* [x] `amd64`

---

## :pencil: Usage

```shell
docker run -d
  --name=cheatsh \
  -e CHEATSH_CACHE_TYPE=none `# optional` \
  -e CHEATSH_CACHE_REDIS_HOST=redis `# optional` \
  -p 8002:8002 \
  --restart unless-stopped \
  nicholaswilde/cheat.sh
```

If you don't plan to use Redis for caching, switch the caching off by setting `CHEATSH_CACHE_TYPE=none`.

Docker compose

```yaml
---
services:
  app:
    image: nicholaswilde/cheat.sh
    container_name: cheatsh
    depends_on:
      - redis
    environment:
      - CHEATSH_CACHE_REDIS_HOST=redis
      # - CHEATSH_CACHE_TYPE=none
    ports:
      - "8002:8002"
    volumes:
      - cheatsh_data:/root/.cheat.sh
    restart: always
  redis:
    image: redis:4-alpine
    volumes:
      - redis_data:/data
volumes:
  redis_data:
  cheatsh_data:
```

> [!NOTE]
> The adapters are stored in a persistent volume, `cheatsh_data`.

Update all adapters while the container is running.

```shell
docker exec -it cheatsh sh -c 'python3 /app/lib/fetch.py update-all'
```

Get a list of `tar` commands.

```shell
curl localhost:8002/tar
```
---

## :construction: Development

```shell
docker --build-args COMMIT=1234 build .
```

Where `COMMIT` is the latest commit from [`cheat.sh`][3].

---

## :balance_scale: License

​[​Apache License 2.0](../LICENSE)

---

## :pencil:​ Author

​This project was started in 2025 by [Nicholas Wilde][2].

## :link: References

- <https://github.com/chubin/cheat.sh/blob/master/doc/standalone.md>

[1]: <https://github.com/chubin/cheat.sh>
[2]: <https://github.com/nicholaswilde/>
[3]: <https://github.com/chubin/cheat.sh/commits/master/>
