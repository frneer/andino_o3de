#!/bin/bash

set +e

# TODO(Fran): cd dirname...

HELP="Usage: $me [-s|--service <service>]"
SERVICE="andino_o3de"

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
    *)
        echo "Invalid argument: $1"
        echo $HELP
        exit 1
        ;;
    esac
done

docker compose exec -it $SERVICE bash
