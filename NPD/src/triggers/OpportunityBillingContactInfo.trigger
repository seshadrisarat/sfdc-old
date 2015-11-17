trigger OpportunityBillingContactInfo on Opportunity (before update) {

//2013.06.15 Nc Added AU, PA, Sector Opportunity summary functionality
    
    if(UserInfo.getUserId() <> '00500000006z3qKAAQ'){
        
        //Calls the Billing Contact Validation Method
        opportunityHandler.opptyBillingContactInfoHandler(Trigger.new);

        //Calls the Earning Date Validation Method
        
             
    }
    
    
        //Calls the AU, PA, Sector Opportunity summary functionality
        if (!UpdatedOpportunityHelper.hasAlreadyUpdatedOpportunity()) {
        
            opportunityHandler.summarize_AU_PA_Sector(Trigger.new);
            UpdatedOpportunityHelper.setAlreadyUpdatedOpportunity();
            
        }    
}