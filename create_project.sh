#!/bin/bash
PROJECT="${PROJECT:-$1}"
if [ -z "$PROJECT" ]; then
	echo "You must specify PROJECT environment variable" > /dev/stderr
	exit
fi

mkdir -p hosts creds
if [ ! -f "creds/@$PROJECT" ]; then
	echo "ssh key missing for jumpE@$PROJECT, creating..."
	ssh-keygen -C "jump" -f "creds/jump@$PROJECT"
  sed -i -e "s|^|jump:|g" "creds/jump@$PROJECT".pub
  ln -s "jump@$PROJECT" creds/current
fi

if ! gcloud alpha projects list | grep -q -- " $PROJECT "; then
  gcloud alpha projects create "$PROJECT"
fi

#add firewall rules to allow https
if ! gcloud compute --project "$PROJECT" firewall-rules list | grep -q "^default-allow-https "; then
  gcloud compute --project "$PROJECT" firewall-rules create "default-allow-https" --allow tcp:443 --network "default" --source-ranges "0.0.0.0/0" --target-tags "https-server"
fi
