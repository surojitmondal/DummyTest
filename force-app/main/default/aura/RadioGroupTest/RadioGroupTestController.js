({
   toggle : function(component, event, helper) {
        var toggleText = component.find("ShowOptions");
        var toggleText1 = component.find("ShowOptions1");
        $A.util.toggleClass(toggleText, "toggle");
        $A.util.addClass(toggleText1, "toggle1");
    },
    toggle1 : function(component, event, helper) {
        var toggleText1 = component.find("ShowOptions1");
        var toggleText = component.find("ShowOptions");
        $A.util.toggleClass(toggleText1, "toggle1");    
        $A.util.addClass(toggleText, "toggle");
    }
})