#!/bin/bash
NAME="jump"
MACHINE_TYPE="f1-micro"
ZONE="us-east1-d"

if [ -z "$PROJECT" ]; then
	echo "You must specify PROJECT environment variable" > /dev/stderr
	exit
fi

function gc {
	gcloud compute --project "$PROJECT" "$@"
}

mkdir -p tmp hosts creds
if [ ! -f "creds/$NAME@$PROJECT" ]; then
	echo "ssh key missing for $NAME@$PROJECT, creating..."
	ssh-keygen -C "" -f "creds/$NAME@$PROJECT"
	sed -i -e 's|\(.*\)|jump:\1jump|' "creds/$NAME@${PROJECT}.pub"
fi
#sed -e "s|SSHKEY|$(cat "creds/$NAME@${PROJECT}.pub")|g" boot.sh > tmp/boot_"$NAME@$PROJECT".sh
gc instances create "$NAME" --zone "$ZONE" --machine-type "$MACHINE_TYPE" --subnet "default" --metadata-from-file startup-script=tmp/boot_"$NAME@$PROJECT".sh --tags "https-server" --boot-disk-size "10" --boot-disk-type "pd-standard" --boot-disk-device-name "$NAME"

#grab IP address
gc instances list -r "$NAME" --format=json | jq -r '.[0].networkInterfaces|.[0].accessConfigs|.[0].natIP' | xargs echo -n > "hosts/$NAME@$PROJECT"
rm hosts/current
ln -s "$NAME@$PROJECT" hosts/current

#add jump key
gc instances add-metadata "$NAME" --zone "$ZONE" --metadata-from-file ssh-keys="creds/$NAME@${PROJECT}.pub"

#add firewall rules to allow https
gc firewall-rules create "default-allow-https" --allow tcp:443 --network "default" --source-ranges "0.0.0.0/0" --target-tags "https-server"
