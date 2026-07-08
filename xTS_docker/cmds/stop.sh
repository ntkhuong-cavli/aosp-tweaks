#!/bin/bash

echo "In the container, enter "exit" to exit docker."
echo "Run with --rm parameter, so container will be remove/stop"
echo "or"
echo "Get Container ID from \"docker ps\", then stop with \"docker stop [container_id]\""

docker-compose stop stick