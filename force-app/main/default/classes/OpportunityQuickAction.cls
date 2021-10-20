public with sharing class OpportunityQuickAction {
public opportunity opp {get;set;}

public OpportunityQuickAction(ApexPages.StandardController stdController) {
    opp = (Opportunity)stdController.getRecord();
}

    public Pagereference redirectToOpp () {  
      PageReference oppPage = new Pagereference('/'+opp.id);
      oppPage.setRedirect(true);
    return oppPage;
    //return new PageReference('/lightning/r/Opportunity/'+opp.id+'/view');  
    }  
}