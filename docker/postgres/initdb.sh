#!/bin/bash
set -e

# Create tablespaces
mkdir -pv /var/lib/postgresql/tbspaces/gsw_security_audit/{idx_gsw,gsw_data,gsw_tbs_ad,gsw_tbs_ams,gsw_tbs_cmdb,gsw_tbs_import,gsw_tbs_network,gsw_tbs_qualys,gsw_tbs_report}
mkdir -pv /var/lib/postgresql/tbspaces/metabase

# Configure values in postgresql.conf
# sed -i '/^max_connections/s/^/#/' $PGDATA/postgresql.conf
# echo "listen_addresses = '*'" >> $PGDATA/postgresql.conf
# echo "max_connections = 10" >> $PGDATA/postgresql.conf

# Configure shared_preload_libraries
echo "shared_preload_libraries = 'citext'" >> "$PGDATA"/postgresql.conf

# restart PostgreSQL
pg_ctl -D "$PGDATA" -w stop
pg_ctl -D "$PGDATA" -w start

gsw_SQL=/var/tmp/gsw_sys.sql
if [ -f $gsw_SQL ]; then
    psql -U postgres -f $gsw_SQL
fi

