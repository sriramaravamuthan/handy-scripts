#!/bin/bash
#Usage ./date_filter csvfile.csv 2019-06-01 2019-06-30 newcsvfile.csv
#Given a csv file along with start and end dates. 
#This utility creates a new file if the record falls with in the range of the start and end date
#This could be used to create batches for calculate HOS since the eld data range is restriced to a month.
IFS=","
given_startDate=$(date -d $2 +"%s")
given_endDate=$(date -d $3 +"%s")
while read driverId startDateTime endDateTime
do
     fileStartDateTime=$(date -d $startDateTime +"%s")
     fileEndDateTime=$(date -d $endDateTime +"%s")
     #echo "$startDateTime"
     if [[ "$fileStartDateTime" -ge  "$given_startDate" && "$fileEndDateTime" -le "$given_endDate" ]];
     then
        echo "$driverId,$startDateTime ,$endDateTime" >> $4
     elif [[ "$fileStartDateTime" -le  "$given_startDate" && "$fileEndDateTime" -ge "$given_endDate" ]];
     then
        echo "$driverId,$2T00:00:00 ,$3T00:00:00" >> $4
     fi
done < $1
