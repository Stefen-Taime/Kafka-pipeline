#!/usr/bin/env python3

argument=$1

if [ $argument = "up" ]; then
    echo "Creating infrastructure..."
    docker-compose up -d mysql
    sleep 10
    docker-compose up -d kafka
    sleep 10
    docker-compose up -d connect
    sleep 10
    docker-compose up -d postgres
    sleep 10
    docker-compose up -d mongo
    sleep 10
    docker-compose up -d elasticsearch
    sleep 10
    docker-compose up -d kibana
    sleep 10
    docker-compose up -d ksql
    sleep 10
     docker-compose up -d adminer
elif [ $argument = "stop" ]; then
    echo "Stopping infrastructure..."
    docker-compose stop
elif [ $argument = "down" ]; then
    echo "Deleting infrastructure..."
    docker-compose down
else
  echo "Unknown argumnet! Options: up, stop, down"
fi