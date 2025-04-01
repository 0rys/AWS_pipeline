# Introduction 
Sample project used to test different aspects of CI/CD pipeline automation tools. Contains a simple flask app that prints hello world

# Getting Started
1.	Installation process
    Download the directory of the project, then simply run the executable hello_world.py file. 
2.	Software dependencies
    Requires the installation of python, only tested with version 3.12.8 and 3.12.9, as well as flask. To run tests, install the requirements included in the requirements.txt file.

# Build and Test
To run the regular tests, one must execute the following:
    python3 -m pytest test_hello_world.py

To run the integration tests, one must execute the following:
    python3 ./hello_world.py &
    python3 -m pytest test_integration.py
