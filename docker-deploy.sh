#! /bin/sh

IMAGE_NAME=todoapp
CONTAINER_NAME=mytodo
PORT=3005
function build_docker_image() {
  docker build --build-arg JWT_SECRET=somethingfishing --build-arg port=$PORT -t todoapp:latest .;
}

function delete_image() {
  docker image rm $IMAGE_NAME;
}

function start_container() {
  docker run -d --name $CONTAINER_NAME -p $PORT:$PORT  $IMAGE_NAME;
}

function delete_container() {
  if [[ $1 == 'y' ]]; then
    docker container stop $CONTAINER_NAME;
    docker container rm $CONTAINER_NAME;
  else
    docker container rm $CONTAINER_NAME;
  fi
}
