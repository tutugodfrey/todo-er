#! /bin/bash

IMAGE_NAME_BE="tutug/todoapp-be"
IMAGE_NAME_FE="tutug/todoapp-fe"
CONTAINER_NAME_BE=todo-container-be
CONTAINER_NAME_FE=todo-container-fe
PORT_BE=3005
PORT_FE=80
API_URL="http://localhost:$PORT_BE/api"

function docker_deploy_help() {
  echo """
    Get help by providing the flags "-h" or "--help"

    To build and run images run the following functions
    build_image_be: accepts 3 arguments ARG 1 jwt_secret (required), 
    ARG 2 portnumber to expose, ARG 3 imagename (optional). 

    run_container_be: Accept 2 optional arguments to override the defaults ARG 1 container name 
    ARG 2  PORT number that the container will map to.

    build_image_fe: accepts 2 optional arguments ARG 1 API_URL the url to reach backend service, 
    ARG 2 imagename  to overide the default

    run_container_fe: Accept 2 optional arguments, ARG 1 container name, 
    ARG 2 PORT number that the container will map to.
    If not provided, container will map to the same port that was used to build the image.

    delete_image: -fe | -be : specify which image to delete -fe for frontend, -be for backend

    delete_container: -be | -fe : specify which container to delete -fe frontend, -be for backend.
    You can also specify -f to delete container if it is running.

    push_image:  -be | -fe : push docker image to repository
   """
}

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
  echo "Hello arg $1"
  docker_deploy_help
  return 0;
fi

function build_image_be() {
  if [ -z "$1" ]; then
    echo "Please provide JWT_SECRET key"
    return 1
  fi

  JWT_SECRET=$1
  if [[ $# == 2 ]]; then 
    PORT_BE=$2
  fi

  if [[ $# == 3 ]]; then 
    PORT_BE=$2
    IMAGE_NAME_BE=$3
  fi

  command="docker build --build-arg JWT_SECRET=$JWT_SECRET --build-arg port=$PORT_BE -t $IMAGE_NAME_BE:latest .";
  echo Executing $command;
  $command;
}

function run_container_be() {
  PORT_MAP=$PORT_BE
  if [[ $# == 1 ]]; then
    CONTAINER_NAME_BE=$1
  fi

  if [[ $# == 2 ]]; then
    CONTAINER_NAME_BE=$1
    PORT_MAP=$2
  fi
  command="docker run -d --name $CONTAINER_NAME_BE -p $PORT_MAP:$PORT_BE  $IMAGE_NAME_BE";
  echo Executing: $command;
  $command
}

# if [ -z "$1" ]; then
#   # PORT=$(kubectl get service $SERVICE --output='jsonpath="{.spec.ports[0].nodePort}"')
#   return "Please provide the url for API requests";
# fi

# Frontend
function build_image_fe() {    
  API_URL=$API_URL;
  if [[ $# == 1 ]]; then
    API_URL=$1;
  fi

  if [[ $# == 2 ]]; then
    API_URL=$1;
    IMAGE_NAME_FE=$2
  fi

  command="docker build  -t $IMAGE_NAME_FE:latest --build-arg API_URL=$API_URL -f dockerfile-frontend .";
  echo Executing: $command;
  $command
}

function run_container_fe () {
  PORT_MAP=$PORT_FE
  if [[ $# == 1 ]]; then
    CONTAINER_NAME_FE=$1
  fi

  if [[ $# == 2 ]]; then
    CONTAINER_NAME_FE=$1
    PORT_MAP=$2
  fi
  command="docker run -d --name $CONTAINER_NAME_FE -p $PORT_MAP:$PORT_FE $IMAGE_NAME_FE";
  echo Executing: $command;
  $command
}


function push_image() {
  if [ ! $1 ]; then
    echo "Please specify which image to push. Use -be for backend image and -fe for frontend image"
    return 1;
  fi
  if [[ $1 == '-be' ]]; then
    IMAGE_NAME=$IMAGE_NAME_BE
  elif [[ $1 == '-fe' ]]; then
    IMAGE_NAME=$IMAGE_NAME_FE
  fi
  command="docker push $IMAGE_NAME:latest";
  echo Executing: $command;
  $command
}

function delete_image () {
  if [ ! $1 ]; then
    echo "Please specify which image to delete. Use -be for backend image and -fe for frontend image"
    return 1;
  fi
  if [[ $1 == '-be' ]]; then
    IMAGE_NAME=$IMAGE_NAME_BE
  elif [[ $1 == '-fe' ]]; then
    IMAGE_NAME=$IMAGE_NAME_FE
  fi
  command="docker rmi $IMAGE_NAME";
  echo Executing: $command;
  $command
}

function delete_container() {
  if [ ! $1 ]; then
    echo "Please specify which container to delete. Use -be for backend container and -fe for frontend container"
    return 1;
  fi

  if [[ $1 == '-be' ]]; then
    CONTAINER_NAME=$CONTAINER_NAME_BE
  elif [[ $1 == '-fe' ]]; then
    CONTAINER_NAME=$CONTAINER_NAME_FE
  fi

  # Provide the -f flag to stop and delete container
  if [[ $2 == '-f' ]]; then
    command="docker container stop $CONTAINER_NAME";
    echo Executing: $command;
    $command

    command="docker container rm $CONTAINER_NAME";
    echo Executing: $command;
    $command
  else
    command="docker container rm $CONTAINER_NAME";
    echo Executing: $command;
    $command
  fi
}
  
echo Get help by providing the flags "-h" or "--help"
