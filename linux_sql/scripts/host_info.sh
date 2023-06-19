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

# Save CPU info into variable
lscpu_out=$(lscpu)

# Gather all relevant fields for host_info insertion
hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out"  | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | awk '{$1=$2=""; print}' | xargs)
cpu_mhz=$(echo "$lscpu_out"  | egrep "^CPU MHz:" | awk '{print $3}' | xargs)
l2_cache=$(echo "$lscpu_out" | egrep "^L2 cache:" | awk '{print $3}' | cut -d "K" -f 1 | xargs)
timestamp=$(date --rfc-3339 seconds | cut -d "-" -f 1-3)
total_mem=$(vmstat --unit K | tail -1 | awk '{print $4}')

# Generate query to insert into host_info table
insert_query="INSERT INTO host_info(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, "timestamp", total_mem) VALUES('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, '$timestamp', $total_mem);"

# Password for psql
export PGPASSWORD=$psql_password

# Run query on host_info table
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_query"
exit $?
