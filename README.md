# handy-scripts
List of shell and sql scripts that can be handy

Data Copier: psql-copy

To copy data from NAPP to Local Postgres.

./psql-copy.sh -e 'napp' \
-c 'd5ddf747-93b5-4dab-b450-5eca585e1f0a' \
-f '2020-03-06'\
-t '2020-03-16'
