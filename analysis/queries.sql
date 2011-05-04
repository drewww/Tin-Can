-- A handy place to save useful queries for analysis work.

-- shows number of events per user. (events is a bit broad, though)
select name, count(*) from events
    join actors on actors.id = events.actor_id
    group by actors.id;

-- shows the distribution of events for all users
SELECT type, count(*) from events group by type;

-- distribution of events for all users.
SELECT name, type, count(*) from events
    join actors on actors.id = events.actor_id
    group by actors.id, type;

-- count the events per meeting. 
SELECT meetings.id, count(*) from events
    join meetings on meetings.id = events.meeting_id
    group by meetings.id;
    
    

-- counts the number of dragged tasks
SELECT tasks.created_by_actor_id=tasks.assigned_by_actor_id, count(*) from tasks
    group by tasks.created_by_actor_id=tasks.assigned_by_actor_id;

-- figures out who dragged how many tasks (change equality to get general
-- idea distribution) beware that ideas are DOUBLE COUNTED IF THEY'RE PUBLICLY
-- SHARED. 
SELECT name, count(*) from tasks
    join actors on actors.id = tasks.assigned_by_actor_id
    where tasks.created_by_actor_id!=tasks.assigned_by_actor_id
    group by name;


-- very much like the previous, except shows the drag-ee, not the drag-er
SELECT name, count(*) from tasks
    join actors on actors.id = tasks.created_by_actor_id
    where tasks.created_by_actor_id!=tasks.assigned_by_actor_id
    group by name;


--
SELECT name, count(*) from tasks
    join actors on actors.id = tasks.assigned_by_actor_id
    where tasks.created_by_actor_id!=tasks.assigned_by_actor_id
    group by name;

-- this is a building block of sorts - if something is shared, the shared 
-- column in this query is 2, otherwise it's 1. Need to use this as a sub-
-- select or something. 
select text, count(*) as shared from tasks 
    join actors on actors.id = tasks.created_by_actor_id
    group by text;

-- distribution per person of shared/unshared ideas
select name, shared, count(*) from tasks 
    join actors on actors.id = tasks.created_by_actor_id
    group by name, shared;


-- total amount of tin can time recorded
-- where clause filters out some short/fake events.
-- can add sum term to add it all up
select *,sum((unix_timestamp(stopped)-unix_timestamp(started))/60) as mins_duration
    from meetings
    where mins_duration > 30;

-- queries to be written
    -- something to figure out the delay between ideas being created and
    -- dragged. 
    
    -- something that sums up the total number of minutes of recording
    -- we have.
    
