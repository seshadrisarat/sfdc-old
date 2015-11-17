global class SL_Batch_Create_Joiners implements Database.Batchable<sObject> {
	
	String query;
	
	global SL_Batch_Create_Joiners()
	{
		query = 'SELECT Id ' +
				'FROM Note__c ' +
				'WHERE Rep_Code__r.Rep_Code__c LIKE \'PA%\' AND Subject_Text__c = \'Client Notes\'';		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope)
   	{
   		Note__c[] tempNList = (Note__c[]) scope;
   		map<Id,Note__c> noteMap = new map<Id,Note__c>();
   		Set<Id> nIds = new Set<Id>();

   		System.debug(tempNList);

   		for(Note__c n : tempNList)
   		{
   			nIds.add(n.Id);
   		}

   		Note_Joiner__c[] tempNJList = [SELECT Id,Note__r.Rep_Code__c,Client_Prospect__c,Note__c
   									   FROM Note_Joiner__c
   									   WHERE Note__c IN: nIds];

   		for(Note_Joiner__c nj : tempNJList)
   		{
   			Note__c n = new Note__c(Id = nj.Note__c,Account_del__c = nj.Client_Prospect__c, Rep_Code__c = nj.Note__r.Rep_Code__c,
   									Create_Joiner_Records__c = true);

   			noteMap.put(n.Id,n);
   		}

   		Note__Share[] delShares = [Select Id
   								   From Note__Share
							   	   WHERE ParentId IN: nIds AND RowCause != 'Owner' AND RowCause != 'Rule'];

   		delete delShares;

   		SL_Note_Joiner_Handler njh = new SL_Note_Joiner_Handler(false,50);
   		njh.createJoinerRecs(noteMap);

   		delete tempNJList;

	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}