#!/bin/sh

#rds_host_name=$1
rds_host_name=eld-rds.test.erdmg.com
#driver_id=$2 
driver_id='0ee52c3e-8eb5-45eb-9288-6d1ba22fec01'
carrier_id='6529af9e-f05a-4464-91e7-67d7bbea353b'
retreive_since='2019-12-01'
password=WeAreAwesome!
export PGPASSWORD=$password
location=/tmp/$carrier_id
rm -rf "$location"
mkdir "$location"

echo "Starting to copy data from RDS $rds_host_name"
psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.carrier where id='"$carrier_id"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/carrier.csv

psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.carrier_hos_cycle where carrier_id='"$carrier_id"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/carrier_hos_cycle.csv
psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.bill_of_lading where org_id='"$carrier_id"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/bill_of_lading.csv

psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.vehicle where carrier_id='"$carrier_id"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/vehicle.csv
psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.terminal) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/terminal.csv

psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.eld where carrier_id='"$carrier_id"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/eld.csv
psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.event where carrier_id='"$carrier_id"' and created > '"$retreive_since"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/event.csv

psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.trailer) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/trailer.csv
psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.event_has_trailer where event_id in (select event_id from eld.event where carrier_id='"$carrier_id"' and created > '"$retreive_since"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/event_has_trailer.csv

psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.driver where carrier_id='"$carrier_id"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/driver.csv
psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.driver_hos_cycle where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/driver_hos_cycle.csv
##psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.driver_terminal where driver_id in (select id from eld.driver)) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/driver_terminal_history.csv

psql -U eld -h "$rds_host_name" -d eld -c "COPY (select * from eld.carrier_edit where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/carrier_edit.csv

psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.hos_ruleset_available where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/hos_ruleset_available.csv
psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.hos_ruleset_available_exemption where hos_ruleset_available_id in (select id from eld.hos_ruleset_available where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"'))) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/hos_ruleset_available_exemption.csv
psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.hos_ruleset_suggestion where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/hos_ruleset_suggestion.csv
psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.hos_ruleset_suggestion_exemption where hos_ruleset_suggestion_id in (select id from eld.hos_ruleset_suggestion where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"'))) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/hos_ruleset_suggestion_exemption.csv
psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.hos_ruleset where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/hos_ruleset.csv
psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.hos_ruleset_exemption where hos_ruleset_id in (select id from eld.hos_ruleset where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"'))) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/hos_ruleset_exemption.csv


psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.output_file_batch where created ='"$retreive_since"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/output_file_batch.csv
psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.output_file where output_file_batch_id in (select id from eld.output_file_batch where created ='"$retreive_since"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/output_file.csv



#total_cpus=$(lscpu | egrep -E '^CPU\(s\):' | awk '{ print $2 }')
#pigz_cpus=$(echo "${total_cpus}*3/4" | bc)
echo "Compressing csvs"
#pigz -p ${pigz_cpus} "$location"/*.csv

pg_dump --dbname=eld --username=eld --encoding=UTF8 --schema=eld --schema-only --file=$location/schema.dump -U eld -h $rds_host_name

echo "Importing to copy"
export PGPASSWORD=postgres
psql -U postgres -h localhost -c "drop database eld"
psql -U postgres -h localhost -c "DROP SCHEMA eld CASCADE;"
psql -U postgres -h localhost -c "create database eld"
psql -U postgres -h localhost -c "create extension \"uuid-ossp\"";
psql -U postgres -h localhost -c "create schema eld";

sed -i "s/uuid_generate_v4/public.uuid_generate_v4/g" $location/schema.dump
sed -i "s/public\.public/public/g" $location/schema.dump

psql -U postgres -h localhost -d postgres --file=$location/schema.dump


echo "Copying data"
psql -U postgres -h localhost -c "COPY eld.carrier FROM '"$location"/carrier.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.carrier_hos_cycle FROM '"$location"/carrier_hos_cycle.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.bill_of_lading FROM '"$location"/bill_of_lading.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.vehicle FROM '"$location"/vehicle.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.terminal FROM '"$location"/terminal.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.eld FROM '"$location"/eld.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.event FROM '"$location"/event.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.trailer FROM '"$location"/trailer.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.event_has_trailer FROM '"$location"/event_has_trailer.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.driver FROM '"$location"/driver.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.driver_hos_cycle FROM '"$location"/driver_hos_cycle.csv' DELIMITER ',' CSV HEADER"
#psql -U postgres -h localhost -c "COPY eld.driver_terminal_history FROM '"$location"/driver_terminal_history.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.carrier_edit FROM '"$location"/carrier_edit.csv' DELIMITER ',' CSV HEADER"

psql -U postgres -h localhost -c "COPY eld.hos_ruleset_available FROM '"$location"/hos_ruleset_available.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.hos_ruleset_available_exemption FROM '"$location"/hos_ruleset_available_exemption.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.hos_ruleset_suggestion FROM '"$location"/hos_ruleset_suggestion.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.hos_ruleset_suggestion_exemption FROM '"$location"/hos_ruleset_suggestion_exemption.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.hos_ruleset FROM '"$location"/hos_ruleset.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.hos_ruleset_exemption FROM '"$location"/hos_ruleset_exemption.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.output_file_batch FROM '"$location"/output_file_batch.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h localhost -c "COPY eld.output_file FROM '"$location"/output_file.csv' DELIMITER ',' CSV HEADER"
echo "Import completed"