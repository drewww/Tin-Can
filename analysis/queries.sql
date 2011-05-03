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
    
