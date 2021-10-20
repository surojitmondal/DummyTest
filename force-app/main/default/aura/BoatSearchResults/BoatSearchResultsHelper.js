({
    onSearch : function(component, event, helper) {
        //Call to Apex Aura Controller using getBoats method
        var boatTypeId = component.get('v.boatTypeId');
        var action = component.get('c.getBoats');
        console.log('boatTypeId:', boatTypeId)
        action.setParams({
            boatTypeId : boatTypeId
        });
        action.setCallback(this, function(response) {
            console.log(response)
            if(response.getState() === 'SUCCESS') {
                console.log(response.getReturnValue())

                //Set list of boats in boats attribute
                component.set('v.boats', response.getReturnValue());
                component.set('v.ready', true);
            } else {
                //If error, use handleError method
                this.handleError(component);
            }
        });
        $A.enqueueAction(action);
	},
    handleError : function (component) {
        return $A.getCallback(function (error) {
            console.log(error);
            var opts = {
                title : 'Boat Search Result',
                message : error,
                type : 'error'
            };
            this.displayToast(opts)
        }.bind(this));
    },
})