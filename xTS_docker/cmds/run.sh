# Start the container
docker-compose up -d stick

# Attach a shell
docker exec -it stick_testtools bash

# STOP
# docker-compose stop stick