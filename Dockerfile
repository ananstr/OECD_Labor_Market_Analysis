FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install system dependencies including curl for uv installation
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy project files
COPY pyproject.toml .
COPY main.py .
COPY *.csv .

# Install Python dependencies
RUN pip install --no-cache-dir -e .

# Run the application
CMD ["uv", "run", "main.py"]
