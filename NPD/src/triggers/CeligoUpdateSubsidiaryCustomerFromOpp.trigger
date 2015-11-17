trigger CeligoUpdateSubsidiaryCustomerFromOpp on Opportunity (before insert, before update) {
    
    List<Id> accountIds = new List<Id>();
    List<String> subsidiaries = new List<String>();
    List<Subsidiary_Customer__c> subsToUpdate = new List<Subsidiary_Customer__c>();
    
    for (Opportunity opp: System.Trigger.new) {
        if (opp.AccountId != null) {
            accountIds.add(opp.AccountId);
        }
        if (opp.Master_Opportunity_Subsidiary__c != null) {
            subsidiaries.add(opp.Master_Opportunity_Subsidiary__c);
        }
    }
    
    List<Subsidiary_Customer__c> subs = [select Id, Subsidiary__c, Account__c, NetSuite_Id__c from Subsidiary_Customer__c where Account__c IN : accountIds and 
    Subsidiary__c IN : subsidiaries];
        
    for (Opportunity opp: System.Trigger.new) {
        Boolean found = false;
        if (opp.Master_Opportunity_Subsidiary__c == null || opp.Master_Opportunity_Subsidiary__c == '') {
            continue;
        }
        for (Subsidiary_Customer__c sub : subs) {
            if (sub.Account__c == opp.AccountId && sub.Subsidiary__c == opp.Master_Opportunity_Subsidiary__c) { 
                opp.Subsidiary_Customer_Id__c = sub.Id;
                opp.Subsidiary_Customer__c = sub.Id;
                found = true;
                break;
            }
        }
        if (found)  
            continue;
            
        if (opp.StageName == 'Closed - Won' || opp.StageName == 'Renew Closed - Won') {
            Subsidiary_Customer__c subCustomer = new Subsidiary_Customer__c();
            subCustomer.Account__c = opp.AccountId;
            subCustomer.Subsidiary__c = opp.Master_Opportunity_Subsidiary__c;
            subsToUpdate.add(subCustomer);
            opp.Subsidiary_Customer_Id__c = subCustomer.Id;
            opp.Subsidiary_Customer__c = subCustomer.Id;
        }
    }
    if (subsToUpdate != null && subsToUpdate.size() > 0) {
        insert subsToUpdate;
    }
}