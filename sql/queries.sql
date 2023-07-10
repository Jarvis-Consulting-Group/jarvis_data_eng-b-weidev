-- Modifying Data

-- 1. Insert a new facility with a set facility ID
INSERT INTO cd.facilities 
VALUES 
  (9, 'Spa', 20, 30, 100000, 800);

-- 2. Insert a new facility with a dynamically generated unique facility ID
INSERT INTO cd.facilities 
VALUES 
  (
    (
      SELECT 
        MAX(facid) + 1 AS new_facid 
      FROM 
        cd.facilities
    ), 
    'Spa', 
    20, 
    30, 
    100000, 
    800
  );

-- 3. Update the initial outlay of the 'Tennis Court 2' facility
UPDATE 
  cd.facilities 
SET 
  initialoutlay = 10000 
WHERE 
  name = 'Tennis Court 2';

-- 4. Change the price (member and guest cost) of 'Tennis Court 2' such that costs 10% more than 'Tennis Court 1'
UPDATE 
  cd.facilities 
SET 
  membercost =(
    membercost + 0.1 *(
      SELECT 
        membercost 
      FROM 
        cd.facilities 
      WHERE 
        name = 'Tennis Court 1'
    )
  ), 
  guestcost =(
    guestcost + 0.1 *(
      SELECT 
        guestcost 
      FROM 
        cd.facilities 
      WHERE 
        name = 'Tennis Court 1'
    )
  ) 
WHERE 
  name = 'Tennis Court 2';

-- 5. Delete all bookings from `cd.bookings`
TRUNCATE cd.bookings;

-- 6. Remove member 37 from the database
DELETE FROM 
  cd.members 
WHERE 
  memid = 37;

-- Basics

-- 7. Return a list of all facilities that have a membership fee and that fee costs less than 1/50th that of the monthly maintenance cost
SELECT 
  facid, 
  name, 
  membercost, 
  monthlymaintenance 
FROM 
  cd.facilities 
WHERE 
  0 < membercost 
  AND membercost < (monthlymaintenance / 50);

-- 8. Return all facilities with 'Tennis' in their name
SELECT 
  * 
FROM 
  cd.facilities 
WHERE 
  name LIKE '%Tennis%';

-- 9. Return the facilities with ID 1 and 5 without using the `OR` operator
SELECT 
  * 
FROM 
  cd.facilities 
WHERE 
  facid IN (1, 5);

-- 10. Return a list of members who joined after the start of September 2012
SELECT 
  memid, 
  surname, 
  firstname, 
  joindate 
FROM 
  cd.members 
WHERE 
  joindate >= '2012-09-01 00:00:00';

-- 11. Return a combined list of surnames and facility names
(
  SELECT 
    DISTINCT surname 
  FROM 
    cd.members
) 
UNION 
  (
    SELECT 
      DISTINCT name 
    FROM 
      cd.facilities
  );

-- Joins

-- 12. Return all bookings made by 'David Farrell'
SELECT 
  starttime 
FROM 
  cd.members 
  JOIN cd.bookings ON cd.members.memid = cd.bookings.memid 
WHERE 
  firstname = 'David' 
  AND surname = 'Farrell';

-- 13. Return all start times for bookings of tennis courts on 2012-09-21
SELECT 
  starttime, 
  name 
FROM 
  cd.bookings 
  INNER JOIN cd.facilities on cd.bookings.facid = cd.facilities.facid 
WHERE 
  name LIKE '%Tennis Court%' 
  AND starttime >= '2012-09-21 00:00:00' 
  AND starttime <= '2012-09-21 23:59:59' 
ORDER BY 
  starttime;

-- 14. Return a list of members and the member who recommended them (can be blank)
SELECT 
  m2.firstname AS memfname, 
  m2.surname AS memsname, 
  m1.firstname AS recfname, 
  m1.surname AS recsname 
FROM 
  cd.members AS m1 
  RIGHT JOIN cd.members AS m2 ON m1.memid = m2.recommendedby 
ORDER BY 
  memsname, 
  memfname;

-- 15. Return a list of every member who has recommended someone
SELECT 
  DISTINCT m1.firstname AS firstname, 
  m1.surname AS surname 
FROM 
  cd.members AS m1 
  JOIN cd.members AS m2 ON m1.memid = m2.recommendedby 
ORDER BY 
  surname, 
  firstname;

-- 16. Return a list of members and who they were recommended by without using joins
SELECT 
  DISTINCT CONCAT(m1.firstname, ' ', m1.surname) AS member, 
  (
    SELECT 
      CONCAT(m2.firstname, ' ', m2.surname) AS recommender 
    FROM 
      cd.members AS m2 
    WHERE 
      m2.memid = m1.recommendedby
  ) 
FROM 
  cd.members AS m1 
ORDER BY 
  member;

-- Aggregation

-- 17. Count the number of recommendations each member has made
SELECT 
  recommendedby, 
  COUNT(*) AS count
FROM 
  cd.members 
WHERE 
  recommendedby IS NOT NULL 
GROUP BY 
  recommendedby 
ORDER BY 
  recommendedby;

-- 18. Return the amount of total slots booked per facility
SELECT 
  facid, 
  SUM(slots) AS "Total Slots" 
FROM 
  cd.bookings 
GROUP BY 
  facid 
ORDER BY 
  facid;

-- 19. Return the total slots booked per facility in the month of September 2012
SELECT 
  facid, 
  SUM(slots) AS "Total Slots" 
FROM 
  cd.bookings 
WHERE 
  starttime <= '2012-09-30 23:59:59' 
  AND starttime >= '2012-09-01 00:00:00' 
GROUP BY 
  facid 
ORDER BY 
  "Total Slots";

-- 20. Return the total slots booked per facility per month in 2012
SELECT 
  facid, 
  EXTRACT(
    MONTH 
    FROM 
      starttime
  ) AS month, 
  SUM(slots) AS "Total Slots" 
FROM 
  cd.bookings 
WHERE 
  EXTRACT(
    YEAR 
    FROM 
      starttime
  )= 2012 
GROUP BY 
  facid, 
  month 
ORDER BY 
  facid, 
  month;

-- 21. Return the number of members who made at least one booking
SELECT 
  COUNT(DISTINCT memid) AS count 
FROM 
  cd.bookings;

-- 22. Return the time of the first booking each member has made after the beginning of September 2012
SELECT 
  surname, 
  firstname, 
  cd.bookings.memid, 
  MIN(starttime) AS starttime 
FROM 
  cd.bookings 
  JOIN cd.members on cd.bookings.memid = cd.members.memid 
WHERE 
  starttime >= '2012-09-01 00:00:00' 
GROUP BY 
  cd.bookings.memid, 
  surname, 
  firstname 
ORDER BY 
  cd.bookings.memid;

-- 23. List the names of all members with each row containing the total number of members
SELECT 
  COUNT(memid) OVER() AS count, 
  firstname, 
  surname 
FROM 
  cd.members 
ORDER BY 
  joindate;

-- 24. Return a list of members and monotonically increasing row numbers based on the member's join date
SELECT 
  ROW_NUMBER() OVER(
    ORDER BY 
      joindate
  ) AS row_number, 
  firstname, 
  surname 
FROM 
  cd.members;

-- 25. Return the facility with the most number of booked slots (return all in event of a tie)
SELECT 
  rank_slots.facid, 
  rank_slots.total_slots 
FROM 
  (
    SELECT 
      facid, 
      SUM(slots) AS total_slots, 
      DENSE_RANK() OVER (
        ORDER BY 
          SUM(slots) DESC
      ) AS slots_rank 
    FROM 
      cd.bookings 
    GROUP BY 
      facid
  ) AS rank_slots 
WHERE 
  slots_rank = 1;

-- Strings

-- 26. Output the names of all members in 'Surname, Firstname' form
SELECT 
  CONCAT(surname, ', ', firstname) AS name 
FROM 
  cd.members;

-- 27. Find all members whose telephone numbers are in '(---) --- ----' form
SELECT 
  memid, 
  telephone 
FROM 
  cd.members 
WHERE 
  telephone LIKE '%(___)%' 
ORDER BY 
  memid;

-- 28. Return a count of how many members have a surname starting with each letter
SELECT 
  SUBSTRING(surname, 1, 1) AS letter, 
  COUNT(*) AS count 
FROM 
  cd.members 
GROUP BY 
  letter 
ORDER BY 
  letter;
