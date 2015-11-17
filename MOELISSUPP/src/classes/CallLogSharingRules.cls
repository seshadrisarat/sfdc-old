public class CallLogSharingRules 
{
	public static boolean UpdateShare(	List<Id> CallLogToUpdate)
	{
		Map<Id, Set<Id>> Map_CallLogId_SetUserId = new Map<Id, Set<Id>> ();

		system.debug('CallLogToUpdate -------------------------->'+CallLogToUpdate);
		for (Id itemId : CallLogToUpdate) Map_CallLogId_SetUserId.put(itemId, new Set<Id>());
		
		/* 
		If an assistant is assigned to an employee record and that employee is assigned to a Call Log, 
		then the manual sharing rule needs to be set for employee user id, and assistant's user id. 
		*/
		for(Call_Log__c item :[	SELECT Id, Organizer__r.User_ID__c,Organizer__r.User_ID__r.IsActive, Organizer__c,Organizer__r.Assistant__c,Organizer__r.Assistant__r.User_ID__c,Organizer__r.Assistant__r.User_ID__r.IsActive
								FROM Call_Log__c
								WHERE Id IN : CallLogToUpdate])
		{
			system.debug('item.Organizer__r.User_ID__c--------->'+item.Organizer__r.User_ID__c);
			system.debug('item.Organizer__r.Assistant__r.User_ID__c--------->'+item.Organizer__r.Assistant__r.User_ID__c);
			if(item.Organizer__r.User_ID__c != null && item.Organizer__r.User_ID__r.IsActive)Map_CallLogId_SetUserId.get(item.Id).add(item.Organizer__r.User_ID__c);
			if(item.Organizer__r.Assistant__r.User_ID__c != null && item.Organizer__r.Assistant__r.User_ID__r.IsActive)Map_CallLogId_SetUserId.get(item.Id).add(item.Organizer__r.Assistant__r.User_ID__c);
		}
		
		/*
		Call Log Moelis Attendees:
   		1. Call Log 1 - Employee 1 - User ID 1 -> Add/Delete Manual Sharing Rule to allow User ID 1 Read/Write access to Call Log 1
   		2. If Employee 1 has assistant (Employee A1 - User ID A1) -> Add/Delete Manual Sharing Rule to allow User ID A Read/Write access to Call Log 1
		*/
		for(Call_Log_Moelis_Attendee__c item :[	SELECT Id,Employee__r.User_ID__c,Employee__r.User_ID__r.IsActive, Employee__c, Call_Log__c,Employee__r.Assistant__c,Employee__r.Assistant__r.User_ID__c,Employee__r.Assistant__r.User_ID__r.IsActive
										FROM Call_Log_Moelis_Attendee__c
										WHERE Call_Log__c IN : CallLogToUpdate])
		{
			if(item.Employee__r.User_ID__c != null && item.Employee__r.User_ID__r.IsActive)Map_CallLogId_SetUserId.get(item.Call_Log__c).add(item.Employee__r.User_ID__c);
			if(item.Employee__r.Assistant__r.User_ID__c != null && item.Employee__r.Assistant__r.User_ID__r.IsActive)Map_CallLogId_SetUserId.get(item.Call_Log__c).add(item.Employee__r.Assistant__r.User_ID__c);
		}
		
		/* A "Call Log" is related to a "Deal" must be accessible to the "Deal Team Members". */
		Map<Id, Set<Id>> Map_DealId_SetCallLogId = new Map<Id, Set<Id>>();
		Set<Id> SetDealId = new Set<Id>();
		for(Call_Log_Deal__c item :[	SELECT Deal__c, Call_Log__c
										FROM Call_Log_Deal__c
										WHERE Call_Log__c IN : CallLogToUpdate])
		{
        	//Map_DealId_CallLogId.put(item.Deal__c,item.Call_Log__c);
        	if (Map_DealId_SetCallLogId.containsKey(item.Deal__c))	Map_DealId_SetCallLogId.get(item.Deal__c).add(item.Call_Log__c);
        	else 
        	{
        		Set<ID> tmp1 = new Set<ID>();
        		tmp1.add(item.Call_Log__c);
        		Map_DealId_SetCallLogId.put(item.Deal__c,tmp1);
        	}
			SetDealId.add(item.Deal__c);
		}
		system.debug('SetDealId -------------------------->'+SetDealId);
		for(Project_Resource__c item :[	SELECT Project__c, Banker__r.User_ID__c, Banker__c,Banker__r.User_ID__r.IsActive
											FROM Project_Resource__c
											WHERE Project__c IN : SetDealId])
		{
			
			if(item.Banker__r.User_ID__c != null && item.Banker__r.User_ID__r.IsActive)
			{ 
				for(Id CallLogId : Map_DealId_SetCallLogId.get(item.Project__c))	Map_CallLogId_SetUserId.get(CallLogId).add(item.Banker__r.User_ID__c);
			}
		}
		
		
		Map<Id,Id> Map_ParentId_UserOwnerId = new Map<Id,Id>();
		List<Call_Log__Share> sharesForDelete = new List<Call_Log__Share>();
		for(Call_Log__Share item : [
			SELECT Id, UserOrGroupId, ParentId,RowCause
			FROM Call_Log__Share 
			WHERE ParentId IN :Map_CallLogId_SetUserId.KeySet() AND (RowCause = 'Manual' OR RowCause = 'Owner')]) 
		{
			if (item.RowCause == 'Manual') sharesForDelete.add(item);
			if (item.RowCause == 'Owner') Map_ParentId_UserOwnerId.put(item.ParentId,item.UserOrGroupId); 
		}
		//system.debug('sharesForDelete.size===' + sharesForDelete.size());
		if(sharesForDelete.size() > 0)delete sharesForDelete;
		
		List<Call_Log__Share> sharesForInsert = new List<Call_Log__Share>();
		for(Id CallLog_Id : Map_CallLogId_SetUserId.KeySet())
		{
			system.debug('CallLog_Id-------------->'+CallLog_Id);
			for(Id UserId : Map_CallLogId_SetUserId.get(CallLog_Id))
			{
				system.debug('UserId-------------->'+UserId);
				if(Map_ParentId_UserOwnerId.get(CallLog_Id) != UserId)
				{
					Call_Log__Share itemShare = new Call_Log__Share();
					itemShare.UserOrGroupId = UserId;
					itemShare.ParentId      = CallLog_Id;
					itemShare.AccessLevel   = 'Edit';
					itemShare.RowCause      = 'Manual';
					sharesForInsert.add(itemShare);
				}
			}
		}
		
		
		system.debug('CallLogToUpdate.size()--------------->'+CallLogToUpdate.size());
		system.debug('sharesForInsert.size()--------------->'+sharesForInsert.size());
		if(sharesForInsert.size() > 0) insert sharesForInsert;
		
		return true;
	}
/*
	public static void Set_UpdateCallLogSharing_True(List<Id> List_CallLogId) 
	{
		system.debug('List_CallLogId------------>'+List_CallLogId);
		List<Call_Log__c> List_CallLog_To_UpdateCallLogSharing = new List<Call_Log__c>();
		for(Call_Log__c item :[	SELECT Id,Update_CallLog_Sharing__c
								FROM Call_Log__c
								WHERE Id IN : List_CallLogId])
		{
			item.Update_CallLog_Sharing__c = true;
			List_CallLog_To_UpdateCallLogSharing.add(item);
		}

		system.debug('List_CallLog_To_UpdateCallLogSharing------------>'+List_CallLog_To_UpdateCallLogSharing);
		if(List_CallLog_To_UpdateCallLogSharing.size() > 0) update List_CallLog_To_UpdateCallLogSharing;	
	}
	*/
}