export var DepartureTable = {
    documentready: function(){
	$(document).ready(function() {
		DepartureTable.restartlastupdatedcount();
	});
    },
    UpdateIntervalVar: {},
    UpdateInterval: 1000 * 60,
    restartlastupdatedcount: function() {
	clearInterval(DepartureTable.UpdateIntervalVar);
	DepartureTable.LastUpdated = 0;
	DepartureTable.updatelastupdated();
	DepartureTable.UpdateIntervalVar = setInterval(function() {
		DepartureTable.updatelastupdated();
	    }, DepartureTable.UpdateInterval);
    },
    updatelastupdated: function() {
	var msg = "updated ";
	if (DepartureTable.LastUpdated == 1) {
	    msg += "1 minute";
	}
	else {
	    msg += DepartureTable.LastUpdated + " minutes";
	}
	$("#lastupdated").text(msg + " ago"); 
	DepartureTable.LastUpdated++;
    },
    LastUpdated: 0
}