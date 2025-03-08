# ============================
# Stage 1: Build the Vite frontend
# ============================
FROM node:18-bullseye-slim AS build-frontend

# Set working directory to frontend source folder
WORKDIR /app/frontend

# Copy package.json and lock file first for caching
COPY BTCTX/frontend/package.json BTCTX/frontend/package-lock.json ./

# Install frontend dependencies
RUN npm ci --legacy-peer-deps

# Copy the rest of the frontend source code
COPY BTCTX/frontend/ ./

# Ensure correct permissions (optional but useful)
RUN chmod -R 755 .

# Build the production-ready static files
RUN npm run build

# ============================
# Stage 2: Build & Run the Python/FastAPI backend
# ============================
FROM python:3.11-slim-bullseye AS final

# Set working directory for backend
WORKDIR /app

# (Optional) Install system dependencies for Python packages
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential libffi-dev libssl-dev \
#     && rm -rf /var/lib/apt/lists/*

# Copy backend requirements and install dependencies
COPY BTCTX/backend/requirements.txt ./backend/
RUN pip install --no-cache-dir -r backend/requirements.txt

# Copy backend source code
COPY BTCTX/backend/ ./backend/

# Copy built frontend from Stage 1 into backend
COPY --from=build-frontend /app/frontend/dist ./frontend/dist

# Expose the FastAPI port
EXPOSE 8000

# Set environment variables (optional, if you use them)
ENV UVICORN_HOST=0.0.0.0
ENV UVICORN_PORT=8000

# Run FastAPI with Uvicorn
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
