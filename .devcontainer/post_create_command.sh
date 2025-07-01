#!/usr/bin/env bash

set -e

echo "🚀 Setting up HA Chore Helper development environment..."
echo "Current directory: $(pwd)"

# First, set up the Home Assistant container
echo "Setting up Home Assistant container..."
container setup

# Install uv if not present
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Create virtual environment for dev tools only
echo "Creating virtual environment for development tools..."
uv venv .venv
source .venv/bin/activate

# Install dev dependencies only (HA is already in the container)
echo "Installing development dependencies..."
uv sync --extra dev --extra test

# Install integration dependencies from manifest.json into the container's HA
echo "Installing integration dependencies..."
if [ -f "custom_components/chore_helper/manifest.json" ]; then
    REQUIREMENTS=$(python -c "
import json
with open('custom_components/chore_helper/manifest.json') as f:
    manifest = json.load(f)
    reqs = manifest.get('requirements', [])
    if reqs:
        print(' '.join(reqs))
    else:
        print('No requirements found')
")

    if [ "$REQUIREMENTS" != "No requirements found" ] && [ -n "$REQUIREMENTS" ]; then
        echo "Installing into container HA: $REQUIREMENTS"
        # Install into the container's Home Assistant python environment
        pip install $REQUIREMENTS
    fi
fi

# Set up pre-commit hooks
echo "Setting up pre-commit hooks..."
uv run pre-commit install

echo "✅ Development environment setup complete!"
echo ""
echo "🔧 Available commands:"
echo "  uv run pytest                 - Run tests"
echo "  uv run black .                - Format code"
echo "  uv run isort .                - Sort imports"
echo "  uv run pylint custom_components - Lint code"
echo "  uv run mypy custom_components  - Type check"
echo "  uv run ruff check .           - Lint with ruff"
echo "  uv run ruff format .          - Format with ruff"
echo ""
echo "🏃 To start Home Assistant:"
echo "  container run"
echo ""
echo "📁 Directory structure:"
echo "  $(pwd)                   - Your repo (with pyproject.toml, dev tools)"
echo "  $(pwd)/custom_components - Your component source"
echo "  /config                  - Home Assistant config directory"
echo "  /config/custom_components - Component mounted for HA"
echo ""
echo "🌟 This container comes with Home Assistant pre-installed and configured!"
