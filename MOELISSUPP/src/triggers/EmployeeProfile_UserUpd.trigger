trigger EmployeeProfile_UserUpd on Employee_Profile__c (before delete, before insert, before update)  
{
	/* sharing for Deal*/
	//DealSharingRules.shareFrom_EmployeeProfile(Trigger.oldMap, Trigger.old, Trigger.new, Trigger.isUpdate, Trigger.isDelete);
	/*
	
	// sharing for Potential Buyer/Investor
	Set<Id> List_Employee = new Set<Id>();
	List<Employee_Profile__c> Trigger_list;
	if(trigger.isInsert || trigger.isUpdate) Trigger_list = Trigger.new;
	if(trigger.isDelete) Trigger_list = Trigger.old;
	Boolean isFireTrigger = false;
	Id oneUser_Id;
	Id secondUser_Id;
	Id oneAssistant_Id;
	Id secondAssistant_Id;
	for (Employee_Profile__c item : Trigger_list) 
	{
		oneUser_Id = null;
		oneAssistant_Id = null;
		secondUser_Id = null;
		secondAssistant_Id = null;
		if(trigger.isInsert || trigger.isUpdate) 
		{
			oneUser_Id = Trigger.newMap.get(item.Id).User_ID__c;
			oneAssistant_Id = Trigger.newMap.get(item.Id).Assistant__c;
		}
		if(trigger.isDelete || trigger.isUpdate) 
		{
			secondUser_Id = Trigger.oldMap.get(item.Id).User_ID__c;
			secondAssistant_Id = Trigger.oldMap.get(item.Id).Assistant__c;
		}	
		system.debug('oneUser_Id----------------------->'+oneUser_Id);
		system.debug('secondUser_Id----------------------->'+secondUser_Id);
		if (oneUser_Id != secondUser_Id || oneAssistant_Id != secondAssistant_Id) 
		{	
			isFireTrigger = true;
			List_Employee.add(item.Id);	
		}
		
	}
	system.debug('List_Employee----------------------->'+List_Employee);
	system.debug('isFireTrigger----------------------->'+isFireTrigger);
	if (isFireTrigger) 
	{
		List<Id> List_PBI_Id = new List<Id>();
		for(Potential_Buyer_Investor_Deal_Team__c item :[	
				SELECT Id,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c, Target_Buyer__c
				FROM Potential_Buyer_Investor_Deal_Team__c
				WHERE Banker__c IN : List_Employee ])
		{
				if(List_Employee.contains(item.Banker__c) && item.Banker__r.User_ID__r.IsActive )List_PBI_Id.add(item.Target_Buyer__c);
		}
		if(List_PBI_Id.size() > 0)PBISharingRules.Set_UpdatePBISharing_True(List_PBI_Id);
	}
	*/
}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*
	
	
	
	//without bulk
	for (Employee_Profile__c epItem : Trigger.new) {
		
		Employee_Profile__c newEmployee = epItem;
		Employee_Profile__c oldEmployee = Trigger.oldMap.get(epItem.Id);
		
		if (oldEmployee.User_ID__c != newEmployee.User_ID__c) {

			// fetching new user's isActivity
			User oldUser = [SELECT Name, isActive FROM User WHERE Id = :oldEmployee.User_ID__c limit 1];
			User newUser = [SELECT Name, isActive FROM User WHERE Id = :newEmployee.User_ID__c limit 1];
			system.debug('oldUserName===' + newUser.Name);
			system.debug('newUserName===' + oldUser.Name);

			// fetching projects of current employee
			List<Id> projectIdList = new List<Id>();
			for(Project_Resource__c item : [
				SELECT Project__c, Banker__c 
				FROM Project_Resource__c 
				WHERE Banker__c = :newEmployee.Id]) 
			projectIdList.add(item.Project__c);
			system.debug('projectIdList.size===' + projectIdList.size());
			
			// deleting project shares for old user
			List<Ibanking_Project__Share> sharesForDelete = [
				SELECT Id 
				FROM Ibanking_Project__Share 
				WHERE ParentId in :projectIdList 
			and UserOrGroupId = :oldEmployee.User_ID__c];
			system.debug('sharesForDelete.size===' + sharesForDelete.size());
			delete sharesForDelete;
			
			
			// creating project shares for new user
			if (newUser.IsActive) {
				List<Ibanking_Project__Share> sharingRulesForInsert = new List<Ibanking_Project__Share>();
				for(Id deal_Id : projectIdList) {
					Ibanking_Project__Share memberShare = new Ibanking_Project__Share();
					memberShare.UserOrGroupId = newEmployee.User_ID__c;
					memberShare.ParentId      = deal_Id;
					memberShare.AccessLevel   = 'Edit';
					memberShare.RowCause      = 'Manual';
					sharingRulesForInsert.add(memberShare);
				}
				system.debug('sharingRulesForInsert.size===' + sharingRulesForInsert);
				insert sharingRulesForInsert;
			}
		}
	}
	*/
	/*
class EmployeeParams {
	public EmployeeParams() {
		this.projectIdSet = new Set<Id>();
	}
	//public Id newUserId {get;set;}
	//public Id oldUserId {get;set;}
	public Set<Id> projectIdSet {get;set;}
}
*/



/*
	{ // ================== USER ACTIVE UPDATE FUNCTIONALITY =========================
		//List<Employee_Profile__c> List_employeeProfileForHandling = new List<Employee_Profile__c>();
		
		Map<Id, Id> Map_EmployeeProfileId_UserId = new Map<Id, Id>();
		
		for(Employee_Profile__c item : Trigger.new) {
			if (item.User_Active_Update__c == true) {
				//List_employeeProfileForHandling.add(item);
				Map_EmployeeProfileId_UserId.put(item.Id, item.User_ID__c);
				item.User_Active_Update__c = false;
			}
		}
		
		Map<Id, Set<Id>> Map_UserId_DealIdSet = new Map<Id, Set<Id>>();
	
		Id userId;
		for(Project_Resource__c item : [
			SELECT Project__c, Banker__c 
			FROM Project_Resource__c 
			WHERE Banker__c in :Map_EmployeeProfileId_UserId.keySet()]) 
		{
			userId = Map_EmployeeProfileId_UserId.get(item.Banker__c);
			if (Map_UserId_DealIdSet.containsKey(userId) == false)
				Map_UserId_DealIdSet.put(userId, new Set<Id>());
			Map_UserId_DealIdSet.get(userId).add(item.Project__c);
		}
		
		for(Ibanking_Project__Share item : [
			SELECT ParentId, UserOrGroupId 
			FROM Ibanking_Project__Share 
			WHERE UserOrGroupId in :Map_UserId_DealIdSet.keySet()]) 
		{
			Map_UserId_DealIdSet.get(item.UserOrGroupId).remove(item.ParentId);
		}
		
	
		List<Ibanking_Project__Share> sharingRulesForInsert = new List<Ibanking_Project__Share>();
		for(Id user_Id : Map_UserId_DealIdSet.keySet()) {
			for(Id deal_Id : Map_UserId_DealIdSet.get(user_Id)) {
				Ibanking_Project__Share memberShare = new Ibanking_Project__Share();
				memberShare.UserOrGroupId = user_Id;
				memberShare.ParentId      = deal_Id;
				memberShare.AccessLevel   = 'Edit';
				memberShare.RowCause      = 'Manual';
				sharingRulesForInsert.add(memberShare);
			}
		}
	
	    insert sharingRulesForInsert;
	} // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	
*/