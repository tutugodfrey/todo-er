#! /bin/sh

# This script will be executed by the startup.sh script on the remote machine
# It is not necessary to modify the script during deployment unless
# you are intentionally changing the deployment configuration settings

# write env file from .env.example file,
# export env and replace env variable in .env file
cat ../.env.example > .env
./switchenvs.sh

