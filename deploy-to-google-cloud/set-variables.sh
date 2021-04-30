#! /bin/bash

# This file will be executed locally and will alter the startup script temporarily
# to make variables available to the startup script

# fill in the appropriate values
JWTSECRET=JWTSECRET
APPPORT=APPPORT

# This will add the variable to startup script before the script is provision
# This ensure that the right variables are present when the startup script is executed 
function setvars() {
  sed -i -e 's/JWTSECRET/$JWTSECRET/' startup.sh
  sed -i -e 's/APPPORT/$APPPORT/' startup.sh
}

# This will revert the changes made in the function above
function resetvars() {
  sed -i -e 's/$JWTSECRET/JWTSECRET/' startup.sh
  sed -i -e 's/$APPPORT/APPPORT/' startup.sh
}

