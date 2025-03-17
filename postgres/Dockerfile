from postgres:15-alpine

workdir /
run pwd
copy init_postgres.sh /docker-entrypoint-initdb.d/init.sh
run chmod +x /docker-entrypoint-initdb.d/init.sh
expose 5432

cmd ["postgres"]
