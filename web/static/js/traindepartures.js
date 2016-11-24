export var App = {
    run: function(){
	var ajaxargs = {
	    type: 'get',
	    url: '/departureinfoupdate',
	    dataType: "html",
	    success: function(data) {
		$("#tablecontainer").html(data);
		App.restartlastupdatedcount();
		return true;
	    },
	    failure: function(data) {
		console.log('oops!: ' + JSON.stringify(data));
		return false;
	    }
	};

	$(document).ready(function() {
		App.restartlastupdatedcount();
		setInterval(function() {$.ajax(ajaxargs)}, 1000 * 60 * 5);
		$(".logo").on("click", function() {$.ajax(ajaxargs)});
		
	});
    },
    lastupdatedcountVar: {},
    restartlastupdatedcount: function() {
	clearInterval(App.lastupdatedcountVar);
	App.LastUpdated = 0;
	App.updatelastupdated();
	App.lastupdatedcountVar = setInterval(function() {App.updatelastupdated()}, 1000 * 60);
    },
    updatelastupdated: function() {
	var msg = "updated ";
	if (App.LastUpdated == 1) {
	    msg += "1 minute";
	}
	else {
	    msg += App.LastUpdated + " minutes";
	}
	$("#lastupdated").text(msg + " ago"); 
	App.LastUpdated++;
    },
    LastUpdated: 0
}