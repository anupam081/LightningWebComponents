({
	getLocalList: function(component, recID) {
        //var searchTerm = component.get("v.defaultSearch");
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");       
        var objectType = component.get("v.sObjectName");
        var searchTerm = component.find("searchTerm").get("v.value");
		if (searchTerm == null) {
            searchTerm = component.get("v.defaultSearch");
        }
        
        if(recID != null){
            var action = component.get("c.getListByAddress");
            action.setParams({
                "searchQuery": searchTerm,
                "objectType": objectType,
                "recordId": recID
            });
        }else{
            var location = component.get("v.location");
            var action = component.get("c.getLocal");
            action.setParams({
				"searchTerm": searchTerm,
                "lat": location.coords.latitude,
                "lon": location.coords.longitude
            });
        }
        
        //location = JSON.parse(location);
        
        action.setCallback(this, function(response) {
            this.doLayout(response, component);
        });
        $A.enqueueAction(action);
    },
    
    // add doLayout function
    doLayout: function(response, component) {
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, "slds-hide"); 
        console.log('response.getState() =='+response.getState());
        if(response.getState() === 'SUCCESS'){
            console.log('response.getReturnValue() =='+response.getReturnValue());
            //debugger; // the JS debugger will pause here
            try{
            	var data = JSON.parse(response.getReturnValue());
                component.set("v.restaurantList", data.bizArray);
            	console.log("The Data: ", data);
            }catch(e){
                var data = null;
                //error message
                var warning = component.find('warning');  
                //console.log('data.error =='+data.error);
                if (data === null) {
                    component.set("v.errorMessage", e.message + ":-The Json is not valid");            
                    $A.util.removeClass(warning, 'slds-hide');
                } else {
                    $A.util.addClass(warning, 'slds-hide');
            }
            //error message
            }
            
            
            
           
        }
    }  
})