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

## Deploying the Application

There are various options possible for deploying this application to testing, staging or production environment.

[Provision Datacenter on AWS and Deploy with Terraform IaC](tf-aws/README.md)

[Deploy to Google Cloud](deploy-to-google-cloud/README.md)

[Deployment with Docker](#Deployment-with-docker)

[Deployment with Kubernetes](k8s/README.md)

### Deployment with Docker

#### using build-arg
- `$ docker build --build-arg JWT_SECRET=somethingfishing --build-arg port=3005  -t todoapp:latest .`

- API_URL=http://localhost:3005/api  -- change the port to your desired port and make the API_URL available in our .env file

### Build the frontend image

- `docker build -t tutug/todoapp-fd:latest -f dockerfile-frontend .`

### Expose the frontend app

- `docker run -d --name todofrontend -p 8084:80 tutug/todoapp-fd`


## Author
Tutu Godfrey <godfrey_tutu@yahoo.com>
