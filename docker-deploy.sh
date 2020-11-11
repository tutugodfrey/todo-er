#! /bin/sh
cd /Users/godfreytutu/Desktop/projects/todo-er
IMAGE_NAME="tutug/todoapp"
FRONEND_IMAGE_NAME="tutug/todoapp-fd"
CONTAINER_NAME="mytodo"
SERVICE="todo-app-service"
PORT=3005
function build_docker_image() {
  docker build --build-arg JWT_SECRET=somethingfishing --build-arg port=$PORT -t $IMAGE_NAME:latest .;
}

function delete_image() {
  docker rmi $IMAGE_NAME;
}

function start_container() {
  docker run -d --name $CONTAINER_NAME -p $PORT:$PORT  $IMAGE_NAME;
}

function delete_container() {
  if [[ $1=='y' ]]; then
    docker container stop $CONTAINER_NAME;
    docker container rm $CONTAINER_NAME;
  else
    docker container rm $CONTAINER_NAME;
  fi
}

# Frontend
function build_docker_image_frontend() {
  if [ $1=='yes' ]; then
    IP=$(minikube ip)
    PORT=$(kubectl get service $SERVICE --output='jsonpath="{.spec.ports[0].nodePort}"')
    API_URL="http://$IP:$PORT/api"
    export IP
    export PORT
    export API_URL
    echo $IP, $PORT, $API_URL
    export API_URL; npm run build
  fi
  docker build  -t $FRONEND_IMAGE_NAME:latest -f dockerfile-frontend .;
}

function run_frontend_app () {
  docker run -d --name todofrontend -p 8084:80 tutug/todoapp-fd
}

