#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
source "${ROOT_DIR}/sh/wait_until_ready.sh"

# - - - - - - - - - - - - - - - - - - - - -
wait_until_running()
{
  local n=20
  while [ $(( n -= 1 )) -ge 0 ]
  do
    if docker ps --filter status=running --format '{{.Names}}' | grep -q "^${1}$" ; then
      return
    else
      sleep 0.1
    fi
  done
  echo "${1} not up after 2 seconds"
  docker logs "${1}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - -

echo
docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate

wait_until_ready custom_start_points    4526
wait_until_ready exercises_start_points 4525
wait_until_ready languages_start_points 4524

wait_until_ready runner    4597
wait_until_ready differ    4567
wait_until_ready saver     4537
#wait_until_ready zipper    4587

wait_until_running test_web
