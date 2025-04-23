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

# Deploy
This project inplempents numerous ways to deploy the project into cloud infrastructure:

    # For AWS
        1. Deploy infrastructure.yml to the AWS account where the pipeline will be activated
        2. Deploy project_template.yml to the same AWS account.
        3. Deploy pipeline.yml to the account to finalize configuration.

        During the deployment of the templates, a number of parameters will be needed to hook the pipeline to the respective repository.

    # For Azure
        # with Azure
            1. Most of the Azure infrastructure is already in place. Simply add the project to ADO if it not yet added, then create a pipeline from the user interface, using the existing azure-pipelines.yml file in the project.

    # For Jenkins
            1. No clue
            2. Create the job in the jenkins dashboard under the appropriate folder/subfolder.
            3. Jenkins automatically hooks to the existing jenkinsfile
        
