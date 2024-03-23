FROM ubuntu:jammy-20240212

ENV SQUID_VERSION 5.7
ENV SQUID_CACHE_DIR /var/spool/squid
ENV SQUID_LOG_DIR /var/log/squid
ENV SQUID_USER proxy
ENV UID 13
ENV GID 13

RUN sed -i 's/htt[p|ps]:\/\/archive.ubuntu.com\/ubuntu\//mirror:\/\/mirrors.ubuntu.com\/mirrors.txt/g' /etc/apt/sources.list

RUN apt-get update && \
 DEBIAN_FRONTEND=noninteractive && \
 apt-get install -y --no-install-recommends squid=${SQUID_VERSION}* && \
 rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3128/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]