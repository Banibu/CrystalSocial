#!/bin/sh
set -e

echo "=========================================="
echo "CrystalSocial - Docker Startup"
echo "=========================================="

# Wait for the database to be ready
echo "Waiting for PostgreSQL database to be ready..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
  if nc -z db 5432 2>/dev/null; then
    echo "✓ Database is reachable"
    break
  fi
  echo "  Attempt $attempt/$max_attempts - Database not ready yet, waiting..."
  sleep 2
  attempt=$((attempt + 1))
done

if [ $attempt -gt $max_attempts ]; then
  echo "✗ Failed to connect to database after $max_attempts attempts"
  exit 1
fi

# Give the database a moment to fully initialize
sleep 2

# Run Prisma migrations
echo ""
echo "Running Prisma database migrations..."
if prisma db push --accept-data-loss; then
  echo "✓ Database migrations completed successfully"
else
  echo "✗ Database migrations failed"
  exit 1
fi

# Start the application
echo ""
echo "=========================================="
echo "Starting Next.js application..."
echo "=========================================="
echo "Application will be available at: http://localhost:3000"
echo ""

exec node server.js
