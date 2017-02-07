#!/bin/bash
NAME="${NAME:-jump}"
MACHINE_TYPE="${MACHINE_TYPE:-f1-micro}"
ZONE="${ZONE:-us-east1-d}"
PROJECT="${PROJECT:-$1}"

if [ -z "$PROJECT" ]; then
	echo "You must specify PROJECT environment variable" > /dev/stderr
	exit
fi

function gc {
	gcloud compute --project "$PROJECT" "$@"
}

./create_project.sh

gc instances create jump --zone "$ZONE" --machine-type "$MACHINE_TYPE" --subnet "default" --metadata-from-file startup-script=boot.sh --tags "https-server" --boot-disk-size "10" --boot-disk-type "pd-standard" --boot-disk-device-name "jump"

#add jump key
gc instances add-metadata jump --zone "$ZONE" --metadata-from-file ssh-keys="creds/jump@${PROJECT}.pub"
