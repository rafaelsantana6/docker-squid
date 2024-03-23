#!/bin/bash

logger() {
    tail -vn 0 -F /var/log/squid/{cache,access}.log &
}

while [ ! -f /var/log/squid/cache.log ] || [ ! -f /var/log/squid/access.log ]; do
    sleep 1
done

logger