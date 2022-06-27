.PHONY: all
all: bullseye.tar.gz bookworm.tar.gz

imagedate.txt:
	date -Iseconds > imagedate.txt

bullseye.tar.gz: imagedate.txt Dockerfile
	docker build -t ghcr.io/lutriseng/debian-base/bullseye --build-arg FLAVOR=bullseye .
	docker save -o bullseye.tar.gz ghcr.io/lutriseng/debian-base/bullseye

bookworm.tar.gz: imagedate.txt Dockerfile
	docker build -t ghcr.io/lutriseng/debian-base/bookworm --build-arg FLAVOR=bookworm .
	docker save -o bookworm.tar.gz ghcr.io/lutriseng/debian-base/bookworm
