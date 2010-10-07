
var itemCounter = 0; // number of items ever created
var items = [];  // array of agenda items
var currentItemId; // current item's id - string
var lastClicked = 'item0'; 
var currentClicked; // element
var uuidDict = {}; // item id keys to uuid values dictionary
var newItemText;

$(document).ready(function(){
    
	connection.addListener({connectionEvent: function(e) {
		console.log("event: " + e.eventType);
		switch(e.eventType) {
			case "GET_STATE_COMPLETE":
				break;
			case "NEW_TOPIC":
				topic = e.results["topic"]
				itemCounter = itemCounter + 1;
				newId = 'item' + itemCounter;
				uuidDict[newId] = topic.uuid;
				makeFutureItem(newId, topic.text, "FUTURE");
				break;
			case "LOCAL_MEETING_SET":
				generateTopicsFromServer();
				break;
			case "UPDATE_TOPIC":
				uuid = e.params["topicUUID"];
				status = e.params["status"];
				console.log(uuid);
				console.log(status);
				updateTopic(uuid, status);
				break;
			case "DELETE_TOPIC":
				uuid = e.params["topicUUID"];
				deleteTopic(uuid);
				break;
		}
	}});
	
	
	
	$("#itemTextbox").keypress(submitWithEnterKey);
	
	$("#doneButton").click(function (e) {
		e.stopPropagation();

		currentClicked = $(this.parentNode);
		tempId = currentClicked[0].id;
		tempUuid = uuidDict[tempId];
		connection.updateTopic(tempUuid, "CURRENT");
		
	});
	connection.getState();
});
	

	function updateTopic(uuid, status){
		id = lookupByUuid(uuid);
		console.log(id);
		$("#"+id)[0].className = status;
		
		// if changing a Future item to a Current item, find the position of the first
		// Future item and insert the new Current item above it in the list view
		if (status == "CURRENT") {
			for (key in uuidDict) {
				if ($("#"+key)[0].className == "FUTURE"){
					firstFutureItem = $("#"+key);
					break;
				}
			}
			if (id != firstFutureItem[0].id){
				$("#"+id).insertBefore(firstFutureItem);
			}
		}
	}
	
	function lookupByUuid(uuid){
		for (id in uuidDict) {
			tempUuid = uuidDict[id];
			console.log(id);
			console.log(tempUuid);
			if (tempUuid == uuid){
				return id;
			}
		}
	}

	function generateTopicsFromServer(){
		topics = connection.getCurrentMeeting().topics;
		for (key in topics) {
			topic = topics[key];
			itemCounter = itemCounter + 1;
			newId = 'item' + itemCounter;
			uuidDict[newId] = topic.uuid;
			makeFutureItem(newId, topic.text, topic.status);
			console.log(topic.status);
		}

	}

// visibility toggle for new item textbox input
	function showTextbox(){
		newItemInput = $("#newItemInput")[0];
		if (newItemInput.style.display!="block"){
			newItemInput.style.display="block";
			$("#itemTextbox").focus();
		}
		else{
			$("#itemTextbox").value="";
			newItemInput.style.display="none";
		}

	}
	
	function sendTopicToServer() {
		newItemText=$("#itemTextbox")[0].value;
		connection.addTopic(newItemText);
		$("#itemTextbox")[0].value="";

	}
	
//grab input from textbox and generate item in list
	function makeFutureItem(newId, newItemText, newItemStatus) {
		
		futureTemplate = $("#futureTemplate");
		itemList = $("#container");
					
		clone = futureTemplate.clone();
		clone.find("span").html(newItemText);
		clone.show();
		clone[0].id = newId;
		itemList.append(clone);
		items.push(clone[0].id);

		clone[0].className = newItemStatus;
		
			clone.click(function (e) {
			extraOptions = $("#extraOptions");
			currentClicked = $(this);
					
			// toggle showing the extra options
			// first, if item is not in items array, then it has been marked done - do nothing i.e. don't show extra options.
			// Only update click handler if item is active, not done items
			if ($.inArray(currentClicked[0].id, items)) console.log("currentClicked is in ITEMS");
			
				// if an item has been clicked on an even number of times (i.e. twice), hide the options
				// otherwise show the options when clicked an odd number of times (i.e. first click)
				if (lastClicked == currentClicked.get(0).id){
					extraOptions.hide();
					lastClicked = 'item0';
				}
				else{
					lastClicked = currentClicked.get(0).id;
					$(this).append(extraOptions);
					if (currentClicked[0].id == currentItemId){  //hide deleteButton if click on the current item
						$("#deleteButton")[0].style.visibility="hidden";
						extraOptions.show();
					}

					else{
						$("#deleteButton")[0].style.visibility="visible";
						extraOptions.show();
					}				
				}
			})				
		defineStartButtonClick();
		defineDeleteButtonClick();	
		
	}
	
	function defineDeleteButtonClick() {
		$("#deleteButton").click(function (e) {
			e.stopPropagation();
			
			//grab parent div (box container in the list view)
			currentClicked = $(this.parentNode.parentNode);
			
			tempId = currentClicked[0].id;
			tempUuid = uuidDict[tempId];
			connection.removeTopic(tempUuid);
		});
	}
	
	function defineStartButtonClick() {
		$(".startButton").click(function (e) {
			e.stopPropagation();
			
			//find item currently marked as Current, and change it to a Past item
			for (key in uuidDict) {
				if ($("#"+key)[0].className == "CURRENT"){
					uuid = uuidDict[key]
					connection.updateTopic(uuid, "PAST");
					break;
				}
			}
			
			// grab the uuid for the item that was clicked on and send it to the server
			currentClicked = $(this.parentNode);
			tempId = currentClicked[0].id;
			tempUuid = uuidDict[tempId];
			connection.updateTopic(tempUuid, "CURRENT");
		});
		
	}
		
	
	function deleteTopic(uuid) {

			extraOptions = $("#extraOptions");
			extraOptions.hide();
			$("#container").append(extraOptions);
			currentClicked.remove();
		
	}

	function submitWithEnterKey(e){
		if (e.which==13){
			$("#submitButton").focus();
			sendTopicToServer();
		}
	}
	
	function loginUser(){
		connection.setUser(state.getUsers()[0].uuid);
		// for (user in state.getUsers())
		connection.connect();
		console.log("login user called");
	}
	
	function joinLocation(){
		connection.joinLocation(state.getLocations()[0].uuid);
	}
	
	function joinRoom(){
		connection.joinRoom(state.rooms[0].uuid);
	}
