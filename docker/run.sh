#!/bin/bash

set +e

HELP="Usage: $me [-b|--build] [-s|--service <service>]"
SERVICE="andino_o3de"
BUILD=false

while [[ "$1" != "" ]]; do
    case "$1" in
    -h | --help)
        echo $HELP
        exit 0
        ;;
    -s | --service)
        SERVICE=$2
        shift 2
        ;;
    -b | --build)
        BUILD=true
        shift
        ;;
    *)
        echo "Invalid argument: $1"
        echo $HELP
        exit 1
        ;;
    esac
done


cd $(dirname $0)

export USERNAME=$(whoami)
export USERID=$(id -u)
export GROUPID=$(id -g)

docker compose run --rm -w /home/$USERNAME/workspace ${BUILD:+--build} $SERVICE
