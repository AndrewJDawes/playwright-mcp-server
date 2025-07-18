#!/bin/bash
set -x
# docker run -i --rm -p 8931:8931 -p 5902:5900 playwright-mcp-server:test --vision
docker build -t playwright-mcp-server:test .
docker network create docker_local_dev_playwright_network || true
docker run -i --rm --name playwright -p 1162:8931 -p 1163:5900 --network docker_local_dev_playwright_network playwright-mcp-server:test
