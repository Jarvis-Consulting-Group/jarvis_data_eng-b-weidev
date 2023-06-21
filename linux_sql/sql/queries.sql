-- First query
SELECT 
	cpu_number, 
	host_id, 
	total_mem 
FROM (SELECT 
		cpu_number, 
		id AS host_id, 
		total_mem, 
		ROW_NUMBER() OVER (PARTITION BY cpu_number ORDER BY total_mem DESC)
	  FROM host_info);

-- Second query

