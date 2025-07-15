FROM node:20-bullseye AS base

# Install common system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Playwright globally so CLI is available
RUN npm install -g playwright

# Install Playwright system dependencies as root
RUN playwright install-deps chromium

# Create a non-root user for security
RUN useradd -m -s /bin/bash playwright

# Switch to playwright user and install Playwright browsers
USER playwright
RUN playwright install chromium

# Switch back to root for configuration
USER root

# =======================================================
# HEADLESS MODE
# =======================================================
FROM base AS headless

# Set environment variables for headless mode
ENV PYTHONUNBUFFERED=1
ENV BROWSER_USE_HEADLESS=true

# Switch to playwright user for running the server
USER playwright

# Use ENTRYPOINT and CMD to allow argument overrides
ENTRYPOINT ["npx", "@playwright/mcp@latest", "--browser", "chromium", "--port", "8931"]
CMD ["--headless"]

# =======================================================
# VNC MODE
# =======================================================
FROM base AS vnc

# Install additional VNC-specific dependencies
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    fluxbox \
    tigervnc-standalone-server \
    && rm -rf /var/lib/apt/lists/*

# Set up VNC for root user
RUN mkdir -p /root/.vnc && \
    echo 'playwright' | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Set environment variables for VNC mode
ENV DISPLAY=:99

# Create startup script
RUN echo '#!/bin/bash\n\
    # Start Xvfb\n\
    Xvfb :99 -screen 0 1024x768x24 &\n\
    sleep 2\n\
    # Start window manager\n\
    fluxbox &\n\
    # Start VNC server\n\
    x11vnc -display :99 -forever -passwd playwright &\n\
    # Give VNC time to start\n\
    sleep 2\n\
    # Switch to playwright user and start MCP server\n\
    su -c "cd /app && npx @playwright/mcp@latest --port 8931 --browser chromium $@" playwright\n\
    ' > /start.sh && chmod +x /start.sh

# Expose VNC port
EXPOSE 5900

# Run the startup script
ENTRYPOINT ["/start.sh"]
CMD []
