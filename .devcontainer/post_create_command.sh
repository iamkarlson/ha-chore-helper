#!/usr/bin/env bash

install_extension() {
    /usr/bin/code --install-extension $1
    /usr/bin/code-insiders --install-extension $1
}

# Install VS Code extensions into VS Code in desktop so we can try
install_extension ms-vscode-remote.remote-containers
install_extension ms-azuretools.vscode-docker
install_extension streetsidesoftware.code-spell-checker
install_extension chrisdias.vscode-opennewinstance
install_extension mads-hartmann.bash-ide-vscode
install_extension rogalmic.bash-debug

set -e

export HA_VERSION="2025.6.3"
echo "Current dir: ${PWD}"
echo "Contents of current dir:"
ls -la
echo -e "\n\n\n\n\n"

curl -LsSf https://astral.sh/uv/install.sh | sh 
uv venv .venv 
source .venv/bin/activate 

echo "Downloading lists of Home Assistant version $HA_VERSION dependencies"
curl -sL https://raw.githubusercontent.com/home-assistant/core/$HA_VERSION/homeassistant/package_constraints.txt -o /tmp/constraints.txt 
curl -sL https://raw.githubusercontent.com/home-assistant/core/$HA_VERSION/requirements.txt  -o /tmp/requirements.txt 
curl -sL https://raw.githubusercontent.com/home-assistant/core/$HA_VERSION/requirements_all.txt -o /tmp/requirements_all.txt

# home assistant requirements file contains `-c homeassistant/package_constraints.txt` at the top so it's build with the constraints
# we need to remove that line so uv can install the requirements
sed -i '/-c homeassistant\/package_constraints.txt/d' /tmp/requirements.txt

# same thing for requirements_all.txt but with `-r requirements.txt`
sed -i '/-r requirements.txt/d' /tmp/requirements_all.txt

uv pip install --constraint /tmp/constraints.txt -r /tmp/requirements.txt
uv pip install --constraint /tmp/constraints.txt -r /tmp/requirements_all.txt

uv pip install --constraint /tmp/constraints.txt homeassistant

# find the exact version Home Assistant wants and install it
HF_VERSION=$(grep -E '^home-assistant-frontend==' /tmp/constraints.txt)
if [ -n "$HF_VERSION" ]; then
  echo "Installing $HF_VERSION"
  uv pip install "$HF_VERSION"
fi

REQS=$(jq -r '.requirements[]' custom_components/chore_helper/manifest.json)

echo "Installing requirements: $REQS"

if [ -n "$REQS" ]; then
  echo "Installing integration requirements with uv: $REQS"
  uv pip install $REQS
fi



# Optionally, you can add a user to Home Assistant
# hass --script auth -d /config add admin admin || true