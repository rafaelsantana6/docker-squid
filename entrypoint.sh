#!/bin/bash
set -e

create_log_dir() {
  echo "mkdir -p ${SQUID_LOG_DIR}"
  mkdir -p ${SQUID_LOG_DIR}
  chmod -R 755 ${SQUID_LOG_DIR}
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_LOG_DIR}
}

create_cache_dir() {
  mkdir -p ${SQUID_CACHE_DIR}
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_CACHE_DIR}
}

change_uid_gid() {
  usermod -u ${UID} ${SQUID_USER}
  groupmod -g ${GID} ${SQUID_USER}
}

echo "UID: ${UID}"
echo "GID: ${GID}"
echo "SQUID_VERSION: ${SQUID_VERSION}"
echo "SQUID_CACHE_DIR: ${SQUID_CACHE_DIR}"
echo "SQUID_LOG_DIR: ${SQUID_LOG_DIR}"
echo "SQUID_USER: ${SQUID_USER}"

if [ ${UID} -ne 13 ] && [ ${GID} -ne 13 ]; then
    echo "Changing UID and GID for user ${SQUID_USER}: $(id ${SQUID_USER})"
    change_uid_gid
    echo "New ${SQUID_USER}'s UID and GID: $(id ${SQUID_USER})"
fi

echo "Creating LOG directory..."
create_log_dir

echo "Creating CACHE directory..."
create_cache_dir

echo "Launching logger..."
/sbin/logger.sh &

# allow arguments to be passed to squid
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == squid || ${1} == $(which squid) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch squid
if [[ -z ${1} ]]; then
  if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]; then
    echo "Initializing cache..."
    $(which squid) -N -f /etc/squid/squid.conf -z
  fi
  echo "Starting squid..."
  exec $(which squid) -f /etc/squid/squid.conf -NYCd 1 ${EXTRA_ARGS}
else
  exec "$@"
fi
