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

-- main ideas dump query. big enough that it needs to go into an outfile.
select creator.name, shared, text, assigned_by.name, assigned_to.name, 
    created, assigned, likes,
    (unix_timestamp(assigned) - unix_timestamp(created)) as time_before_share
    INTO OUTFILE '/tmp/ideas.csv'
      FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '"'
      LINES TERMINATED BY '\n'
    from tasks
    left join actors as creator on creator.id = tasks.created_by_actor_id
    left join actors as assigned_by on assigned_by.id = tasks.assigned_by_actor_id
    left join actors as assigned_to on assigned_to.id = tasks.assigned_to_actor_id
    order by created asc;

select name, sum(likes) from actors
    join tasks on tasks.created_by_actor_id = actors.id
    group by name
    order by name asc;

select name, count(*) from actors 
    join events on events.actor_id = actors.id 
    where type="LIKE_TASK"
    group by name
    order by name asc;

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

-- set shared to 0 or 1 to get public/private
SELECT name, tasks_shared from actors
    left join (SELECT actors.id as task_count_actor_id, count(*) as tasks_shared
    from actors
    join tasks on tasks.created_by_actor_id=actors.id
    where shared=0 and tasks.created_by_actor_id=tasks.assigned_by_actor_id
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

SELECT name, topics_created from actors
    left join (SELECT actors.id as actor_id, count(*) as topics_created
        from actors
        join topics on topics.stopped_by_actor_id=actors.id
        group by actor_id
    ) as subselect on actor_id = actors.id
    order by name asc;


SELECT name, likes from actors
    left join (select actors.id as actor_id, count(*) as likes from actors 
        join events on events.actor_id = actors.id 
        where type="LIKE_TASK"
        group by actor_id
    ) as subselect on actor_id = actors.id
    order by name asc;

-- total amount of tin can time recorded
-- where clause filters out some short/fake events.
-- can add sum term to add it all up
select *,sum((unix_timestamp(stopped)-unix_timestamp(started))/60) as mins_duration
    from meetings
    where (unix_timestamp(stopped)-unix_timestamp(started))/60 > 30;


-- queries for generating the per-meeting timeline charts
select id, meeting_id, unix_timestamp(created), shared, likes, length(text), created_by_actor_id
    INTO OUTFILE '/tmp/ideas.csv'
         FIELDS TERMINATED BY '\t'
         LINES TERMINATED BY '\n'
    from tasks
    where ;


select id, meeting_id, unix_timestamp(created), unix_timestamp(started),unix_timestamp(stopped)
    INTO OUTFILE '/tmp/topics.csv'
         FIELDS TERMINATED BY '\t'
         LINES TERMINATED BY '\n'
    from topics;


select id, unix_timestamp(started),unix_timestamp(stopped)
    INTO OUTFILE '/tmp/meetings.csv'
         FIELDS TERMINATED BY '\t'
         LINES TERMINATED BY '\n'
    from meetings;
    
-- queries to be written
    -- something to figure out the delay between ideas being created and
    -- dragged. 
    
    -- something that sums up the total number of minutes of recording
    -- we have.
    
    
-- various counting queries for finding numbers I need for writing.


select meetings.id, count(*) from meetings join topics on topics.meeting_id = meetings.id group by meetings.id;

select meetings.id, count(*) from meetings join topics on topics.meeting_id = meetings.id where topics.started is not null group by meetings.id;



    