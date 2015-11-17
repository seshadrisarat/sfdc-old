/**  
* \arg ClassName		: SL_DelegatePublicGroupMemberHandler
* \arg JIRATicket		: HL-30
* \arg CreatedOn		: 06/Oct/2014
* \arg LastModifiedOn	: 06/Oct/2014
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: Handler class for Delegate PublicGroup Member Trigger
*/
public with sharing class SL_DelegatePublicGroupMemberHandler 
{
	/* Start - Variables */
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    /* End - Variables */

	/* Start - Constructor */
	public SL_DelegatePublicGroupMemberHandler(boolean isExecuting, integer size) 
	{
		m_isExecuting = isExecuting;
        BatchSize = size;
	} 
	/* End - Constructor */

	/*
        @MethodName        : onAfterInsert
        @param             : map of Delegate_Public_Group_Member__c New
        @Description       : create the group member records
    */
	public void onAfterInsert(Map<Id, Delegate_Public_Group_Member__c> mapIdToDelegatePublicGroupMemberNew)
    {
    	createGroupMemberRecords(mapIdToDelegatePublicGroupMemberNew.keySet());//to create new Group Member records.
    }
	/* End */
	
	/*
        @MethodName        : onAfterUpdate
        @param             : map of Delegate_Public_Group_Member__c New and Old
        @Description       : create and delete the group member records
    */
    public void onAfterUpdate(Map<Id, Delegate_Public_Group_Member__c> mapIdToDelegatePublicGroupMemberNew, Map<Id, Delegate_Public_Group_Member__c> mapIdToDelegatePublicGroupMemberOld)
    {
    	createGroupMemberRecords(mapIdToDelegatePublicGroupMemberNew.keySet());//to create new Group Member records.
    	deleteGroupMemberRecords(mapIdToDelegatePublicGroupMemberOld);//to delete Group Member records.
    }
	/* End */
	
	/*
        @MethodName        : onAfterDelete
        @param             : map of Delegate_Public_Group_Member__c Old         
        @Description       : delete the group member records
    */
    public void onAfterDelete(Map<Id, Delegate_Public_Group_Member__c> mapIdToDelegatePublicGroupMemberOld)
    {
    	deleteGroupMemberRecords(mapIdToDelegatePublicGroupMemberOld);//to delete Group Member records.
    }
	/* End */
	
	/*
        @MethodName        : createGroupMemberRecords
        @param             : map of Delegate_Public_Group_Member__c 
        @Description       : to create Group Member records.
    */
	@future
	private static void createGroupMemberRecords(Set<Id> setDPGMId)
	{
		Set<Id> setDPGIds = new Set<Id>();//Set of Delegate_Public_Group__c id.
		Set<Id> setUserIds = new Set<Id>();//Set of user id
		Set<Id> setPublicGroupId = new Set<Id>();//Set of public group id
		Set<String> setExistingGroupMember = new Set<String>();//Set of string with combination of group id to user id
		Map<Id, Delegate_Public_Group__c> mapIdToDPG = new Map<Id, Delegate_Public_Group__c>();//Map of id to Delegate_Public_Group__c
		List<GroupMember> lstGroupMemberToInsert = new List<GroupMember>();//List of GroupMember to insert
		
		//Iterating on Delegate_Public_Group_Member__c for getting the Delegate_Public_Group__c id and user id
		for(Delegate_Public_Group_Member__c objDPGM : [SELECT Id,
															  Delegate__c,	
															  Delegate_Public_Group__c
														 FROM Delegate_Public_Group_Member__c
														WHERE Id IN : setDPGMId])
		{
			if(objDPGM.Delegate__c != null)
			{
				setDPGIds.add(objDPGM.Delegate_Public_Group__c);
				setUserIds.add(objDPGM.Delegate__c);
			}
		}
		
		//Iterating on Delegate_Public_Group__c for getting the group id and map of Delegate_Public_Group__c 
		for(Delegate_Public_Group__c objDPG : [SELECT Id, 
													  Banker__c, 
													  Public_Group_ID__c 
											     FROM Delegate_Public_Group__c 
											    WHERE Id IN: setDPGIds 
											      AND Public_Group_ID__c != null])
		{
			setPublicGroupId.add(objDPG.Public_Group_ID__c);
			mapIdToDPG.put(objDPG.Id, objDPG);
		}
		
		//Iterating on GroupMember for checking its existence 
		for(GroupMember objGM : [SELECT Id, 
									    UserOrGroupId, 
									    GroupId 
								   FROM GroupMember 
								  WHERE GroupId IN:setPublicGroupId 
								    AND UserOrGroupId IN: setUserIds])
		{
			setExistingGroupMember.add(objGM.GroupId +'~'+ objGM.UserOrGroupId);
		}
		
		//Iterating on Delegate_Public_Group_Member__c to create the GroupMember records.
		for(Delegate_Public_Group_Member__c objDPGM : [SELECT Id,
															  Delegate__c,	
															  Delegate_Public_Group__c
														 FROM Delegate_Public_Group_Member__c
														WHERE Id IN : setDPGMId])
		{
			if(mapIdToDPG.containsKey(objDPGM.Delegate_Public_Group__c) && objDPGM.Delegate__c != null 
				&& !setExistingGroupMember.contains(mapIdToDPG.get(objDPGM.Delegate_Public_Group__c).Public_Group_ID__c +'~'+ objDPGM.Delegate__c))
			{
				lstGroupMemberToInsert.add(new GroupMember(UserOrGroupId = objDPGM.Delegate__c, 
    													   GroupId = mapIdToDPG.get(objDPGM.Delegate_Public_Group__c).Public_Group_ID__c));
			}
		}
		//Insert GroupMember records
		if(!lstGroupMemberToInsert.isEmpty())
			insert lstGroupMemberToInsert;
	}
	/* End */
	
	/*
        @MethodName        : deleteGroupMemberRecords
        @param             : map of Delegate_Public_Group_Member__c 
        @Description       : to delete the Group Member Records in future method.
    */
	private void deleteGroupMemberRecords(Map<Id, Delegate_Public_Group_Member__c> mapIdToDelegatePublicGroupMember)
	{
		Set<Id> setDPGIds = new Set<Id>();//Set of Delegate_Public_Group__c id
		Set<Id> setUserIds = new Set<Id>();//Set of user id
		Set<Id> setPublicGroupId = new Set<Id>();//Set of public group id
		Set<Id> setGroupMemberId = new Set<Id>();//Set of GroupMember id to delete
		Set<String> setUserId_DPGId = new Set<String>();//Set of string with combination of userId and delegate public group id.
		Map<Id, Delegate_Public_Group__c> mapIdToDPG = new Map<Id, Delegate_Public_Group__c>();//Map of id to Delegate_Public_Group__c
		Map<String, GroupMember> mapUserGroupToExistingGroupMember = new Map<String, GroupMember>();//Map of string with combination of user id and group id to group member
		
		//Iterating on Delegate_Public_Group_Member__c for getting the Delegate_Public_Group__c id and user id 
		for(Delegate_Public_Group_Member__c objDPGM : mapIdToDelegatePublicGroupMember.values())
		{
			if(objDPGM.Delegate__c != null)
			{
				setDPGIds.add(objDPGM.Delegate_Public_Group__c);
				setUserIds.add(objDPGM.Delegate__c);    
			}
		}
		
		//To prevent from deleting the group member records for the existing Delegate_Public_Group_Member__c records
		for(Delegate_Public_Group_Member__c objDPGM : [SELECT Id, 
															  Delegate__c, 
															  Delegate_Public_Group__c 
														 FROM Delegate_Public_Group_Member__c
														WHERE Delegate__c IN:setUserIds
														  AND Delegate_Public_Group__c IN:setDPGIds
														  AND Id NOT IN:mapIdToDelegatePublicGroupMember.keyset()])
		{
			setUserId_DPGId.add(objDPGM.Delegate__c + '_' + objDPGM.Delegate_Public_Group__c);
		}
		
				
		//Iterating on Delegate_Public_Group__c for getting the Public_Group_ID__c id and map of Delegate_Public_Group__c
		for(Delegate_Public_Group__c objDPG : [SELECT Id, 
													  Banker__c, 
													  Public_Group_ID__c 
											     FROM Delegate_Public_Group__c 
											    WHERE Id IN: setDPGIds 
											      AND Public_Group_ID__c != null])
		{
			setUserId_DPGId.add(objDPG.Banker__c + '_' + objDPG.Id);
			setPublicGroupId.add(objDPG.Public_Group_ID__c);
			mapIdToDPG.put(objDPG.Id, objDPG);
		}
		
		//Iterating on GroupMember to check existing GroupMember records 
		for(GroupMember objGM : [SELECT Id, 
									    UserOrGroupId, 
									    GroupId 
								   FROM GroupMember 
								  WHERE GroupId IN:setPublicGroupId 
								    AND UserOrGroupId IN: setUserIds])
		{
			mapUserGroupToExistingGroupMember.put(objGM.GroupId +'~'+ objGM.UserOrGroupId, objGM);
		}
		
		//Iterating on Delegate_Public_Group_Member__c for deleting the GroupMember records. 
		for(Delegate_Public_Group_Member__c objDPGM : mapIdToDelegatePublicGroupMember.values())
		{
			if(mapIdToDPG.containsKey(objDPGM.Delegate_Public_Group__c) && objDPGM.Delegate__c != null 
			   && !setUserId_DPGId.contains(objDPGM.Delegate__c + '_' + objDPGM.Delegate_Public_Group__c)
			   && mapUserGroupToExistingGroupMember.containsKey(mapIdToDPG.get(objDPGM.Delegate_Public_Group__c).Public_Group_ID__c +'~'+ objDPGM.Delegate__c))
			{
				setGroupMemberId.add(mapUserGroupToExistingGroupMember.get(mapIdToDPG.get(objDPGM.Delegate_Public_Group__c).Public_Group_ID__c +'~'+ objDPGM.Delegate__c).Id);
			}
		}
		//Calling the future method for deleting the GroupMember records
		if(!setGroupMemberId.isEmpty())
			deleteGroupMembers(setGroupMemberId);	
		
	}
	/* End */
	
	/*
        @MethodName        : deleteGroupMembers
        @param             : set of GroupMember id
        @Description       : to delete the Group Member Records.
    */
	@future
	private static void deleteGroupMembers(Set<Id> setGroupMemberId)
	{
		List<GroupMember> lstGroupMemberToDelete = new List<GroupMember>();//List of GroupMember to delete	
		
		//Iterating on groupmember id to delete the group member records
		for(Id groupMemberId : setGroupMemberId)
		{
			lstGroupMemberToDelete.add(new GroupMember(Id = groupMemberId));
		}
		//Delete the group member records
		if(!lstGroupMemberToDelete.isEmpty())
			delete lstGroupMemberToDelete;
	}
	/* End */
}