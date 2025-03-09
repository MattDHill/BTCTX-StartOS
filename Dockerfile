# ==================================================
# Stage 1: Build the Vite frontend
# ==================================================
FROM node:18-alpine AS build-frontend

WORKDIR /app/frontend

# Copy package.json and lock for better caching
COPY BTCTX/frontend/package*.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy the rest of the frontend source
COPY BTCTX/frontend/ ./

# Build the production bundle
RUN npm run build

# ==================================================
# Stage 2: Run the Python/FastAPI backend
# ==================================================
FROM python:3.11-slim-bullseye AS final

WORKDIR /app

# 1) Set environment variables so your app *always* uses the /data path
ENV DATABASE_FILE=/data/bitcoin_tracker.db
ENV DATABASE_URL=sqlite:////data/bitcoin_tracker.db

# (Optional) Copy .env if you want to load other variables, 
# but "DATABASE_FILE" and "DATABASE_URL" are set above so .env won't overwrite them.
COPY BTCTX/.env /app/.env

# 2) Install Python requirements
COPY BTCTX/backend/requirements.txt ./backend/
RUN pip install --no-cache-dir -r backend/requirements.txt

# 3) Copy backend source code
COPY BTCTX/backend/ ./backend/

# 4) Copy the built frontend from Stage 1
COPY --from=build-frontend /app/frontend/dist ./frontend/dist

# 5) Make the /data directory for the DB (StartOS will mount a volume here)
RUN mkdir -p /data && chmod 777 /data

EXPOSE 8000

# 6) Final command
CMD ["sh", "-c", "python3 backend/create_db.py && uvicorn backend.main:app --host 0.0.0.0 --port 8000"]
