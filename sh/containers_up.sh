#!/bin/bash -Eeu

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

containers_up()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose-depends.yml" \
    --file "${ROOT_DIR}/docker-compose.yml" \
    up \
    -d \
    --force-recreate \
    web

  wait_until_ready model     4528
  wait_until_ready runner    4597
  wait_until_ready saver     4537

  wait_until_running test_web
}
