# Playwright MCP Server

This repository contains Docker configuration for running the Playwright MCP server with different browser modes.

## Overview

The Playwright MCP server provides browser automation capabilities to AI assistants like Claude Desktop. This setup provides both headless and VNC-enabled (visual) modes for different use cases.

## Modes Available

### 1. Headless Mode (Production)

-   No visual interface
-   Minimal resource usage
-   Perfect for production deployments
-   Postfix `-headless` to the image tag
-   Example: `ghcr.io/andrewjedawes/playwright-mcp-server:latest-headless`

### 2. VNC/Visual Mode (Debugging)

-   Visual browser interface via VNC
-   Great for debugging and development
-   Watch the browser in real-time
-   Postfix `-vnc` to the image tag
-   Example: `ghcr.io/andrewjedawes/playwright-mcp-server:latest-vnc`

## Running the MCP Server

### Headless Mode

```bash
docker run -i --rm ghcr.io/andrewjedawes/playwright-mcp-server:latest-headless
```

### Visual (VNC) Mode

To run in visual mode, use the `-vnc` image and expose both the MCP server and VNC ports:

```bash
docker run -i --rm -p 8931:8931 -p 5900:5900 ghcr.io/andrewjedawes/playwright-mcp-server:latest-vnc
```

#### Passing Arguments (e.g., --vision)

You can pass any Playwright MCP server arguments after the image name. For example, to enable visual mode with the `--vision` flag:

```bash
docker run -i --rm -p 8931:8931 -p 5900:5900 ghcr.io/andrewjedawes/playwright-mcp-server:latest-vnc --vision
```

Or to specify a different MCP port:

```bash
docker run -i --rm -p 9000:8931 -p 5900:5900 ghcr.io/andrewjedawes/playwright-mcp-server:latest-vnc --port 8931 --vision
```

## Environment Configuration

### For Cursor/Claude Desktop

Create an MCP server configuration:

VNC:

```json
{
	"playwright-mcp-server-vnc": {
		"command": "docker",
		"args": [
			"run",
			"-i",
			"--rm",
			"-p",
			"8931:8931",
			"-p",
			"5900:5900",
			"ghcr.io/andrewjedawes/playwright-mcp-server:latest-vnc"
		]
	}
}
```

Headless:

```json
{
	"playwright-mcp-server-headless": {
		"command": "docker",
		"args": [
			"run",
			"-i",
			"--rm",
			"ghcr.io/andrewjedawes/playwright-mcp-server:latest-headless"
		]
	}
}
```

### Passing Custom Arguments

To pass custom arguments (such as `--browser firefox` or `--vision`), include them directly in the `docker run` command after the image name.

Example:

```bash
docker run -i --rm -p 8931:8931 -p 5900:5900 ghcr.io/andrewjedawes/playwright-mcp-server:latest-vnc --vision --browser firefox
```

## VNC Access

When using VNC mode:

-   **URL**: `vnc://localhost:5900`
-   **Password**: `playwright`
-   **Resolution**: 1024x768

### VNC Clients:

-   **macOS**: Built-in Screen Sharing or TigerVNC
-   **Windows**: TigerVNC, RealVNC, or UltraVNC
-   **Linux**: Remmina, TigerVNC, or browser-based clients

## Connecting to the Server

The server should be connected to over streamable HTTP. For example, the `mcp.json` file includes the following configuration:

```json
{
	"servers": {
		"playwright-mcp-server-vnc": {
			"url": "http://localhost:8931/mcp"
		}
	}
}
```

Ensure that your server configuration follows a similar structure to enable proper connectivity.

## How It Works

1. **MCP Communication**: The container runs with `-i` flag for stdin/stdout communication
2. **Browser Session**: Playwright launches Chromium (or your selected browser) within the container
3. **VNC Access**: X11 forwarding allows you to see the browser in action
4. **Dual Mode**: Same MCP server, different visibility options

## Troubleshooting

**If you encounter issues:**

1. **Rebuild the images** to get the latest fixes:

    ```bash
    docker build -t ghcr.io/andrewjedawes/playwright-mcp-server:latest-vnc .
    docker build -t ghcr.io/andrewjedawes/playwright-mcp-server:latest-headless .
    ```

2. **Verify the container works**:

    ```bash
    docker run --rm ghcr.io/andrewjedawes/playwright-mcp-server:latest-headless npx playwright --version
    ```

### Browser Not Starting

```bash
# Check if the container is running
docker ps
# Check logs
docker logs <container_id>
```

Replace `<container_id>` with the actual container ID from `docker ps`.

### VNC Connection Issues

```bash
# Test VNC port
nc -zv localhost 5900
# Check if VNC server is running in container
docker exec <container_id> ps aux | grep vnc
```

Replace `<container_id>` with the actual container ID from `docker ps`.

## Architecture

```
MCP Client (Claude Desktop)
    ↓ (stdin/stdout)
Docker Container
    ├── MCP Server (Playwright CLI)
    ├── Playwright
    ├── Chromium/Other Browser
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
docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix playwright-mcp-server:latest

# macOS (with XQuartz)
xhost +localhost
docker run -it --rm -e DISPLAY=host.docker.internal:0 playwright-mcp-server:latest
```

## License
