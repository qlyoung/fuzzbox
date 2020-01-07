#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit
fi

docker build .
VOL=$(docker volume create)
VOLDETAILS=$(docker volume inspect $VOL)

printf "Results are saved in the container filesystem.\n"
printf "Container /opt filesystem details: %s\n" $VOLDETAILS
sleep 1

docker run -it -p 3000:3000 -p 8086:8086 --mount source=$VOL,target=/opt `docker images -q | head -n 1`

