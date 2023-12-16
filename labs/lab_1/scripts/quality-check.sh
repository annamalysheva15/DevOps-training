#!/bin/bash

PROJECT_PATH=${1:-.}

cd "${PROJECT_PATH}"

if [ ! -f package.json ]; then
  echo "No package.json file was found in the specified folder"
  exit 1
fi

echo -e "Quality check started\n"

echo "Running linter..."
npm run lint

echo "Running unit tests..."
npm run test -- --watch=false

echo "Running npm audit..." 
npm audit

echo "Quality check completed."

