#!/bin/bash

PROJECT_PATH=${1:-.}
export ENV_CONFIGURATION=${2:-''}

cd "$PROJECT_PATH"

if [ ! -f package.json ]; then
	echo "No package.json file was found in the specified folder"
	exit 1;
fi

echo "Inslalling project dependencies..."
npm install

if [ -f dist/client-app.zip ]; then
	rm dist/client-app.zip
fi

echo "Building the project..."
npm run build -- --configuration="$ENV_CONFIGURATION"

if [ $? -eq 0 ]; then
	echo "Compressing the build..."
	cd dist && zip -r client-app.zip * && cd ..
	echo "Build completed successfully!"
else
	echo "Build failed"
fi

