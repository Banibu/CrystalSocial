#!/bin/sh

# Wait for the database to be ready
echo "Waiting for database..."
while ! nc -z db 5432; do
  sleep 1
done
echo "Database is ready!"

# Run migrations
echo "Running prisma db push..."
prisma db push --accept-data-loss

# Start the application
echo "Starting application..."
node server.js
