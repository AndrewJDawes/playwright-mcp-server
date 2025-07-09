#!/bin/bash

# Helper script to run browser-use MCP server in different modes

set -e

case "$1" in
headless)
    echo "Starting headless MCP server..."
    docker-compose run --rm browser-use-headless
    ;;
vnc)
    echo "Starting VNC-enabled MCP server..."
    echo "Access the browser at: http://localhost:5900 (password: browseruse)"
    docker-compose run --rm browser-use-vnc
    ;;
build)
    echo "Building both Docker images..."
    docker-compose build
    ;;
*)
    echo "Usage: $0 {headless|vnc|build}"
    echo ""
    echo "  headless - Run MCP server in headless mode (for production)"
    echo "  vnc      - Run MCP server with VNC access to browser (for debugging)"
    echo "  build    - Build both Docker images"
    exit 1
    ;;
esac
