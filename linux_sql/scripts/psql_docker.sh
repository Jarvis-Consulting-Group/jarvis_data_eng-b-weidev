#!/bin/sh

# CLI arguments - arg1 = command, arg2 = psql username, arg3 = psql password
cmd=$1
db_username=$2
db_password=$3

# Check if docker service running, if not then start service
sudo systemctl status docker || systemctl start docker

# Check if container exists (exit code 0)
docker container inspect jrvs-psql
container_status=$?

# Handle create|start|stop commands 
case $cmd in
	
	create)
	
		# Container already exists, error exit 1
		if [ $container_status -eq 0 ]; then
			echo 'Container already exists'
			exit 1
		fi

		# If container does not exist, check if enough arguments to build it (error exit 1 otherwise)
		if [ $# -ne 3 ]; then
			echo 'Create requires username and password'
			exit 1
		fi
	
		# Generate container
		docker volume create pgdata 
		docker run --name jrvs-psql -e POSTGRES_USER=$db_username -e POSTGRES_PASSWORD=$db_password -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres:9.6-alpine
		exit $? # Exit code based on successful creation of docker container
		;;

	start|stop)

		# Container does not exist, nothing to start or stop, error exit 1
		if [ $container_status -ne 0 ]; then
			echo 'Container does not exist'
			exit 1
		fi
		
		# Start or stop container, exit based on subsequent success of start or stop
		docker container $cmd jrvs-psql
		exit $?
		;;

	# Command does not match create|start|stop, error exit 1
	*)
		echo 'Illegal command'
		echo 'Commands: start|stop|create'
		exit 1
		;;

esac
