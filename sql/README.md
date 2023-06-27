# Introduction
(about 100-150 words)
Discuss the design of the project. What does this project/product do? Who are the users? What are the technologies you have used? (e.g. bash, docker, git, etc..)

# SQL Quries

###### Table Setup (DDL)

CREATE TABLE IF NOT EXISTS cd.members (
	memid INTEGER NOT NULL PRIMARY KEY,
	surname VARCHAR(200),
	firstname VARCHAR(200),
	address VARCHAR(300),
	zipcode INTEGER,
	telephone VARCHAR(20),
	recommendedby INTEGER NOT NULL,
	joindate TIMESTAMP,
	CONSTRAINT FK_MemberRecommended FOREIGN KEY (recommendedby) REFERENCES (memid)
)

CREATE TABLE IF NOT EXISTS cd.bookings (
	facid INTEGER NOT NULL PRIMARY KEY,
	memid INTEGER NOT NULL,
	starttime TIMESTAMP,
	slots INTEGER,
	CONSTRAINT FK_Member FOREIGN KEY (memid) REFERENCES cd.members(memid),
	CONSTRAINT FK_Face FOREIGN KEY (facid) REFERENCES cd.facilities(facid)	
)

CREATE TABLE IF NOT EXISTS cd.facilities (
	facid INTEGER NOT NULL PRIMARY KEY,
	name VARCHAR(100),
	membercost FLOAT,
	guestcost FLOAT,
	initialoutlay FLOAT,
	monthlymaintenance FLOAT
)

###### Question 1: Show all members 

```sql
SELECT *
FROM cd.members
```
