#!/bin/sh


while getopts ":e:c:f:t:d:s:l:" opt; do
  case $opt in
    e) environment="$OPTARG"
    ;;
    c) carrier_id="$OPTARG"
    ;;
    f) retrieve_since="$OPTARG"
    ;;
    t) retreive_till="$OPTARG"
    ;;
    d) export_data="$OPTARG"
    ;;
    s) import_schema="$OPTARG"
    ;;
    l) user_location="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

week_before=$(date -d "$date -2 days" +"%Y-%m-%d")
today=$(date -d "$date -0 days" +"%Y-%m-%d")

retrieve_since=${retrieve_since:-$week_before}
retreive_till=${retreive_till:-$today}
import_schema=${import_schema:="yes"}
export_data=${export_data:="yes"}

if [ "$environment" = "napp" ];
then
    rds_host_name=eld-rds.napp.erdmg.com
    password=CGvxeERuNcEXG3CX
else
    rds_host_name=eld-rds.test.erdmg.com
    password=WeAreAwesome!
fi

export PGPASSWORD=$password
destination_server=172.19.1.97

default_location=/tmp/$carrier_id
location=${user_location:-$default_location}


echo "Data copying from environment: $environment for carrier_id= $carrier_id from date=$retrieve_since till= $retreive_till.  More options: export data = $export_data, erase data-= $import_schema, file location = $location"

if [ "$export_data" = "yes" ];
then

  echo "Starting to copy data from RDS $rds_host_name"
  rm -rf "$location"
  mkdir "$location"
  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.carrier where id='"$carrier_id"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/carrier.csv

  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.carrier_hos_cycle where carrier_id='"$carrier_id"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/carrier_hos_cycle.csv
  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.bill_of_lading where org_id='"$carrier_id"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/bill_of_lading.csv

  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.vehicle where carrier_id='"$carrier_id"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/vehicle.csv
  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.terminal) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/terminal.csv

  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.eld where carrier_id='"$carrier_id"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/eld.csv
  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.event where carrier_id='"$carrier_id"' and event_timestamp between '"$retrieve_since"' and '"$retreive_till"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/event.csv

  #psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.trailer) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/trailer.csv
  #psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.event_has_trailer where event_id in (select event_id from eld.event where carrier_id='"$carrier_id"'  and event_timestamp >= '"$retrieve_since"' and event_timestamp >= '"$retreive_till"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/event_has_trailer.csv

  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.driver where carrier_id='"$carrier_id"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/driver.csv
  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.driver_hos_cycle where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/driver_hos_cycle.csv
  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.driver_terminal_history where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/driver_terminal_history.csv

  psql -U eld -h "$rds_host_name" -d eld -c "COPY (select * from eld.carrier_edit where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/carrier_edit.csv

  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.hos_ruleset_available where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/hos_ruleset_available.csv
  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.hos_ruleset_available_exemption where hos_ruleset_available_id in (select id from eld.hos_ruleset_available where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"'))) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/hos_ruleset_available_exemption.csv
  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.hos_ruleset_suggestion where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/hos_ruleset_suggestion.csv
  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.hos_ruleset_suggestion_exemption where hos_ruleset_suggestion_id in (select id from eld.hos_ruleset_suggestion where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"'))) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/hos_ruleset_suggestion_exemption.csv
  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.hos_ruleset where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/hos_ruleset.csv
  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.hos_ruleset_exemption where hos_ruleset_id in (select id from eld.hos_ruleset where driver_id in (select id from eld.driver where carrier_id='"$carrier_id"'))) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/hos_ruleset_exemption.csv


  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.output_file_batch where created >='"$retrieve_since"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/output_file_batch.csv
  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.output_file where output_file_batch_id in (select id from eld.output_file_batch where created >='"$retrieve_since"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/output_file.csv

  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.unassigned_trip where carrier_id ='"$carrier_id"' and start_date >= '"$retrieve_since"' and end_date <= '"$retreive_till"') To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/unassigned_trip.csv
  psql -U eld -h "$rds_host_name"  -d eld -c "COPY (select * from eld.unassigned_trip_has_events where trip_id in (select id from eld.unassigned_trip where carrier_id='"$carrier_id"' and start_date >='"$retrieve_since"' and end_date <= '"$retreive_till"')) To STDOUT With CSV HEADER DELIMITER ',';" > "$location"/unassigned_trip_has_events.csv

fi

if [ $import_schema = "yes" ];
then
  echo "Exporting schema from $rds_host_name" 
  pg_dump --dbname=eld --username=eld --encoding=UTF8 --schema=eld --schema-only --file=$location/schema.dump -U eld -h $rds_host_name
  echo "Trucating your eld database. This would erase all your data."
  
  export PGPASSWORD=postgres
  psql -U postgres -h "$destination_server" -c "drop database eld"
  #psql -U postgres -h "$destination_server" -c "DROP SCHEMA eld CASCADE;"
  psql -U postgres -h "$destination_server" -c "create database eld"
  psql -U postgres -h "$destination_server" -d eld -c "create extension \"uuid-ossp\"";
  psql -U postgres -h "$destination_server" -d eld -c "create schema eld";
  psql -U postgres -h "$destination_server" -d eld -c "CREATE ROLE eld WITH LOGIN ENCRYPTED PASSWORD 'WeAreAwesome!'"

  sed -i "s/uuid_generate_v4/public.uuid_generate_v4/g" $location/schema.dump
  sed -i "s/public\.public/public/g" $location/schema.dump

  psql -U postgres -h "$destination_server" -d eld --file=$location/schema.dump
  echo "New schema imported."
fi

echo "Copying data..."
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.carrier FROM '"$location"/carrier.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.carrier_hos_cycle FROM '"$location"/carrier_hos_cycle.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.bill_of_lading FROM '"$location"/bill_of_lading.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.vehicle FROM '"$location"/vehicle.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.terminal FROM '"$location"/terminal.csv' DELIMITER ',' CSV HEADER"

psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.driver FROM '"$location"/driver.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.driver_hos_cycle FROM '"$location"/driver_hos_cycle.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.driver_terminal_history FROM '"$location"/driver_terminal_history.csv' DELIMITER ',' CSV HEADER"


psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.eld FROM '"$location"/eld.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.event FROM '"$location"/event.csv' DELIMITER ',' CSV HEADER"
#psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.trailer FROM '"$location"/trailer.csv' DELIMITER ',' CSV HEADER"
#psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.event_has_trailer FROM '"$location"/event_has_trailer.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.carrier_edit FROM '"$location"/carrier_edit.csv' DELIMITER ',' CSV HEADER"

psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.hos_ruleset_available FROM '"$location"/hos_ruleset_available.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.hos_ruleset_available_exemption FROM '"$location"/hos_ruleset_available_exemption.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.hos_ruleset_suggestion FROM '"$location"/hos_ruleset_suggestion.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.hos_ruleset_suggestion_exemption FROM '"$location"/hos_ruleset_suggestion_exemption.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.hos_ruleset FROM '"$location"/hos_ruleset.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.hos_ruleset_exemption FROM '"$location"/hos_ruleset_exemption.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.output_file_batch FROM '"$location"/output_file_batch.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.output_file FROM '"$location"/output_file.csv' DELIMITER ',' CSV HEADER"

psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.unassigned_trip FROM '"$location"/unassigned_trip.csv' DELIMITER ',' CSV HEADER"
psql -U postgres -h "$destination_server" -d eld -c "\COPY eld.unassigned_trip_has_events FROM '"$location"/unassigned_trip_has_events.csv' DELIMITER ',' CSV HEADER"


echo "Data Copied successfully"
