#!/bin/bash
#Usage ./date_filter csvfile.csv 2019-06-01 2019-06-30 newcsvfile.csv
#Given a csv file along with start and end dates. 
#This utility creates a new file if the record falls with in the range of the start and end date
#This could be used to create batches for calculate HOS since the eld data range is restriced to a month.

if [ -z "$1" ]
  then
    echo "Usage ./date_filter csvfile.csv 2019-06-01 2019-06-30 newcsvfile.csv"
    exit 1
fi

if [ -z "$2" ]
  then
    echo "Usage ./date_filter csvfile.csv 2019-06-01 2019-06-30 newcsvfile.csv"
    exit 1
fi

if [ -z "$3" ]
  then
    echo "Usage ./date_filter csvfile.csv 2019-06-01 2019-06-30 newcsvfile.csv"
    exit 1
fi

if [ -z "$4" ]
  then
    echo "Usage ./date_filter csvfile.csv 2019-06-01 2019-06-30 newcsvfile.csv"
    exit 1
fi

input_file=$1
input_start_date=$2
input_end_date=$3
fmt_start_date=$(date -d $input_start_date +"%s")
fmt_end_date=$(date -d $input_end_date +"%s")
output_file=$4
rm -rf $output_file
while IFS=, read driverId startDateTime endDateTime
do
     rec_start_date=$(date -d $startDateTime +"%s")
     rec_end_date=$(date -d $endDateTime +"%s")
     if [[ "$rec_start_date" -ge  "$fmt_start_date" && "$rec_end_date" -le "$fmt_end_date" ]];
     then
        echo "$driverId,$startDateTime,$endDateTime" >> $output_file
     elif [[ "$rec_start_date" -le  "$fmt_start_date" && "$rec_end_date" -ge "$fmt_end_date" ]];
     then
        echo "$driverId,"$input_start_date"T00:00:00,"$input_end_date"T23:59:59" >> $output_file
     elif [[ "$rec_end_date" -le "$fmt_end_date" && "$rec_end_date" -ge "$fmt_start_date" ]] || [[ "$rec_start_date" -ge "$fmt_start_date" && "$rec_end_date" -ge "$fmt_end_date" ]];
     then
        echo "$driverId,"$input_start_date"T00:00:00,"$endDateTime"" >> $output_file
     elif [[ "$rec_start_date" -ge "$fmt_start_date" && "$rec_end_date" -ge "$fmt_end_date" ]];
     then
       echo "$driverId,"$startDateTime","$input_end_date"T23:59:59" >> $output_file
     fi
done < $input_file
