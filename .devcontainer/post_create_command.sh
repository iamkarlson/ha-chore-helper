#!/bin/bash

# Create storage directory with proper permissions
mkdir -p /config/.storage
#sudo chown -R vscode:vscode /config
#sudo chmod -R 755 /config

# Ensure www directory exists
mkdir -p /config/www
#sudo chown -R vscode:vscode /config/www

echo "Current directory: $(pwd)"
echo "Contents of current directory:"

ls -la

echo "Running container setup ..."


# Run the original container setup
sudo .devcontainer/container.sh setup-dev
