/**
* @ClassName    : SL_GroupMemberHandler   
* @JIRATicket   : HIL-20
* @CreatedOn    : 22/July/2015
* @ModifiedBy   : Nrusingh
* @Description  : Handler class used to roll up the Notes to the Household
*/  
public with sharing class SL_GroupMemberHandler 
{
	private static List<Note_Joiner__c>  lstGlobalDeleteNotes = new List<Note_Joiner__c>();
	private static List<Group_Account__c>  lstGlobalDeleteFinanicalAccount = new List<Group_Account__c>();
	private static Map <Id, Set<Id>> mapHouseholdIdToSetOfTotalClients = new Map <Id, Set<Id>>(); 
	
	/*
        * MethodName : onAfterInsert
        * Param      : List<Group_Member__c>(Trigger.new) 
        * Description: Triggers on after insert of Group Member record to add the notes to the Household
    */  
    public void onAfterInsert(List<Group_Member__c> lstGroupMembers)
    {
    	rollUpNotesToHouseHold(lstGroupMembers,null);
    }
    
    /*
        * MethodName : onAfterDelete
        * Param      : Map<Id, Group_Member__c> mapIdToNewGroupMembers, Map<Id, Group_Member__c> mapIdToOldGroupMembers(Trigger.NewMap,Trigger.OldMap ) 
        * Description: Triggers on after delete of Group Member record to remove the notes from the Household
    */  
    public void onAfterUpdate(Map<Id, Group_Member__c> mapIdToNewGroupMembers, Map<Id, Group_Member__c> mapIdToOldGroupMembers)
    {
    	rollUpNotesToHouseHold(mapIdToNewGroupMembers.values(),mapIdToOldGroupMembers);
    }
    
    
    /*
        * MethodName : onAfterDelete
        * Param      : Map<Id, Group_Member__c> mapIdToGroupMembers(Trigger.oldMap) 
        * Description: Triggers on after delete of Group Member record to remove the notes from the Household
    */  
    public void onAfterDelete(Map<Id, Group_Member__c> mapIdToGroupMembers)
    {
    	updateNotes();
    	removeFinanicalAccounts();
    }
   
    public void onBeforeDelete(Map<Id, Group_Member__c> mapIdToGroupMembers)
    {
    	rollUpNotesToHouseHold(null, mapIdToGroupMembers);
    }
	
	public void onBeforeUpdate(Map<Id, Group_Member__c> mapIdToNewGroupMembers, Map<Id, Group_Member__c> mapIdToOldGroupMembers)
	{
	 	fetchallOldClients(mapIdToNewGroupMembers, mapIdToOldGroupMembers);
	}
	
	/*
        * MethodName : rollUpNotesToHouseHold
        * Param      : List <Group_Member__c> lstGroupMembers, Map<Id, Group_Member__c> mapIdToOldGroupMembers
        * Description: Fetching the notes and Rolling up the Notes
    */ 
	private void rollUpNotesToHouseHold(List <Group_Member__c> lstGroupMembers, Map<Id, Group_Member__c> mapIdToOldGroupMembers)
	{
		Map <Id, Set <Id>> mapHouseholdToSetOfClientProspects = new Map <Id, Set <Id>> ();
		Map <String, Set <Id>> mapHouseholdToOldSetOfClientProspects = new Map <String, Set <Id>> ();
		Set <Id> setClientId = new Set <Id> ();
		Set <String> setHousehold_Client = new Set <String> ();
		Set <Id> setOldHouseholdId = new Set <Id> ();
		Set <Id> setNewHouseholdId = new Set <Id> ();
		Map <Id, Set <Id>> mapHouseholdIdToSetGroupId = new Map <Id, Set <Id>>(); 
		Map <Id, Set <Id>> mapHouseholdToOLDClientProspects = new Map <Id, Set <Id>>(); 
		Set <Id> setOldSelectedClientId = new Set <Id>(); 
		// If the Group Member is Deleted
		if(trigger.isDelete)
		{
			for(Group_Member__c objGroupMember : mapIdToOldGroupMembers.values())
			{
				if(!mapHouseholdIdToSetGroupId.containsKey(objGroupMember.Relationship_Group__c))
					mapHouseholdIdToSetGroupId.put(objGroupMember.Relationship_Group__c, new Set<Id>{objGroupMember.Id});
				else
					mapHouseholdIdToSetGroupId.get(objGroupMember.Relationship_Group__c).add(objGroupMember.Id);
			}
			removeNotes(mapHouseholdIdToSetGroupId);
			removeFinanicalAccounts(mapHouseholdIdToSetGroupId);
		}
		
		// If the Group Member is inserted/updated
		if(Trigger.isInsert || Trigger.isUpdate)
		{
			for(Group_Member__c objGroupMember : lstGroupMembers)
			{
				Group_Member__c objOldGM;
				if(!setHousehold_Client.contains(objGroupMember.Relationship_Group__c+'_'+objGroupMember.Client_Prospect__c))
				{
					// Checking if the Group Member is updating
					if(trigger.isUpdate && !mapIdToOldGroupMembers.isEmpty())
					{
						objOldGM = mapIdToOldGroupMembers.get(objGroupMember.Id);
						
						// Checking if the Relationship_Group is updated for the Group Member and maintaining the Map of old_new_Clients
						if(objGroupMember.Relationship_Group__c != objOldGM.Relationship_Group__c)
						{
							if(!mapHouseholdToOldSetOfClientProspects.containsKey(objOldGM.Relationship_Group__c+'_'+objGroupMember.Relationship_Group__c+'_'+objGroupMember.Client_Prospect__c))
								mapHouseholdToOldSetOfClientProspects.put(objOldGM.Relationship_Group__c+'_'+objGroupMember.Relationship_Group__c+'_'+objGroupMember.Client_Prospect__c, new Set<Id>{objGroupMember.Client_Prospect__c});
								
								setOldHouseholdId.add(objOldGM.Relationship_Group__c);
								setNewHouseholdId.add(objGroupMember.Relationship_Group__c);
								setOldSelectedClientId.add(objOldGM.Client_Prospect__c);
								
							if(!mapHouseholdToOLDClientProspects.containsKey(objOldGM.Relationship_Group__c))
								mapHouseholdToOLDClientProspects.put(objOldGM.Relationship_Group__c, new Set<Id>{objOldGM.Client_Prospect__c});
							else
								mapHouseholdToOLDClientProspects.get(objOldGM.Relationship_Group__c).add(objOldGM.Client_Prospect__c);
						}
					}
					// Holding the map that will contain the Relation groups and set of Clients
					if(!mapHouseholdToSetOfClientProspects.containsKey(objGroupMember.Relationship_Group__c))
						mapHouseholdToSetOfClientProspects.put(objGroupMember.Relationship_Group__c, new Set<Id>{objGroupMember.Client_Prospect__c});
					else
						mapHouseholdToSetOfClientProspects.get(objGroupMember.Relationship_Group__c).add(objGroupMember.Client_Prospect__c);
				    		
					setClientId.add(objGroupMember.Client_Prospect__c);
					setHousehold_Client.adD(objGroupMember.Relationship_Group__c+'_'+objGroupMember.Client_Prospect__c);
				}
			}
			
			// Calling insertFinanicalAccounts method
			insertFinanicalAccounts(mapHouseholdToOldSetOfClientProspects,mapHouseholdToSetOfClientProspects,setClientId, setOldHouseholdId);
			
			// Calling the UpdateNotesToHousehold method
			UpdateNotesToHousehold(mapHouseholdToOldSetOfClientProspects,mapHouseholdToSetOfClientProspects,setClientId, setOldHouseholdId);
			
			if(trigger.isUpdate)
				updateFinanicalAccounts(mapHouseholdToOldSetOfClientProspects,mapHouseholdToSetOfClientProspects,setClientId, setOldHouseholdId,
																				setNewHouseholdId, mapHouseholdToOLDClientProspects, setOldSelectedClientId);
		}
	}
	
	
	/*
        * MethodName : checkExistingHouseHold_ValidRepCodeUser
        * Param      :Map <Id, Set<Id>> mapExistingHouseholdToClient_Note, String strHouseholdId, Note_Joiner__c objNoteJoiner, 
					  Map <Id, Id> mapHouseholdToRepCodeId, Map <Id, Set<Id>> mapRepCodeIdToUsersId
        * Description: multiple times called for checking the Existing Households and Repcode user
    */ 
	private boolean checkExistingHouseHold_ValidRepCodeUser(Map <Id, Set<Id>> mapExistingHouseholdToClient_Note, String strHouseholdId, Note_Joiner__c objNoteJoiner, 
	Map <Id, Id> mapHouseholdToRepCodeId, Map <Id, Set<Id>> mapRepCodeIdToUsersId )
	{
		if((mapExistingHouseholdToClient_Note.isEmpty() || (!mapExistingHouseholdToClient_Note.isEmpty()
							&& mapExistingHouseholdToClient_Note.containsKey(Id.valueOf(strHouseholdId)) 
							&& !mapExistingHouseholdToClient_Note.get(Id.valueOf(strHouseholdId)).contains(objNoteJoiner.Note__c)))
							
							&& ((!mapHouseholdToRepCodeId.isEmpty() && mapHouseholdToRepCodeId.containsKey(Id.valueOf(strHouseholdId))
							&& !mapRepCodeIdToUsersId.isEmpty() && mapRepCodeIdToUsersId.containsKey(mapHouseholdToRepCodeId.get(Id.valueOf(strHouseholdId)))
							&& mapRepCodeIdToUsersId.get(mapHouseholdToRepCodeId.get(Id.valueOf(strHouseholdId))).contains(objNoteJoiner.Note__r.OwnerId)
							)))
			return true;
		else
			return false;
	}
	
	/*
        * MethodName : insertFinanicalAccounts
        * Param      :	Map <String, Set <Id>> mapHouseholdToOldSetOfClientProspects, Map <Id, Set <Id>>mapHouseholdToSetOfClientProspects,
						Set <Id> setClientId, Set <Id> setOldHouseholdId
        * Description: Insertion of Financial Accounts based on the Group Member Insetion
    */ 
	private void insertFinanicalAccounts(Map <String, Set <Id>> mapHouseholdToOldSetOfClientProspects, Map <Id, Set <Id>>mapHouseholdToSetOfClientProspects,
	Set <Id> setClientId, Set <Id> setOldHouseholdId)
	{
		Map <Id, Set <Id>> mapNewRelationGroupToFAIds = new Map <Id, Set <Id>>(); 
		Map <Id, List<Hilliard_Lyons_Account__c>> mapSelectedClientToFAs = new Map <Id, List <Hilliard_Lyons_Account__c>>();
		Map <Id, Id> mapHouseholdToRepCodeId = new Map <Id, Id>();
		set <Id> setAlreadyExistingAcc = new set <Id>();
		List <Group_Account__c> lstToBeInserted = new List <Group_Account__c> (); 
		if(!mapHouseholdToSetOfClientProspects.isEmpty())
		{
			for(Group_Account__c objGA : [SELECT Id, Financial_Account__c, Relationship_Group__c FROM Group_Account__c WHERE Relationship_Group__c 
											  IN:mapHouseholdToSetOfClientProspects.keySet() AND Financial_Account__c !=null])
			{
				if(!mapNewRelationGroupToFAIds.containsKey(objGA.Relationship_Group__c))
					mapNewRelationGroupToFAIds.put(objGA.Relationship_Group__c, new Set<Id>{objGA.Financial_Account__c});
				else
					mapNewRelationGroupToFAIds.get(objGA.Relationship_Group__c).add(objGA.Financial_Account__c);
			}
		}
		
		if(!setClientId.isEmpty())
		{
			for(Hilliard_Lyons_Account__c objHIL : [SELECT Client__c, Financial_Account__c, Financial_Account__r.Rep_Code__c
													FROM Hilliard_Lyons_Account__c WHERE Client__c IN: setClientId])
			{
				if(!mapSelectedClientToFAs.containsKey(objHIL.Client__c))
					mapSelectedClientToFAs.put(objHIL.Client__c, new List<Hilliard_Lyons_Account__c>{objHIL});
				else
					mapSelectedClientToFAs.get(objHIL.Client__c).add(objHIL);
			}
		}
		
		for(Relationship_Group__c objRelationshipGrp : [SELECT Id, Rep_Code__c FROM Relationship_Group__c WHERE Id IN: mapHouseholdToSetOfClientProspects.keySet()])
    	{
    		if(objRelationshipGrp.Rep_Code__c != null)
    			mapHouseholdToRepCodeId.put(objRelationshipGrp.Id,objRelationshipGrp.Rep_Code__c );
    	}
		
		if(!mapHouseholdToSetOfClientProspects.isEmpty())
		{
			for(Id HousehodId : mapHouseholdToSetOfClientProspects.keySet())
			{
				setAlreadyExistingAcc = new Set <Id>();
				if(!mapNewRelationGroupToFAIds.isEmpty() && mapNewRelationGroupToFAIds.containsKey(HousehodId))
				{
					for(Id FinanicalAccountId : mapNewRelationGroupToFAIds.get(HousehodId))
					{
						setAlreadyExistingAcc.add(FinanicalAccountId);
					}
				}
				for(Id clientId : mapHouseholdToSetOfClientProspects.get(HousehodId))
				{
					if(!mapSelectedClientToFAs.isEmpty() && mapSelectedClientToFAs.containsKey(clientId))
					{
						for(Hilliard_Lyons_Account__c obj : mapSelectedClientToFAs.get(clientId))
						{
							if((setAlreadyExistingAcc.isEmpty() || (!setAlreadyExistingAcc.isEmpty() 
							&& !setAlreadyExistingAcc.contains(obj.Financial_Account__c)))
							&& (!mapHouseholdToRepCodeId.isEmpty() && mapHouseholdToRepCodeId.containsKey(HousehodId)
							&& mapHouseholdToRepCodeId.get(HousehodId) == obj.Financial_Account__r.Rep_Code__c))
							{
								lstToBeInserted.add(new Group_Account__c(Financial_Account__c = obj.Financial_Account__c, Relationship_Group__c = HousehodId ));
							}
						}
					}
				}
			}
		}	
		if(!lstToBeInserted.isEmpty())
			insert lstToBeInserted;
	}
	
	/*
        * MethodName : UpdateNotesToHousehold
        * Param      : Map <String, Set <Id>> mapHouseholdToOldSetOfClientProspects, Map <Id, Set <Id>>mapHouseholdToSetOfClientProspects,Set <Id> setClientId, Set <Id> setOldHouseholdId
        * Description: Insering and updating the Note Joiners when the Group Members are inserted/updated
    */ 
	private void UpdateNotesToHousehold(Map <String, Set <Id>> mapHouseholdToOldSetOfClientProspects, Map <Id, Set <Id>>mapHouseholdToSetOfClientProspects,Set <Id> setClientId, Set <Id> setOldHouseholdId)
	{
		Set <Id> setRepId = new Set <Id>();
		Set <Id> setRepUserId = new Set <Id>(); 
		
		List <Note_Joiner__c> lstNoteJoinerTobeUpdated = new List <Note_Joiner__c>  (); 
		Map <Id, List <Note_Joiner__c>> mapHouseholdIdToNotejoinersTobeUpdated = new Map <Id, List <Note_Joiner__c>> (); 
		Map <String, List <Note_Joiner__c>> mapHousehold_ClientToListNoteJoiner = new Map <String, List <Note_Joiner__c>>(); 
		Map <Id, Id> mapHouseholdToRepCodeId = new Map <Id, Id> (); 
		Map <Id, Set<Id>> mapRepCodeIdToUsersId = new Map <Id, Set<Id>> (); 
		Map <String, List<Note_Joiner__c>> mapHouseholdIdToSetOfNoteId = new Map <String, List<Note_Joiner__c>>(); 
		Map <Id, Set<Id>> mapExistingHouseholdToClient_Note = new Map <Id, Set<Id>> (); 
		Map <Id, List<Note_Joiner__c>> mapClientPropspectToNotes = new Map <Id, List<Note_Joiner__c>>();
		
		
		if(!mapHouseholdToSetOfClientProspects.isEmpty())
		{
			// Calling queryToNoteJoiners method to fetch note joiners
			for(Note_Joiner__c objNote_Joiner : queryToNoteJoiners('Relationship_Group__c', mapHouseholdToSetOfClientProspects.keySet()))
			{
				if(!mapExistingHouseholdToClient_Note.containsKey(objNote_Joiner.Relationship_Group__c))
					mapExistingHouseholdToClient_Note.put(objNote_Joiner.Relationship_Group__c, new Set<Id>{objNote_Joiner.Note__c});
				else
					mapExistingHouseholdToClient_Note.get(objNote_Joiner.Relationship_Group__c).add(objNote_Joiner.Note__c);
					
			}
			
			for(Note_Joiner__c objNoteJoiner : queryToNoteJoiners('Client_Prospect__c', setClientId))				
			{
				if(!mapClientPropspectToNotes.containsKey(objNoteJoiner.Client_Prospect__c))
					mapClientPropspectToNotes.put(objNoteJoiner.Client_Prospect__c, new List<Note_Joiner__c>{objNoteJoiner});
				else
					mapClientPropspectToNotes.get(objNoteJoiner.Client_Prospect__c).add(objNoteJoiner);
			}
			
			// Fetching the Rep code from the context Households
			for(Relationship_Group__c objRelationshipGrp : [SELECT Id, Rep_Code__c FROM Relationship_Group__c WHERE Id IN: mapHouseholdToSetOfClientProspects.KeySet()])
	    	{
	    		if(objRelationshipGrp.Rep_Code__c != null)
	    		{
	    			setRepId.add(objRelationshipGrp.Rep_Code__c);
	    			mapHouseholdToRepCodeId.put(objRelationshipGrp.Id,objRelationshipGrp.Rep_Code__c );
	    		}
	    	}
	    	
	    	// Fetching the rep code users
	    	if(!setRepId.isEmpty())
	    	{
	    		for(Rep_Code_User__c objRepCodeUser : [SELECT User__c, Rep_Code__c FROM Rep_Code_User__c WHERE Rep_Code__c IN: setRepId])
	    		{
	    			setRepUserId.add(objRepCodeUser.User__c);
	    			
	    			if(!mapRepCodeIdToUsersId.containsKey(objRepCodeUser.Rep_Code__c))
    					mapRepCodeIdToUsersId.put(objRepCodeUser.Rep_Code__c, new Set<Id>{objRepCodeUser.User__c});
    				else
						mapRepCodeIdToUsersId.get(objRepCodeUser.Rep_Code__c).add(objRepCodeUser.User__c);
	    		}
	    	}
	    	
	    	// If update trigger is fired
	    	if(!setOldHouseholdId.isEmpty() && Trigger.isUpdate)
			{
				// Calling queryToNoteJoiners method to fetch note joiners 
				for(Note_Joiner__c objOldNote_Joiner : queryToNoteJoiners('Relationship_Group__c', setOldHouseholdId))									 
				{
					if(!mapHousehold_ClientToListNoteJoiner.containsKey(objOldNote_Joiner.Relationship_Group__c+'_'+objOldNote_Joiner.Client_Prospect__c))
    					mapHousehold_ClientToListNoteJoiner.put(objOldNote_Joiner.Relationship_Group__c+'_'+objOldNote_Joiner.Client_Prospect__c, new List<Note_Joiner__c>{objOldNote_Joiner});
    				else
						mapHousehold_ClientToListNoteJoiner.get(objOldNote_Joiner.Relationship_Group__c+'_'+objOldNote_Joiner.Client_Prospect__c).add(objOldNote_Joiner);
				}
				
				if(!mapHouseholdToOldSetOfClientProspects.isEmpty())
				{
					for(String strJoinedString : mapHouseholdToOldSetOfClientProspects.keySet())
					{
						String strOldGMId = '';
						String strNewGMID = '';
						String strClientId = '';
						if(strJoinedString.contains('_'))
						{
							strOldGMId = strJoinedString.split('_')[0];
							strNewGMID = strJoinedString.split('_')[1];
							strClientId = strJoinedString.split('_')[2];
						}
						
						if(mapHousehold_ClientToListNoteJoiner.containsKey(strOldGMId+'_'+strClientId))
						{
							for(Note_Joiner__c obj : mapHousehold_ClientToListNoteJoiner.get(strOldGMId+'_'+strClientId))
							{
								if(!mapHouseholdIdToNotejoinersTobeUpdated.containsKey(strNewGMID))
    								mapHouseholdIdToNotejoinersTobeUpdated.put(strNewGMID, new List<Note_Joiner__c>{obj});
    							else
									mapHouseholdIdToNotejoinersTobeUpdated.get(strNewGMID).add(obj);
							}
						}
						if(!mapHousehold_ClientToListNoteJoiner.containsKey(strOldGMId+'_'+strClientId))
						{
							for(Id ClientId : mapHouseholdToOldSetOfClientProspects.get(strJoinedString))
							{
								if(mapClientPropspectToNotes.containsKey(ClientId))
									mapHouseholdIdToSetOfNoteId.put(strNewGMID+'_'+ClientId, mapClientPropspectToNotes.get(ClientId));
							}
						}
					}
				}
				
				if(!mapHouseholdIdToNotejoinersTobeUpdated.isEmpty())
				{
					for(String strHouseholdId : mapHouseholdIdToNotejoinersTobeUpdated.keySet())
					{
						for(Note_Joiner__c objOldNote_JoinerToBeUpdated : mapHouseholdIdToNotejoinersTobeUpdated.get(strHouseholdId))
						{
							if(checkExistingHouseHold_ValidRepCodeUser(mapExistingHouseholdToClient_Note, strHouseholdId, objOldNote_JoinerToBeUpdated, mapHouseholdToRepCodeId,
							 mapRepCodeIdToUsersId))
								
								lstNoteJoinerTobeUpdated.add(new Note_Joiner__c(Id = objOldNote_JoinerToBeUpdated.Id, 
								Relationship_Group__c = Id.valueOf(strHouseholdId) ));
							
							if(((mapHouseholdToRepCodeId.isEmpty() || mapRepCodeIdToUsersId.isEmpty()) || (!mapHouseholdToRepCodeId.isEmpty() 
							&& mapHouseholdToRepCodeId.containsKey(Id.valueOf(strHouseholdId))
							&& !mapRepCodeIdToUsersId.isEmpty() && mapRepCodeIdToUsersId.containsKey(mapHouseholdToRepCodeId.get(Id.valueOf(strHouseholdId)))
							&& !mapRepCodeIdToUsersId.get(mapHouseholdToRepCodeId.get(Id.valueOf(strHouseholdId))).contains(objOldNote_JoinerToBeUpdated.Note__r.OwnerId))) || (!mapExistingHouseholdToClient_Note.isEmpty() && mapExistingHouseholdToClient_Note.containsKey(Id.valueOf(strHouseholdId))
							&& mapExistingHouseholdToClient_Note.get(Id.valueOf(strHouseholdId)).contains(objOldNote_JoinerToBeUpdated.Note__c)))
								
								lstNoteJoinerTobeUpdated.add(new Note_Joiner__c(Id = objOldNote_JoinerToBeUpdated.Id, 
								Relationship_Group__c = null ));
						}
					}
				}
				
				// Updating the Notes
				update lstNoteJoinerTobeUpdated;
			}
	    	if(Trigger.isInsert)
	    	{
	    		// Calling queryToNoteJoiners method to fetch note joiners 
				for(Id householdId : mapHouseholdToSetOfClientProspects.keySet())
				{
					for(Id ClientId : mapHouseholdToSetOfClientProspects.get(householdId))
					{
						if(mapClientPropspectToNotes.containsKey(ClientId))
							mapHouseholdIdToSetOfNoteId.put(householdId+'_'+ClientId, mapClientPropspectToNotes.get(ClientId));
					}
				}
			}
			
			if(!mapHouseholdIdToSetOfNoteId.isEmpty())
			{
				insertNotes(mapHouseholdIdToSetOfNoteId, mapExistingHouseholdToClient_Note,mapHouseholdToRepCodeId,mapRepCodeIdToUsersId);
			}
		}
	}
	
	/*
        * MethodName : insertNotes
        * Param      : Map <String, List<Note_Joiner__c>> mapHouseholdIdToSetOfNoteId,Map <Id, Set<Id>> mapExistingHouseholdToClient_Note, Map <Id, Id> mapHouseholdToRepCodeId, Map <Id, Set<Id>> mapRepCodeIdToUsersId
        * Description: Insering the Note Joiners
    */ 
	private void insertNotes(Map <String, List<Note_Joiner__c>> mapHouseholdIdToSetOfNoteId,Map <Id, Set<Id>> mapExistingHouseholdToClient_Note, Map <Id, Id> mapHouseholdToRepCodeId, Map <Id, Set<Id>> mapRepCodeIdToUsersId )
	{
		Map <Id,Set<Id>> mapHouseholdIdToNoteId = new Map <Id,Set<Id>> (); 
		List <Note_Joiner__c> lstNoteJoinerTobeInserted = new List <Note_Joiner__c>  (); 
		if(!mapHouseholdIdToSetOfNoteId.isEmpty())
		{
			for(String HouseholdClientId : mapHouseholdIdToSetOfNoteId.keySet())
			{
				mapHouseholdIdToNoteId = new Map <Id,Set<Id>> (); 
				for(Note_Joiner__c obj : mapHouseholdIdToSetOfNoteId.get(HouseholdClientId))
				{
					if(checkExistingHouseHold_ValidRepCodeUser(mapExistingHouseholdToClient_Note, HouseholdClientId.split('_')[0], obj, mapHouseholdToRepCodeId,
					 mapRepCodeIdToUsersId) && ((mapHouseholdIdToNoteId.isEmpty() || (!mapHouseholdIdToNoteId.isEmpty() 
					&& mapHouseholdIdToNoteId.containsKey(Id.valueOf(HouseholdClientId.split('_')[0]))
					&& !mapHouseholdIdToNoteId.get(Id.valueOf(HouseholdClientId.split('_')[0])).contains(obj.Note__c)))))
					{
						if(!mapHouseholdIdToNoteId.containsKey(Id.valueOf(HouseholdClientId.split('_')[0])))
							mapHouseholdIdToNoteId.put(Id.valueOf(HouseholdClientId.split('_')[0]), new Set<Id>{obj.Note__c});
						else
						mapHouseholdIdToNoteId.get(Id.valueOf(HouseholdClientId.split('_')[0])).add(obj.Note__c);
						lstNoteJoinerTobeInserted.add(new Note_Joiner__c(Note__c = obj.Note__c, Relationship_Group__c =  HouseholdClientId.split('_')[0], Client_Prospect__c =  HouseholdClientId.split('_')[1]));
					}
				}
			}
		}
		insert lstNoteJoinerTobeInserted;
	}
	
	
	/*
        * MethodName : queryToNoteJoiners
        * Param      : String strFilterdFld, Set <Id> setFilterdSet
        * Description: Fetching the Note Joiners
    */ 
	private List <Note_Joiner__c> queryToNoteJoiners(String strFilterdFld, Set <Id> setFilterdSet)
	{
		List <Note_Joiner__c> lstNotejoiners = new List <Note_Joiner__c>();  
		lstNotejoiners = Database.query('SELECT Relationship_Group__c, Client_Prospect__c, Note__c,Note__r.OwnerId FROM Note_Joiner__c WHERE '+strFilterdFld+' IN: setFilterdSet');
		
		return lstNotejoiners;
	}
	
	/*
        * MethodName : fetchallOldClients
        * Param      : None
        * Description: Fetching all the clients and mapping the household and clients
    */ 
	private void fetchallOldClients(Map<Id, Group_Member__c> mapIdToNewGroupMembers, Map<Id, Group_Member__c> mapIdToOldGroupMembers)
	{
		Set <Id> setOldHouseholdId = new Set <Id> (); 
	 	for(Group_Member__c objGroupMember : mapIdToNewGroupMembers.values())
	 	{
	 		Group_Member__c objOldGM;
	 		objOldGM = mapIdToOldGroupMembers.get(objGroupMember.Id);
	 		if(objGroupMember.Relationship_Group__c != objOldGM.Relationship_Group__c)
	 		{
	 			setOldHouseholdId.add(objOldGM.Relationship_Group__c);
	 		}
	 	}
	 	
	 	if(!setOldHouseholdId.isEmpty())
	 	{
	 		for(Group_Member__c objGroupMember : [SELECT Id, Client_Prospect__c, Relationship_Group__c FROM Group_Member__c 
												WHERE Relationship_Group__c IN: setOldHouseholdId])
			{
				if(!mapHouseholdIdToSetOfTotalClients.containsKey(objGroupMember.Relationship_Group__c))
					mapHouseholdIdToSetOfTotalClients.put(objGroupMember.Relationship_Group__c, new Set<Id>{objGroupMember.Client_Prospect__c});
				else
					mapHouseholdIdToSetOfTotalClients.get(objGroupMember.Relationship_Group__c).add(objGroupMember.Client_Prospect__c);
			}
	 	}
	}
	
	/*
        * MethodName : updateFinanicalAccounts
        * Param      : Map <String, Set <Id>> mapHouseholdToOldSetOfClientProspects, Map <Id, Set <Id>>mapHouseholdToSetOfClientProspects,
										Set <Id> setClientId, Set <Id> setOldHouseholdId,Set <Id>setNewHouseholdId, Map <Id, Set <Id>> mapHouseholdToOLDClientProspects,
										Set <Id> setOldSelectedClientId
        * Description: Updating Finanical Accountsbased on the updating of Group Members
    */ 
	private void updateFinanicalAccounts(Map <String, Set <Id>> mapHouseholdToOldSetOfClientProspects, Map <Id, Set <Id>>mapHouseholdToSetOfClientProspects,
										Set <Id> setClientId, Set <Id> setOldHouseholdId,Set <Id>setNewHouseholdId, Map <Id, Set <Id>> mapHouseholdToOLDClientProspects,
										Set <Id> setOldSelectedClientId)
	{
		Set <Id> setNonSelectedClientId = new Set <Id>(); 
		Map <Id, List <Group_Account__c>> mapOldRelationGroupToExistingFAs = new Map <Id, List <Group_Account__c>>(); 
		Map <Id, Set <Id>> mapNewRelationGroupToFAIds = new Map <Id, Set <Id>> ();
		Map <Id, Id> mapHouseholdToRepCodeId = new Map <Id, Id>(); 
		Map <Id, Set <Id>> mapNonselectedClientToFAs = new Map <Id, Set <Id>>();
		Map <Id, Set <Id>> mapSelectedClientToFAs = new Map <Id, Set <Id>>();
		Set <Id> setAlreadyPresentFAId = new Set <Id>();
		List <Group_Account__c> lstGrpAccToBeUpdated = new List <Group_Account__c>(); 
		List <Group_Account__c> lstGrpAccToInserted = new List <Group_Account__c>(); 
		Map <Id, Group_Account__c>mapIdToDeletedGAS = new Map <Id, Group_Account__c>();
		if(!setOldHouseholdId.isEmpty())
		{
			for(Group_Member__c objGroupMember : [SELECT Id, Client_Prospect__c, Relationship_Group__c FROM Group_Member__c 
												WHERE Relationship_Group__c IN: setOldHouseholdId])
			{
				setNonSelectedClientId.add(objGroupMember.Client_Prospect__c);
			}
			for(Group_Account__c objGA : [SELECT Id, Financial_Account__c, Relationship_Group__c, Financial_Account__r.Rep_Code__c FROM Group_Account__c WHERE Relationship_Group__c 
											  IN:setOldHouseholdId AND Financial_Account__c !=null])
			{
				if(!mapOldRelationGroupToExistingFAs.containsKey(objGA.Relationship_Group__c))
					mapOldRelationGroupToExistingFAs.put(objGA.Relationship_Group__c, new List<Group_Account__c>{objGA});
				else
					mapOldRelationGroupToExistingFAs.get(objGA.Relationship_Group__c).add(objGA);
			}
		}
		
		if(!setNewHouseholdId.isEmpty())
		{
			for(Group_Account__c objGA : [SELECT Id, Financial_Account__c, Relationship_Group__c FROM Group_Account__c WHERE Relationship_Group__c 
											  IN:setNewHouseholdId AND Financial_Account__c !=null])
			{
				if(!mapNewRelationGroupToFAIds.containsKey(objGA.Relationship_Group__c))
					mapNewRelationGroupToFAIds.put(objGA.Relationship_Group__c, new Set<Id>{objGA.Financial_Account__c});
				else
					mapNewRelationGroupToFAIds.get(objGA.Relationship_Group__c).add(objGA.Financial_Account__c);
			}
			
			// Fetching the Rep code from the context Households
			for(Relationship_Group__c objRelationshipGrp : [SELECT Id, Rep_Code__c FROM Relationship_Group__c WHERE Id IN: setNewHouseholdId])
	    	{
	    		if(objRelationshipGrp.Rep_Code__c != null)
	    			mapHouseholdToRepCodeId.put(objRelationshipGrp.Id,objRelationshipGrp.Rep_Code__c );
	    	}
		}
		
		if(!setNonSelectedClientId.isEmpty())
		{
			for(Hilliard_Lyons_Account__c objHIL : [SELECT Client__c, Financial_Account__c 
													FROM Hilliard_Lyons_Account__c WHERE Client__c IN: setNonSelectedClientId])
			{
				if(!mapNonselectedClientToFAs.containsKey(objHIL.Client__c))
					mapNonselectedClientToFAs.put(objHIL.Client__c, new Set<Id>{objHIL.Financial_Account__c});
				else
					mapNonselectedClientToFAs.get(objHIL.Client__c).add(objHIL.Financial_Account__c);
			}
		}
		
		if(!setOldSelectedClientId.isEmpty())
		{
			for(Hilliard_Lyons_Account__c objHIL : [SELECT Client__c, Financial_Account__c 
													FROM Hilliard_Lyons_Account__c WHERE Client__c IN: setOldSelectedClientId])
			{
				if(!mapSelectedClientToFAs.containsKey(objHIL.Client__c))
					mapSelectedClientToFAs.put(objHIL.Client__c, new Set<Id>{objHIL.Financial_Account__c});
				else
					mapSelectedClientToFAs.get(objHIL.Client__c).add(objHIL.Financial_Account__c);
			}
		}
		
		if(!mapHouseholdToOldSetOfClientProspects.isEmpty())
		{
			for (String strJoinedString : mapHouseholdToOldSetOfClientProspects.keySet())
			{
				String strOldGMId = '';
				String strNewGMID = '';
				String strClientId = '';
				if(strJoinedString.contains('_'))
				{
					strOldGMId = strJoinedString.split('_')[0];
					strNewGMID = strJoinedString.split('_')[1];
					strClientId = strJoinedString.split('_')[2];
				}
				setAlreadyPresentFAId = new Set <Id>();
				if(!mapHouseholdIdToSetOfTotalClients.isEmpty() && mapHouseholdIdToSetOfTotalClients.containsKey(strOldGMId))
				{
					for(Id clientId : mapHouseholdIdToSetOfTotalClients.get(strOldGMId))
					{
						if(!mapNonselectedClientToFAs.isEmpty() && mapNonselectedClientToFAs.containsKey(clientId))
						{
							for(Id AlreadyFAId : mapNonselectedClientToFAs.get(clientId))
							{
								setAlreadyPresentFAId.add(AlreadyFAId);
							}
						}
					}
					for(Id clientId : mapHouseholdIdToSetOfTotalClients.get(strOldGMId)){
						if(!mapOldRelationGroupToExistingFAs.isEmpty() && mapOldRelationGroupToExistingFAs.containsKey(strOldGMId))
						{
							for(Group_Account__c objG : mapOldRelationGroupToExistingFAs.get(strOldGMId))
							{
								if(!mapSelectedClientToFAs.isEmpty() && mapSelectedClientToFAs.containsKey(clientId))
								{
									for(Id FaId : mapSelectedClientToFAs.get(clientId))
									{
										if(objG.Financial_Account__c == FaId && !mapHouseholdToRepCodeId.isEmpty() && mapHouseholdToRepCodeId.containsKey(strNewGMID)
										&& mapHouseholdToRepCodeId.get(strNewGMID) == objG.Financial_Account__r.Rep_Code__c )
										{
											if((setAlreadyPresentFAId.isEmpty() || (!setAlreadyPresentFAId.isEmpty()
											&& !setAlreadyPresentFAId.contains(objG.Financial_Account__c))))
											{
												if(mapNewRelationGroupToFAIds.isEmpty() || (!mapNewRelationGroupToFAIds.isEmpty() && mapNewRelationGroupToFAIds.containsKey(strNewGMID)
												&& !mapNewRelationGroupToFAIds.get(strNewGMID).contains(FaId)))
													//lstGrpAccToBeUpdated.add(new Group_Account__c(Id=objG.Id, Relationship_Group__c = strNewGMID));
													mapIdToDeletedGAS.put(objG.Id, new Group_Account__c(Id = objG.Id, Relationship_Group__c = strNewGMID));
													
												else if( (!mapNewRelationGroupToFAIds.isEmpty() && mapNewRelationGroupToFAIds.containsKey(strNewGMID)
												&& mapNewRelationGroupToFAIds.get(strNewGMID).contains(FaId)))
													//lstGrpAccToBeUpdated.add(new Group_Account__c(Id=objG.Id, Relationship_Group__c = null));
													mapIdToDeletedGAS.put(objG.Id, new Group_Account__c(Id = objG.Id, Relationship_Group__c = null));
											}
											else if(((!setAlreadyPresentFAId.isEmpty()
											&& setAlreadyPresentFAId.contains(objG.Financial_Account__c))))
											{
												if(mapNewRelationGroupToFAIds.isEmpty() || (!mapNewRelationGroupToFAIds.isEmpty() && mapNewRelationGroupToFAIds.containsKey(strNewGMID)
												&& !mapNewRelationGroupToFAIds.get(strNewGMID).contains(FaId)))
													lstGrpAccToInserted.add(new Group_Account__c(Financial_Account__c = FaId, Relationship_Group__c = strNewGMID));
													
												/*else if(mapNewRelationGroupToFAIds.isEmpty() || (!mapNewRelationGroupToFAIds.isEmpty() && mapNewRelationGroupToFAIds.containsKey(strNewGMID)
												&& mapNewRelationGroupToFAIds.get(strNewGMID).contains(FaId)))
												{
													// Do nothing
												}*/	
											}
										}
										if(objG.Financial_Account__c == FaId && (mapHouseholdToRepCodeId.isEmpty() || (!mapHouseholdToRepCodeId.isEmpty() && mapHouseholdToRepCodeId.containsKey(strNewGMID)
										&& mapHouseholdToRepCodeId.get(strNewGMID) != objG.Financial_Account__r.Rep_Code__c )))
										{
											//lstGrpAccToBeUpdated.add(new Group_Account__c(Id=objG.Id, Relationship_Group__c = null));
											mapIdToDeletedGAS.put(objG.Id, new Group_Account__c(Id = objG.Id, Relationship_Group__c = null));
										}
									}
								}
							}	
						}
						
					}
					
				}
			}
		}
		if(!mapIdToDeletedGAS.isEmpty())
			update mapIdToDeletedGAS.values();
		if(!lstGrpAccToInserted.isEmpty())
			insert lstGrpAccToInserted;
	}
	/*
        * MethodName : removeFinanicalAccounts
        * Param      : Map <Id, Set <Id>> mapHouseholdIdToSetGroupId
        * Description: Removing finanical accounts based on the removal of group member
    */  
	private void removeFinanicalAccounts(Map <Id, Set <Id>> mapHouseholdIdToSetGroupId)
	{
		Map<Id, Set <Id>>mapHouseholdTosetOfNonDeletedClients = new Map<Id, Set <Id>>(); 
		Set <Id> setAllClients = new Set <Id>();
		Set <Id> setAllHouseholds = new Set <Id>();
		Map <Id, List <Group_Account__c>> mapOldRelationGroupToExistingFAs = new Map <Id, List <Group_Account__c>>();
		Map <Id, Set <Id>> mapAllClientToFAs = new Map <Id, Set <Id>>();
		Map <Id, Set <Id>> mapAllHouseholdToClients= new Map <Id, Set <Id>>(); 
		Set <Id> setAlreadyPresentNoteId = new Set <Id> (); 
		Map <Id, Group_Account__c> mapIdToDeletedGAS = new Map <Id,Group_Account__c>();
		
		for(Group_Member__c objGrpMember : [SELECT Id, Client_Prospect__c, Relationship_Group__c FROM Group_Member__c 
												WHERE Relationship_Group__c IN: mapHouseholdIdToSetGroupId.keySet()])
		{
			setAllClients.add(objGrpMember.Client_Prospect__c);
			setAllHouseholds.add(objGrpMember.Relationship_Group__c);
			if(mapHouseholdIdToSetGroupId.containsKey(objGrpMember.Relationship_Group__c) 
			&& !mapHouseholdIdToSetGroupId.get(objGrpMember.Relationship_Group__c).contains(objGrpMember.Id))
			{
				if(!mapHouseholdTosetOfNonDeletedClients.containsKey(objGrpMember.Relationship_Group__c))
					mapHouseholdTosetOfNonDeletedClients.put(objGrpMember.Relationship_Group__c, new Set<Id>{objGrpMember.Client_Prospect__c});
				else
					mapHouseholdTosetOfNonDeletedClients.get(objGrpMember.Relationship_Group__c).add(objGrpMember.Client_Prospect__c);
			}
			
			if(!mapAllHouseholdToClients.containsKey(objGrpMember.Relationship_Group__c))
				mapAllHouseholdToClients.put(objGrpMember.Relationship_Group__c, new Set<Id>{objGrpMember.Client_Prospect__c});
			else
				mapAllHouseholdToClients.get(objGrpMember.Relationship_Group__c).add(objGrpMember.Client_Prospect__c);
			
			/*if(mapHouseholdIdToSetGroupId.containsKey(objGrpMember.Relationship_Group__c) 
			&& mapHouseholdIdToSetGroupId.get(objGrpMember.Relationship_Group__c).contains(objGrpMember.Id))
			{
				if(!mapHouseholdTosetOfDeletedClients.containsKey(objGrpMember.Relationship_Group__c))
					mapHouseholdTosetOfDeletedClients.put(objGrpMember.Relationship_Group__c, new Set<Id>{objGrpMember.Client_Prospect__c});
				else
					mapHouseholdTosetOfDeletedClients.get(objGrpMember.Relationship_Group__c).add(objGrpMember.Client_Prospect__c);
			}*/
		}
		
		if(!setAllHouseholds.isEmpty())
		{
			for(Group_Account__c objGA : [SELECT Id, Financial_Account__c, Relationship_Group__c, Financial_Account__r.Rep_Code__c FROM Group_Account__c WHERE Relationship_Group__c 
											  IN:setAllHouseholds AND Financial_Account__c !=null])
			{
				if(!mapOldRelationGroupToExistingFAs.containsKey(objGA.Relationship_Group__c))
					mapOldRelationGroupToExistingFAs.put(objGA.Relationship_Group__c, new List<Group_Account__c>{objGA});
				else
					mapOldRelationGroupToExistingFAs.get(objGA.Relationship_Group__c).add(objGA);
			}
		}
		if(!setAllClients.isEmpty())
		{
			for(Hilliard_Lyons_Account__c objHIL : [SELECT Client__c, Financial_Account__c 
														FROM Hilliard_Lyons_Account__c WHERE Client__c IN: setAllClients])
			{
				if(!mapAllClientToFAs.containsKey(objHIL.Client__c))
					mapAllClientToFAs.put(objHIL.Client__c, new Set<Id>{objHIL.Financial_Account__c});
				else
					mapAllClientToFAs.get(objHIL.Client__c).add(objHIL.Financial_Account__c);
			}
		}
		
		if(!mapAllHouseholdToClients.isEmpty())
		{
			for(Id householdId : mapAllHouseholdToClients.keySet())
			{
				setAlreadyPresentNoteId = new Set <Id> (); 
				if(!mapHouseholdTosetOfNonDeletedClients.isEmpty() &&
				mapHouseholdTosetOfNonDeletedClients.containsKey(householdId))
				{
					for(id ClientId : mapHouseholdTosetOfNonDeletedClients.get(householdId))
					{
						if(!mapOldRelationGroupToExistingFAs.isEmpty() && mapOldRelationGroupToExistingFAs.containsKey(householdId))
						{
							for(Group_Account__c objN : mapOldRelationGroupToExistingFAs.get(householdId))
							{
								if(!mapAllClientToFAs.isEmpty() && mapAllClientToFAs.containsKey(ClientId) && 
								mapAllClientToFAs.get(ClientId).contains(objN.Financial_Account__c))
									setAlreadyPresentNoteId.add(objN.Financial_Account__c);
							}
						}
					}
				}
				
				if(!mapHouseholdIdToSetGroupId.isEmpty() && mapHouseholdIdToSetGroupId.containsKey(householdId))
				{
					for(id ClientId : mapHouseholdIdToSetGroupId.get(householdId))
					{
						if(!mapOldRelationGroupToExistingFAs.isEmpty() && mapOldRelationGroupToExistingFAs.containsKey(householdId))
						{
							for(Group_Account__c objN : mapOldRelationGroupToExistingFAs.get(householdId))
							{
								if(setAlreadyPresentNoteId.isEmpty() || !setAlreadyPresentNoteId.contains(objN.Financial_Account__c))
									mapIdToDeletedGAS.put(objN.Id, new Group_Account__c(Id = objN.Id, Relationship_Group__c = null));
							}
						}
					}
				}
			}
		}
		lstGlobalDeleteFinanicalAccount = mapIdToDeletedGAS.values();
	}
	
	/*
        * MethodName : removeNotes
        * Param      : Map<Id, Group_Member__c> mapHouseholdToSetOfClientProspects,Set <Id> setOldHouseholdId  
        * Description: Removing notes based on the Group Member Deletion
    */  
	private void removeNotes(Map <Id, Set <Id>> mapHouseholdIdToSetGroupId)
	{
		Map<Id, Set <Id>> mapHouseholdTosetOfDeletedClients = new Map<Id, Set <Id>>();
		Map<Id, Set <Id>> mapHouseholdTosetOfNonDeletedClients = new Map<Id, Set <Id>>();
		Map <Id, Set <Id>> mapHouseholdTosetOfAllClients = new Map<Id, Set <Id>>();
		Map<Id, Set<Id>>mapClientPropspectToNotes = new Map<Id, Set<Id>>(); 
		Map<Id, List<Note_Joiner__c>>mapClientPropspectToHouseholdNotes = new Map<Id, List<Note_Joiner__c>>(); 
		Map <Id,Note_Joiner__c >mapIdToDeletedNotes = new Map <Id,Note_Joiner__c >(); 
		
		Set <Id> setAllClients = new Set <Id>();
		Set <Id> setAllHouseholds = new Set <Id>();
		Set <Id> setAlreadyPresentNoteId = new Set <Id>(); 
		 
		if(!mapHouseholdIdToSetGroupId.isEmpty())
		{
			for(Group_Member__c objGrpMember : [SELECT Id, Client_Prospect__c, Relationship_Group__c FROM Group_Member__c 
												WHERE Relationship_Group__c IN: mapHouseholdIdToSetGroupId.keySet()])
			{
				setAllClients.add(objGrpMember.Client_Prospect__c);
				setAllHouseholds.add(objGrpMember.Relationship_Group__c);
				if(mapHouseholdIdToSetGroupId.containsKey(objGrpMember.Relationship_Group__c) 
				&& !mapHouseholdIdToSetGroupId.get(objGrpMember.Relationship_Group__c).contains(objGrpMember.Id))
				{
					if(!mapHouseholdTosetOfNonDeletedClients.containsKey(objGrpMember.Relationship_Group__c))
						mapHouseholdTosetOfNonDeletedClients.put(objGrpMember.Relationship_Group__c, new Set<Id>{objGrpMember.Client_Prospect__c});
					else
						mapHouseholdTosetOfNonDeletedClients.get(objGrpMember.Relationship_Group__c).add(objGrpMember.Client_Prospect__c);
				}
				if(mapHouseholdIdToSetGroupId.containsKey(objGrpMember.Relationship_Group__c) 
				&& mapHouseholdIdToSetGroupId.get(objGrpMember.Relationship_Group__c).contains(objGrpMember.Id))
				{
					if(!mapHouseholdTosetOfDeletedClients.containsKey(objGrpMember.Relationship_Group__c))
						mapHouseholdTosetOfDeletedClients.put(objGrpMember.Relationship_Group__c, new Set<Id>{objGrpMember.Client_Prospect__c});
					else
						mapHouseholdTosetOfDeletedClients.get(objGrpMember.Relationship_Group__c).add(objGrpMember.Client_Prospect__c);
				}
			}
		}
		if(!mapHouseholdTosetOfNonDeletedClients.isEmpty())
			mapHouseholdTosetOfAllClients.putAll(mapHouseholdTosetOfNonDeletedClients);
		if(!mapHouseholdTosetOfDeletedClients.isEmpty())
			mapHouseholdTosetOfAllClients.putAll(mapHouseholdTosetOfDeletedClients);
		
		for(Note_Joiner__c objNoteJoiner : queryToNoteJoiners('Relationship_Group__c', setAllHouseholds))				
		{
			if(!mapClientPropspectToHouseholdNotes.containsKey(objNoteJoiner.Relationship_Group__c))
				mapClientPropspectToHouseholdNotes.put(objNoteJoiner.Relationship_Group__c, new List<Note_Joiner__c>{objNoteJoiner});
			else
				mapClientPropspectToHouseholdNotes.get(objNoteJoiner.Relationship_Group__c).add(objNoteJoiner);
		}
		
		for(Note_Joiner__c objNoteJoiner : queryToNoteJoiners('Client_Prospect__c', setAllClients))				
		{
			if(!mapClientPropspectToNotes.containsKey(objNoteJoiner.Client_Prospect__c))
				mapClientPropspectToNotes.put(objNoteJoiner.Client_Prospect__c, new Set<Id>{objNoteJoiner.Note__c});
			else
				mapClientPropspectToNotes.get(objNoteJoiner.Client_Prospect__c).add(objNoteJoiner.Note__c);
		}
		
		if(!mapHouseholdTosetOfAllClients.isEmpty())
		{
			for(Id householdId : mapHouseholdTosetOfAllClients.keySet())
			{
				setAlreadyPresentNoteId = new Set <Id> (); 
				if(!mapHouseholdTosetOfNonDeletedClients.isEmpty() && mapHouseholdTosetOfNonDeletedClients.containsKey(householdId))
				{
					for(id ClientId : mapHouseholdTosetOfNonDeletedClients.get(householdId))
					{
						if(!mapClientPropspectToHouseholdNotes.isEmpty() && mapClientPropspectToHouseholdNotes.containsKey(householdId))
						{
							for(Note_Joiner__c objN : mapClientPropspectToHouseholdNotes.get(householdId))
							{
								if(!mapClientPropspectToNotes.isEmpty() && mapClientPropspectToNotes.containsKey(ClientId) && 
								mapClientPropspectToNotes.get(ClientId).contains(objN.Note__c))
									setAlreadyPresentNoteId.add(objN.Note__c);
							}
						}
					}
				}
				if(!mapHouseholdTosetOfDeletedClients.isEmpty() && mapHouseholdTosetOfDeletedClients.containsKey(householdId))
				{
					for(id ClientId : mapHouseholdTosetOfDeletedClients.get(householdId))
					{
						if(!mapClientPropspectToHouseholdNotes.isEmpty() && mapClientPropspectToHouseholdNotes.containsKey(householdId))
						{
							for(Note_Joiner__c objN : mapClientPropspectToHouseholdNotes.get(householdId))
							{
								if(setAlreadyPresentNoteId.isEmpty() || !setAlreadyPresentNoteId.contains(objN.Note__c))
									mapIdToDeletedNotes.put(objN.Id, new Note_Joiner__c(Id = objN.Id, Relationship_Group__c = null));
							}
						}
					}
				}
			}
		}
		lstGlobalDeleteNotes = mapIdToDeletedNotes.values();
	}
	
	/*
        * MethodName : updateNotes
        * Param      : 
        * Description: update the notes and removing from household
    */  
	private static void updateNotes()
    {
    	update lstGlobalDeleteNotes;
    }
     private void removeFinanicalAccounts()
    {
    	update lstGlobalDeleteFinanicalAccount;
    }
}