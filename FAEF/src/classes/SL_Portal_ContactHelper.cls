public with sharing class SL_Portal_ContactHelper {
	
	/*BEGIN PROPERTIES*/

	/*END PROPERTIES*/

	/***************************************************
	*	SHARED METHODS    					   		   *
	***************************************************/

	/***************************************************
	*	BEFORE INSERT METHODS    					   *
	***************************************************/

	public static void createGroupMembers(SL_TriggerParameters tp){
		Set<Id> newContacts = new Set<Id>();
		Set<Id> userIds = new Set<Id>();
		for (Portal_Contact__c pc : (List<Portal_Contact__c>)tp.newList){
			if(pc.Is_Chatter__c){
				newContacts.add(pc.Id);
   				userIds.add(pc.User__c);
			}
		}
   		SL_ChatterGroupHelper.insertPermissionSet(userIds);
		SL_ChatterGroupHelper.createAdminGroupMembers(newContacts);
	}

	/***************************************************
	*	BEFORE UPDATE METHODS    					   *
	***************************************************/
	
	public static void updateGroupMember(SL_TriggerParameters tp){
		Map<Id, Portal_Contact__c> oldContacts = new Map<Id, Portal_Contact__c>();
		for(Portal_Contact__c pc : (List<Portal_Contact__c>)tp.oldList){
			oldContacts.put(pc.id, pc);
		}
		Map<Id, Portal_Contact__c> addToChatter = new Map<Id, Portal_Contact__c>();
		Map<Id, Portal_Contact__c> removeChatter = new Map<Id, Portal_Contact__c>();
		Map<Id, Portal_Contact__c> updateFrequency = new Map<Id, Portal_Contact__c>();
		Map<Id, List<Portal_Contact__c>> brandingToContactForRemove = new Map<Id, List<Portal_Contact__c>>();
		List<Id> brandingForRemove = new List<Id>();
		Map<Id, List<Portal_Contact__c>> brandingToContactForUpdate = new Map<Id, List<Portal_Contact__c>>();
		List<Id> brandingForUpdate = new List<Id>();
		for (Portal_Contact__c pc : (List<Portal_Contact__c>)tp.newList){
			//if the contact is active and is set to chatter and either of these fields has changed
			if(pc.Is_Chatter__c && pc.Is_Chatter__c != oldContacts.get(pc.Id).Is_Chatter__c){
				addToChatter.put(pc.Id, pc);
			}
			//if portal contact has been set to inactive and it was on chatter while active or
			//if it's been active but chatter has been set to false
			if(!pc.Is_Chatter__c && oldContacts.get(pc.Id).Is_Chatter__c){
				removeChatter.put(pc.Id, pc);
				brandingForRemove.add(pc.Portal_Branding__c);
				if(brandingToContactForRemove.containsKey(pc.Portal_Branding__c)){
					brandingToContactForRemove.get(pc.Portal_Branding__c).add(pc);
				}else{
					brandingToContactForRemove.put(pc.Portal_Branding__c, new List<Portal_Contact__c>{pc});
				}
			}
		}
		for(Portal_Contact__c pc : (List<Portal_Contact__c>)tp.newList){		
			//if the contact is already on chatter and has changed it's email frequency
			if(!addToChatter.containsKey(pc.Id) && !removeChatter.containsKey(pc.Id) 
				&& pc.Community_Email_Frequency__c != oldContacts.get(pc.Id).Community_Email_Frequency__c){
				updateFrequency.put(pc.Id, pc);
				brandingForUpdate.add(pc.Portal_Branding__c);
				if(brandingToContactForUpdate.containsKey(pc.Portal_Branding__c)){
					brandingToContactForUpdate.get(pc.Portal_Branding__c).add(pc);
				}else{
					brandingToContactForUpdate.put(pc.Portal_Branding__c, new List<Portal_Contact__c>{pc});
				}
			}
		}
  		Set<Id> userIds = new Set<Id>();
   		for(Portal_Contact__c pc : addToChatter.values()){
   			userIds.add(pc.User__c);
   		}
   		SL_ChatterGroupHelper.insertPermissionSet(userIds);
		SL_ChatterGroupHelper.createAdminGroupMembers(addToChatter.keySet());

		List<Account_Portal__c> apForRemove = [SELECT Chatter_Group_Id__c, Portal__c FROM Account_Portal__c WHERE Portal__c IN : brandingForRemove];

		List<String> groupsForRemove = new List<String>();
		Map<Id, Set<String>> userToGroup = new Map<Id, Set<String>>();
		for(Account_Portal__c ap : apForRemove){
			groupsForRemove.add(ap.Chatter_Group_Id__c);
			for(Portal_Contact__c pc : brandingToContactForRemove.get(ap.Portal__c)){
				if(userToGroup.containsKey(pc.User__c)){
					userToGroup.get(pc.User__c).add(ap.Chatter_Group_Id__c);
				}
				else{
					userToGroup.put(pc.User__c, new Set<String>{ap.Chatter_Group_Id__c});
				}
			}
		} 
		
		List<CollaborationGroupMember> cGroupMembersForRemove = [SELECT MemberId, CollaborationGroupId FROM CollaborationGroupMember WHERE CollaborationGroupId IN : groupsForRemove];
	
		Map<String, List<CollaborationGroupMember>> groupIdToMembers = new Map<String, List<CollaborationGroupMember>>();
		for(CollaborationGroupMember cGroupMember : cGroupMembersForRemove){
			if(groupIdToMembers.containsKey(cGroupMember.CollaborationGroupId)){
				groupIdToMembers.get(cGroupMember.CollaborationGroupId).add(cGroupMember);
			}else{
				groupIdToMembers.put(cGroupMember.CollaborationGroupId, new List<CollaborationGroupMember>{cGroupMember});
			}
		}

		List<CollaborationGroupMember> membersToDelete = new List<CollaborationGroupMember>();
		for(Account_Portal__c ap : apForRemove){
			for(CollaborationGroupMember cGroupMember : groupIdToMembers.get(ap.Chatter_Group_Id__c)){
				if(userToGroup.get(cGroupMember.MemberId).contains((String)cGroupMember.CollaborationGroupId)){
					membersToDelete.add(cGroupMember);
				}
			}
		}
		delete membersToDelete;

		List<Account_Portal__c> apForUpdate = [SELECT Chatter_Group_Id__c, Portal__c FROM Account_Portal__c WHERE Portal__c IN : brandingForUpdate];
		List<String> groupsForUpdate = new List<String>();
		Map<Id, Set<String>> userToGroupUpdate = new Map<Id, Set<String>>();
		Map<Id, String> userToFreq = new Map<Id, String>();
		for(Account_Portal__c ap : apForUpdate){
			groupsForRemove.add(ap.Chatter_Group_Id__c);
			for(Portal_Contact__c pc : brandingToContactForUpdate.get(ap.Portal__c)){
				if(userToGroupUpdate.containsKey(pc.User__c)){
					userToGroupUpdate.get(pc.User__c).add(ap.Chatter_Group_Id__c);
				}
				else{
					userToGroupUpdate.put(pc.User__c, new Set<String>{ap.Chatter_Group_Id__c});
				}
				userToFreq.put(pc.Id, pc.Community_Email_Frequency__c);
			}
		} 
		
		List<CollaborationGroupMember> cGroupMembersForUpdate = [SELECT MemberId, CollaborationGroupId FROM CollaborationGroupMember WHERE CollaborationGroupId IN : groupsForRemove];
	
		Map<String, List<CollaborationGroupMember>> groupIdToMembersForUpdate = new Map<String, List<CollaborationGroupMember>>();
		for(CollaborationGroupMember cGroupMember : cGroupMembersForUpdate){
			if(groupIdToMembersForUpdate.containsKey(cGroupMember.CollaborationGroupId)){
				groupIdToMembersForUpdate.get(cGroupMember.CollaborationGroupId).add(cGroupMember);
			}else{
				groupIdToMembersForUpdate.put(cGroupMember.CollaborationGroupId, new List<CollaborationGroupMember>{cGroupMember});
			}
		}

		Map<Id, String> membersToFreq = new Map<Id, String>();
		for(Account_Portal__c ap : apForUpdate){
			for(CollaborationGroupMember cGroupMember : groupIdToMembersForUpdate.get(ap.Chatter_Group_Id__c)){
				if(userToGroupUpdate.get(cGroupMember.MemberId).contains((String)cGroupMember.CollaborationGroupId)){
					membersToFreq.put(cGroupMember.Id, userToFreq.get(cGroupMember.MemberId));
				}
			}
		}
		SL_ChatterGroupHelper.updateGroupMembers(membersToFreq);
	}

	/***************************************************
	*	BEFORE DELETE METHODS    					   *
	***************************************************/

	public static void removeGroupMembers(SL_TriggerParameters tp){
		Map<Id, Portal_Contact__c> deletedContacts = new Map<Id, Portal_Contact__c>();
		Map<Id, List<Portal_Contact__c>> brandingToContactForRemove = new Map<Id, List<Portal_Contact__c>>();
		List<Id> brandingForRemove = new List<Id>();
		
		for (Portal_Contact__c pc : (List<Portal_Contact__c>)tp.oldList){
			if(pc.Is_Chatter__c){
				deletedContacts.put(pc.Id, pc);
				brandingForRemove.add(pc.Portal_Branding__c);
				if(brandingToContactForRemove.containsKey(pc.Portal_Branding__c)){
					brandingToContactForRemove.get(pc.Portal_Branding__c).add(pc);
				}else{
					brandingToContactForRemove.put(pc.Portal_Branding__c, new List<Portal_Contact__c>{pc});
				}
			}
		}

		List<Account_Portal__c> apForRemove = [SELECT Chatter_Group_Id__c, Portal__c FROM Account_Portal__c WHERE Portal__c IN : brandingForRemove];

		List<String> groupsForRemove = new List<String>();
		Map<Id, Set<String>> userToGroup = new Map<Id, Set<String>>();
		for(Account_Portal__c ap : apForRemove){
			groupsForRemove.add(ap.Chatter_Group_Id__c);
			for(Portal_Contact__c pc : brandingToContactForRemove.get(ap.Portal__c)){
				if(userToGroup.containsKey(pc.User__c)){
					userToGroup.get(pc.User__c).add(ap.Chatter_Group_Id__c);
				}else{
					userToGroup.put(pc.User__c, new Set<String>{ap.Chatter_Group_Id__c});
				}
			}
		} 
		
		List<CollaborationGroupMember> cGroupMembersForRemove = [SELECT MemberId, CollaborationGroupId FROM CollaborationGroupMember WHERE CollaborationGroupId IN : groupsForRemove];
	
		Map<String, List<CollaborationGroupMember>> groupIdToMembers = new Map<String, List<CollaborationGroupMember>>();
		for(CollaborationGroupMember cGroupMember : cGroupMembersForRemove){
			if(groupIdToMembers.containsKey(cGroupMember.CollaborationGroupId)){
				groupIdToMembers.get(cGroupMember.CollaborationGroupId).add(cGroupMember);
			}else{
				groupIdToMembers.put(cGroupMember.CollaborationGroupId, new List<CollaborationGroupMember>{cGroupMember});
			}
		}

		List<CollaborationGroupMember> membersToDelete = new List<CollaborationGroupMember>();
		for(Account_Portal__c ap : apForRemove){
			for(CollaborationGroupMember cGroupMember : groupIdToMembers.get(ap.Chatter_Group_Id__c)){
				if(userToGroup.get(cGroupMember.MemberId).contains((String)cGroupMember.CollaborationGroupId)){
					membersToDelete.add(cGroupMember);
				}
			}
		}
		delete membersToDelete;

		SL_ChatterGroupHelper.removePermissionSet(userToGroup.keySet());
	}

	/***************************************************
	*	AFTER INSERT METHODS    					   *
	***************************************************/

	/***************************************************
	*	AFTER UPDATE METHODS    					   *
	***************************************************/

	/***************************************************
	*	AFTER DELETE METHODS    					   *
	***************************************************/

	/***************************************************
	*	AFTER UNDELETE METHODS    					   *
	***************************************************/

}