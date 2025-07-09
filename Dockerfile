FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install uv

# Set working directory
WORKDIR /app

# Install browser-use with CLI extras using pip instead of uv pip
RUN pip install "browser-use[cli]"

# Install Playwright system dependencies as root
RUN playwright install-deps chromium

# Create a non-root user for security
RUN useradd -m -s /bin/bash browseruse

# Switch to browseruse user and install Playwright browsers
USER browseruse
RUN playwright install chromium

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV BROWSER_USE_HEADLESS=true

# Run the browser-use MCP server
CMD ["python", "-m", "browser_use.cli", "--mcp"]
