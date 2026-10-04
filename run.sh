#!/usr/bin/env bash
set -e

docker rm -f krasivina-01-web krasivina-01-db 2>/dev/null || true

docker build \
  --build-arg VERSION=2.0 \
  -t krasivina-01/probe:2.0 .

docker volume create krasivina-01-data

docker run -d \
  --name krasivina-01-db \
  -e POSTGRES_PASSWORD=lab \
  -e POSTGRES_DB=lab \
  -p 8005:5432 \
  -v krasivina-01-data:/var/lib/postgresql/data \
  postgres:16-alpine

docker run -d \
  --name krasivina-01-web \
  -p 8003:5001 \
  --add-host host.docker.internal:host-gateway \
  -e DATABASE_URL=postgresql://postgres:lab@host.docker.internal:8005/lab \
  krasivina-01/probe:2.0

SECONDS=0
until curl -sf -m 3 localhost:8003/notes > /dev/null || [ $SECONDS -ge 60 ]; do
  sleep 2
done

curl -s localhost:8003/notes
echo