# Task marker Deployment to Google Compute VM

This documentation contains a brief description of how this application can be deployed to google cloud.

We are using a single VM instance for deploying the application.

This deployment option assumes that you already have your project setup. If that is not the case please go ahead a create a Google cloud project before you proceed. Also set the environment variable DEVSHELL_PROJECT_ID=your-google-cloud-project-id. This will be required by the shell script that will provision the infrastructure.

The file `deploy-compute-engine.sh` contains scripts to create the resources we need to deploy the infrastructure

- Firewall rules to allow us access the application over the public internet
- Static IP address that the application will use
- Compute engine instance that the application will run on

The `startup.sh` script present in the directory contains the userdata script to 

- Install git
- Install node.js and npm
- Clone the application from repository
- Configure/ set environment variables
- Installl dependencies
- Build the frontend of the application
- Copy build artifacts to nginx directory
- Start the node.js 

The `startup.sh` scripts requires the static ip address to complete the application configuration. So we are making it available to it. However to ensure that the script can be run multiple times and to keep the startup script from unintended changes the value is reversed after the deployment completes.

## Deploying the Application

Perform the following steps to deploy the application

Run `cd deploy-to-google-cloud/` enter the directory where the deployment scripts are residing

Inspect the files in the directory. you may not need to alter any of the files here expect `set-variables.sh` which allows you to preprovision environment variables required to configure the application.

Open `./set-variables.sh` script and fill in the appropriate variable values

This let you provide values for variable that can be Secrets or  dynamic. The `./deploy-compute-engine.sh` will executed the script to insert the variables in the startup file. The script contain a function `setvars` to set the variables in the startup file before compute VM is provision and another function `resetvars` to revert the changes after compute vm has finish provisioning. This will ensure that the startup script is kept intact between multiple executions and that we are not untentionally updating and commiting changes to startup file, thus not exposing secrets.

Execute `./deploy-compute-engine.sh`

The script will provision resources and Deploy the application. After the application has finish deploying. It will output the IP Address at which we can access the application. 

Please note that it will take sometime before the application will be able to respond to requests as it will need to perform necessary installations before starting the application

**NOTE:** This is not a very complex deployment meant for production use. It provides a simple way use to test application and see the functionalities it provide.
