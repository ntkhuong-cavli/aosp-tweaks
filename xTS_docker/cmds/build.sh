#!/bin/bash

docker-compose build --no-cache base
# docker-compose build --no-cache cts
docker-compose build --no-cache stick
# or
# docker build -t cavli-test-docker:stick_testtools ./cts-stick

