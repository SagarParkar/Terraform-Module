#! /bin/bash
cd /home/sparkar/airbyte
bash run-ab-platform.sh -d
docker compose up -d
cd /home/sparkar/observability
docker compose up -d
sleep 60
docker exec rundeck sudo bash /tmp/rd.sh