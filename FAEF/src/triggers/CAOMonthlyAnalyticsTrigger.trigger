trigger CAOMonthlyAnalyticsTrigger on CAO_Monthly_Analytics__c (before insert) {

	
	for(CAO_Monthly_Analytics__c cao : Trigger.new) {
		if(cao.AccountID__c == null || cao.AccountID__c == '') continue;
		cao.OwnerId = cao.AccountID__c;
	}
	
  
}