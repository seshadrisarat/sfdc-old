public without sharing class SL_TargetedNews {
	public SL_TargetedNews() {
		
	}

	public Set<String> getNewsMessages(){
		Set<String> permissionSetNames = new Set<String>();
		for(PermissionSetAssignment pSetAssignment :[SELECT Id, AssigneeId, PermissionSet.Label 
													 FROM PermissionSetAssignment 
													 WHERE AssigneeId = :UserInfo.getUserId()])
		{
			permissionSetNames.add(pSetAssignment.PermissionSet.Label);
		}
		List<Notification__c> activeNotifications = [SELECT Id, Notification__c, Job_Codes__c, Process_Levels__c 
													 FROM Notification__c 
													 WHERE Active__c = true];
		Set<String> filteredNotifications = new Set<String>();
		for(Notification__c n :activeNotifications)
		{
			Set<String> jobCodes = new Set<String>(n.Job_Codes__c.split(';'));
			Set<String> procLevels = new Set<String>(n.Process_Levels__c.split(';'));
			
			Boolean jobCodePass = false;
			Boolean procLevelPass  = false;
			for(String pName :permissionSetNames)
			{
				if(jobCodes.contains('All') || jobCodes.contains(pName) || jobCodePass == true)
				{
					jobCodePass = true;
				}
				if(procLevels.contains('All') || procLevels.contains(pName) || procLevelPass == true)
				{
					procLevelPass = true;
				}
			}
			if(jobCodePass && procLevelPass)
				filteredNotifications.add(n.Notification__c);
		}
		return filteredNotifications;
	}
}