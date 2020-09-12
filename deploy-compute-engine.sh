#! /bin/bash

gcloud compute firewall-rules create default-allow-http-access \
    --project todo-er
    --allow tcp:80,tcp:8081,tcp:8080 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server \
    --description "Allow port 80,8080 and 8081 access to http-server"

gcloud compute instances create todoapp-vm \
--zone us-central1-a \
--tags http-server \
--metadata-from-file startup-script=startup.sh

# Get the vm external ip address
VM_IP=$(gcloud compute instances describe todoapp-vm   --format='get(networkInterfaces[0].accessConfigs[0].natIP)' --zone us-central1-a)
echo "See the vm External IP address below"
echo $VM_IP