#!/usr/bin/env bash
set -e

# Basic utilities
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    ripgrep \
    less

# Markdown lint
npm install -g markdownlint-cli

# Create and activate a virtual environment
python -m venv .venv
source .venv/bin/activate

# Upgrade pip in the virtual environment
python -m pip install --upgrade pip
pip install \
    mkdocs \
    mkdocs-material \
    mkdocs-literate-nav \
    mkdocs-section-index 
#    mkdocs-exporter

# Clean up apt caches
sudo rm -rf /var/lib/apt/lists/*

