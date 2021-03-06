#! /bin/bash
# update apt-get, install git, node and npm
sudo apt-get update
sudo apt install git-all -y
sudo apt install nodejs -y
sudo apt install npm -y

# Clone the repository
git clone https://github.com/tutugodfrey/todo-er
cd todo-er

JWT_SECRET=JWTSECRET; export JWT_SECRET
PORT=APPPORT; export PORT
IP=SERVERIP; export IP

# Setup environment variables
./setenv.sh

# Install dependencies
npm install

# Build the frontend application
npm run build

# Move the frontend compoent to /var/www/html folder
sudo cp public/{index.html,bundle.js} /var/www/html/
sudo mkdir /var/www/html/public
sudo cp public/*.{png,jpg} /var/www/html/public

# start the backend api
npm start
