# Troubleshooting Guide

## Common Issues and Solutions

### 1. Chromium Not Found Error

**Error:**

```
Error: [Errno 2] No such file or directory: '/home/browseruse/.cache/ms-playwright/chromium-1179/chrome-linux/chrome'
```

**Cause:** Playwright browsers were installed as root user, but the MCP server runs as the `browseruse` user who can't access the root user's cache.

**Solution:** Install Playwright system dependencies as root, then install browsers as the `browseruse` user:

```dockerfile
# Install system dependencies as root
RUN playwright install-deps chromium

# Create user
RUN useradd -m -s /bin/bash browseruse

# Install browsers as browseruse user
USER browseruse
RUN playwright install chromium
```

### 2. Verification Commands

Test if the Docker container works properly:

```bash
# Test browser-use import
docker run --rm browser-use-mcp-server:latest python -c "from browser_use import BrowserSession; print('Browser-use imported successfully')"

# Test Playwright chromium path
docker run --rm browser-use-mcp-server:latest python -c "from playwright.sync_api import sync_playwright; p = sync_playwright().start(); print('Playwright chromium path:', p.chromium.executable_path); p.stop()"

# Test chromium executable exists
docker run --rm browser-use-mcp-server:latest ls -la /home/browseruse/.cache/ms-playwright/chromium-1179/chrome-linux/chrome

# Test browser session
docker run --rm browser-use-mcp-server:latest python -c "
import asyncio
from browser_use import BrowserSession
async def test():
    session = BrowserSession()
    await session.start()
    await session.stop()
    print('Browser session started and stopped successfully!')
asyncio.run(test())
"
```

### 3. Building the Images

Build both versions:

```bash
# Build headless version
docker build -t browser-use-mcp-server:latest -f Dockerfile .

# Build VNC version
docker build -t browser-use-mcp-vnc:latest -f Dockerfile.vnc .

# Or use the helper script
./setup-mcp.sh
```

### 4. Testing the MCP Server

Test the MCP server interactively:

```bash
# Headless mode
docker run -it --rm browser-use-mcp-server:latest

# VNC mode (in another terminal)
docker run -it --rm -p 5900:5900 browser-use-mcp-vnc:latest
# Then connect to vnc://localhost:5900 with password: browseruse
```

### 5. MCP Configuration

Use the correct configuration for your MCP client:

**Production (headless):**

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

**Debug (VNC):**

```json
{
	"browser-use-debug": {
		"command": "docker",
		"args": [
			"run",
			"-i",
			"--rm",
			"-p",
			"5900:5900",
			"-e",
			"GOOGLE_API_KEY",
			"browser-use-mcp-vnc:latest"
		],
		"env": {
			"GOOGLE_API_KEY": "your_google_api_key_here"
		}
	}
}
```

### 6. Permission Issues

If you encounter permission issues:

```bash
# Check user in container
docker run --rm browser-use-mcp-server:latest whoami

# Check chromium ownership
docker run --rm browser-use-mcp-server:latest ls -la /home/browseruse/.cache/ms-playwright/chromium-1179/chrome-linux/chrome
```

### 7. VNC Connection Issues

For VNC debugging:

```bash
# Check if VNC port is exposed
docker run --rm -p 5900:5900 browser-use-mcp-vnc:latest netstat -tlnp

# Connect with VNC client
# macOS: open vnc://localhost:5900
# Windows: Use TigerVNC or similar
# Linux: vncviewer localhost:5900
```

## Fixed Issues

✅ **Chromium installation path issue** - Fixed by installing system deps as root, browsers as user
✅ **User permissions** - browseruse user can now access chromium
✅ **VNC password setup** - Now uses tigervnc-standalone-server
✅ **Docker layer optimization** - Proper order of operations

## Status

Both Docker containers are now working correctly:

-   Headless version: Ready for production MCP usage
-   VNC version: Ready for debugging and development

The browser-use MCP server can now successfully:

-   Start browser sessions
-   Navigate to websites
-   Interact with web elements
-   Extract content from pages
-   Manage tabs and windows
