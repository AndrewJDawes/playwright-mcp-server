# Browser-Use MCP Server

This repository contains Docker configuration for running the browser-use MCP server with different browser modes.

## Overview

The browser-use MCP server provides browser automation capabilities to AI assistants like Claude Desktop. This setup provides both headless and VNC-enabled modes for different use cases.

## Modes Available

### 1. Headless Mode (Production)

-   No visual interface
-   Minimal resource usage
-   Perfect for production deployments
-   Built with `docker build --target headless -t browser-use-mcp-server:latest .`

### 2. VNC Mode (Debugging)

-   Visual browser interface via VNC
-   Great for debugging and development
-   Watch the browser in real-time
-   Built with `docker build --target vnc -t browser-use-mcp-vnc:latest .`

## Quick Build

Use the provided build script to build both images:

```bash
./build.sh
```

## Environment Configuration

### For Cursor/Claude Desktop

Create an MCP server configuration:

```json
{
	"browser-use": {
		"command": "docker",
		"args": [
			"run",
			"-i",
			"--rm",
			"-e",
			"GOOGLE_API_KEY",
			"browser-use-mcp-server:latest"
		],
		"env": {
			"GOOGLE_API_KEY": "your_google_api_key_here"
		}
	}
}
```

Cursor:

```json
{
	"mcpServers": {
		"browser-use-debug2": {
			"command": "docker",
			"args": [
				"run",
				"-i",
				"--rm",
				"-p",
				"5900:5900",
				"-e",
				"GOOGLE_API_KEY=YOUR_API_KEY",
				"browser-use-mcp-vnc:latest"
			],
			"env": {
				"GOOGLE_API_KEY": "YOUR_API_KEY"
			}
		}
	}
}
```

### Environment Variables

-   `DISPLAY`: X11 display for VNC mode (automatically set)

## VNC Access

When using VNC mode:

-   **URL**: `vnc://localhost:5900`
-   **Password**: `browseruse`
-   **Resolution**: 1024x768

### VNC Clients:

-   **macOS**: Built-in Screen Sharing or TigerVNC
-   **Windows**: TigerVNC, RealVNC, or UltraVNC
-   **Linux**: Remmina, TigerVNC, or browser-based clients

## How It Works

1. **MCP Communication**: The container runs with `-i` flag for stdin/stdout communication
2. **Browser Session**: Playwright launches Chromium within the container
3. **VNC Access**: X11 forwarding allows you to see the browser in action
4. **Dual Mode**: Same MCP server, different visibility options

## Troubleshooting

**If you encounter issues:**

1. **Rebuild the images** to get the latest fixes:

2. **Verify the container works**:

    ```bash
    docker run --rm browser-use-mcp-server:latest python -c "from browser_use import BrowserSession; print('Browser-use working!')"
    ```

### Browser Not Starting

```bash
# Check if the container is running
docker ps
# Check logs
docker logs browser-use-mcp-vnc
```

### VNC Connection Issues

```bash
# Test VNC port
nc -zv localhost 5900
# Check if VNC server is running in container
docker exec browser-use-mcp-vnc ps aux | grep vnc
```

## Architecture

```
MCP Client (Claude Desktop)
    ↓ (stdin/stdout)
Docker Container
    ├── MCP Server (browser-use CLI)
    ├── Playwright
    ├── Chromium Browser
    └── VNC Server (optional)
        ↓ (port 5900)
VNC Client (for debugging)
```

## Use Cases

**Headless Mode:**

-   Production MCP server
-   Automated workflows
-   Resource-constrained environments

**VNC Mode:**

-   Debugging browser automation
-   Development and testing
-   Visual verification of browser actions
-   Demonstrating browser capabilities

## Alternatives

### Option 3: X11 Forwarding (Linux/macOS)

```bash
# Linux
docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix browser-use-mcp-server:latest

# macOS (with XQuartz)
xhost +localhost
docker run -it --rm -e DISPLAY=host.docker.internal:0 browser-use-mcp-server:latest
```
