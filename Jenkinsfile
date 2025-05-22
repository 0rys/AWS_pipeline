pipeline{
    agent {
        label 'DEV'
    }

    environment {
        PYTHON_VERSION = 3.9
        AZURE_SUBSCRIPTION = 'dev-devopsreference-00001-spn'
        RESOURCE_GROUP = 'dev-devopsreference-00001-rg'
        APP_NAME = 'Azure-pipeline-test'
        PLAN_NAME = 'dev-devopsreference-00001-plan'
    }

    stages {
        stage('Build') {
            steps {
                sh '''
                    python3 --version
                    python3 -m ensurepip --upgrade
                    python3 -m pip install -r requirements.txt
                '''
            }
        }

        stage('Test'){
            steps{
                sh '''
                    mkdir -p junit
                    python3 -m pytest test_hello_world.py --junitxml=junit/test-results.xml
                '''

                sh '''
                    python3 hello_world.py &
                    echo \$! > flask.pid
                    sleep 5
                    python3 -m pytest test_integration.py --junitxml=junit/integration-test-results.xml
                    kill -9 \$(cat flask.pid)
                '''

                junit '**/junit/*.xml'
            }
        }

        stage('Deploy'){
            steps{
                withCredentials([azureServicePrincipal('AZURE_CREDENTIALS')]){
                    sh '''
                        az login --service-principal -u \$AZURE_CLIENT_ID -p \$AZURE_CLIENT_SECRET -t \$AZURE_TENANT_ID
                        az account set -s \$AZURE_SUBSCRIPTION_ID
                    '''
                }

                sh '''
                    az appservice plan create --resource-group ${RESOURCE_GROUP} --name ${PLAN_NAME} --sku B1 --is-linux
                    az webapp create --resource-group ${RESOURCE_GROUP} --plan ${PLAN_NAME} --name ${APP_NAME} --runtime "PYTHON|$(PYTHON_VERSION)"
                '''

                sh '''
                    zip -r app.zip *.py requirements.txt startup_script.sh

                    az webapp deployment source config-zip --resource-group ${RESOURCE_GROUP} --name ${APP_NAME} --src app.zip
                    az webapp config set --resource-group ${RESOURCE_GROUP} --name ${APP_NAME} --startup-command "./startup_script.sh"
                '''
            }
        }        
    }

    post {
        always {
            cleanWs ()
        }
        success {
            echo 'Pipeline completed successfully'
        }
        failure{
            echo 'Pipeline failed!'
        }
    }

}

