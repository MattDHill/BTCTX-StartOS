# ==================================================
# Stage 1: Build the Vite frontend
# ==================================================
FROM node:18-alpine AS build-frontend

# Create a working directory
WORKDIR /app/frontend

# Copy package.json and lock for better caching
COPY BTCTX/frontend/package*.json ./

# Install dependencies (npm ci is also fine)
RUN npm install --legacy-peer-deps

# Copy the rest of the frontend source
COPY BTCTX/frontend/ ./

# Build the production bundle
RUN npm run build

# ==================================================
# Stage 2: Run the Python/FastAPI backend
# ==================================================
FROM python:3.11-slim-bullseye AS final

# (Optional) install system deps if needed by Python packages
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     libffi-dev libssl-dev \
#     && rm -rf /var/lib/apt/lists/*

# Create a working directory
WORKDIR /app

# (Optional) Copy .env if you rely on it *inside* the container
# ONLY do this if you actually need your container to see .env
COPY BTCTX/.env /app/.env

# Copy Python requirements and install dependencies
COPY BTCTX/backend/requirements.txt ./backend/
RUN pip install --no-cache-dir -r backend/requirements.txt

# Copy backend source code
COPY BTCTX/backend/ ./backend/

# Copy the built frontend from Stage 1
COPY --from=build-frontend /app/frontend/dist ./frontend/dist

# Make a /data directory for the SQLite DB or any persistent data
#  - EmbassyOS can mount a volume at /data if you like
RUN mkdir -p /data && chmod 777 /data

# Expose FastAPI on port 8000
EXPOSE 8000

# CMD: run create_db.py first, then start Uvicorn
CMD ["sh", "-c", "python3 backend/create_db.py && uvicorn backend.main:app --host 0.0.0.0 --port 8000"]
