public with sharing class AccountActivityFields {

	// could be tasks, could be events...
	public static void execute(List<sObject> activities) {
		
		String accountPrefix = Account.sObjectType.getDescribe().getKeyPrefix();
		    
		// get related Accounts
		Set<String> relatedAccountIds = new Set<String>();
		String whatId = null;
		
		for(sObject so : activities) {
			
			try {
				whatId = String.valueOf(so.get('WhatId'));
				if(!whatId.startsWith(accountPrefix)) continue;
				relatedAccountIds.add(whatId);
			}
			catch(Exception ex) {
				whatId = null;
				continue;
			}  
			
		}
		
		// stop if there are no accounts to modify
		if(relatedAccountIds.size() == 0) return;
		
		List<Account> accounts;
		
		// load for Last Activity Type...
		accounts = [select
			Id,
			Last_Activity_Type2__c,
			(select ActivityDate, Type from Tasks where ActivityDate <= :Date.today() order by ActivityDate desc limit 1),
			(select ActivityDate, Type from Events where ActivityDate <= :Date.today() order by ActivityDate desc limit 1)
			from Account
			where Id in :relatedAccountIds
		];
				
		system.debug(accounts);
		
		for(Account a : accounts) {
			if(a.Tasks.size() > 0) {
				if(a.Events.size() > 0) {
					if(a.Tasks[0].ActivityDate > a.Events[0].ActivityDate) {
						a.Last_Activity_Type2__c = a.Tasks[0].Type;	
					}
					else {
						a.Last_Activity_Type2__c = a.Events[0].Type;
					}
				}
				else {
					a.Last_Activity_Type2__c = a.Tasks[0].Type;
				}
			}
			else if(a.Events.size() > 0) {
				a.Last_Activity_Type2__c = a.Events[0].Type;
			}
			else {
				a.Last_Activity_Type2__c = null;
			}
		}
		
		update accounts;
		
		// load for Next Activity Date
		accounts = [select  
			Id,
			Next_Activity_Date__c,
			(select ActivityDate from Tasks where ActivityDate >= :Date.today() and Status != 'Completed' order by ActivityDate asc limit 1),
			(select ActivityDate from Events where ActivityDate >= :Date.today() order by ActivityDate asc limit 1)
			from Account
			where Id in :relatedAccountIds
		];
		
		
		system.debug(accounts);
		
		for(Account a : accounts) {
			if(a.Tasks.size() > 0) {
				if(a.Events.size() > 0) {
					if(a.Tasks[0].ActivityDate < a.Events[0].ActivityDate) {
						a.Next_Activity_Date__c = a.Tasks[0].ActivityDate;	
					}
					else {
						a.Next_Activity_Date__c = a.Events[0].ActivityDate;
					}
				}
				else {
					a.Next_Activity_Date__c = a.Tasks[0].ActivityDate;
				}
			}
			else if(a.Events.size() > 0) {
				a.Next_Activity_Date__c = a.Events[0].ActivityDate;
			}
			else {
				a.Next_Activity_Date__c = null;
			}
		}
		
		update accounts;
		
	}

}