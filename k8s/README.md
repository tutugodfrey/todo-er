# Task Marker on Kubernetes

This documentation provide description and steps required to deploy this application on Kubernetes

There is already functionality to build the docker images for the frontend and backend aspects of the application and the images are available on Docker Hub.

More on documentation later

Currently updating kubernetes deployment workflow. Documentation will be updated when the feature is ready

### Using Jenkin build

- Add JWT_SECRET key  and value pair to your jenkins environment variables. this will be used as --build-arg for building docker images
