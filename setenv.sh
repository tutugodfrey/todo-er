#! /bin/sh

# write env file from .env.example file,
# export env and replace env variable in .env file
cat .env.example > .env
# . ./exportvars.sh
./switchenvs.sh

