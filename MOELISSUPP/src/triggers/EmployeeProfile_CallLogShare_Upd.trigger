trigger EmployeeProfile_CallLogShare_Upd on Employee_Profile__c (before delete, before insert, before update) 
{
	/*
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
		if(trigger.isDelete)
		{
			List<Project_Resource__c> List_To_delete = new List<Project_Resource__c>();
			for(Project_Resource__c item : [	SELECT Id	FROM Project_Resource__c WHERE Banker__c IN : List_Employee])	List_To_delete.add(item);
			if(List_To_delete.size() > 0 ) delete List_To_delete; 
		}
		else
		{
			List<Id> List_CallLogId = new List<Id>();
			for(Call_Log__c item :[	SELECT Id, Organizer__r.User_ID__c,Organizer__r.User_ID__r.IsActive, Organizer__c,Organizer__r.Assistant__c,Organizer__r.Assistant__r.User_ID__c,Organizer__r.Assistant__r.User_ID__r.IsActive
									FROM Call_Log__c
									WHERE Organizer__c IN : List_Employee OR Organizer__r.Assistant__c IN : List_Employee])
			{
				if(List_Employee.contains(item.Organizer__c) && item.Organizer__r.User_ID__r.IsActive )List_CallLogId.add(item.Id);
				if(List_Employee.contains(item.Organizer__r.Assistant__c) && item.Organizer__r.Assistant__r.User_ID__r.IsActive )List_CallLogId.add(item.Id);
			}
			for(Call_Log_Moelis_Attendee__c item :[	SELECT Id,Employee__r.User_ID__c,Employee__r.User_ID__r.IsActive, Employee__c, Call_Log__c,Employee__r.Assistant__c,Employee__r.Assistant__r.User_ID__c,Employee__r.Assistant__r.User_ID__r.IsActive
											FROM Call_Log_Moelis_Attendee__c
											WHERE Employee__c IN : List_Employee OR Employee__r.Assistant__c IN : List_Employee ])
			{
				if(List_Employee.contains(item.Employee__c) && item.Employee__r.User_ID__r.IsActive )List_CallLogId.add(item.Call_Log__c);
				if(List_Employee.contains(item.Employee__r.Assistant__c) && item.Employee__r.Assistant__r.User_ID__r.IsActive )List_CallLogId.add(item.Call_Log__c);
			}
			List<Id> List_DealId = new List<Id>();
			for(Project_Resource__c item :[	SELECT Project__c,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c 
											FROM Project_Resource__c
											WHERE Banker__c IN : List_Employee])
			{
				if(item.Banker__r.User_ID__r.IsActive)  List_DealId.add(item.Project__c);
			}
			for(Call_Log_Deal__c item :[	SELECT Deal__c, Call_Log__c
											FROM Call_Log_Deal__c
											WHERE Deal__c IN :List_DealId])
			{
	        	List_CallLogId.add(item.Call_Log__c);
			}
			
			if(List_CallLogId.size() > 0)CallLogSharingRules.Set_UpdateCallLogSharing_True(List_CallLogId);
		}
	}
	
	/////////////////////////////////////////////////////////////////////////////////////////
	
	
	
	Map<Id, Set<Id>> Map_EmployeeId_EmployeeParams = new Map<Id, Set<Id>>();
	Map<Id, Id> Map_oldUserId_EmployeeId = new Map<Id, Id>();
	Map<Id, Id> Map_newUserId_EmployeeId = new Map<Id, Id>();
	
	Id newUser_Id;
	Id oldUser_Id;
	Id newAssistant_Id;
	Id oldAssistant_Id;
		
	Map<Id, Set<Id>> Map_EmployeeId_newEmployeeAssistantParams = new Map<Id, Set<Id>>();
	Map<Id, Set<Id>> Map_EmployeeId_oldEmployeeAssistantParams = new Map<Id, Set<Id>>();
	Set<Id> List_EmployeeId = new Set<Id>();
	Map<Id,Id> Map_EmployeeId_newAssistantId = new Map<Id,Id>();
	Map<Id,Id> Map_EmployeeId_oldAssistantId = new Map<Id,Id>();
	
	for (Employee_Profile__c epItem : Trigger.new) 
	{
		newUser_Id = epItem.User_ID__c;
		oldUser_Id = Trigger.oldMap.get(epItem.Id).User_ID__c;
		if (newUser_Id != oldUser_Id) {
			Map_EmployeeId_EmployeeParams.put(epItem.Id, new Set<Id>());
			Map_newUserId_EmployeeId.put(newUser_Id, epItem.Id);
			Map_oldUserId_EmployeeId.put(oldUser_Id, epItem.Id);
		}
		//MOELIS-24: Employee assistant should be in CallLogShare
		newAssistant_Id = Trigger.newMap.get(epItem.Id).Assistant__c;
		oldAssistant_Id = Trigger.oldMap.get(epItem.Id).Assistant__c;
		if(newAssistant_Id != oldAssistant_Id)
		{
			List_EmployeeId.add(epItem.Id);
			if(newAssistant_Id != null)
			{
				Map_EmployeeId_newAssistantId.put(epItem.Id,newAssistant_Id);
				Map_EmployeeId_newEmployeeAssistantParams.put(newAssistant_Id, new Set<Id>());
			}
			if(oldAssistant_Id != null)
			{
				Map_EmployeeId_oldAssistantId.put(epItem.Id,oldAssistant_Id);
				Map_EmployeeId_oldEmployeeAssistantParams.put(oldAssistant_Id, new Set<Id>());
			}
		}
		//MOELIS-24: end
		
	}
	//system.debug('Map_EmployeeId_EmployeeParams===' + Map_EmployeeId_EmployeeParams);
	//system.debug('Map_newUserId_EmployeeId===' + Map_newUserId_EmployeeId);
	//system.debug('Map_oldUserId_EmployeeId===' + Map_oldUserId_EmployeeId);




	Map<Id, User> Map_UserId_User = new Map<Id, User>([
		SELECT ID, Name, isActive 
		FROM User 
		WHERE Id in :Map_oldUserId_EmployeeId.keySet() or Id in :Map_newUserId_EmployeeId.keySet()]);
	//system.debug('Map_UserId_User===' + Map_UserId_User);
	
	List<Call_Log_Moelis_Attendee__c> CLMAList = [
		SELECT Call_Log__c, Employee__c 
		FROM Call_Log_Moelis_Attendee__c
		WHERE Employee__c in :Map_EmployeeId_EmployeeParams.keySet()];
	//system.debug('CLMAList===' + CLMAList);
	
	List<Id> CallLogIdList = new List<Id>();
	for(Call_Log_Moelis_Attendee__c item : CLMAList) {
		Map_EmployeeId_EmployeeParams.get(item.Employee__c).add(item.Call_Log__c);
		CallLogIdList.add(item.Call_Log__c);
	} 
	//system.debug('CallLogIdList===' + CallLogIdList);
	
	// MOELIS-24:	if this employee is assistant for an other employee. we should add him to the CallLogShare of parent employee 
	//CallLogs where organizer assistant 
	for (Call_Log__c clItem : [SELECT Id,Organizer__r.Assistant__c FROM Call_Log__c WHERE Organizer__r.Assistant__c IN : Map_EmployeeId_EmployeeParams.keySet()]) 
	{
		Map_EmployeeId_EmployeeParams.get(clItem.Organizer__r.Assistant__c).add(clItem.Id);
		CallLogIdList.add(clItem.Id);
	}
	//system.debug('CallLogIdList===' + CallLogIdList);
	// END MOELIS-24:
	
	// exclude users of Employee of Call_Log_Moelis_Attendee__c
	Map<Id, Set<Id>> Map_EployeeUserId_CallLogList0 = getMap_EployeeUserId_CallLogList(CallLogIdList);
	
	// deleting shares for old user
	List<Call_Log__Share> sharesForDelete = new List<Call_Log__Share>();
	for(Call_Log__Share item : [
		SELECT Id, UserOrGroupId, ParentId
		FROM Call_Log__Share 
		WHERE (UserOrGroupId in :Map_oldUserId_EmployeeId.keySet() or UserOrGroupId in :Map_newUserId_EmployeeId.keySet()) 
			and ParentId in :CallLogIdList
			and RowCause      = 'Manual']) 
	{
		//RowCause != 'Owner' AND 
		if(	item.UserOrGroupId != null && item.ParentId != null && Map_oldUserId_EmployeeId.containsKey(item.UserOrGroupId) && 
			Map_EmployeeId_EmployeeParams.containsKey(Map_oldUserId_EmployeeId.get(item.UserOrGroupId)) && 
			Map_EmployeeId_EmployeeParams.get(Map_oldUserId_EmployeeId.get(item.UserOrGroupId)).contains(item.ParentId)
		) 
		{
			 // exclude users of Employee of Call_Log_Moelis_Attendee__c 
			if (Map_EployeeUserId_CallLogList0.get(item.UserOrGroupId) == null || Map_EployeeUserId_CallLogList0.get(item.UserOrGroupId) != null && !Map_EployeeUserId_CallLogList0.get(item.UserOrGroupId).contains(item.ParentId) )
				sharesForDelete.add(item);
		}
	}
	//system.debug('sharesForDelete.size===' + sharesForDelete.size());
	delete sharesForDelete;
	
	List<Id> userIdList_ForInsert = new List<Id>();
	for(Id idItem : Map_newUserId_EmployeeId.keySet()) 
		if (Map_UserId_User.get(idItem).IsActive == true) 
			userIdList_ForInsert.add(idItem);
	// creating project shares for new user
	List<Call_Log__Share> sharesForInsert = new List<Call_Log__Share>();
	for(Id new_UserId : userIdList_ForInsert) 
	{
		//system.debug('new_UserId='+new_UserId);
		//system.debug('Map_newUserId_EmployeeId.get(new_UserId) --------->'+Map_newUserId_EmployeeId.get(new_UserId));
		if ( Map_EmployeeId_EmployeeParams.get(Map_newUserId_EmployeeId.get(new_UserId)) != null)
		{
			for(Id Call_LogId : Map_EmployeeId_EmployeeParams.get(Map_newUserId_EmployeeId.get(new_UserId))) 
			{
				Call_Log__Share memberShare = new Call_Log__Share();
				memberShare.UserOrGroupId = newUser_Id;
				memberShare.ParentId      = Call_LogId;
				memberShare.AccessLevel   = 'Edit';
				memberShare.RowCause      = 'Manual';
				sharesForInsert.add(memberShare);
			}
		}
	}
	//system.debug('sharesForInsert.size===' + sharesForInsert.size());
	insert sharesForInsert;
	
	
	
	
	
	
	//MOELIS-24:
	Map<Id, Id> Map_oldAssistantUserId_EmployeeId = new Map<Id, Id>();
	Map<Id, Id> Map_newAssistantUserId_EmployeeId = new Map<Id, Id>();
	Map<Id, Id> Map_newAssistantUserIdisActive_EmployeeId = new Map<Id, Id>();
	for (Employee_Profile__c EP_Item : [
			SELECT Id,User_ID__c, User_ID__r.isActive
			FROM Employee_Profile__c
			WHERE Id IN : Map_EmployeeId_newAssistantId.values()]) 
	{
		Map_newAssistantUserId_EmployeeId.put(EP_Item.User_ID__c, EP_Item.Id);
		if(EP_Item.User_ID__r.isActive)Map_newAssistantUserIdisActive_EmployeeId.put(EP_Item.User_ID__c, EP_Item.Id);
	}
	
	for (Employee_Profile__c EP_Item : [
			SELECT Id,User_ID__c, User_ID__r.isActive
			FROM Employee_Profile__c
			WHERE Id IN :Map_EmployeeId_oldAssistantId.values()]) 
	{
		Map_oldAssistantUserId_EmployeeId.put(EP_Item.User_ID__c,  EP_Item.Id);
	}
	
	system.debug('Map_newAssistantUserId_EmployeeId==' + Map_newAssistantUserId_EmployeeId);
	system.debug('Map_oldAssistantUserId_EmployeeId===' + Map_oldAssistantUserId_EmployeeId);
	List<Id> CallLogIdForAssistantList = new List<Id>();
	for (Call_Log__c clItem : [
			SELECT Id,Organizer__c,Organizer__r.Assistant__c
			FROM Call_Log__c 
			 WHERE Organizer__c IN : List_EmployeeId	
			])
	{
		if( Map_EmployeeId_newAssistantId.get(clItem.Organizer__c) == clItem.Organizer__r.Assistant__c && 
			Map_EmployeeId_newAssistantId.get(clItem.Organizer__c) != null && 
			Map_EmployeeId_newEmployeeAssistantParams.get(Map_EmployeeId_newAssistantId.get(clItem.Organizer__c)) != null
		)
				Map_EmployeeId_newEmployeeAssistantParams.get(Map_EmployeeId_newAssistantId.get(clItem.Organizer__c)).add(clItem.Id);
		if(//Map_EmployeeId_oldAssistantId.get(clItem.Organizer__c) == clItem.Organizer__r.Assistant__c && 
			Map_EmployeeId_oldAssistantId.get(clItem.Organizer__c) != null && 
			Map_EmployeeId_oldEmployeeAssistantParams.get(Map_EmployeeId_oldAssistantId.get(clItem.Organizer__c)) != null
		)
				Map_EmployeeId_oldEmployeeAssistantParams.get(Map_EmployeeId_oldAssistantId.get(clItem.Organizer__c)).add(clItem.Id);
		CallLogIdForAssistantList.add(clItem.Id);
	}

	system.debug('Map_EmployeeId_newEmployeeAssistantParams===' + Map_EmployeeId_newEmployeeAssistantParams);
	system.debug('Map_EmployeeId_oldEmployeeAssistantParams===' + Map_EmployeeId_oldEmployeeAssistantParams);
	system.debug('CallLogIdForAssistantList===' + CallLogIdForAssistantList);
	//system.debug('Map_newAssistantUserId_EmployeeId.===' + Map_newAssistantUserId_EmployeeId);
	//system.debug('Map_oldAssistantUserId_EmployeeId.===' + Map_oldAssistantUserId_EmployeeId);

	// exclude users of Employee of Call_Log_Moelis_Attendee__c
	Map<Id, Set<Id>> Map_EployeeUserId_CallLogList = getMap_EployeeUserId_CallLogList(CallLogIdForAssistantList);
	system.debug('Map_EployeeUserId_CallLogList===' + Map_EployeeUserId_CallLogList);
	
	
	

	// deleting shares for old Assistant user 
	List<Call_Log__Share> sharesAssistantForDelete = new List<Call_Log__Share>();
	for(Call_Log__Share item : [
		SELECT Id, UserOrGroupId, ParentId
		FROM Call_Log__Share 
		WHERE (UserOrGroupId in :Map_oldAssistantUserId_EmployeeId.keySet() or UserOrGroupId in :Map_newAssistantUserId_EmployeeId.keySet()) 
			and ParentId IN :CallLogIdForAssistantList
			and RowCause      = 'Manual']) 
	{
		if(item.UserOrGroupId != null && item.ParentId != null && 
			Map_oldAssistantUserId_EmployeeId.containsKey(item.UserOrGroupId) && 
			Map_EmployeeId_oldEmployeeAssistantParams.containsKey(Map_oldAssistantUserId_EmployeeId.get(item.UserOrGroupId)) && 
		    Map_EmployeeId_oldEmployeeAssistantParams.get(Map_oldAssistantUserId_EmployeeId.get(item.UserOrGroupId)).contains(item.ParentId) 
		    ) 
		{
			 // exclude users of Employee of Call_Log_Moelis_Attendee__c 
			if (Map_EployeeUserId_CallLogList.get(item.UserOrGroupId) == null || Map_EployeeUserId_CallLogList.get(item.UserOrGroupId) != null && !Map_EployeeUserId_CallLogList.get(item.UserOrGroupId).contains(item.ParentId) )
				sharesAssistantForDelete.add(item);
		}
	}
	//system.debug('sharesAssistantForDelete.size===' + sharesAssistantForDelete.size());
	system.debug('sharesAssistantForDelete===' + sharesAssistantForDelete);
	if(sharesAssistantForDelete.size() > 0)delete sharesAssistantForDelete;
	
	// Insert shares for new Assistant user 
	List<Call_Log__Share> sharesAssistantForInsert = new List<Call_Log__Share>();
	for(Id new_UserId : Map_newAssistantUserIdisActive_EmployeeId.KeySet()) 
	{
		if ( Map_EmployeeId_newEmployeeAssistantParams.get(Map_newAssistantUserIdisActive_EmployeeId.get(new_UserId)) != null)
		{
			for(Id Call_LogId : Map_EmployeeId_newEmployeeAssistantParams.get(Map_newAssistantUserIdisActive_EmployeeId.get(new_UserId))) 
			{
				Call_Log__Share memberShare = new Call_Log__Share();
				memberShare.UserOrGroupId = new_UserId;
				memberShare.ParentId      = Call_LogId;
				memberShare.AccessLevel   = 'Edit';
				memberShare.RowCause      = 'Manual';
				sharesAssistantForInsert.add(memberShare);
			}
		}
	}
	//system.debug('sharesAssistantForInsert.size===' + sharesAssistantForInsert.size());
	system.debug('sharesAssistantForInsert===' + sharesAssistantForInsert);
	if(sharesAssistantForInsert.size() >0)insert sharesAssistantForInsert;



    private Map<Id, Set<Id>>  getMap_EployeeUserId_CallLogList(List<Id> varCallLogIdList)
    {
		Map<Id, Set<Id>> varMap_EployeeUserId_CallLogList = new Map<Id, Set<Id>>();
	   for(Call_Log_Moelis_Attendee__c item : [
			SELECT Call_Log__c, Employee__c, Employee__r.User_ID__c
			FROM Call_Log_Moelis_Attendee__c
			WHERE Call_Log__c IN : varCallLogIdList
			])
		{
			if (varMap_EployeeUserId_CallLogList.containsKey(item.Employee__r.User_ID__c))	varMap_EployeeUserId_CallLogList.get(item.Employee__r.User_ID__c).add(item.Call_Log__c);
	        else 
	        {
	        	Set<ID> tmp1 = new Set<ID>();
	        	tmp1.add(item.Call_Log__c);
	        	varMap_EployeeUserId_CallLogList.put(item.Employee__r.User_ID__c,tmp1);
	        }
		}
		return varMap_EployeeUserId_CallLogList;
    }
*/
}