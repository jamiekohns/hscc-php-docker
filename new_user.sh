#!/bin/bash
USERNAME=""
NGINX_PORT=""
IDE_PORT=""
IDE_PASSWORD=""
IDE_SUDO_PASSWORD=""

usage() {
  echo "Usage: $0 -u USERNAME -n NGINX_PORT -i IDE_PORT [-p PASSWORD] [-s SUDO_PASSWORD]" 1>&2
}

exit_abnormal() {
  usage
  exit 1
}

while getopts ":u:n:i:" options; do
    case "${options}" in
        u)
            USERNAME=${OPTARG}
            ;;
        n)
            NGINX_PORT=${OPTARG}
            ;;
        i)
            IDE_PORT=${OPTARG}
            ;;
        p)
            IDE_PASSWORD=${OPTARG}
            ;;
        s)
            IDE_SUDO_PASSWORD=${OPTARG}
            ;;
        :)
            echo "Error: -${OPTARG} requires an argument."
            exit_abnormal
            ;;
        *)
            exit_abnormal
            ;;
    esac
done

if [ "$IDE_PASSWORD" = "" ]; then
    IDE_PASSWORD="hscc-atlanta"
fi

if [ "$IDE_SUDO_PASSWORD" = "" ]; then
    IDE_SUDO_PASSWORD="s7d2m0-i1y"
fi

if test -f "${USERNAME}.env"; then
    echo "User ${USERNAME} alredy exists."
    exit 1
fi

IDE_PORT_IN_USE=$(grep -rl "_PORT=${IDE_PORT}" ./*.env)
NGX_PORT_IN_USE=$(grep -rl "_PORT=${NGINX_PORT}" ./*.env)

if [ -n "$NGX_PORT_IN_USE" ]; then
    echo "NGINX port is in use."
    exit 1
fi

if [ -n "$IDE_PORT_IN_USE" ]; then
    echo "IDE port is in use."
    exit 1
fi

echo "USERNAME=${USERNAME}
NGINX_PORT=${NGINX_PORT}
IDE_PORT=${IDE_PORT}
PASSWORD=${IDE_PASSWORD}
SUDO_PASSWORD=${IDE_SUDO_PASSWORD}" >> "${USERNAME}.env";

#docker-compose --env-file="$1.env" --project-name="$1-dev" up -d