#!/bin/bash
PROJECT="${PROJECT:-$1}"

if [ -z "$PROJECT" ]; then
	echo "You must specify PROJECT environment variable" > /dev/stderr
	exit
fi

exec openssl s_client -connect $(gcloud compute instances list --project "$PROJECT" | awk '/^jump / {print $5}'):443 -quiet 2> /dev/null
