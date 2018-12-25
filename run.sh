#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "usage: <import|run>"
    echo "commands:"
    echo "    import: 初始化数据库以及导入数据"
    echo "    run: 启动地图服务器 at http://ip:3000/t/map/{z}/{x}/{y}.png"
    echo "环境变量参考:"
    echo "    MAX_MEM: 导入地图数据时候需要的内存，最多不能超过30000(30GB)，默认4000"
    echo "    THREADS: 允许的线程数量，默认4"
    echo "    SHARED_BUFFER: 默认值是128MB，需要带单位 GB，MB"
    echo "    WORK_MEM: 默认值是4MB，需要带单位 GB，MB"
    echo "    MAINTENANCE_WORK_MEM: 默认值是64MB，需要带单位 GB，MB"
    echo "    EFFECTIVE_CACHE_SIZE: 默认值是4GB，需要带单位 GB，MB"

    exit 1
fi

if [ "$1" = "import" ]; then
    ## 授权卷
    chown postgres:postgres /home/pgdata
    chmod 750 /home/pgdata

    ## 初始化数据库且配置
    su postgres -c 'initdb -D /home/pgdata/'
    su postgres -c 'pg_ctl -D /home/pgdata/ start'
    su postgres -c 'exit'
    sed -i '/listen_addresses/d' /home/pgdata/postgresql.conf
    sed -i '/max_connections/d' /home/pgdata/postgresql.conf
    sed -i '/password_encryption/d' /home/pgdata/postgresql.conf
    sed -i '/hot_standby/d' /home/pgdata/postgresql.conf
    sed -i '/synchronous_commit/d' /home/pgdata/postgresql.conf
    sed -i '/#fsync = on/d' /home/pgdata/postgresql.conf
    sed -i '/shared_buffers = 128MB/d' /home/pgdata/postgresql.conf
    sed -i '/#work_mem = 4MB/d' /home/pgdata/postgresql.conf
    sed -i '/#maintenance_work_mem = 64MB/d' /home/pgdata/postgresql.conf
    sed -i '/#effective_cache_size = 4GB/d' /home/pgdata/postgresql.conf


    sed -i "/Connection Settings/ a\listen_addresses = '*'" /home/pgdata/postgresql.conf
    sed -i '/#port = 5432/ a\max_connections = 1000' /home/pgdata/postgresql.conf
    sed -i '/#ssl_crl_file = ''/ a\password_encryption = on' /home/pgdata/postgresql.conf
    sed -i '/These settings are ignored on a master server/ a\hot_standby = on' /home/pgdata/postgresql.conf
    sed -i '/#full_page_writes = on/ a\synchronous_commit = off' /home/pgdata/postgresql.conf
    sed -i '/#full_page_writes = on/ a\fsync = off' /home/pgdata/postgresql.conf
    sed -i '/# - Memory -/ a\shared_buffers = '${SHARED_BUFFER:-128MB} /home/pgdata/postgresql.conf
    sed -i '/# - Memory -/ a\work_mem = '${WORK_MEM:-4MB} /home/pgdata/postgresql.conf
    sed -i '/# - Memory -/ a\maintenance_work_mem = '${MAINTENANCE_WORK_MEM:-64MB} /home/pgdata/postgresql.conf
    sed -i '/# - Memory -/ a\effective_cache_size = '${EFFECTIVE_CACHE_SIZE:-4GB} /home/pgdata/postgresql.conf


    sed -i '$a host       all      all      0.0.0.0/0     trust' /home/pgdata/pg_hba.conf
    su postgres -c 'pg_ctl -D /home/pgdata/ restart'
    su postgres -c 'exit'
    sleep 5

    ## 创建地图服务器且配置postgis
    psql -U  postgres -c "UPDATE pg_database SET datistemplate=FALSE WHERE datname='template1'";
    psql -U  postgres -c "DROP DATABASE template1;";
    psql -U  postgres -c "CREATE DATABASE template1 WITH owner=postgres template=template0 encoding='UTF8'";
    psql -U  postgres -c "UPDATE pg_database SET datistemplate=TRUE WHERE datname='template1';";
    psql -U  postgres -c "CREATE USER btf CREATEDB LOGIN PASSWORD '123456';"
    psql -U  postgres -c "CREATE DATABASE osm OWNER btf encoding='UTF8';"
    psql -U postgres -d osm -c "CREATE EXTENSION postgis;"
    psql -U postgres -d osm -c "CREATE EXTENSION postgis_topology;"
    psql -U postgres -d osm -c "CREATE EXTENSION ogr_fdw;"
    psql -U postgres -d osm -c "CREATE EXTENSION postgis_sfcgal;"
    psql -U postgres -d osm -c "CREATE EXTENSION hstore;"
    psql -U postgres -d osm -c "CREATE EXTENSION fuzzystrmatch;"

    ## 导入数据
    osm2pgsql -U btf -P 5432 --number-processes ${THREADS:-4} -C $((${MAX_MEM:-4000} < 30000?${MAX_MEM:-4000}:30000)) -S /home/openstreetmap-carto/openstreetmap-carto.style -s -d osm -k -c --slim /data.osm.pbf
    psql -U postgres -d osm < /indexes.sql
    su postgres -c 'pg_ctl -D /home/pgdata/ stop'
    su postgres -c 'exit'
    exit 0
fi

if [ "$1" = "run" ]; then
    chown postgres:postgres /home/pgdata
    chmod 700 /home/pgdata
    su postgres -c 'pg_ctl -D /home/pgdata/ start'
    su postgres -c 'exit'
    sleep 5
    pm2 -i ${THREADS:-4} start /home/tileserver/app.js
    tail -f /var/log/1.txt
    exit 0
fi

echo "invalid command"
exit 1
