# syntax = docker/dockerfile:experimental
ARG FLAVOR=bullseye
FROM debian:${FLAVOR} AS stage0

COPY imagedate.txt /

RUN --mount=type=cache,id=stage0-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=stage0-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y debootstrap && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN mkdir /debian
ARG FLAVOR=bullseye
RUN --mount=type=cache,id=stage0-debootstrap-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=stage0-debootstrap-apt-lib,sharing=locked,target=/var/lib/apt \
    debootstrap --variant=minbase --include=debootstrap ${FLAVOR} /debian http://deb.debian.org/debian/

FROM scratch AS stage1

COPY imagedate.txt /

COPY --from=stage0 /debian /
CMD ["/bin/bash"]

RUN mkdir /debian
ARG FLAVOR=bullseye
RUN --mount=type=cache,id=stage1-debootstrap-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=stage1-debootstrap-apt-lib,sharing=locked,target=/var/lib/apt \
    debootstrap \
    --include=build-essential,curl,wget,apt-transport-https,ruby,bundler,ruby-foreman,file,neovim,gzip,nodejs,git,postgresql-client,libsqlite3-0,libssl-dev,zlib1g-dev \
    ${FLAVOR} /debian http://deb.debian.org/debian/

FROM scratch AS debian-base

COPY imagedate.txt /

COPY --from=stage1 /debian /
CMD ["/bin/bash"]