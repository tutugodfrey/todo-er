#! /bin/bash

## This script order the creation of kubernetes objects

function create-all () {
  # Create sql config map
  kubectl create -f sql-configmap.yaml

  # Create db deployment and service
  kubectl create -f Deployment-db.yaml
  kubectl create -f Service-db.yaml

  # Create backend deployment and service
  kubectl create -f Deployment.yaml
  kubectl create -f Service.yaml

  # Create the frontend service
  kubectl create -f Deployment-fe.yaml
  kubectl create -f Service-fe.yaml
}

# Function clean out all k8s resources created
function delete-all () {
  kubectl delete deployment todoapp-be-deployment;
  kubectl delete deployment todoapp-db-deployment;
  kubectl delete services todoapp-be-service;
  kubectl delete services todoapp-db-service;
  kubectl delete deployment todoapp-fe-deployment;
  kubectl delete service todoapp-fe-service;
  kubectl delete cm sql-config;
}

echo You can now run the following functions
echo create-all: to create all objects
echo delete-all: to delete created resources

