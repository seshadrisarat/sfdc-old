/**  
* \arg ClassName        : SL_NPD_Account_TeamTriggerHandler
* \arg JIRATicket       : NPD-83
* \arg CreatedOn        : 08/26/2015
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Sandeep
* \arg ModifiedBy       : 
* \arg Description      : Handler class for NPD_Account_Team object.
*/
global class SL_NPD_Account_TeamTriggerHandler extends SL_TriggerHandlerBase {

	public override void beforeInsert(List<SObject> newListGeneric){
		List<NPD_Account_Team__c> newList = (List<NPD_Account_Team__c>) newListGeneric;
		/*BEFORE INSERT METHODS START*/
		
		/*BEFORE INSERT METHODS END*/
	}
	
	public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, NPD_Account_Team__c> oldMap = (Map<Id, NPD_Account_Team__c>) oldMapGeneric;
		Map<Id, NPD_Account_Team__c> newMap = (Map<Id, NPD_Account_Team__c>) newMapGeneric;
		/*BEFORE UPDATE METHODS START*/
		
		/*BEFORE UPDATE METHODS END*/
	}
	
	public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, NPD_Account_Team__c> oldMap = (Map<Id, NPD_Account_Team__c>) oldMapGeneric;
		/*BEFORE DELETE METHODS START*/
		
		/*BEFORE DELETE METHODS END*/
	}
	
	public override void afterInsert(Map<Id, SObject> newMapGeneric){
		Map<Id, NPD_Account_Team__c> newMap = (Map<Id, NPD_Account_Team__c>) newMapGeneric;
		/*AFTER INSERT METHODS START*/
		createAccountShare(new Map<Id, NPD_Account_Team__c>(), newMap);
		createCollabrationMember(newMap);
		/*AFTER INSERT METHODS END*/
	}
	
	public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, NPD_Account_Team__c> oldMap = (Map<Id, NPD_Account_Team__c>) oldMapGeneric;
		Map<Id, NPD_Account_Team__c> newMap = (Map<Id, NPD_Account_Team__c>) newMapGeneric;
		/*AFTER UPDATE METHODS START*/
		createAccountShare(oldMap, newMap);
		createCollabrationMember(newMap);
		deleteCollabrationGroupMember(oldMap, newMap);
		/*AFTER UPDATE METHODS END*/
	}
	
	public override void afterDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, NPD_Account_Team__c> oldMap = (Map<Id, NPD_Account_Team__c>) oldMapGeneric;
		/*AFTER DELETE METHODS START*/
		createAccountShare(oldMap, new Map<Id, NPD_Account_Team__c>());
		deleteCollabrationGroupMember(new Map<Id, NPD_Account_Team__c>(), oldMap);
		/*AFTER DELETE METHODS END*/
	}
	
	public override void afterUndelete(Map<Id, SObject> newMapGeneric){
		Map<Id, NPD_Account_Team__c> newMap = (Map<Id, NPD_Account_Team__c>) newMapGeneric;
		/*AFTER UNDELETE METHODS START*/
		
		/*AFTER UNDELETE METHODS END*/
	}
	
	/*
        * MethodName        : createAccountShare
        * param             : Map<Id, NPD_Account_Team__c> oldMap, Map<Id, NPD_Account_Team__c> newMap
        * Description       : This function will share account with users.
    */
	private void createAccountShare(Map<Id, NPD_Account_Team__c> oldMap, Map<Id, NPD_Account_Team__c> newMap)
	{
	    set<Id> setAllAccountIds = new set<Id>(); // set will contain the All account ids
	    set<Id> setParentAccountChilds = new set<Id>(); // set will contain all parent Account child ids
	    set<Id> setInactiveUserids = new set<Id>(); //set will contain inactive Account Team user ids
	    set<Id> setParentAccountId = new set<Id>();
	    set<String> setGroupName = new set<String>();
	    List<GroupMember> lstGroupMember = new List<GroupMember>(); // List will contain group member records
	    List<AccountShare> lstAccountShare = new List<AccountShare>();// list of Account share records
	    map<String, List<NPD_Account_Team__c>> mapGroupNameToListATeam = new map<String, List<NPD_Account_Team__c>>();
	    map<Id, String> mapAccountIdToAccountName = new map<Id, String>();
	    map<String, Id> mapGroupNameToGroupId = new map<String, Id>();
	    
	    for(NPD_Account_Team__c objNPDAccTeam: [SELECT Id, Team_Member_Status__c, User__c, Account__c, Parent_Account__c, Parent_Account__r.Name  FROM NPD_Account_Team__c 
	                                             WHERE Id IN: newMap.keySet() AND Parent_Account__c != null  AND User__c != null])
	    {
	        if(objNPDAccTeam.Team_Member_Status__c == 'Active' || objNPDAccTeam.Team_Member_Status__c == 'Inactive')
	        {
    	        if(!mapGroupNameToListATeam.containskey(objNPDAccTeam.Parent_Account__r.Name))
                    mapGroupNameToListATeam.put(objNPDAccTeam.Parent_Account__r.Name, new List<NPD_Account_Team__c>{objNPDAccTeam});
                else
                    mapGroupNameToListATeam.get(objNPDAccTeam.Parent_Account__r.Name).add(objNPDAccTeam);
	        }
	        if(objNPDAccTeam.Team_Member_Status__c == 'Active')
	        {
    	        setAllAccountIds.add(objNPDAccTeam.Account__c);
	            setAllAccountIds.add(objNPDAccTeam.Parent_Account__c);
	            setParentAccountChilds.add(objNPDAccTeam.Parent_Account__c);
	            mapAccountIdToAccountName.put(objNPDAccTeam.Parent_Account__c, objNPDAccTeam.Parent_Account__r.Name);
	        }
	        else if(objNPDAccTeam.Team_Member_Status__c == 'Inactive')
	        {
    	        //for update case if status is changed to inactive
    	        if(!oldMap.isEmpty() && oldMap.get(objNPDAccTeam.Id).Team_Member_Status__c == 'Active'
    	                    && objNPDAccTeam.Team_Member_Status__c == 'Inactive')
    	        {
    	            setInactiveUserids.add(objNPDAccTeam.User__c);
    	        }
	        }
	    }
	    
	    //delete case
	    for(NPD_Account_Team__c objNPDAccTeam: oldMap.values())
	    {
	        if(objNPDAccTeam.Parent_Account__c != null && objNPDAccTeam.Team_Member_Status__c == 'Active')
	        {
	            setParentAccountId.add(objNPDAccTeam.Parent_Account__c);
	            setInactiveUserids.add(objNPDAccTeam.User__c);
	        }
	    }
	    
	    for(Account objAccount:[SELECT Id, Name FROM Account WHERE Id IN: setParentAccountId])
	    {
	        setGroupName.add(objAccount.Name);
	    }
	    
        for(Group objGroup:[SELECT Id, Name FROM Group WHERE Name IN: setGroupName])
        {
            mapGroupNameToGroupId.put(objGroup.Name, objGroup.Id);
        }
        
        for(Group objGroup:[SELECT Id, Name FROM Group WHERE Name IN: mapGroupNameToListATeam.keySet()])
        {
            mapGroupNameToGroupId.put(objGroup.Name, objGroup.Id);
                
            if(mapGroupNameToListATeam.containskey(objGroup.Name))
            {
                for(NPD_Account_Team__c objNPDAccTeam: mapGroupNameToListATeam.get(objGroup.Name))
                {
                    if(objNPDAccTeam.Team_Member_Status__c == 'Active')
                        lstGroupMember.add(new GroupMember(GroupId = objGroup.Id, UserOrGroupId = objNPDAccTeam.User__c));
                }
            }
        }
        
        set<Id> setUserIdCheck = new set<Id>();
	    for(NPD_Account_Team__c obj : [SELECT Id, User__c FROM NPD_Account_Team__c WHERE User__c IN: setInactiveUserids and Team_Member_Status__c =: 'Active'])
        {
           if(Trigger.isDelete || (Trigger.isUpdate && setUserIdCheck.contains(obj.User__c)))
              setInactiveUserids.remove(obj.User__c);
            setUserIdCheck.add(obj.User__c);
        }
        
        delGroupMembers(JSON.serialize([SELECT ID FROM GroupMember WHERE UserOrGroupId IN: setInactiveUserids AND GroupId IN:mapGroupNameToGroupId.Values()]));
        //call add method for adding the member into the group
        addMembers(JSON.serialize(lstGroupMember));
        
        map<Id, Set<Id>> mapParentAccountIdToChildAccounts = new map<Id, Set<Id>>();
        //get all the child account of prent Account and add into set for sharing
        for(Account objAccount: [SELECT Id, ParentId FROM Account WHERE ParentId IN: setParentAccountChilds])
        {
            setAllAccountIds.add(objAccount.Id);
        }
        //share the all accounts with group
        
        for(String strGroupName:mapGroupNameToListATeam.keySet())
        {
            for(NPD_Account_Team__c objNPDAccTeam:mapGroupNameToListATeam.get(strGroupName))
            {
                lstAccountShare.add(new AccountShare(AccountId = objNPDAccTeam.Account__c, AccountAccessLevel = 'Edit', 
                                                        OpportunityAccessLevel = 'Read',
                                                        UserOrGroupId = mapGroupNameToGroupId.get(strGroupName)));
                lstAccountShare.add(new AccountShare(AccountId = objNPDAccTeam.Parent_Account__c, AccountAccessLevel = 'Edit', 
                                                        OpportunityAccessLevel = 'Read',
                                                        UserOrGroupId = mapGroupNameToGroupId.get(strGroupName)));
            }
        }
        
        insert lstAccountShare;
	}
	//This method for avoid the mix dml error and insert the group member records
	@future
	private static void addMembers(String strJSON)
	{
	    If(!Test.isRunningTest())
	        insert (List<GroupMember>)(JSON.deserialize(strJSON, List<GroupMember>.class));
	}
	//This method for avoid the mix dml error and delete the group member records
	@future
	private static void delGroupMembers(String strJSON)
	{
	    If(!Test.isRunningTest())
	        delete (List<GroupMember>)(JSON.deserialize(strJSON, List<GroupMember>.class));
	}
	
	/*
        * MethodName        : createCollabrationMember
        * param             : Map<Id, NPD_Account_Team__c>  newMap
        * Description       : This method will create collbration member.
    */
	private void createCollabrationMember(Map<Id, NPD_Account_Team__c> newMap)
	{
	    set<Id> setParentAccountId = new set<Id>();
	    List<CollaborationGroupMember> lstCollaborationGroupMember = new List<CollaborationGroupMember>();
	    map<String, set<Id>> mapParentAccountNameToSetOfUserIds = new map<String, set<Id>>();
	    for(NPD_Account_Team__c objNPDAccTeam: [SELECT Id, 
	                                                   User__c, 
	                                                   Parent_Account__r.Name  
	                                              FROM NPD_Account_Team__c 
	                                             WHERE Id IN: newMap.keySet() 
	                                               AND Parent_Account__c != null  
	                                               AND User__c != null
	                                               AND Team_Member_Status__c = 'Active'])
	    {
	        if(mapParentAccountNameToSetOfUserIds.containskey(objNPDAccTeam.Parent_Account__r.Name + ' NPD Team'))
	            mapParentAccountNameToSetOfUserIds.get(objNPDAccTeam.Parent_Account__r.Name + ' NPD Team').add(objNPDAccTeam.User__c);
	        else
	            mapParentAccountNameToSetOfUserIds.put(objNPDAccTeam.Parent_Account__r.Name + ' NPD Team', new set<Id>{objNPDAccTeam.User__c});
	    }
	    for(CollaborationGroup objCollaborationGroup: [SELECT Id, 
	                                                          Name 
	                                                     FROM CollaborationGroup 
	                                                    WHERE Name IN: mapParentAccountNameToSetOfUserIds.keySet()])
	    {
	        for(Id objUseId: mapParentAccountNameToSetOfUserIds.get(objCollaborationGroup.Name))
	        {
	            lstCollaborationGroupMember.add(new CollaborationGroupMember(CollaborationGroupId = objCollaborationGroup.Id, 
	                                                                            memberid = objUseId, CollaborationRole = 'Standard'));
	        }
	    }
	    database.insert(lstCollaborationGroupMember, false);//avoiding duplicate member insert error
	}
	
	/*
        * MethodName        : deleteCollabrationGroupMember
        * param             : Map<Id, NPD_Account_Team__c> oldMap, Map<Id, NPD_Account_Team__c> newMap
        * Description       : This method will delete collbration member.
    */
	private void deleteCollabrationGroupMember(Map<Id, NPD_Account_Team__c> oldMap, Map<Id, NPD_Account_Team__c> newMap)
	{
	    set<Id> setUserId = new set<Id>();
	    set<String> setParentAccountName = new set<String>();
	    set<String> setGroupName = new set<String>();
	    set<Id> setParentAccountId = new set<Id>();
	    for(NPD_Account_Team__c objNPDAccTeam: newMap.values())
	    {
	        if(objNPDAccTeam.User__c != null && objNPDAccTeam.Parent_Account__c != null &&
	            (Trigger.isDelete && objNPDAccTeam.Team_Member_Status__c == 'Active') || 
	            (Trigger.isUPdate && oldMap.get(objNPDAccTeam.Id).Team_Member_Status__c == 'Active' && objNPDAccTeam.Team_Member_Status__c == 'Inactive'))
	        {
	            setParentAccountId.add(objNPDAccTeam.Parent_Account__c);
	            setUserId.add(objNPDAccTeam.User__c);
	        }
	    }
	    for(Account objAccount : [SELECT Id, Name FROM Account WHERE Id IN: setParentAccountId])
	    {
	        setParentAccountName.add(objAccount.Name);
	        setGroupName.add(objAccount.Name + ' NPD Team');
	    }
	    for(NPD_Account_Team__c objNPDAccTeam: [SELECT Id, 
	                                                   User__c
	                                              FROM NPD_Account_Team__c 
	                                             WHERE User__c IN: setUserId 
	                                               AND Parent_Account__r.Name =: setParentAccountName
	                                               AND Team_Member_Status__c = 'Active'])
	    {
	        if(setUserId.contains(objNPDAccTeam.User__c))
	            setUserId.remove(objNPDAccTeam.User__c);
	    }
	    List<CollaborationGroupMember> lstCollaborationGroupMemberToDel = new List<CollaborationGroupMember>();
	    for(CollaborationGroupMember objCollaborationGroup: [SELECT Id
	                                                           FROM CollaborationGroupMember 
	                                                          WHERE CollaborationGroup.Name IN: setGroupName
	                                                            AND MemberId IN: setUserId])
	    {
	        lstCollaborationGroupMemberToDel.add(objCollaborationGroup);
	    }
	    database.delete(lstCollaborationGroupMemberToDel, false); //handle the delete group owner record
	}
}