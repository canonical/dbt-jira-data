#!/bin/bash

# Install poetry
sudo apt install python3-poetry

# Install dependencies using poetry
poetry config keyring.enabled false
poetry install --only main --no-root
