FROM timescale/timescaledb:1.7.1-pg12

LABEL maintainer="Chatchai Daecha (chatchai.daecha@outlook.com, chkob81@hotmail.com)"
ARG POSTGIS_VERSION
ENV POSTGIS_VERSION ${POSTGIS_VERSION:-2.5.3}

COPY 003_setup_replication.sh /docker-entrypoint-initdb.d
COPY 004_add_pg_extension.sql /docker-entrypoint-initdb.d
COPY 005_create_db_users.sql /docker-entrypoint-initdb.d

RUN set -ex \
    && apk add --no-cache --virtual .fetch-deps \
                ca-certificates \
                openssl \
                tar \
    # add libcrypto from (edge:main) for gdal-2.3.0
    #&& apk add --no-cache --virtual .crypto-rundeps \
    #            --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    #            libressl2.7-libcrypto \
    #            libcrypto1.1 \
    #            poppler \
    #            llvm9-dev \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        file \
        json-c-dev \
        libtool \
        libxml2-dev \
        make \
        perl \
        llvm \
        clang \
        clang-dev \
    && apk add --no-cache --virtual .build-deps-edge \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        g++ \
        gdal-dev \
        geos-dev \
        proj-dev \
        protobuf-c-dev \
    && cd /tmp \
    && wget https://github.com/postgis/postgis/archive/${POSTGIS_VERSION}.tar.gz -O - | tar -xz \
    && chown root:root -R postgis-${POSTGIS_VERSION} \
    && cd /tmp/postgis-${POSTGIS_VERSION} \
    && ./autogen.sh \
    && ./configure \
    && echo "PERL = /usr/bin/perl" >> extensions/postgis/Makefile \
    && echo "PERL = /usr/bin/perl" >> extensions/postgis_topology/Makefile \
    && make -s \
    && make -s install \
    && apk add --no-cache --virtual .postgis-rundeps \
        json-c \
    && apk add --no-cache --virtual .postgis-rundeps-edge \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        geos \
        gdal \
        proj \
        protobuf-c \
        libstdc++ \
    && cd / \
    && rm -rf /tmp/postgis-${POSTGIS_VERSION} \
    && apk del .fetch-deps .build-deps .build-deps-edge

ENV PG_MAX_WAL_SENDERS 8
ENV PG_WAL_KEEP_SEGMENTS 8