#!/bin/bash
# docker run -i --rm -p 8931:8931 -p 5902:5900 playwright-mcp-server:test --vision
docker build -t playwright-mcp-server:test .
docker run -i --rm -p 8931:8931 -p 5902:5900 playwright-mcp-server:test
