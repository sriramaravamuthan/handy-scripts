# handy-scripts
List of shell and sql scripts that can be handy

# Data Copier: psql-copy

To copy data from NAPP to Local Postgres.

# Example 1 : For a carrier from start to end date
./psql-copy.sh -e 'napp' -c 'd5ddf747-93b5-4dab-b450-5eca585e1f0a' -f '2020-03-06' -t '2020-03-16'

# Example 2 : For a carrier for last 1 week (default) without erasing local data.
./psql-copy.sh -e 'napp' -c 'd5ddf747-93b5-4dab-b450-5eca585e1f0a' -s 'no'
