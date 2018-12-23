sed -i '/Environment=PGDATA/d' /usr/lib/systemd/system/postgresql-9.5.service
sed -i '/Location of database directory/ a\Environment=PGDATA=/home/pgdata' /usr/lib/systemd/system/postgresql-9.5.service
systemctl enable postgresql-9.5.service
systemctl start postgresql-9.5.service
su postgres -c 'initdb'
su postgres -c 'pg_ctl -D $PGDATA start'
su postgres -c 'pg_ctl -D $PGDATA stop'
su postgres -c 'exit'
sed -i '/listen_addresses/d' /home/pgdata/postgresql.conf
sed -i '/max_connections/d' /home/pgdata/postgresql.conf
sed -i '/password_encryption/d' /home/pgdata/postgresql.conf
sed -i "/Connection Settings/ a\listen_addresses = '*'" /home/pgdata/postgresql.conf
sed -i '/#port = 5432/ a\max_connections = 1000' /home/pgdata/postgresql.conf
sed -i '/#ssl_crl_file = ''/ a\password_encryption = on' /home/pgdata/postgresql.conf
sed -i '$a host       all      all      0.0.0.0/0     trust' /home/pgdata/pg_hba.conf

systemctl restart postgresql-9.5.service
systemctl stop firewalld.service
systemctl disable firewalld.service
psql -U postgres -c "CREATE USER btf CREATEDB LOGIN PASSWORD '123456';"
psql -U postgres -c "CREATE DATABASE osm OWNER btf;"
psql -U postgres -d osm -c "CREATE EXTENSION postgis;"
psql -U postgres -d osm -c "CREATE EXTENSION postgis_topology;"
psql -U postgres -d osm -c "CREATE EXTENSION ogr_fdw;"
psql -U postgres -d osm -c "CREATE EXTENSION postgis_sfcgal;"
psql -U postgres -d osm -c "CREATE EXTENSION hstore;"
psql -U postgres -d osm -c "CREATE EXTENSION fuzzystrmatch;"
