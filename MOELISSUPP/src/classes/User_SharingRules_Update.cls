/**
* Test methods are in Test_Sharing.cls
**/

/*

Created: Ekrivobok 02/23/2010 - task: 927 
Modified: Ekrivobok 04/08/2010 - task: 10107

*/

global class User_SharingRules_Update{
	
	public static void updateSharingRules_Bulk(Map<Id, Employee_Profile__c> Map_epId_ep) { 

		system.debug('Map_epId_ep=====' + Map_epId_ep);
		
		deletingNeededSharingRules(Map_epId_ep);

		// fetching Map_epId_ep_ForSharing
		Map<Id, Employee_Profile__c> Map_epId_ep_ForSharing = new Map<Id, Employee_Profile__c>();
		for(Employee_Profile__c item : Map_epId_ep.values())
			if (item.Status__c == 'Active')
				Map_epId_ep_ForSharing.put(item.Id, item);
				
		system.debug('Map_epId_ep_ForSharing=====' + Map_epId_ep_ForSharing);
		
		if (Map_epId_ep_ForSharing.size() == 0) {
			// fetching Map_epId_ListOfDealId_ForSharing
			Map<Id, List<Id>> Map_epId_ListOfDealId_ForSharing = new Map<Id, List<Id>>();
			for(Project_Resource__c item : [
				SELECT Project__c, Banker__c 
				FROM Project_Resource__c 
				WHERE Banker__c in :Map_epId_ep_ForSharing.keySet()])
			{
				if (!Map_epId_ListOfDealId_ForSharing.containsKey(item.Banker__c)) 
					Map_epId_ListOfDealId_ForSharing.put(item.Banker__c, new List<Id>());
				Map_epId_ListOfDealId_ForSharing.get(item.Banker__c).add(item.Project__c);
			}
	    	
	    	system.debug('Map_epId_ListOfDealId_ForSharing=====' + Map_epId_ListOfDealId_ForSharing);
	
			// creating sharing rules
			List<Ibanking_Project__Share> sharingRulesForInsert = new List<Ibanking_Project__Share>();
			List<Id> curListOfProjectId;
			Id curUserId;
			for(Id curEpId : Map_epId_ListOfDealId_ForSharing.keySet()) {
				curUserId = Map_epId_ep_ForSharing.get(curEpId).User_ID__c;
				for(Id curDealId : Map_epId_ListOfDealId_ForSharing.get(curEpId)) {
					Ibanking_Project__Share memberShare = new Ibanking_Project__Share();
					memberShare.UserOrGroupId = curUserId;
					memberShare.ParentId      = curDealId; 
					memberShare.AccessLevel   = 'Edit';
					memberShare.RowCause      = 'Manual';
					sharingRulesForInsert.add(memberShare);
				}
			}
	
			system.debug('sharingRulesForInsert.size()===' + sharingRulesForInsert.size());
			
			system.debug('sharingRulesForInsert=====' + sharingRulesForInsert);
			
		    insert sharingRulesForInsert;
		}
	}
	

	private static void deletingNeededSharingRules(Map<Id, Employee_Profile__c> Map_epId_ep) {
		// fetching UserIds
		Set<Id> userIdSet = new Set<Id>();
		for(Employee_Profile__c item : Map_epId_ep.values()) userIdSet.add(item.User_ID__c);
		
		system.debug('userIdSet=====' + userIdSet);

		// fetching Map_UserId_SetOfDealId
		// fetching DealIds
		Map<Id, Set<Id>> Map_UserId_SetOfDealId = new Map<Id, Set<Id>>();
		Set<Id> dealIdSet = new Set<Id>();
		Id curUserId;
		for(Project_Resource__c item : [
			SELECT Project__c, Banker__c 
			FROM Project_Resource__c 
			WHERE Banker__c in :Map_epId_ep.keySet()])
		{
			curUserId = Map_epId_ep.get(item.Banker__c).User_ID__c;
			if (!Map_UserId_SetOfDealId.containsKey(curUserId)) Map_UserId_SetOfDealId.put(curUserId, new Set<Id>());
			Map_UserId_SetOfDealId.get(curUserId).add(item.Project__c);
			dealIdSet.add(item.Project__c);
		}
		
		system.debug('dealIdSet=====' + dealIdSet);
		system.debug('Map_UserId_SetOfDealId=====' + Map_UserId_SetOfDealId);

		// delete share for all users
		List<Ibanking_Project__Share> sharesForDelete = new List<Ibanking_Project__Share>();
		for(Ibanking_Project__Share item : [SELECT ParentId, UserOrGroupId FROM Ibanking_Project__Share WHERE ParentId in :dealIdSet AND UserOrGroupId in :userIdSet AND RowCause = 'Manual']) {
			if (Map_UserId_SetOfDealId.containsKey(item.UserOrGroupId) && Map_UserId_SetOfDealId.get(item.UserOrGroupId).contains(item.ParentId))
				sharesForDelete.add(item);
		}
		
		system.debug('sharesForDelete=====' + sharesForDelete);
		
		delete sharesForDelete;
	}
	
	
	
	
	
    WebService static String updateSharingRules(String userId) 
    {
    	String userName = '';
    	Boolean isActive = false;
    	for(User item : [SELECT Id, Name, isActive FROM User WHERE Id = :userId limit 1]) {
    		userName = item.Name;
    		isActive = item.IsActive;
    	}
		if (!isActive) return 'The User ' + userName + ' must be Active prior to updating the sharing rules. Please activate the User.';
		
		List<Id> List_dealId = new List<Id>();

		for(Project_Resource__c item :[	SELECT Id,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c, Project__c
										FROM Project_Resource__c
										WHERE Banker__r.User_ID__c  = :userId ])
		{
			if(item.Banker__r.User_ID__r.IsActive )List_dealId.add(item.Project__c);
		}

		List<Schedule_Data__c> List_toInsert = new List<Schedule_Data__c>();
		if(List_dealId.size() > 0)
		{
			for(Id itemId : List_dealId)
			{
				Schedule_Data__c newSD = new Schedule_Data__c();
				newSD.Object_Id__c = itemId;
				newSD.Type__c = 'Deal';
				List_toInsert.add(newSD);
			}
		}
		if(List_toInsert.size() > 0) insert List_toInsert;
    	return 'Deal Sharing Rules for the ' + userName + ' user were created.';
    	
    	/*
		// fetching user name
    	String userName = '';
    	Boolean isActive = false;
    	for(User item : [SELECT Id, Name, isActive FROM User WHERE Id = :userId limit 1]) {
    		userName = item.Name;
    		isActive = item.IsActive;
    	}
		if (!isActive) return 'The User ID must be Active prior to updating the sharing rules. Please activate the user.';
		// delete share for this user
		List<Ibanking_Project__Share> sharesForDelete = new List<Ibanking_Project__Share>();
		List<Potential_Buyer_Investor__Share> pbiSharesForDelete = new List<Potential_Buyer_Investor__Share>();
		Set<Id> list_DealId_Owner_RowCause = new Set<Id>();
		Set<Id> list_pbiId_Owner_RowCause = new Set<Id>();
		for(Ibanking_Project__Share item : [
				SELECT RowCause, ParentId, UserOrGroupId
				FROM Ibanking_Project__Share 
				WHERE UserOrGroupId = :userId])
		{
			if(item.RowCause == 'Owner') list_DealId_Owner_RowCause.add(item.ParentId);
			else sharesForDelete.add(item);
		}
		for(Potential_Buyer_Investor__Share item : [
				SELECT RowCause, ParentId, UserOrGroupId
				FROM Potential_Buyer_Investor__Share 
				WHERE UserOrGroupId = :userId])
		{
			if(item.RowCause == 'Owner') list_pbiId_Owner_RowCause.add(item.ParentId);
			else pbiSharesForDelete.add(item);
		}
		if (sharesForDelete.size() > 0)delete sharesForDelete;
		if (pbiSharesForDelete.size() > 0)delete pbiSharesForDelete;
		

    	//if (!isActive) 	return 'Sharing Rules for the ' + userName + ' user were deleted.';
		
		// fetching employee profile id list
		List<Id> ListId_employeeProfileForUser = new List<Id>();
		for(Employee_Profile__c item : [SELECT id, User_ID__c FROM Employee_Profile__c WHERE User_ID__c = :userId])
			ListId_employeeProfileForUser.add(item.Id);

		// fetching deal id list
		Set<Id> Set_DealId = new Set<Id>();
		Set<Id> Set_PbiId = new Set<Id>();
		for(Project_Resource__c item : [SELECT Project__c, Banker__c FROM Project_Resource__c WHERE Banker__c in :ListId_employeeProfileForUser]) 
			Set_DealId.add(item.Project__c);
		system.debug('Set_DealId.size()===' + Set_DealId.size());
		for(Potential_Buyer_Investor_Deal_Team__c item : 
								[SELECT Target_Buyer__r.Project__c, Banker__c 
								FROM Potential_Buyer_Investor_Deal_Team__c 
								WHERE Banker__c in :ListId_employeeProfileForUser]) 
			Set_PbiId.add(item.Target_Buyer__r.Project__c);
		system.debug('Set_PbiId.size()===' + Set_PbiId.size());

		// creating sharing rules
		List<Ibanking_Project__Share> sharingRulesForInsert = new List<Ibanking_Project__Share>();
		List<Potential_Buyer_Investor__Share> sharingPbiRulesForInsert = new List<Potential_Buyer_Investor__Share>();
		for(Id dealId : Set_DealId) {
			if (!list_DealId_Owner_RowCause.contains(dealId))
			{
				Ibanking_Project__Share memberShare = new Ibanking_Project__Share();
				memberShare.UserOrGroupId = userId;
				memberShare.ParentId      = dealId;
				memberShare.AccessLevel   = 'Edit';
				memberShare.RowCause      = 'Manual';
				sharingRulesForInsert.add(memberShare);
			}
		}
		for(Id pbiId : Set_PbiId) {
			if (!list_pbiId_Owner_RowCause.contains(pbiId))
			{
				Potential_Buyer_Investor__Share memberShare = new Potential_Buyer_Investor__Share();
				memberShare.UserOrGroupId = userId;
				memberShare.ParentId      = pbiId;
				memberShare.AccessLevel   = 'Edit';
				memberShare.RowCause      = 'Manual';
				sharingPbiRulesForInsert.add(memberShare);
			}
		}
	
		system.debug('sharingRulesForInsert.size()===' + sharingRulesForInsert.size());
		
	    insert sharingRulesForInsert;
	    insert sharingPbiRulesForInsert;
		
        return 'Sharing Rules for the ' + userName + ' user were created.';
        */
    }
    
    WebService static String updateCallLogSharingRules(String userId) 
    {
    	String userName = '';
    	Boolean isActive = false;
    	for(User item : [SELECT Id, Name, isActive FROM User WHERE Id = :userId limit 1]) {
    		userName = item.Name;
    		isActive = item.IsActive;
    	}
		if (!isActive) return 'The User ' + userName + ' must be Active prior to updating the sharing rules. Please activate the User.';
		
		List<Id> List_CallLogId = new List<Id>();
		for(Call_Log__c item :[	SELECT Id, Organizer__r.User_ID__c,Organizer__r.User_ID__r.IsActive, Organizer__c,Organizer__r.Assistant__c,Organizer__r.Assistant__r.User_ID__c,Organizer__r.Assistant__r.User_ID__r.IsActive
								FROM Call_Log__c
								WHERE Organizer__r.User_ID__c = :userId OR Organizer__r.Assistant__r.User_ID__c = :userId])
		{
			if(item.Organizer__r.User_ID__c == userId && item.Organizer__r.User_ID__r.IsActive )List_CallLogId.add(item.Id);
			if(item.Organizer__r.Assistant__r.User_ID__c == userId && item.Organizer__r.Assistant__r.User_ID__r.IsActive )List_CallLogId.add(item.Id);
		}
		for(Call_Log_Moelis_Attendee__c item :[	SELECT Id,Employee__r.User_ID__c,Employee__r.User_ID__r.IsActive, Employee__c, Call_Log__c,Employee__r.Assistant__c,Employee__r.Assistant__r.User_ID__c,Employee__r.Assistant__r.User_ID__r.IsActive
										FROM Call_Log_Moelis_Attendee__c
										WHERE Employee__r.User_ID__c = :userId OR Employee__r.Assistant__r.User_ID__c = :userId])
		{
			if(item.Employee__r.User_ID__c  == userId && item.Employee__r.User_ID__r.IsActive )List_CallLogId.add(item.Call_Log__c);
			if(item.Employee__r.Assistant__r.User_ID__c  == userId && item.Employee__r.Assistant__r.User_ID__r.IsActive )List_CallLogId.add(item.Call_Log__c);
		}
		List<Id> List_DealId = new List<Id>();
		for(Project_Resource__c item :[	SELECT Project__c,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c 
										FROM Project_Resource__c
										WHERE Banker__r.User_ID__c = :userId ])
		{
			if(item.Banker__r.User_ID__r.IsActive)  List_DealId.add(item.Project__c);
		}
		for(Call_Log_Deal__c item :[	SELECT Deal__c, Call_Log__c
										FROM Call_Log_Deal__c
										WHERE Deal__c IN :List_DealId])
		{
        	List_CallLogId.add(item.Call_Log__c);
		}
		List<Schedule_Data__c> List_toInsert = new List<Schedule_Data__c>();
		if(List_CallLogId.size() > 0)
		{
			/*
			Batch_CallLogShareUPD batch = new Batch_CallLogShareUPD(List_CallLogId);
			Database.executeBatch(batch, 100);
			//CallLogSharingRules.UpdateShare(List_CallLogId);
			*/
			for(Id itemId : List_CallLogId)
			{
				Schedule_Data__c newSD = new Schedule_Data__c();
				newSD.Object_Id__c = itemId;
				newSD.Type__c = 'Call Log';
				List_toInsert.add(newSD);
			}
		}
		if(List_toInsert.size() > 0) insert List_toInsert;
		
		
    	return 'Call Log Sharing Rules for the ' + userName + ' user were created.';
    	/*
		// fetching user name
    	String userName = '';
    	Boolean isActive = false;
    	for(User item : [SELECT Id, Name, isActive FROM User WHERE Id = :userId limit 1]) {
    		userName = item.Name;
    		isActive = item.IsActive;
    	}
		if (!isActive) return 'The User ID must be Active prior to updating the sharing rules. Please activate the user.';
		// delete share for this user
		List<Call_Log__Share> sharesForDelete = new List<Call_Log__Share>();
		Set<Id> list_CallLogId_Owner_RowCause = new Set<Id>();
		for(Call_Log__Share item : [
				SELECT RowCause, ParentId, UserOrGroupId
				FROM Call_Log__Share 
				WHERE UserOrGroupId = :userId])
		{
			if(item.RowCause == 'Owner') list_CallLogId_Owner_RowCause.add(item.ParentId);
			else sharesForDelete.add(item);
		}
		if (sharesForDelete.size() > 0)delete sharesForDelete;
		
		// fetching employee profile id list
		List<Id> ListId_employeeProfileForUser = new List<Id>();
		for(Employee_Profile__c item : [SELECT id, User_ID__c FROM Employee_Profile__c WHERE User_ID__c = :userId])
			ListId_employeeProfileForUser.add(item.Id);

		// fetching deal id list
		Set<Id> Set_CallLogId = new Set<Id>();
		for(Call_Log_Moelis_Attendee__c item : [SELECT Call_Log__c, Employee__c FROM Call_Log_Moelis_Attendee__c WHERE Employee__c in :ListId_employeeProfileForUser]) 
			Set_CallLogId.add(item.Call_Log__c);
		system.debug('Set_CallLogId.size()===' + Set_CallLogId.size());

		// creating sharing rules
		List<Call_Log__Share> sharingRulesForInsert = new List<Call_Log__Share>();
		for(Id tmpCallLogId : Set_CallLogId) {
			if (!list_CallLogId_Owner_RowCause.contains(tmpCallLogId))
			{
				Call_Log__Share memberShare = new Call_Log__Share();
				memberShare.UserOrGroupId = userId;
				memberShare.ParentId      = tmpCallLogId;
				memberShare.AccessLevel   = 'Edit';
				memberShare.RowCause      = 'Manual';
				sharingRulesForInsert.add(memberShare);
			}
		}
		//system.debug('sharingRulesForInsert.size()===' + sharingRulesForInsert.size());
	    insert sharingRulesForInsert;
        return 'Call Log Sharing Rules for the ' + userName + ' user were created.';
       */
    }
    
    WebService static String updatePBISharingRules(String userId) 
    {
    	String userName = '';
    	Boolean isActive = false;
    	for(User item : [SELECT Id, Name, isActive FROM User WHERE Id = :userId limit 1]) {
    		userName = item.Name;
    		isActive = item.IsActive;
    	}
		if (!isActive) return 'The User ' + userName + ' must be Active prior to updating the sharing rules. Please activate the User.';
		
		List<Id> List_PBIId = new List<Id>();
		for(Potential_Buyer_Investor_Deal_Team__c item :[	SELECT Id,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c, Target_Buyer__c
										FROM Potential_Buyer_Investor_Deal_Team__c
										WHERE Banker__r.User_ID__c  = :userId ])
		{
			if(item.Banker__r.User_ID__r.IsActive )List_PBIId.add(item.Target_Buyer__c);
		}
		
		/* The sharing rules for the Deal Team Membership will need to be amended to apply to related PBI as well. */
		List<Id> List_DealId = new List<Id>();
		for(Project_Resource__c item :[	SELECT Project__c,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c 
										FROM Project_Resource__c
										WHERE Banker__r.User_ID__c = :userId ])
		{
			if(item.Banker__r.User_ID__r.IsActive)  List_DealId.add(item.Project__c);
		}
		for(Potential_Buyer_Investor__c item :[	SELECT Id
											FROM Potential_Buyer_Investor__c
											WHERE Project__c IN :List_DealId])
		{
	        	List_PBIId.add(item.Id);
		}
		List<Schedule_Data__c> List_toInsert = new List<Schedule_Data__c>();
		system.debug('List_PBIId--------------->'+List_PBIId);
		if(List_PBIId.size() > 0)
		{
			/*
			Batch_PBIShareUPD batch = new Batch_PBIShareUPD(List_PBIId);
			Database.executeBatch(batch, 100);
			//PBISharingRules.UpdateShare(List_PBIId);
			*/
			for(Id itemId : List_PBIId)
			{
				Schedule_Data__c newSD = new Schedule_Data__c();
				newSD.Object_Id__c = itemId;
				newSD.Type__c = 'PBI';
				List_toInsert.add(newSD);
			}
		}
		if(List_toInsert.size() > 0) insert List_toInsert;
    	return 'PBI Sharing Rules for the ' + userName + ' user were created.';
    }
}