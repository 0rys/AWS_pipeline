#!/bin/bash
echo "Starting deployment script"
python -m ensurepip --upgrade
echo "Installing pip..."
python -m pip install --upgrade pip
echo "Installing requirements..."
python -m pip install -r requirements.txt
echo "Starting application..."
python hello_world.py