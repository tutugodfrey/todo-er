# Deploying Task Marker on Kubernetes

This documentation provide description and steps required to deploy this application on Kubernetes

There is already functionality to build the docker images for the backend and frontend components of the application and the images are available on Docker Hub as `tutug/todoapp-be` and `tutug/todoapp-fe` respectively.

## K8S templates

The Kubernetes templates for deploying the application is found in the `k8s` directory relative to the project root directory. The following yaml files are important for deploying the appplication at this time. 

`k8s/Deployment-db.yaml` Contain template for deploying PostgreSQL database engine.

`k8s/Deployment-fe.yaml` Contains template for deploying the frontend of the application.

`k8s/Deployment.yaml` Contains template for deploying the backend of the application.

`k8s/Service-db.yml` Contains template for db service.

`k8s/Service-fe.yaml` Contains template for frontend service.

`k8s/Service.yaml` Contains service for the backend service.

`k8s/sql-configmap.yaml` Contains template configmap to create the database that the application will use.

You can go about execute individual `kubectl` command to create the objects. For example

`kubectl create -f k8s/Deployment.yaml`

But the entire steps has been scripted and you can find the in `k8s/deploy.sh` file.

## Deploying the Application to GKE

This section provide instruction on how to deploy the application to GKE. You want to make sure you have your Google Cloud project setup.

To follow the instructions below make sure you are in the `./k8s` directory relative to the project root directory.

Before the application can be deploy to GKE, you want to provision the Kubernetes cluster that the application will run on. The file `mycluster.sh` contain functions to help you manage the cluster.

### Create the Kubernetes cluster

To source the file, execute

`. ./mycluster.sh` You can use `--help` or `-h` to get help

Once the file is sourced, you can execute the following functions

`create_cluster` to create the cluster. You can provide a numeric argument to specify the number of nodes

`resize_cluster` To resize the cluster. You need to provide a numeric value for the number of nodes to resize to.

`delete_cluster` To delete the cluster.

You can you `kubectl get nodes -o wide` to view the nodes created by GKE

### Create the Kubernetes objects

Once GKE has finish provising the cluster you can source the `deploy.sh`.

Source the deploy.sh script

`. ./deploy.sh`

You can execute the following command to create the Kubernetes objects

`create-all`

You can execute the following command to delete the Kubernetes objects

`delete-all`


When all the objects are created, use

`kubectl get pods` to see the pods created

`kubectl get deployment` to see the deployment

`kubectl get services` to see the services create.

You can access the frontend and the backend seperately of the load balancer of the services. There is a `sample-curl-request` at the root of the project that you can you to test the backend service. You need to provide the Load balancer IP address of the backend servide to the curl command to work.

You can execute the following command to connect to the database if you would like to inspect what was created.

<!-- kubectl run -ti --rm --image=postgres postgres-server -- psql -h db -U postgres -p 5432 -->

`kubectl run -ti --rm --image=postgres postgres-server -- psql -h todoapp-db-service -U postgres -p 5432`

`\c todoapp` connect to the database of the application

Assuming you have execute the curl command to create the users, the following command should show what was created.

`select * from users;`


**PLEASE NOTE** due to DNS resolution issue and the way the frontend image is build, the frontend may not be able to communication with the backend unless the image is rebuild with appropriate dns name to communicate with the backend. But you can still access the frontend with the frontend service Load balancer IP address.

### Using Jenkin build

Jenkins Pipeline for deploying the application to K8s need updates. Once that is done, more documentation will be added.

- Add JWT_SECRET key  and value pair to your jenkins environment variables. this will be used as --build-arg for building docker images.


## Useful commands for interacting with Kubernetes Objects

To view logs for frontend deployment (Change the pod name to what is created for you)

`kubectl logs todoapp-fe-deployment-54659bc577-hgqfc --container log-container`
