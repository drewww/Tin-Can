
var itemCounter = 0; // number of items ever created
var items = [];  // array of agenda items
var currentItemId; // current item's id - string
var lastClicked = 'item0'; 
var currentClicked; // element
var uuidDict = {};
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
		
		// extraOptions = $("#extraOptions");
		// currentIndex = items.indexOf($("#"+currentItemId)[0].id);
		// $("#"+currentItemId)[0].className = "PAST";
		// $("#"+currentItemId).click(function() {
		// 	extraOptions.hide();
		// });			
		// items.splice(currentIndex, 1);
		// $("#doneButton").hide();
		// $(".startButton").show();
	});
	connection.getState();
});
	
	function updateTopic(uuid, status){
		id = lookupByUuid(uuid);
		console.log(id);
		$("#"+id)[0].className = status;
		
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
        // $("#newItemInput")[0].style.display="none"
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
			// console.log('items: ' + items);
			// console.log('index of current clicked is ' + items.indexOf(currentClicked[0].id));
			// console.log('current clicked id is ' + currentClicked[0].id);

						
			// toggle showing the extra options
			// first, if item is not in items array, then it has been marked done - do nothing i.e. don't show extra options
			
			// only update click handler if item is active, not done items
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
			console.log("DELETE BUTTON");
			e.stopPropagation();
			currentClicked = $(this.parentNode.parentNode);
			tempId = currentClicked[0].id;
			console.log(tempId);
			tempUuid = uuidDict[tempId];
			console.log(tempUuid);
			connection.removeTopic(tempUuid);
		});
	}
	
	function defineStartButtonClick() {
		$(".startButton").click(function (e) {
			e.stopPropagation();
			
			for (key in uuidDict) {
				console.log(key);
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
			
			
			// clickedIndex = items.indexOf(currentClicked[0].id);
			// temp = items[clickedIndex];
			// 
			// items.splice(clickedIndex, 1);
			// items.splice(0,0,temp);
			// lastCurrentElement = $("#"+currentItemId);
			// 
			// 
			// currentItemId = $(this.parentNode)[0].id;

		});
		
	}
		
	
	function deleteTopic(uuid) {

			extraOptions = $("#extraOptions");
			extraOptions.hide();
			$("#container").append(extraOptions);
			// currentIndex = items.indexOf(currentClicked[0].id);
			// items.splice(currentIndex, 1);
			currentClicked.remove();
		
	}
	

	
	function makeNext() {
		console.log('current ITEM is ' + currentItemId);
		console.log(currentItemId);
		console.log(currentClicked);
		
		if (currentItemId == currentClicked[0].id) {
			return;
		}
		else{
			// update the items array to reflect the new order of items
			// remove the item to be queued from array, set as temp, then insert in the new position
			clickedIndex = items.indexOf(currentClicked[0].id);
			temp = items[clickedIndex];
			items.splice(clickedIndex, 1);
			currentIndex = items.indexOf(currentItemId);
			tempindex = currentIndex + 1;
			items.splice(tempindex,0,temp);
			console.log('updated items list: ');
			console.log(items);			
			(currentClicked).insertAfter($("#"+currentItemId));

		}
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
