({
	handleclick : function(component, event, helper) {
        var btnclicked = event.getSource();
        var btnMessage = btnclicked.get("v.label");
        component.set("v.message",btnMessage);
 		
	}
})