#!/bin/bash
NAME="${NAME:-jump}"
ZONE="${ZONE:-us-east1-d}"
PROJECT="${PROJECT:-$1}"

if [ -z "$PROJECT" ]; then
	echo "You must specify PROJECT environment variable" > /dev/stderr
	exit
fi

function gc {
	gcloud compute --project "$PROJECT" "$@"
}

gc instances delete "$NAME" --zone "$ZONE"  --delete-disks=all
