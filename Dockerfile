FROM python:3.11-slim

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_INSTALL_DIR=/python \
    UV_PYTHON_PREFERENCE=only-managed

# Install build dependencies and clean up in the same layer
RUN apt-get update -y && \
    apt-get install --no-install-recommends -y clang git && \
    rm -rf /var/lib/apt/lists/*

# VNC password will be read from Docker secrets or fallback to default
# Create a fallback default password file
RUN mkdir -p /run/secrets && \
    echo "browser-use" > /run/secrets/vnc_password_default

# Install required packages including Chromium and clean up in the same layer
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    tigervnc-standalone-server \
    tigervnc-tools \
    nodejs \
    npm \
    fonts-freefont-ttf \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-thai-tlwg \
    fonts-kacst \
    fonts-symbola \
    fonts-noto-color-emoji && \
    npm i -g proxy-login-automator && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/*

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

ENV ANONYMIZED_TELEMETRY=false \
    PATH="/app/.venv/bin:$PATH" \
    DISPLAY=:0 \
    CHROME_BIN=/usr/bin/chromium \
    CHROMIUM_FLAGS="--no-sandbox --headless --disable-gpu --disable-software-rasterizer --disable-dev-shm-usage"

# Combine VNC setup commands to reduce layers
RUN mkdir -p ~/.vnc && \
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nstartxfce4' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup && \
    printf '#!/bin/bash\n\n# Use Docker secret for VNC password if available, else fallback to default\nif [ -f "/run/secrets/vnc_password" ]; then\n  cat /run/secrets/vnc_password | vncpasswd -f > /root/.vnc/passwd\nelse\n  cat /run/secrets/vnc_password_default | vncpasswd -f > /root/.vnc/passwd\nfi\n\nchmod 600 /root/.vnc/passwd\nvncserver -depth 24 -geometry 1920x1080 -localhost no -PasswordFile /root/.vnc/passwd :0\nproxy-login-automator\npython /app/server --port 8000' > /app/boot.sh && \
    chmod +x /app/boot.sh

RUN playwright install --with-deps --no-shell chromium

EXPOSE 8000

# Install uv
RUN pip install uv

# Set working directory
WORKDIR /app

# Install browser-use with CLI extras using pip instead of uv pip
RUN pip install "browser-use[cli]"

# Install Playwright browsers
RUN playwright install chromium
RUN playwright install-deps chromium

# Create a non-root user for security
RUN useradd -m -s /bin/bash browseruse
USER browseruse

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV BROWSER_USE_HEADLESS=true

# Expose any ports if needed (MCP typically uses stdin/stdout)
# No specific port needed for MCP server mode

# Run the browser-use MCP server
CMD ["python", "-m", "browser_use.cli", "--mcp"]
