#!/bin/sh
set -e

echo "Generating Prisma client..."
npx prisma generate

echo "Starting development server..."
exec npm run dev