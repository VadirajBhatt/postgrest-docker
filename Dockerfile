FROM debian:stretch-slim

ARG POSTGREST_VERSION

# Install libpq5
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends libpq5; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install postgrest
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl ca-certificates xz-utils; \
    cd /tmp; \
    curl -SLO https://github.com/PostgREST/postgrest/releases/download/${POSTGREST_VERSION}/postgrest-${POSTGREST_VERSION}-ubuntu.tar.xz; \
    tar -xJvf postgrest-${POSTGREST_VERSION}-ubuntu.tar.xz; \
    mv postgrest /usr/local/bin/postgrest; \
    cd /; \
    apt-get purge --auto-remove -y ca-certificates xz-utils; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /etc/postgrest
VOLUME /etc/postgrest
COPY postgrest.conf /etc/postgrest/postgrest.conf


ENV PGRST_DB_URI= \
    PGRST_DB_SCHEMA=public \
    PGRST_DB_ANON_ROLE= \
    PGRST_DB_POOL=100 \
    PGRST_DB_EXTRA_SEARCH_PATH=public \
    PGRST_SERVER_HOST=*4 \
    PGRST_SERVER_PORT=3000 \
    PGRST_SERVER_PROXY_URI= \
    PGRST_JWT_SECRET= \
    PGRST_SECRET_IS_BASE64=false \
    PGRST_JWT_AUD= \
    PGRST_MAX_ROWS= \
    PGRST_PRE_REQUEST= \
    PGRST_ROLE_CLAIM_KEY=".role"

# PostgREST reads /etc/postgrest/postgrest.conf so map the configuration
# file in when you run this container
CMD exec postgrest /etc/postgrest/postgrest.conf

EXPOSE 3000
