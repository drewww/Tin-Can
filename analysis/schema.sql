-- A schema for representing events in Tin Can.
-- 
-- We're going to want tables for:
--     - users
--     - meetings
--     - ideas
--  - topics
-- 
-- Do we want to do this in the proper normalized way? If so, it's going to be an
-- events table and event-params tables. In meeting tin can, that's probably the
-- only way to represent things because ideas can be passed around. But 
-- 
-- We're going to have to have an events thing, but we can also make some convenience tables for ideas, topics, etc. But still want to capture all the raw event data in parallel for things like join/leave, 
-- 
-- Another angle is to think about what kinds of questions we want to answer - 

DROP DATABASE IF EXISTS tincan;

CREATE DATABASE tincan;

USE tincan;


CREATE TABLE event (
    id INT              NOT NULL AUTO_INCREMENT,
    uuid CHAR(36)       NOT NULL,
    user_id INT         NOT NULL,   -- references the users table. we don't use uuids for this because they shift between sessions.
    meeting_id INT      NOT NULL,   -- references the meeting table.
    created DATETIME    NOT NULL,
    type VARCHAR(50)    NOT NULL   -- properly, this should be an enum of all the event types. 
);


CREATE TABLE meeting (
    id INT              NOT NULL AUTO_INCREMENT,
    uuid CHAR(36)       NOT NULL,
    started             DATETIME,
    stopped             DATETIME
)


CREATE TABLE users (
    id INT              NOT NULL AUTO_INCREMENT,
    uuid CHAR(36)       NOT NULL,
    name VARCHAR(255)   NOT NULL,
);



-- These are the derivative tables that make life easier to manage. 
