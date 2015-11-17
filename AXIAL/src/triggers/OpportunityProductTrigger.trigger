trigger OpportunityProductTrigger on OpportunityLineItem (after insert, after update) {

	List<String> pbeIds = new List<String>();
    List<Account> acctsForUpdate = new List<Account>();
    List<String> acctIds = new List<String>();
    List<String> oppIds = new List<String>();
    for (OpportunityLineItem oppProduct : Trigger.new){
        oppIds.add(oppProduct.OpportunityId);
        pbeIds.add(oppProduct.PriceBookEntryId);
    }
    
    Map<Id, PriceBookEntry> pbeMap = new Map<Id, PriceBookEntry>([
		SELECT Id, Name FROM PriceBookEntry Where Id in :pbeIds
	]);
    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
    List<Opportunity> opps = [SELECT Id, AccountId FROM Opportunity WHERE Id in :oppIds];
    for(Opportunity o : opps){
    	acctIds.add(o.AccountId);
    	oppMap.put(o.Id, o);
    }

    Map<Id, Account> accts = new Map<Id, Account>([
        SELECT Id, Revenue_Level__c, Membership_Level__c
        FROM   Account
        WHERE  Id in :acctIds
    ]);
    for (OpportunityLineItem oppProduct : Trigger.new) {
        String prodName = pbeMap.get(oppProduct.PriceBookEntryId).Name.toLowerCase();
        if(
          oppProduct.Active__c && 
          prodName != null &&
          (prodName.contains('basic') ||
           prodName.contains('advanced') ||
           prodName.contains('professional'))
        ){
          Account acct = accts.get(oppMap.get(oppProduct.OpportunityId).AccountId);
          acct.Revenue_Level__c = oppProduct.Revenue_Level__c;
          acct.Membership_Level__c = pbeMap.get(oppProduct.PriceBookEntryId).Name;
          acctsForUpdate.add(acct);
        }
    }

    update acctsForUpdate;
}