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


CREATE TABLE events (
    id INT              PRIMARY KEY AUTO_INCREMENT,
    uuid CHAR(36)       NOT NULL UNIQUE,
    actor_id INT         ,   -- references the users table. we don't use uuids for this because they shift between sessions.
    meeting_id INT      ,   -- references the meeting table.
    created DATETIME    NOT NULL,
    type VARCHAR(50)    NOT NULL   -- properly, this should be an enum of all the event types. 
);


CREATE TABLE meetings (
    id INT              PRIMARY KEY AUTO_INCREMENT,
    uuid CHAR(36)       NOT NULL UNIQUE,
    started DATETIME    NOT NULL,
    stopped DATETIME
);


CREATE TABLE actors (
    id INT              PRIMARY KEY AUTO_INCREMENT,
                                            -- Used to store the uuid, but this rapidly made no sense because users have many uuids. No particular reason to cache them here.
    name VARCHAR(255)   NOT NULL UNIQUE     -- We're lucky on this one, but we can ensure uniqueness on it because of the closed set of participants.
);


-- These are the derivative tables that make life easier to manage. 
CREATE TABLE topics (
    id INT                  PRIMARY KEY AUTO_INCREMENT,
    uuid CHAR(36)           NOT NULL UNIQUE,
    meeting_id INT          NOT NULL,
    text VARCHAR(255)       NOT NULL,
    created DATETIME        NOT NULL,
    created_by_actor_id INT NOT NULL,
    started DATETIME                ,
    started_by_actor_id INT         ,
    stopped DATETIME                ,
    stopped_by_actor_id INT
);


-- the model here is a little bit weird because of the way I hacked in the
-- classroom mechanics - things go directly to a person if they're created
-- with the assigned field set. Tasks that have no assignment are created
-- publicly. Tasks that were dragged are created with no assignment, but 
-- have an assigner other than the creator.

CREATE TABLE tasks (
    id INT                  PRIMARY KEY AUTO_INCREMENT,
    uuid CHAR(36)           NOT NULL UNIQUE,
    alt_uuid CHAR(36)       ,
    meeting_id INT          NOT NULL,
    text TEXT               NOT NULL,
    created DATETIME        NOT NULL,
    created_by_actor_id INT NOT NULL,
    assigned_to_actor_id INT      ,
    assigned_by_actor_id INT NOT NULL,
    assigned DATETIME           ,
    shared BOOLEAN          NOT NULL DEFAULT FALSE,
    likes INT               DEFAULT 0
);