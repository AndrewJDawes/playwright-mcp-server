#!/bin/bash

# Setup script for browser-use MCP server

set -e

echo "Setting up browser-use MCP server..."

# Build the images
echo "Building headless image..."
docker build -t browser-use-mcp-server:latest .

echo "Building VNC image..."
docker build -f Dockerfile.vnc -t browser-use-mcp-vnc:latest .

# Create environment file from template
if [ ! -f .env ]; then
    cp env.template .env
    echo "Created .env file from template - please edit with your API keys"
fi

echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your API keys"
echo "2. Choose configuration:"
echo "   - mcp-config.json (production/headless)"
echo "   - mcp-config-debug.json (debug/VNC)"
echo "3. Use the config in your MCP client (Claude Desktop, Cursor, etc.)"
echo ""
echo "For VNC debug mode, connect to localhost:5900 with password 'browseruse'"
