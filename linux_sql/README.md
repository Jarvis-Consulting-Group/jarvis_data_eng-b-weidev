# Linux Cluster Monitoring Agent
This project is under development. Since this project follows the GitFlow, the final work will be merged to the main branch after Team Code Team.

# Introduction

## Quick Start
First create and start up a `psql` instance with `psql_docker.sh` with username `postgres` and password `password`.
```.bash
./scripts/psql_docker.sh create postgres password
./scripts/psql_docker.sh start
```
Connect to the `psql` instance and create a new database `host_agent`.
```.bash
psql -h localhost -U postgres -W
postgres=# CREATE DATABASE host_agent;
```
Then generate the database tables with `ddl.sql`.
```.bash
psql -h localhost -U postgres -d host_agent -f sql/ddl.sql
```
To insert data on hardware specifications for the current machine run the `host_info.sh` script.
```.bash
./scripts/host_info.sh localhost 5432 host_agent postgres password
```
To insert data on current hardware usage run the `host_usage.sh` script.
```.bash
./scripts/host_usage.sh localhost 5432 host_agent postgres password
```
To automate the gathering of hardware usage data every minute, add this line to your `crontab` file (access using `crontab -e` command).
Replace the path with the full path from `pwd` to the `host_usage.sh` script on your machine.
```.bash
* * * * * .../host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log
```

## Implementation

## Architecture

## Scripts
- `psql_docker.sh`
  - Creates a Docker container called `jrvs-psql` using the official PostgresSQL 9.6 Alpine image. If the container has been created, it is also responsible for stopping and starting the container.
  - Usage: 
    - ```shell
      # Create a psql docker container with login info
      ./scripts/psql_docker.sh create [USERNAME] [PASSWORD]
      
      # Start the container
      ./scripts/psql_docker.sh start
      
      # Stop the container
      ./scripts/psql_docker.sh stop
      ```
- `host_info.sh`
  - Inserts a row of hardware specification data on the current machine into the `host_info` table.
  - Usage:
    - ```shell
      ./scripts/host_info.sh [HOST_NAME] [PORT_NUM] [DATABASE] [PSQL_USERNAME] [PSQL_PASSWORD]
      ```
- `host_usage.sh`
    - Inserts a row of hardware usage data on the current machine into the `host_usage` table.
  - Usage:
    - ```shell
      ./scripts/host_usage.sh [HOST_NAME] [PORT_NUM] [DATABASE] [PSQL_USERNAME] [PSQL_PASSWORD]
      ```
- `ddl.sql`
    - Generates two tables `host_info` and `host_usage` in the `host_agent` database if they do not exist.
    - Usage:
      - ```shell
        psql -h [HOST_NAME] -U [PSQL_USERNAME] -d host_agent -f sql/ddl.sql
        ```
- `crontab`
  - Automates the 

# Test
Testing was mainly done through running the scripts and verifying the result.
Here are the processes taken for each script:
- `psql_docker.sh
- 

# Deployment

