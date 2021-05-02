# Todo-er
Create simple  demo todo app with the data-modela npm package.
## Status Badges

[![CircleCI](https://circleci.com/gh/tutugodfrey/todo-er.svg?style=svg)](https://circleci.com/gh/tutugodfrey/todo-er)
[![Maintainability](https://api.codeclimate.com/v1/badges/7293372337221c98bfdd/maintainability)](https://codeclimate.com/github/tutugodfrey/todo-er/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/7293372337221c98bfdd/test_coverage)](https://codeclimate.com/github/tutugodfrey/todo-er/test_coverage)

## Features & Routes
- Users signup: `/api/users/signup`
- User sign in: `/api/users/signin`
- User update their profile: `/api/users`
- Create todo item: `/api/todos`
- Get todos: `/api/todos`
- Get todo by id: `/api/todos/:id`
- Update todos: `/api/todos/:id`
- Delete todos: `/api/todos/:id`

#### Evironment variables
Add environment variable after what is .env.example

#### Running e2e test

To run e2e test, you may need to reinstall the chromedriver to match your version of your chrome browser.
My latest install version is `^86.0.0`. But I've changed the version in package.json to earlier version `80.0.1` because it is causing the build to fail on CircleCI.

## Deploying the Application

There are various options possible for deploying this application to testing, staging or production environment. Click any of the links below to see what is possible

[Provision Datacenter on AWS and Deploy with Terraform IaC](tf-aws/README.md)

[Deploy to Google Cloud](deploy-to-google-cloud/README.md)

[Deployment with Docker](#Deployment-with-docker)

[Deployment with Kubernetes](k8s/README.md)

### Deployment with Docker

This section provide instructions on how to deploy and test the application in a docker container. Dockerfiles to build the frontend and the backend images are present in the root directory of the project. There is also the `docker-helper.sh` that contains functions for building images, running containers, pushing container to Docker Hub, delete images and containers.

## Building a docker images
Environment variable require for building an image in 
- PORT
- JWT_SECRET
- API_URL

You can also provide this as --build-arg in your docker run command as follows
- PORT=
- JWT_SECRET=
- API_URL=

Note the API_URL should be the base url that frontend app will run on. if your are running on localhost, the port should correspond with the port you set in your env or build-arg for docker run command. The default port for running the application in development is 3005 and hence the default API_URL is set as 3005. Useful when running the application in development. If you which to use another port please provide it as --build-arg to your docker build command or export your docker environment variable in docker build command as --env-file=path/to/.env.

To begin source the file to expose the functions

`. ./docker-helper.sh` Use `-h` or `--help` to get help

After sourcing the file, the following functions are exposed

**Note:** argument in [] are optional

`build_image_be JWT_SECRET [PORT_NUMBER] [IMAGE_NAME]`  Build the backned image. provide the JWT_SECRET value that the application will use. This value is required. You can also provide port to expose as well and the image name and tag

`run_container_be [CONTAINER_NAME] [PORT_NUMBER]`  Run the backend container. You can provide optional argument for the container name and port to bind to. If not provide default values will be used. Changing the argument will enable you to run multiple copies of the container image.


`build_image_fe [API_URL] [IMGE_NAME]` Build the frontend image. To enable api request reach the backend service, You will need to provide the API_URL argument. Otherwise, the application will bind to localhost. The API_URL is just a way to allow requests from the frontend reach the backend. Thus, it could for example be the uri of an nginx server if nginx is configure to proxy requests to the backend.

`run_container_fe [CONTAINER_NAME] [PORT_NUMBER]` Run the frontend container. You can provide optional arguments [CONTAINER_NAME] [PORT_NUMBER] to change the defaults. Changing the argument will enable you to run multiple copies of the container image.

`delete_image -fe` Delete an image. Provide `-fe` for frontend  or `-be` backend.

`delete_container -fe [-f]`  Delete a container. Provide `-be` for backend or `-fe` for frontend image. You can also provide `-f` to force the container delete if it is still running.

`push_image -fe`  push docker image to repository. provide `-be` for backend image or `-fe` for for the frontend image

When any of the command run, you will be able to see exactly what is executed. You can copy and modify it if you desire to.

## Author
Tutu Godfrey <godfrey_tutu@yahoo.com>
