/**
* \arg ClassName      : SL_NoteHandler
* \arg JIRATicket     : HIL-4
* \arg CreatedOn      : 13/FEB/2015
* \arg LastModifiedOn : 26/MAR/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Bryan Anderson
* \arg Description    : This class serves as handler for SL_Note and used to create sharing records corresponding to Note__c. This class calls SL_Util_SharingController for creating sharing records.
*/
public without sharing class SL_NoteHandler 
{
	static final String ACCESS_LEVEL = 'Read';
	
	/* Start - Constructor */
	public SL_NoteHandler()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	 /*
        * MethodName   : onAfterInsert
        * Param        : list of inserted Note__c records
        * Description  : This method is used to create sharing records corresponding to inserted Note__c records. This method calls createSharingRecords method for performing this operation.
    */
	public void onAfterInsert(Map<Id,Note__c> newMap)
	{
		SL_Note_Joiner_Handler njHandler = new SL_Note_Joiner_Handler(false,200);
		njHandler.createJoinerRecs(newMap);
		createSharingRecords(null,newMap);//calling method to create association of rep code ids with object record ids.
		
		//updateDatesOnClientAndHousehold(null, newMap.values());
	}

	public void onAfterUpdate(Map<Id,Note__c> oldMap, Map<Id,Note__c> newMap)
	{
		SL_Note_Joiner_Handler njHandler = new SL_Note_Joiner_Handler(false,200);
		njHandler.createJoinerRecs(newMap);
		
		myUpdateSLA(newMap.keySet(),false);
		
		//updateDatesOnClientAndHousehold(oldMap, newMap.values());
		//createSharingRecords(null,newMap);//calling method to create association of rep code ids with object record ids.
	}
	
	/******************Added by Lodhi 13 MAY 2015****************/
	
	public void onBeforeDelete(Map<Id, Note__c> mapIdToNoteOld)
	{
		myUpdateSLA(mapIdToNoteOld.keySet(),true);
	    
	    //updateDatesOnClientAndHousehold(null, mapIdToNoteOld.values());
	}
	
    /*
        * MethodName   : updateDatesOnClientAndHousehold
        * Param        : Map of Note__c
        * Description  : 
    */
    private void updateDatesOnClientAndHousehold(Map<Id, Note__c> mapIdToNoteOld, List<Note__c> lstNote)
    {
        Set<Id> setClientProspectId = new Set<Id>();
        Set<Id> setRelationGroupId = new Set<Id>();
        
        for(Note__c objNote : lstNote)
        {
            // if(mapIdToNoteOld == null || (objNote.Type__c != mapIdToNoteOld.get(objNote.Id).Type__c 
            //   || objNote.ActivityDate__c != mapIdToNoteOld.get(objNote.Id).ActivityDate__c))
            // {
                if(objNote.Account_del__c != null)
    	            setClientProspectId.add(objNote.Account_del__c);
    	        if(objNote.Relationship_Group__c != null)
    	            setRelationGroupId.add(objNote.Relationship_Group__c);   
            // }    	            
        }
        updateMembers(setClientProspectId, setRelationGroupId);
    }
    
    @future
    private static void updateMembers(Set<Id> setClientProspectId, Set<Id> setRelationGroupId)
    {
        Map<Id, Id> mapAccIdToMaxActivityDateNoteId = new Map<Id, Id>();
        Map<Id, Id> mapAccIdToNonMaxActivityDateNoteId = new Map<Id, Id>();
        Map<Id, Id> mapRelGrpIdToMaxActivityDateNoteId = new Map<Id, Id>();
        Map<Id, Id> mapRelGrpIdToNonMaxActivityDateNoteId = new Map<Id, Id>();
        Map<Id, Note__c> mapIdToNote = new Map<Id, Note__c>();
        List<Account> lstAccount = new List<Account>();
        List<Group_Member__c> lstGM = new List<Group_Member__c>();
        
        for(Note__c objNote : [SELECT Id, Account_del__c,
                                      Relationship_Group__c,
                                      ActivityDate__c
                                 FROM Note__c
                                WHERE Account_del__c IN : setClientProspectId 
                                  AND Count_Towards_SLA__c = true
                                  AND Type__c = 'Meeting'
                            ORDER BY ActivityDate__c DESC])
        {
            if(objNote.Account_del__c != null && !mapAccIdToMaxActivityDateNoteId.containsKey(objNote.Account_del__c))
                mapAccIdToMaxActivityDateNoteId.put(objNote.Account_del__c, objNote.Id);
        }  
        
        for(Note__c objNote : [SELECT Id, Account_del__c,
                                      Relationship_Group__c,
                                      ActivityDate__c
                                 FROM Note__c
                                WHERE Relationship_Group__c IN : setRelationGroupId
                                  AND Count_Towards_SLA__c = true
                                  AND Type__c = 'Meeting'
                            ORDER BY ActivityDate__c DESC])
        {
            if(objNote.Relationship_Group__c != null && !mapRelGrpIdToMaxActivityDateNoteId.containsKey(objNote.Relationship_Group__c))
                mapRelGrpIdToMaxActivityDateNoteId.put(objNote.Relationship_Group__c, objNote.Id);
        }      
        
        mapIdToNote = new Map<Id, Note__c>([SELECT Id, ActivityDate__c 
        									  FROM Note__c 
        									 WHERE Id IN : mapAccIdToMaxActivityDateNoteId.values()
        									    OR Id IN : mapRelGrpIdToMaxActivityDateNoteId.values()]);
        
        for(Note_Joiner__c objNoteJoiner : [SELECT Id, 
                                                   Note__c, 
                                                   Client_Prospect__c, 
                                                   Relationship_Group__c 
                                              FROM Note_Joiner__c
                                             WHERE Note__c IN : mapIdToNote.keySet()])
        {
        	if(objNoteJoiner.Client_Prospect__c != null) setClientProspectId.add(objNoteJoiner.Client_Prospect__c);
        	if(objNoteJoiner.Relationship_Group__c != null) setRelationGroupId.add(objNoteJoiner.Relationship_Group__c);
        }
        
        for(Id accountId :setClientProspectId )
        {
        	lstAccount.add(new Account(Id = accountId, 
        	                           Last_Meeting_Date__c = (mapAccIdToMaxActivityDateNoteId.containsKey(accountId))
        	                           						   ? mapIdToNote.get(mapAccIdToMaxActivityDateNoteId.get(accountId)).ActivityDate__c
        	                           						   : null));
        }
        if(!lstAccount.isEmpty())
            update lstAccount;
        
        for(Group_Member__c objGM : [SELECT Id, Client_Prospect__c, Relationship_Group__c FROM Group_Member__c 
        							  WHERE Client_Prospect__c IN : setClientProspectId OR Relationship_Group__c IN: setRelationGroupId])
    	{
    	    if(mapAccIdToMaxActivityDateNoteId.containsKey(objGM.Client_Prospect__c) && mapRelGrpIdToMaxActivityDateNoteId.containsKey(objGM.Relationship_Group__c))
    		{ 
    		    Date dtDate = (mapIdToNote.get(mapAccIdToMaxActivityDateNoteId.get(objGM.Client_Prospect__c)).ActivityDate__c > mapIdToNote.get(mapRelGrpIdToMaxActivityDateNoteId.get(objGM.Relationship_Group__c)).ActivityDate__c )
	                           ? mapIdToNote.get(mapAccIdToMaxActivityDateNoteId.get(objGM.Client_Prospect__c)).ActivityDate__c
	                           : mapIdToNote.get(mapRelGrpIdToMaxActivityDateNoteId.get(objGM.Relationship_Group__c)).ActivityDate__c;
    		    lstGM.add(new Group_Member__c(Id = objGM.Id, Last_Meeting_Date__c = dtDate));
    		}
    		
    		else if(mapAccIdToMaxActivityDateNoteId.containsKey(objGM.Client_Prospect__c) && !mapRelGrpIdToMaxActivityDateNoteId.containsKey(objGM.Relationship_Group__c))
    		{
    		    Date dtDate = mapIdToNote.get(mapAccIdToMaxActivityDateNoteId.get(objGM.Client_Prospect__c)).ActivityDate__c;   
    		    lstGM.add(new Group_Member__c(Id = objGM.Id, Last_Meeting_Date__c = dtDate));
    		}
    		
    		else if(!mapAccIdToMaxActivityDateNoteId.containsKey(objGM.Client_Prospect__c) && mapRelGrpIdToMaxActivityDateNoteId.containsKey(objGM.Relationship_Group__c))
    		{
    		    Date dtDate = mapIdToNote.get(mapRelGrpIdToMaxActivityDateNoteId.get(objGM.Relationship_Group__c)).ActivityDate__c;   
    		    lstGM.add(new Group_Member__c(Id = objGM.Id, Last_Meeting_Date__c = dtDate));
    		}
    		else
    		{
    		    lstGM.add(new Group_Member__c(Id = objGM.Id, Last_Meeting_Date__c = null));
    		}
    	} 
    	if(!lstGM.isEmpty())
    	    update lstGM;
    }
    
    
    /* End */
    	
	/******************Added by Lodhi 13 MAY 2015****************/
	
	/*
        * MethodName   : createSharingRecords
        * Param        : list of inserted Note__c records
        * Description  : This method is used to create sharing records corresponding to inserted Note__c records. This method calls createSharingRecords method of SL_Util_SharingController class.
    */
	
	
    public static void myUpdateSLA(Set<Id> nIds, Boolean isDelete)
    {
    	Set<Id> relGrpIds = new Set<Id>();
		Set<Id> acctIds = new Set<Id>();
		Set<Id> nIdsAcct = new Set<Id>();

		System.debug(nIds);

		map<Id,Account> acctMap = new map<Id,Account>();

		Note_Joiner__c[] njList = [Select Id,Note__c,Client_Prospect__c,Relationship_Group__c
								   From Note_Joiner__c
								   WHERE Note__c IN: nIds];

		for(Note_Joiner__c nj : njList)
		{
			if(nj.Client_Prospect__c != null)
			{
				acctIds.add(nj.Client_Prospect__c);
			}

			if(nj.Relationship_Group__c != null)
			{
				relGrpIds.add(nj.Relationship_Group__c);
			}
		}

		System.debug(acctIds);

		njList = [Select Id,Note__c
				  From Note_Joiner__c
				  WHERE Relationship_Group__c IN: relGrpIds];

		for(Note_Joiner__c nj : njList)
		{
			if(nj.Note__c != null)
			{
				nIdsAcct.add(nj.Note__c);
			}
		}

		System.debug(nIdsAcct);

		if(isDelete)
		{
			nIdsAcct.removeAll(nIds);
		}

		AggregateResult[] arNoteAcctContDate = [SELECT Client_Prospect__c client,MAX(Note__r.ActivityDate__c) maxDate
												 FROM Note_Joiner__c
												 WHERE Client_Prospect__c IN: acctIds AND Note__c IN: nIdsAcct AND Note__r.ActivityDate__c != null AND (Note__r.Type__c = 'Call' OR Note__r.Type__c = 'Note') AND Note__r.Count_Towards_SLA__c = true GROUP BY Client_Prospect__c];
		System.debug(arNoteAcctContDate);

		AggregateResult[] arNoteAcctMeetDate = [SELECT Client_Prospect__c client,MAX(Note__r.ActivityDate__c) maxDate
												 FROM Note_Joiner__c
												 WHERE Client_Prospect__c IN: acctIds AND Note__c IN: nIdsAcct AND Note__r.ActivityDate__c != null AND Note__r.Type__c = 'Meeting' AND Note__r.Count_Towards_SLA__c = true GROUP BY Client_Prospect__c];
		System.debug(arNoteAcctMeetDate);

		for(AggregateResult ar : arNoteAcctContDate)
		{
			Id acctId = (Id)ar.get('client');
			Date maxDate = (Date)ar.get('maxDate');
			
			if(acctMap.containsKey(acctId))
			{
				acctMap.get(acctId).Last_Contact_Date__c = maxDate;
			}else
			{
				acctMap.put(acctId, new Account(Id = acctId,Last_Contact_Date__c = maxDate));	
			}
		}

		for(AggregateResult ar : arNoteAcctMeetDate)
		{
			Id acctId = (Id)ar.get('client');
			Date maxDate = (Date)ar.get('maxDate');
			
			if(acctMap.containsKey(acctId))
			{
				acctMap.get(acctId).Last_Meeting_Date__c = maxDate;
			}else
			{
				acctMap.put(acctId, new Account(Id = acctId,Last_Meeting_Date__c = maxDate));	
			}
		}

		Group_Member__c[] gmList = [Select Id,Client_Prospect__c,Last_Contact_Date__c,Last_Meeting_Date__c
									From Group_Member__c
									WHERE Relationship_Group__c IN: relGrpIds];

		for(Group_Member__c gm : gmList)
		{
			if(acctMap != null && !acctMap.isEmpty() && acctMap.get(gm.Client_Prospect__c) != null)
			{
				Account a = acctMap.get(gm.Client_Prospect__c);
				gm.Last_Contact_Date__c = a.Last_Contact_Date__c;
				gm.Last_Meeting_Date__c = a.Last_Meeting_Date__c;
			}else
			{
				//gm.Last_Contact_Date__c = null;
				//gm.Last_Meeting_Date__c = null;
			}
		}


		System.debug(gmList);
		update gmList;
		System.debug(acctMap.values());
		update acctMap.values();
    }
	private void createSharingRecords(Map<Id,Note__c> oldMap, Map<Id,Note__c> newMap)
	{
		List<SL_Util_SharingController.RepCodeType> rcList = new List<SL_Util_SharingController.RepCodeType>();
		
		for(Note__c objNote : newMap.values())
		{
			if(objNote.Account_del__c != null && objNote.Rep_Code__c != null && objNote.Create_Sharing_Records__c)
			{
				rcList.add(new SL_Util_SharingController.RepCodeType(objNote.Id, objNote.Rep_Code__c));
			}
		}
		
		if(!rcList.isEmpty())
        {
			insert SL_Util_SharingController.createSharingRecords(rcList, ACCESS_LEVEL);
        }
	}
}