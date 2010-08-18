var users;
var names=[];
var nameElements=[];
var nameTemplate;

var locs;
var locNames=[];
var locElements=[];
var locTemplate;

var rooms;
var set = false;
$(document).ready(function() {
	//When page loads...
	$(".tab_content").hide(); //Hide all content
	$("ul.tabs li:first").addClass("active").show(); //Activate first tab
	$(".tab_content:first").show(); //Show first tab content

	//On Click Event
	$("ul.tabs li").click(function() {

		$("ul.tabs li").removeClass("active"); //Remove any "active" class
		$(this).addClass("active"); //Add "active" class to selected tab
		$(".tab_content").hide(); //Hide all tab content

		var activeTab = $(this).find("a").attr("href"); //Find the href attribute value to identify the active tab + content
		$(activeTab).fadeIn(); //Fade in the active ID content
		return false;
	});
	
	nameTemplate=$("#name");
	locTemplate=$("#loc");
	nameTemplate.hide();
	locTemplate.hide();
	
	connection.addListener({connectionEvent: function(e) {
		console.log("event: " + e.eventType);
		switch(e.eventType) {
			case "GET_STATE_COMPLETE":
				update();
				if (!set){
					connection.setUser(users[0].uuid);
					// connection.setUser($.cookie('user'))
					connection.connect();
					set=true;
				}
				else{
					connection.joinLocation(locs[0].uuid);
				}
				break;
			case "ADD_ACTOR_DEVICE":
				update();
				//connection.joinLocation(locs[0].uuid);
	            break;
	        case "NEW_LOCATION":
                update();
                break;	
			case "NEW_USER":
	            
	            break;

	        case "USER_JOINED_LOCATION":
				update();
				connection.joinRoom(rooms[0].uuid);
				break;

	        case "USER_LEFT_LOCATION":
	            update();
				break;

	        case "LOCATION_JOINED_MEETING":
	            update();
				for (key in users){
					if (users[key].uuid==connection.userUUID){
						user=users[key]
					}
				}
				$("#header").html("<b>Tin-Can - </b>"+ user.loc.meeting.room.name + ": " + user.loc.meeting.name)
				$("title").html(user.loc.meeting.room.name + ": " + user.loc.meeting.name)
	            break;

	        case "LOCATION_LEFT_MEETING":
	            update();
	            break;
			
        }
	}});
	connection.getState();
});

function update(){
	users=state.getUsers();
	locs=state.getLocations();
	rooms=state.rooms;
	displayUsers();
	displayLocs();
	
}

function displayUsers(){
	for (nameElement in nameElements){
		nameElements[nameElement].remove();
	}
	
	names=[];
	nameElements=[];
	for (user in users){
		names.push(users[user].name);
	}
	
	for (var name in names){
		var newNameElement = nameTemplate.clone();
		newNameElement.find("div").html(names[name]);
		$("#names").append(newNameElement);
		newNameElement.show();
		nameElements.push(newNameElement);
	}
}

function displayLocs(){
	for (locElement in locElements){
		locElements[locElement].remove();
	}
	
	locNames=[];
	locElements=[];
	for (loc in locs){
		locNames.push(locs[loc].name);
	}
	
	for (var key in locNames){
		var newLocElement = locTemplate.clone();
		newLocElement.find("div").html(locNames[key]);
		$("#locs").append(newLocElement);
		newLocElement.show();
		locElements.push(newLocElement);
	}
}