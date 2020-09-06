#! /bin/bash
# update apt-get, install git, node and npm
sudo apt-get update
sudo apt install git-all -y
sudo apt install nodejs -y
sudo apt install npm -y

# Clone the repository
git clone https://github.com/tutugodfrey/todo-er
cd todo-er

# fetch exportenvs.sh file from cloud storage.
gsutil cp gs://todo-er/exportenvs.sh exportenvs.sh

# Setup environment variables
./setenv.sh

# Install dependencies
npm install

# Build the frontend application
npm run build

# Move the frontend compoent to /var/www/html folder
sudo cp public/* /var/www/html/public

# start the backend api
npm start
