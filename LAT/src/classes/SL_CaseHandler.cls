/**
*  ClassName      : SL_CaseHandler
*  JIRATicket     : LAT-2
*  CreatedOn      : 28/May/2014
*  ModifiedBy     : Sruti
*  Description    : 
*/
public with sharing class SL_CaseHandler {

	/*
    	* MethodName        : onAfterInsert
        * param             : Map<Id, Case> mapNewCase
        * Description       : This method is called after Case record insert.
    */
    public void onAfterInsert(Map<Id, Case> mapNewCase) {
    	
    	/* Call this method to insert Case Team Member */
    	createCaseTeamMember(mapNewCase);
    	
    }
    
    /*
    	* MethodName        : createCaseTeamMember
        * param             : Map<Id, Case> mapNewCase
        * Description       : This method is called to insert Case Team Member if the current user is not having profile either "Service team" or "Service Team Manager".
    */
    private void createCaseTeamMember(Map<Id, Case> mapNewCase) {
    	
    	String strCaseTeamRoleId 				  = ''; //!< Holding Case Team Role Id.
    	List<CaseTeamMember> lstCaseTeamMember 	  = new List<CaseTeamMember>(); //!< Hold Case Team Member records to be inserted.
    	Map<Id, String> MapProfileIdToProfileName = new Map<Id, String>(); //!< Hole both profile ids with its respective names.
    	
    	/* Query profiles where Name is "Service Team" or "Service Team Manager" and maintaining map for it */
    	For(Profile objProfile : [Select Id, Name From Profile WHERE Name = 'Service Team' OR Name = 'Service Team Manager']) {
		
				MapProfileIdToProfileName.put(objProfile.Id, objProfile.Name);
		}
		
		/* Query User record value who is creating Case record  */
		User objUser = [SELECT Id, Name, ProfileId, Role__c from User where Id =: UserInfo.getUserId()];
		
		
		/* If the current user profile is not match with the profile in map then create case Team Member with respective values. */
		if(!MapProfileIdToProfileName.containsKey(objUser.ProfileId)) {
			
			
			/* If the User Role__c field is not null then query Case Team role Id  */
			if(objUser.Role__c != null && objUser.Role__c != '') 
				strCaseTeamRoleId = [Select Name, Id From CaseTeamRole where Name =: objUser.Role__c].Id;
			
			/* Query the default case team role */
			String strDefaultCaseTeamRole = [Select Name, Id From CaseTeamRole where Name ='Laticrete Sales Rep'].Id;
			
			/* Iterating over new case records to get Case Team member list */
			for(Case objCase: mapNewCase.values()) {
				
				CaseTeamMember objCaseTeamMember = new CaseTeamMember(ParentId = objCase.Id, MemberId =  UserInfo.getUserId());
				
				/* If user record is having Team role then assign it to TeamRoleId otherwise assign the default value. */
				if(strCaseTeamRoleId != null && strCaseTeamRoleId != '') 
					objCaseTeamMember.TeamRoleId = strCaseTeamRoleId;
					 
				else if(strDefaultCaseTeamRole != null && strDefaultCaseTeamRole != '')
					objCaseTeamMember.TeamRoleId = strDefaultCaseTeamRole;
				
				lstCaseTeamMember.add(objCaseTeamMember);
					
			}
				
		}
		
		/* If list is not empty then insert in database. */
		if(!lstCaseTeamMember.isEmpty()) 
			database.insert(lstCaseTeamMember, false);
    }
    
}