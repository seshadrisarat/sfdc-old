global class BatchAccountNextActivityDate implements Database.Batchable<sObject>,Schedulable {

	// usage:
   // Id batchId = Database.executeBatch(new BatchAccountNextActivityDate()); 
   
	global BatchAccountNextActivityDate() {}
	
	global void execute(SchedulableContext SC){
		Id batchId = Database.executeBatch(new BatchAccountNextActivityDate());
	}

	global Database.Querylocator start(Database.BatchableContext context) {
		
		if(Test.isRunningTest()) {
			return Database.getQueryLocator([select  
				Id,
				Next_Activity_Date__c,
				(select ActivityDate from Tasks where ActivityDate >= :Date.today() and Status != 'Completed' order by ActivityDate asc limit 1),
				(select ActivityDate from Events where ActivityDate >= :Date.today() order by ActivityDate asc limit 1) 
				from Account limit 200
			]);
		}
		
		return Database.getQueryLocator([select  
			Id,
			Next_Activity_Date__c,
			(select ActivityDate from Tasks where ActivityDate >= :Date.today() and Status != 'Completed' order by ActivityDate asc limit 1),
			(select ActivityDate from Events where ActivityDate >= :Date.today() order by ActivityDate asc limit 1)
			from Account
		]);
	}

	global void execute(Database.BatchableContext context, List<Account> accounts) {
		
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

	global void finish(Database.BatchableContext context) {}

	@isTest (SeeAllData=true)
	public static void testBatch() {
   		Account a = new Account(name = 'test account');
   		insert a;
   		Task t = new Task(subject = 'test task', Status = 'Not Started', ActivityDate = Date.today().addDays(7), WhatId = a.id);
   		insert t;
   		Event e = new Event(subject = 'test event', ActivityDate = Date.today().addDays(7), DurationInMinutes = 30, ActivityDateTime = DateTime.now(), WhatId = a.id);
   		insert e;
   		  
		
		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5)
        {
        	Test.StartTest();
        		BatchAccountNextActivityDate batch = new BatchAccountNextActivityDate();
				Id batchProcessId = Database.executeBatch(batch);
			Test.StopTest();
        }	
		
	
	} 

}