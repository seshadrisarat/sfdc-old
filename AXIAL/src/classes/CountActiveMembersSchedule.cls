global class CountActiveMembersSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		runJob();
	}

	public void runJob(){
		Map<Id, Account> acctMap = new Map<Id, Account>([SELECT Id, Count_Active_Members_CM__c FROM Account WHERE Investor_Classification__c = 'Client']);
		for(Id acctId :acctMap.keySet()){
			Account a = acctMap.get(acctId);
			a.Count_Active_Members_CM__c = 0;
            a.Count_Active_Members_LM__c = 0;
		}

		AggregateResult[] groupedResults = [SELECT AccountId, Account.Name, COUNT(Id) ActiveMembers FROM Contact WHERE Active_Member_1_0__c > 0 AND AccountId != null Group By AccountId, Account.Name];
		for (AggregateResult ar :groupedResults){
			String aid = String.valueOf(ar.get('AccountId'));
			Account acct = acctMap.get(aid);
			if(acct != null){
				acct.Count_Active_Members_CM__c = Integer.valueOf(ar.get('ActiveMembers'));
			}
		}

		AggregateResult[] groupedResults1 = [SELECT AccountId, Account.Name, COUNT(Id) ActiveMembers FROM Contact WHERE Active_Member_LM_1_0__c  > 0 AND AccountId != null Group By AccountId, Account.Name];
		for (AggregateResult ar :groupedResults1){
			String aid = String.valueOf(ar.get('AccountId'));
			Account acct = acctMap.get(aid);
			if(acct != null){
				acct.Count_Active_Members_LM__c = Integer.valueOf(ar.get('ActiveMembers'));
			}
		}

		update acctMap.values();
	}
}