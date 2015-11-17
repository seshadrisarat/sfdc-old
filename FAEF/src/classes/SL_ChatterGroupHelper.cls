/*
 * This class contains helper methods which are called by triggers on User, Account Portal, and Portal contact
 * 
 */
public without sharing class SL_ChatterGroupHelper {

	private static PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Vendor_Community_Access'];
	private static Vendor_Community_Name__c communityName = Vendor_Community_Name__c.getInstance('Vendor Community');
	private static Network community = [SELECT Id FROM Network WHERE Name =: communityName.Community_Name__c LIMIT 1];

	/*
	 * Assign the community access permission set
	 */
	@future
  public static void insertPermissionSet(Set<Id> userIds) {
    	System.debug(LoggingLevel.ERROR, 'entered insertPermissionSet');
		System.debug(LoggingLevel.ERROR, 'received' + userIds);
    	List<PermissionSetAssignment> assignedList = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN : userIds AND PermissionSetId = : ps.Id];
		Set<Id> alreadyAssigned = new Set<Id>();
		for(PermissionSetAssignment psa : assignedList){
			alreadyAssigned.add(psa.AssigneeId);
		}
		List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
		for(Id uId : userIds){
			if(!alreadyAssigned.contains(uId)){
				psaList.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = uId));
			}
		}
		insert psaList;
		System.debug(LoggingLevel.ERROR, 'inserted' + psaList);
  }

    /*
     * Remove the community access permission set
     */
    @future 
    public static void removePermissionSet(Set<Id> userIds){
 		List<PermissionSetAssignment> assignedList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId IN : userIds AND PermissionSetId = : ps.Id];
     	delete assignedList;
    }

    /*
     * Create chatter groups for accounts provided
     */
    public static Map<Id, CollaborationGroup> createChatterGroup(List<Account> accounts){
    	System.debug(LoggingLevel.ERROR, 'entered createChatterGroup');
    	List<CollaborationGroup> cGroupList = new List<CollaborationGroup>();
    	Map<Id, CollaborationGroup> acctIdToGroup = new Map<Id, CollaborationGroup>();
    	for(Account acct : accounts){
    		CollaborationGroup cGroup = new CollaborationGroup(CanHaveGuests = false, CollaborationType = 'Public', NetworkId = community.Id,
       															IsAutoArchiveDisabled = false, Name = acct.Name.substring(0, acct.Name.length() > 20 ? 20 : acct.Name.length()) + '... Chatter Group', OwnerId = acct.OwnerId);
       		acctIdToGroup.put(acct.Id, cGroup);
       		cGroupList.add(cGroup);
    	}
    	insert cGroupList;
    	System.debug(LoggingLevel.ERROR, 'returning ' + acctIdToGroup);
    	return acctIdToGroup;
    }

    /* 
     * Create Chatter Group Members for users provided
     */ 
    @future
    public static void createStandardGroupMembers(Map<Id, Id> userIdToGroupId){      
      List<User> users = [SELECT Id, Email FROM User WHERE Id IN : userIdToGroupId.keySet()];
      for(User u : users){
        u.Email = u.Email + 'removechatter';
      }
      update users;
      
    	List<CollaborationGroupMember> cGroupMembers = new List<CollaborationGroupMember>();
      for(Id userId : userIdToGroupId.keySet()){
    		if(userIdToGroupId.get(userId) != null && userId != null){			
	    		CollaborationGroupMember member = new CollaborationGroupMember(CollaborationGroupId = userIdToGroupId.get(userId), 
																					  CollaborationRole = 'Standard', 
		   																			MemberId = userId,
		   																			NotificationFrequency = 'P');
	    		cGroupMembers.add(member);
    		}
    	}
    	insert cGroupMembers;

      List<User> newUsers = [SELECT Id, Email FROM User WHERE Id IN : userIdToGroupId.keySet()];
      for(User u : newUsers){
        u.Email = u.Email.substring(0, u.Email.indexOf('removechatter'));
      }
      update newUsers;
    }

    /* 
     * Create Admin Chatter Group Members for users provided
     * Users passed should only be internal users
     */ 
    @future
    public static void createAdminGroupMembers(Set<Id> portalContactIds){
    	System.debug(LoggingLevel.ERROR, 'entered createAdminGroupMembers');
		  System.debug(LoggingLevel.ERROR, 'received' + portalContactIds);
    	Map<Id, Portal_Contact__c> portalContacts = new Map<Id, Portal_Contact__c>([SELECT Id, User__c, Portal_Branding__c, Community_Email_Frequency__c
   												  FROM Portal_Contact__c 
   												  WHERE Id IN : portalContactIds 
   												  AND Is_Chatter__c = true]);

    	Map<Id, List<Portal_Contact__c>> brandingToPortalContacts = new Map<Id, List<Portal_Contact__c>>();
    	Map<Id, String> userIdToFreq = new Map<Id, String>();
   		//construct a map of a portal branding to it's list of portal contacts
   		for(Portal_Contact__c pc : portalContacts.values()){
   			if(brandingToPortalContacts.containsKey(pc.Portal_Branding__c)){
   				brandingToPortalContacts.get(pc.Portal_Branding__c).add(pc);
  			}else{
  				brandingToPortalContacts.put(pc.Portal_Branding__c, new List<Portal_Contact__c>{pc});
  			} 
  			userIdToFreq.put(pc.User__c, pc.Community_Email_Frequency__c);
   		}

   		List<Account_Portal__c> accountPortals = new List<Account_Portal__c>([SELECT Id, Portal__c, Chatter_Group_Id__c
   												  FROM Account_Portal__c 
   												  WHERE Portal__c IN : brandingToPortalContacts.keySet()]);
   		Map<Id, List<String>> userToGroup = new Map<Id, List<String>>();
   		Set<String> groupIds = new Set<String>();
   		for(Account_Portal__c ap : accountPortals){
   			for(Portal_Contact__c pc : brandingToPortalContacts.get(ap.Portal__c)){
   				if(userToGroup.keySet().contains(pc.User__c)){
   					userToGroup.get(pc.User__c).add(ap.Chatter_Group_Id__c);
   				}else{
   					userToGroup.put(pc.User__c, new List<String>{ap.Chatter_Group_Id__c});
   				}
   				groupIds.add(ap.Chatter_Group_Id__c);
   			}
   		}

   		Map<Id, CollaborationGroup> cGroups = new Map<Id, CollaborationGroup>([SELECT Id, OwnerId FROM CollaborationGroup WHERE Id IN : groupIds]);

    	List<CollaborationGroupMember> cGroupMembers = new List<CollaborationGroupMember>();
    	for(Id userId : userToGroup.keySet()){
    		for(String groupId : userToGroup.get(userId)){	
    			if(userId != cGroups.get(groupId).OwnerId){
		    		String freq = userIdToFreq.get(userId);
		    		if(userIdToFreq.get(userId) == 'On Each Post'){
						freq = 'P';
					}
					else if(userIdToFreq.get(userId) == 'Daily'){
						freq = 'D';
					}
					else if(userIdToFreq.get(userId) == 'Weekly'){
						freq = 'W';
					}
					else{
						freq = 'N';
					}
		    		CollaborationGroupMember member = new CollaborationGroupMember(CollaborationGroupId = groupId, 
																						CollaborationRole = 'Admin', 
			   																			MemberId = userId,
			   																			NotificationFrequency = freq);
		    		cGroupMembers.add(member);
    			}		
    		}
    	}
    	insert cGroupMembers;
		  System.debug(LoggingLevel.ERROR, 'inserted' + cGroupMembers);
    }

    /*
     * Update the notification frequency of a chatter group member
     */
    @future 
    public static void updateGroupMembers(Map<Id, String> memberIdToFreq){
    	System.debug(LoggingLevel.ERROR, 'entered updateGroupMembers');
		  System.debug(LoggingLevel.ERROR, 'received' + memberIdToFreq);
    	List<CollaborationGroupMember> cGroupMembers = [SELECT Id, NotificationFrequency FROM CollaborationGroupMember WHERE MemberId IN : memberIdToFreq.keySet()];
    	for(CollaborationGroupMember member : cGroupMembers){
    		member.NotificationFrequency = memberIdToFreq.get(member.Id);
    	}
    	update cGroupMembers;
		  System.debug(LoggingLevel.ERROR, 'updated' + cGroupMembers);
    }
}