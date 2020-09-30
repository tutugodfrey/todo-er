#! /bin/bash

project=$DEVSHELL_PROJECT_ID

gcloud compute firewall-rules create default-allow-http-access \
    --project todo-er \
    --allow tcp:80,tcp:8081,tcp:8080 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server \
    --description "Allow port 80,8080 and 8081 access to http-server"

gcloud compute addresses create mc-server-ip --project=$project --region=us-central1 # create a static ip address (reserved)
ipaddress=$(gcloud compute addresses describe mc-server-ip --region us-central1 | grep address: | sed 's/address: /'""/) # get the value of the ip address
echo reserved ip address is $ipaddress
sed -i -e 's/SERVERIP/'$ipaddress/ ./startup.sh
gcloud compute instances create todoapp-vm \
--zone us-central1-a \
--tags http-server \
--address=$ipaddress \
--metadata-from-file startup-script=startup.sh

# Get the vm external ip address
VM_IP=$(gcloud compute instances describe todoapp-vm   --format='get(networkInterfaces[0].accessConfigs[0].natIP)' --zone us-central1-a)
echo "See the vm External IP address below"
echo $VM_IP
