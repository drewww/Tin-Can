#!/usr/bin/env python
# encoding: utf-8
"""
log_to_db.py

Converts a JSON-streaming log file format (as generated by yarn.py during
an event) into a database, for easier cross-cutting analysis. 

Built to work with MySQL.

Created by Drew Harry on 2011-05-03.
Copyright (c) 2011 MIT Media Lab. All rights reserved.
"""

import MySQLdb
import json
import os

# this will keep a reference to the database connection.
db = None
cursor = None

name_map = {}
uuid_map = {}

meeting_map = {}
current_meeting_id = None

last_join = {}
total_time = {}


# maps task text to a task id to help resolve the shared-task duplication
# problem in the classroom data context.
task_map = {}

total_likes = 0

def convert_log(path):
    f = open(path, 'r')
    
    for line in f:
        process_event(line)
    
    
def process_event(event_string):
    global name_map
    global uuid_map
    global meeting_map
    global current_meeting_id
    global task_map
    global last_join
    global total_time
    global total_likes
    
    # first, unpack the string into a JSON object for easy management.
    
    if (event_string == "----server reset----\n"):
        # for now, later we'll need to be careful about noting these.
        print "SERVER RESET"
        return
    
    #otherwise, carry on.
    event = json.loads(event_string)
    
    # first, check and see if there is any special processing we want to do.
    if(event["eventType"]=="NEW_USER" or event["eventType"]=="NEW_LOCATION"):
        # check to see if that user has a database-assigned id yet.
        # if they do, add that id to the map. Otherwise, push it into the db.
        if(not name_map.has_key(event["params"]["name"])):
            cursor.execute("INSERT INTO actors (name) VALUES (%s)",
            event["params"]["name"])
            
            # set up a name mapping in memory, for ease of access.
            name_map[event["params"]["name"]] = cursor.lastrowid
            
            # print "NEW USER: " + str(cursor.lastrowid)
            
        
        # whether we're creating a new, never-before-seen use or not,
        # we need to create a uuid mapping. Check the name of this user to
        # get the appropriate user id, and then map the uuid to that id so
        # future events can make the connection easily.
        
        uuid_map[event["results"]["actor"]["uuid"]] = name_map[event["params"]["name"]]
        
        # print uuid_map
    
    
    # there are some baked in assumptions here about the non-simultaneity of
    # meetings. Be careful with this section if that changes.
    if(event["eventType"]=="NEW_MEETING"):
        print "NEW MEEEEEEEEEEEEEETING"
        if(not meeting_map.has_key(event["results"]["meeting"]["uuid"])):
            cursor.execute("INSERT INTO meetings (uuid, started) VALUES\
                (%s, from_unixtime(%s))", 
                (event["results"]["meeting"]["uuid"], event["timestamp"]))
            
            meeting_map[event["results"]["meeting"]["uuid"]] = cursor.lastrowid
            
            current_meeting_id = cursor.lastrowid
            
            # reset the task map (probably doesn't matter, unless the same
            # exact idea comes up in two meeitngs, but better safe)
            task_map = {}
            
    if(event["eventType"]=="END_MEETING"):
        cursor.execute("UPDATE meetings SET stopped=from_unixtime(%s)\
            where id=%s", (event["timestamp"],current_meeting_id))
        current_meeting_id = None
        last_join = {}
    
    
    if(event["eventType"]=="NEW_TOPIC"):
        cursor.execute("INSERT INTO topics (uuid, text, created,\
            created_by_actor_id, meeting_id) VALUES (%s, %s,\
            from_unixtime(%s), %s, %s)",
            (event["results"]["topic"]["uuid"],
            event["results"]["topic"]["text"],
            event["timestamp"], uuid_map[event["actorUUID"]],
            current_meeting_id))
    if(event["eventType"]=="UPDATE_TOPIC"):
        status = event["params"]["status"]
        
        if(status=="CURRENT"):
            #started
            cursor.execute("UPDATE topics SET started=from_unixtime(%s),\
                started_by_actor_id=%s WHERE topics.uuid=%s",
                (event["timestamp"], uuid_map[event["actorUUID"]], 
                event["params"]["topicUUID"]))
        elif(status=="PAST"):
            #stopped
            cursor.execute("UPDATE topics SET stopped=from_unixtime(%s),\
                stopped_by_actor_id=%s WHERE topics.uuid=%s",
                (event["timestamp"], uuid_map[event["actorUUID"]], 
                event["params"]["topicUUID"]))
    
    if(event["eventType"]=="NEW_TASK"):
        task = event["results"]["task"]
        
        if task["assignedTo"]!=None:
            assignedTo = uuid_map[task["assignedTo"]]
        else:
            assignedTo = None
        
        
        
        
        # in what order do the double tasks come? 
        # it doesn't really matter, just make sure that the one with the
        # assigner different from the creator is the one that gets entered
        if(task_map.has_key(task["text"])):
            # if it has the key, it's already in the db. for sure, we're
            # going to update that record and mark is shared. the only
            # question is whether we copy the assigner in.
            if(task["assignedTo"]!=task["createdBy"]):
                # print "\t + in expected order sharing branch"
                # then copy it in and set the time and set shared.
                cursor.execute("UPDATE tasks SET shared=TRUE,\
                assigned_by_actor_id=%s, assigned_to_actor_id=%s,\
                assigned=from_unixtime(%s), alt_uuid=%s WHERE id=%s",
                (uuid_map[task["assignedBy"]], assignedTo, event["timestamp"],
                task["uuid"], task_map[task["text"]]))
            else:
                # print "\t - in reverse sharing order branch"
                # in this branch, the existing data is the one with the shared
                # info that we don't want to overwrite, so just flip the bit.
                cursor.execute("UPDATE tasks SET shared=TRUE\
                WHERE id=%s", (task_map[task["text"]],))
                
        else:
            cursor.execute("INSERT INTO tasks (uuid, text, created,\
                created_by_actor_id, assigned_to_actor_id, assigned_by_actor_id,\
                assigned, meeting_id) VALUES (%s, %s, from_unixtime(%s), %s, %s, %s,\
                from_unixtime(%s), %s)" ,(task["uuid"], task["text"],
                event["timestamp"], uuid_map[task["createdBy"]], assignedTo,
                uuid_map[task["assignedBy"]], event["timestamp"],
                current_meeting_id))
            
            task_map[task["text"]] = cursor.lastrowid
    
    
    # unswizzle the uuid into a database-id for the user and meeting, if
    # they exist.
    actor_id = event["actorUUID"]
    if(event["actorUUID"]!=None):
        actor_id = uuid_map[event["actorUUID"]]

    if(event["eventType"]=="USER_JOINED_LOCATION"):
        if(not last_join.has_key(event["actorUUID"])):
            # print "fresh join " + str(actor_id)
            last_join[event["actorUUID"]] = event["timestamp"];
        else:
            pass
            # print "+duplicate join " + str(actor_id)

    if(event["eventType"]=="USER_LEFT_LOCATION"):
        if(not total_time.has_key(actor_id)):
            total_time[actor_id] = 0
        
        total_time[actor_id] = total_time[actor_id] + (event["timestamp"] - last_join[event["actorUUID"]])
        del last_join[event["actorUUID"]]
        # print "-deleting last_join " + str(actor_id)

    if(event["eventType"]=="LIKE_TASK"):
        total_likes = total_likes+1
        cursor.execute("UPDATE tasks SET likes=likes+1 WHERE uuid=%s OR\
            alt_uuid=%s", (event["params"]["taskUUID"], event["params"]["taskUUID"]))
        cursor.execute("SELECT * from tasks where UUID=%s", event["params"]["taskUUID"])
        print "+++++++ " + event["params"]["taskUUID"]
        print "------- " + str(cursor.fetchone())
        
        

    # this approach, while reasonable, turns out not to work because many
    # events don't actually have a meeting id associated with them, for some
    # reason. I suspect it's a side effect of my on again/off again attempts
    # to broadcast all events to all clients v. limit them to specific 
    # recipients. 
    # meeting_id = event["meetingUUID"]
    # print "base meeting_id: " + str(meeting_id)
    # if(event["meetingUUID"]!=None):
    #     meeting_id = meeting_map[event["meetingUUID"]]
    meeting_id = current_meeting_id
    
    
    # now, for each event we need to push it into the DB.
    cursor.execute("INSERT INTO events (uuid, actor_id, meeting_id, created,\
    type) VALUES (%s, %s, %s, from_unixtime(%s), %s)",
        (event["uuid"], actor_id, meeting_id, event["timestamp"], event["eventType"]))
    
    # print event['uuid'] + " - " + event['eventType']



if __name__ == '__main__':
    print "Opening database connection."
    db = MySQLdb.connect(host = "localhost", user="root", db="tincan")
    cursor = db.cursor()
    
    for filename in os.listdir("emerson-logs/"):
        convert_log("emerson-logs" + os.sep + filename)
    
    print "TOTAL LIKES: " + str(total_likes)
    
    global total_time
    print total_time
    
    print "Closing database connection."
    db.close()
    

