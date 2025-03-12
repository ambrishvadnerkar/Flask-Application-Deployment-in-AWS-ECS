# Stage 1: Build dependencies using python:3.9-slim
FROM python:3.12-slim AS builder

# Set environment variables for security and performance
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=100

# Install dependencies required for compilation
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc python3-dev libffi-dev libssl-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy only requirements file first (better caching)
COPY requirements.txt . 

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Use a lightweight Python base image
FROM python:3.12-slim

# Create a non-root user
RUN addgroup --system appuser && adduser --system --ingroup appuser appuser

# Set the working directory
WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application files
COPY . .

# Set permissions
RUN chown -R appuser:appuser /app && chmod -R 755 /app

# Switch to non-root user
USER appuser

# Expose only necessary ports
EXPOSE 5000

# Use exec form for CMD to prevent zombie processes
CMD ["python", "app.py"]
