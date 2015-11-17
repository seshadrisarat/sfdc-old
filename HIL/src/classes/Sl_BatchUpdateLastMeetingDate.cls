/** 
* @author Sruti Srivastava
* @date 11/April/2014
* \HIL-1
*/

global class Sl_BatchUpdateLastMeetingDate implements Database.Batchable<Sobject>  
{
	public Datetime previousDate; //To store the current Date
	public Datetime todayDate; //To store the current Date
    /*  Start : Constructor */
    public Sl_BatchUpdateLastMeetingDate()  
    {
    	previousDate = datetime.newInstance(Date.Today().addDays(-1).year(), Date.Today().addDays(-1).month(), Date.Today().addDays(-1).day());
    	todayDate = datetime.newInstance(Date.Today().year(), Date.Today().month(), Date.Today().day());
    }

    /*
        @MethodName : start 
        @param      : Database.BatchableContext BC
        @Description: Queries the events records 
    */
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
    	
    	String strQuery = 'SELECT ActivityDate, EndDateTime, Id, WhoId, WhatId, Type FROM Event WHERE '+
    						' EndDateTime < :todayDate AND EndDateTime >= :previousDate AND Count_Towards_SLA__c = True';
    	system.debug(strQuery);
        return Database.getQueryLocator(strQuery);
    }
    /*
        @MethodName : execute 
        @param      : Database.BatchableContext BC, List<Event> lstSobjects
        @Description: Processes the Event records recieved from the Start method in batches
    */
    global void execute(Database.BatchableContext BC, List<SObject> lstSobjects )
    {
    	// Creating Meeting Attendee(s) and/or Meeting Staff(s) based on Event/Event Relation(s) associated. 
        UpdateLastMeetingDateOnAccAndRelGroup(lstSobjects);
    }
    
     /*
        @MethodName : execute 
        @param      : Database.BatchableContext BC, List<Event> lstSobjects
        @Description: 
    */ 
	public void UpdateLastMeetingDateOnAccAndRelGroup(List<Event> lstActivityObjects)
	{
		Map<Id, Account> mapId_UpdateAccount = new Map<Id, Account>(); // Map for storing Account Id and Account object for updating the Account
		
		Set<Id> setAccountIds = new Set<Id>();
		Set<Id> setContactIds = new Set<Id>();
		
		Map<Id, Account> mapIdPersonAccount 		= new Map<Id, Account>(); 
		Map<Id, Date> mapAccountIdRecentDate = new Map<Id, Date>(); //Storing Map of Account Id to most recent Activity Date
		Map<Id, String> mapContactIdPersonAccountId	= new Map<Id, String>();
		Map<Id, Event> mapEvent = new Map<Id, Event>();
		mapEvent.putAll(lstActivityObjects);
		todayDate = datetime.newInstance(Date.Today().year(), Date.Today().month(), Date.Today().day());
		for(Event objEvent : mapEvent.values())
		{
			If( objEvent.Type == 'Meeting')
			{
				if(objEvent.WhatId != null && String.valueOf(objEvent.WhatId).startsWith('001') )
					setAccountIds.add(objEvent.WhatId);	
				if(objEvent.WhoId != null &&  String.valueOf(objEvent.WhoId).startsWith('003') )
					setContactIds.add(objEvent.WhoId);
			}	
		}
		if(!setContactIds.isEmpty())
		{
			for(Contact objContact : [Select Id, Name, AccountId FROM Contact WHERE Id In :setContactIds and Account.IsPersonAccount = true])
			{
				mapContactIdPersonAccountId.put(objContact.Id, objContact.AccountId);
			}
		}
		
		//Querying Event records
		if(!setAccountIds.isEmpty())
			for(Event objEvent : [Select Id, WhatId, WhoId, EndDateTime, Type From Event where (WhatId IN: setAccountIds 
			OR WhoId IN: mapContactIdPersonAccountId.keyset() ) AND 
					Id NOT IN: mapEvent.keyset() AND EndDateTime != null AND Type = 'Meeting' AND EndDateTime >=  :todayDate AND Count_Towards_SLA__c = True])
			{
				Date eventDate = objEvent.EndDateTime.Date();
				
				Id strAccId = setAccountIds.contains(objEvent.WhatId) ? objEvent.WhatId : mapContactIdPersonAccountId.containsKey(objEvent.WhoId) 
				? mapContactIdPersonAccountId.get(objEvent.WhoId): null ;
				
				if(strAccId != null && mapAccountIdRecentDate.containsKey(strAccId) && mapAccountIdRecentDate.get(strAccId) < eventDate)
					mapAccountIdRecentDate.put(strAccId, eventDate);
				else if(strAccId != null && !mapAccountIdRecentDate.containsKey(strAccId))
					mapAccountIdRecentDate.put(strAccId, eventDate);
			}
		
		//Querying related Task records
		if(!setAccountIds.isEmpty())
			for(Task objTask : [Select Id, WhatId, WhoId, ActivityDate, Type From Task where (WhatId IN: setAccountIds 
			OR WhoId IN: mapContactIdPersonAccountId.keyset() ) 
			AND ActivityDate != null AND Type = 'Meeting' AND ActivityDate >= :Date.today() AND Count_Towards_SLA__c = True ])
			{
				Id strAccId = setAccountIds.contains(objTask.WhatId) ? objTask.WhatId : mapContactIdPersonAccountId.containsKey(objTask.WhoId) 
				? mapContactIdPersonAccountId.get(objTask.WhoId): null ;
				
				if(strAccId != null && mapAccountIdRecentDate.containsKey(strAccId) && mapAccountIdRecentDate.get(strAccId)< objTask.ActivityDate)
					mapAccountIdRecentDate.put(strAccId, objTask.ActivityDate);
				else if(strAccId != null && !mapAccountIdRecentDate.containsKey(strAccId))
					mapAccountIdRecentDate.put(strAccId, objTask.ActivityDate);
			}
		//Updating Last Meeting Date on Event
		if(!mapAccountIdRecentDate.isEmpty())
			for(Account objAccount : [Select Id, Last_Meeting_Date__c From Account where Id IN: mapAccountIdRecentDate.keyset() ])
			{
				if(mapAccountIdRecentDate.containsKey(objAccount.Id) && (objAccount.Last_Meeting_Date__c == null 
				|| objAccount.Last_Meeting_Date__c < mapAccountIdRecentDate.get(objAccount.Id)))
				{
					objAccount.Last_Meeting_Date__c = mapAccountIdRecentDate.get(objAccount.Id);
					mapIdPersonAccount.put(objAccount.Id, objAccount);	
				}	
			}
		
		//Updating Account records
		if(!mapIdPersonAccount.isEmpty())
			Database.update(mapIdPersonAccount.values(), false); 
			
		Map<Id, Group_Member__c> mapIdGroupMember = new Map<Id, Group_Member__c>();//Group member records to update
		//Updating Group relationship records
		if(!mapIdPersonAccount.keyset().isEmpty())
			for(Group_Member__c objGroupMember : [Select Id, Last_Meeting_Date__c, Last_Contact_Date__c, Client_Prospect__c From Group_Member__c 
													where Client_Prospect__c IN:  mapIdPersonAccount.keyset()])
			{
				if(mapIdPersonAccount.containsKey(objGroupMember.Client_Prospect__c))
				{
					objGroupMember.Last_Meeting_Date__c = mapIdPersonAccount.get(objGroupMember.Client_Prospect__c).Last_Meeting_Date__c;
					mapIdGroupMember.put(objGroupMember.Id, objGroupMember);
				}
			}
		
		if(!mapIdGroupMember.isEmpty())
			Database.update(mapIdGroupMember.values(), false);
	}
	 /*
        @MethodName : finish 
        @param      : Database.BatchableContext BC
        @Description: Performs the post-execution steps
    */
    global void finish(Database.BatchableContext BC)
    {

    }
}