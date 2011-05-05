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
    right join actors on actors.id = tasks.created_by_actor_id
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



----------------------------------------------------------
-- These queries are used to generate the main analysis spreadsheets.
-- Every query has every actor, sorted by name ASC for easy combination
-- Subselecting is the only real way to do this, as far as I can tell.
-- Annoying.
----------------------------------------------------------

SELECT name, tasks_created from actors
    left join (SELECT actors.id as task_count_actor_id, count(*) as tasks_created
    from actors
    join tasks on tasks.created_by_actor_id=actors.id
    group by name
order by name asc) as tasks_created_table on task_count_actor_id = actors.id
    order by name asc;


SELECT name, dragged_tasks from actors
    left join (SELECT actors.id as actor_id, count(*) as dragged_tasks
        from actors
        left outer join tasks on tasks.assigned_by_actor_id=actors.id
        where tasks.created_by_actor_id!=tasks.assigned_by_actor_id
        group by name
    ) as tasks_dragged_table on actor_id = actors.id
    order by name asc;

SELECT name, tasks_dragged from actors
    left join (SELECT actors.id as actor_id, count(*) as tasks_dragged
        from actors
        left outer join tasks on tasks.created_by_actor_id=actors.id
        where tasks.created_by_actor_id!=tasks.assigned_by_actor_id
        group by name
    ) as tasks_dragged_table on actor_id = actors.id
    order by name asc;




-- total amount of tin can time recorded
-- where clause filters out some short/fake events.
-- can add sum term to add it all up
select *,sum((unix_timestamp(stopped)-unix_timestamp(started))/60) as mins_duration
    from meetings
    where (unix_timestamp(stopped)-unix_timestamp(started))/60 > 30;

-- queries to be written
    -- something to figure out the delay between ideas being created and
    -- dragged. 
    
    -- something that sums up the total number of minutes of recording
    -- we have.
    
