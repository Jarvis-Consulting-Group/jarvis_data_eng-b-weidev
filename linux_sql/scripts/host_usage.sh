#!/bin/sh

# Assign arguments to variables
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Needs exactly 5 parameters
if [ "$#" -ne 5 ]; then
	echo "Illegal number of parameters"
	exit 1
fi

# Virtual memory statistics in MB
vmstat_mb=$(vmstat --unit M)

# Gather all relevant fields for host_usage insertion
hostname=$(hostname -f)
timestamp=$(vmstat -t | tail -1 | awk '{print $18, $19}' | xargs)
memory_free=$(echo "$vmstat_mb" | tail -1 | awk -v col="4" '{print $col}')
cpu_idle=$(echo "$vmstat_mb" | tail -1 | awk -v col="15" '{print $col}')
cpu_kernel=$(echo "$vmstat_mb" | tail -1 | awk -v col="14" '{print $col}')
disk_io=$(vmstat --unit M -d | tail -1 | awk -v col="10" '{print $col}')
disk_available=$(df -BM | tail -1 | awk -v col="4" '{print $col}' | cut -d "M" -f 1)

# Subquery to retrieve host id from host_info using host name
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"

# Generate query to insert into host_usage
insert_query="INSERT INTO host_usage("timestamp", host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)  VALUES('$timestamp', $host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"

# Password for psql
export PGPASSWORD=$psql_password

# Run query on host_usage table
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_query"
exit $?
