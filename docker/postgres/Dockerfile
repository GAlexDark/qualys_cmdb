ARG PG_VER
ARG BUILD_VERSION
FROM postgres:${PG_VER}

ENV TZ=Europe/Kiev

LABEL  name="sandbox/postgres-${PG_VER}" version="${BUILD_VERSION}"
COPY ./gsw_sys.sql /var/tmp/
RUN localedef -i uk_UA -c -f UTF-8 -A /usr/share/locale/locale.alias uk_UA.UTF-8 && \
    mkdir -pv /var/lib/postgresql/tbspaces/{gsw_security_audit,metabase} && mkdir -pv /import && chown postgres:postgres /import

EXPOSE 5432/tcp
VOLUME [ "/var/lib/postgresql/tbspaces" ]
VOLUME [ "/import" ]