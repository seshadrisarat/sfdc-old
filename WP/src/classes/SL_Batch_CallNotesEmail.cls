/**
* \arg ClassName      : SL_Batch_CallNotesEmail
* \arg JIRATicket     : WP-136
* \arg CreatedOn      : 4/MAY/2014
* \arg LastModifiedOn : 8/MAY/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This batch process is used to send emails to all the internal contacts of Event to respond with the call notes
*/
global class SL_Batch_CallNotesEmail implements Database.Batchable<sobject>
{
	/* Start - Variables */
	private static String strBody = 'Please enter the Call Notes for ';
	private static Id employeeRecordType = [SELECT Id FROM RecordType WHERE DeveloperName=:'Employee' LIMIT 1].Id;
	private static String defaultEmailAddress = Reply_To_Address__c.getInstance('Default')!=NULL ? Reply_To_Address__c.getInstance('Default').Email__c : NULL;
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_Batch_CallNotesEmail()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	/*
        * MethodName   : start
        * Param        : Database.BatchableContext BC
        * Description  : This method returns the event records that will be processed by execute method.
    */
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        DateTime dtPastOneHour = !Test.isRunningTest() ? DateTime.now().addHours(-1) : Datetime.newInstance(2015, 5, 5, 11, 35, 45);
        return Database.getQueryLocator('SELECT Id, CallNotesRequestSent__c,Subject FROM Event WHERE RecordType.DeveloperName=\'Fundraising_Event\' AND CallNotesRequestSent__c=false AND ((EndDateTime <=:dtPastOneHour AND IsAllDayEvent=false) OR (ActivityDateTime <=:dtPastOneHour AND IsAllDayEvent=true))');
    }
    
     /*
        * MethodName   : execute
        * Param        : Database.BatchableContext BC, List of event records
        * Description  : This method is used to send an email reminder to all internal contacts and their admins.
    */
    global void execute(Database.BatchableContext BC, List<Event> lstEvent)
    {
    	Map<Id, Set<String>> mapConIdToCCAddress = new Map<Id, Set<String>>();// map to hold the internal contact id and its corresponding admin assignments email addresses. 
    	Set<Id> setRelationIds = new Set<Id>();// set to hold Id of internal contacts
    	Map<Id, Event> mapIdToEvent = new Map<Id, Event>(lstEvent);//map to hold event records
    	Map<Id,Set<Id>> mapEventIdToSetOfInternalContacts = new Map<Id, Set<Id>>();//map to hold the event and its corresponding internal contacts
    	Map<Id, Contact> mapIdToContact = new Map<Id,Contact>();
    	List<Messaging.Singleemailmessage> lstMails = new List<Messaging.Singleemailmessage>();
    	
    	//Fetching the event relations corresponding to the internal contacts
    	for(EventRelation objEventRelation : [SELECT RelationId, EventId FROM EventRelation WHERE EventId IN :mapIdToEvent.keyset() AND Relation.RecordTypeId =:employeeRecordType AND Relation.Type=:'Contact'])
    	{
    		setRelationIds.add(objEventRelation.RelationId);
    		if(!mapEventIdToSetOfInternalContacts.containskey(objEventRelation.EventId))
    			mapEventIdToSetOfInternalContacts.put(objEventRelation.EventId, new Set<Id>{objEventRelation.RelationId});
    		else
    			mapEventIdToSetOfInternalContacts.get(objEventRelation.EventId).add(objEventRelation.RelationId);
    	}
    	
    	//Fetching admin assignment records
    	for(Contact objContact : [SELECT Id, Email, (SELECT Admin__r.Email From Admin_Assignments__r WHERE Admin__r.Email!=NULL) FROM Contact WHERE Id IN : setRelationIds AND Email!=NULL])
    	{
    		mapIdToContact.put(objContact.Id,objContact);
    		if(!objContact.Admin_Assignments__r.isEmpty())
    		{    			
	    		for(Admin_Assignment__c objAdminAssignment : objContact.Admin_Assignments__r)
	    		{	    			
	    			if(!mapConIdToCCAddress.containskey(objContact.Id))
	    				mapConIdToCCAddress.put(objContact.Id, new Set<String>{objAdminAssignment.Admin__r.Email});
	    			else
	    				mapConIdToCCAddress.get(objContact.Id).add(objAdminAssignment.Admin__r.Email);
	    		}    	
    		}		
    	}
    	
    	//Iterating over event records to send an email.
    	for(Event objEvent : mapIdToEvent.values())
    	{
    		Set<String> setToAddresses = new Set<String>();
    		Set<String> setCCAddresses = new Set<String>();
    		if(mapEventIdToSetOfInternalContacts.containskey(objEvent.Id))
    		{
	    		for(Id contactId : mapEventIdToSetOfInternalContacts.get(objEvent.Id))
	    		{
	    			if(mapIdToContact.containskey(contactId))
	    				setToAddresses.add(mapIdToContact.get(contactId).Email);
	    			if(mapConIdToCCAddress.containskey(contactId))
	    			{
	    				setCCAddresses.addAll(mapConIdToCCAddress.get(contactId));
	    			}
	    		}
    		}
    		if(!setToAddresses.isEmpty())
    		{
	    		Messaging.Singleemailmessage objEmail = new Messaging.Singleemailmessage();
	            objEmail.setHtmlBody(strBody + objEvent.Subject);
	            objEmail.setSubject(objEvent.Subject + ' - ' + String.format('({0})', new List<String>{objEvent.Id}));
	            objEmail.setToAddresses(new List<String>(setToAddresses));
	            objEmail.setCcAddresses(new List<String>(setCCAddresses));
	            if(String.isNotEmpty(defaultEmailAddress))
	            	objEmail.setReplyTo(defaultEmailAddress);
	            lstMails.add(objEmail);
	            mapIdToEvent.get(objEvent.Id).CallNotesRequestSent__c = true;
    		}                
    	}
    	
    	if(!lstMails.isEmpty())
    	{
            Messaging.sendEmail(lstMails);
            update mapIdToEvent.values();
    	}
    }
    
     /*
        * MethodName   : finish
        * Param        : Database.BatchableContext BC
        * Description  : Performs necessary post-execution steps
    */
    global void finish(Database.BatchableContext BC)
    {
        //Do Nothing
    }     
}