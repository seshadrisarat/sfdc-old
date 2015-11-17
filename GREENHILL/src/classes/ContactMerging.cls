global class ContactMerging implements Database.Batchable<sObject>{
	
	global String Query;
    global String CombinedField;
    global list<String> Fields;
    global String ObjectType;
    global String Delimeter;
	
	global ContactMerging(){
		Delimeter = ':';
		CombinedField = 'CombinedOwners__c';
		Fields = new list<string>();
		/**
		We do not fill in OwnerID because that field is already set correctly. That was how we select which contact to merge into
		Fields.add('OwnerID');
		**/
		Fields.add('Contact_Owner1__c');
		Fields.add('Contact_Owner2__c');
		Fields.add('Contact_Owner3__c');
		Fields.add('Contact_Owner4__c');
		ObjectType = 'Contact';
		
		Query='select '+CombinedField+','+' OwnerID,';
		for(string s : Fields)
			Query=Query+s+',';
		Query= Query+'ID'+' from '+ObjectType+ ' where '+CombinedField+' != \'\'';
	}
	
	global ContactMerging(String CF, list<string> Fieldlist, String O, string Delim){
		Delimeter = Delim;
		CombinedField = CF;
		Fields = Fieldlist;
		ObjectType = O;
		
		Query='select '+CombinedField+',';
		for(string s : Fields)
			Query=Query+s+',';
		Query= Query+'ID'+' from '+ObjectType+ ' where '+CombinedField+' != \'\'';
		system.debug('***QUERY: '+Query);	
   	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   	}
   	
   	global void execute(Database.BatchableContext BC, List<sObject> scope){
 	 integer fieldnum = Fields.size();
 	 	  		
     for(sobject s : scope){
     	string CFvalue = (string) s.get(CombinedField);
     	set<string> CFvalueSet = new set<string>(CFvalue.split(Delimeter,0));
     	
     	list<string> ExcludedOwners = new list<string>();
     	ExcludedOwners.add(String.valueof(s.get('OwnerID')));
     	/**test users**/
     	ExcludedOwners.add('00540000000nK6Q');
     	ExcludedOwners.add('00540000001RC9fAAG');
     	ExcludedOwners.add('00540000001RC9m');
     	CFvalueSet.removeall(ExcludedOwners);
     	
     	list<string> CFvalues = new list<string>(CFvalueSet);
     	
     	integer valuenum = CFvalues.size();
     	for(integer i=0; i<valuenum && i<fieldnum;i++){
     			s.put(Fields.get(i),CFvalues.get(i));
     			//system.debug('****FIELD: '+Fields.get(i)+' value: '+CFvalues.get(i));
     	}
     }
     
     update scope;
    }
	
	
	global void finish(Database.BatchableContext BC){
	    
	   AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
	   
	   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	   String[] toAddresses = new String[] {'greg.grin@gmail.com'};
	   mail.setToAddresses(toAddresses);
	   mail.setSubject('Apex batch job ' + a.Status);
	   mail.setPlainTextBody
	   ('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
	   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

}