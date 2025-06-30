#!/usr/bin/env bash

set -e

echo "🚀 Setting up HA Chore Helper development environment..."
echo "Current directory: $(pwd)"

# Install uv if not present
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Create virtual environment and install dependencies
echo "Creating virtual environment..."
uv venv .venv
source .venv/bin/activate

echo "Installing development dependencies..."
uv sync --extra dev --extra test

# Install integration dependencies from manifest.json
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
        echo "Installing: $REQUIREMENTS"
        uv add $REQUIREMENTS
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
echo "  source .venv/bin/activate"
echo "  hass -c /config --debug"
echo ""
echo "📁 Directory structure:"
echo "  $(pwd)                   - Your repo (with pyproject.toml, etc.)"
echo "  $(pwd)/custom_components - Your component source"
echo "  /config                  - Home Assistant config (ha_config folder)"
echo "  /config/custom_components - Component symlinked for HA"
