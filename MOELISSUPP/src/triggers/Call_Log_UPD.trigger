trigger Call_Log_UPD on Call_Log__c (after delete, after insert, after update) 
{
	List<Call_Log__c> List_Call_Log = new List<Call_Log__c>();
	List<Call_Log__c> Trigger_list;
	List<Id> List_CallLogIDs = new List<Id>();
	if(trigger.isInsert || trigger.isUpdate) Trigger_list = Trigger.new;
	if(trigger.isDelete) Trigger_list = Trigger.old;
	Boolean isFireTrigger = false;
	Id oneEmployee_Id;
	Id secondEmployee_Id;
	for (Call_Log__c item : Trigger_list) 
	{
		if(trigger.isInsert || trigger.isUpdate) oneEmployee_Id = Trigger.newMap.get(item.Id).Organizer__c;

		if(trigger.isDelete)	oneEmployee_Id = null;
		if(trigger.isDelete || trigger.isUpdate) secondEmployee_Id = Trigger.oldMap.get(item.Id).Organizer__c;
		if(trigger.isInsert)	secondEmployee_Id = null;
		
		if (oneEmployee_Id != secondEmployee_Id) 
		{	
			isFireTrigger = true;	
			List_Call_Log.add(item);
		}
		List_CallLogIDs.add(item.Id);
	}
	
	if(trigger.isUpdate)
	{
		List<Call_Log_related__c> ListToUpdate = new List<Call_Log_related__c>();
		for(Call_Log_related__c tmpCallLogRelated: [ 
				SELECT ID,Call_Log__c,Type__c,Subject__c,Send_Email__c,Organizer__c,HIDDEN_Email_Feild__c,Detailed_Description__c,Date__c, Account__c,Name
				FROM Call_Log_related__c
				WHERE Call_Log__c IN : List_CallLogIDs]
		)
		{
			tmpCallLogRelated.Type__c = Trigger.newMap.get(tmpCallLogRelated.Call_Log__c).Type__c;
			tmpCallLogRelated.Subject__c = Trigger.newMap.get(tmpCallLogRelated.Call_Log__c).Subject__c;
			tmpCallLogRelated.Send_Email__c = Trigger.newMap.get(tmpCallLogRelated.Call_Log__c).Send_Email__c;
			tmpCallLogRelated.Organizer__c = Trigger.newMap.get(tmpCallLogRelated.Call_Log__c).Organizer__c;
			tmpCallLogRelated.HIDDEN_Email_Feild__c = Trigger.newMap.get(tmpCallLogRelated.Call_Log__c).HIDDEN_Email_Feild__c;
			tmpCallLogRelated.Detailed_Description__c = Trigger.newMap.get(tmpCallLogRelated.Call_Log__c).Detailed_Description__c;
			tmpCallLogRelated.Date__c = Trigger.newMap.get(tmpCallLogRelated.Call_Log__c).Date__c;
			tmpCallLogRelated.Name = Trigger.newMap.get(tmpCallLogRelated.Call_Log__c).Name;
			ListToUpdate.add(tmpCallLogRelated);
		}
		if(ListToUpdate.size() > 0) update ListToUpdate;
	}
	
	
	if (isFireTrigger) 
	{
		List<Schedule_Data__c> List_toInsert = new List<Schedule_Data__c>();
		for(Call_Log__c item : List_Call_Log)
		{
			Schedule_Data__c newSD = new Schedule_Data__c();
			newSD.Object_Id__c = item.Id;
			newSD.Type__c = 'Call Log';
			List_toInsert.add(newSD);
		}
		if(List_toInsert.size() > 0) insert List_toInsert;
		/*
		List<Id> List_CallLogId = new List<Id>();
		for(Call_Log__c item : List_Call_Log)
		{
			List_CallLogId.add(item.Id);
		}
		//if(List_CallLogId.size() > 0)CallLogSharingRules.Set_UpdateCallLogSharing_True(List_CallLogId);
		
		if(List_CallLogId.size() > 0)
		{
			old logic
			Batch_CallLogShareUPD batch = new Batch_CallLogShareUPD(List_CallLogId);
			Database.executeBatch(batch, 100);
			
		}
		*/
	}
	
	
	
	
	
	
	/*
	if (trigger.isUpdate) 
    {
		List<Call_Log__c> List_newCallLogs = new List<Call_Log__c>();
		List<Id> List_newCallLogIDs = new List<Id>();
		for (Call_Log__c item : Trigger.new) 
		{
			if(item.Update_CallLog_Sharing__c)List_newCallLogIDs.add(item.Id);
		}

		if (List_newCallLogIDs.size() > 0)
		{
		
			Batch_CallLogShareUPD batch = new Batch_CallLogShareUPD(List_newCallLogIDs);
			Database.executeBatch(batch, 100);
			
		}
    }
    */
    

	
	/*
MOELIS-24: 698 Need a trigger on Call Log to automatically add a banker's administrative assistant to Sharing Rules

    Set<Id> EmployeeIdOldList = new Set<Id>();
    Map<Id,Id> EmployeeIdCallLogId_OldMap = new Map<Id,Id>();
  //  List<Id> EmployeeAssistantUserIdOldList = new List<Id>();
    Map<Id,Employee_Profile__c> CallLogIdEmployee_OldMap = new Map<Id,Employee_Profile__c>();
    if (trigger.isDelete || trigger.isUpdate) 
    {
        for (Call_Log__c pr : trigger.old) 
        {
          	if (pr.Organizer__c != null)
            {
                EmployeeIdOldList.add(pr.Organizer__c);
                EmployeeIdCallLogId_OldMap.put(pr.Organizer__c,pr.Id);
            }
        }
        system.debug(EmployeeIdCallLogId_OldMap);
        
        List<Id> EmployeeAssistantUserIdList = new List<Id>();
        if(EmployeeIdOldList.size() > 0)
        {
            for(Employee_Profile__c tmpEmployee : [SELECT Id, Assistant__c, Assistant__r.User_ID__c
                            FROM Employee_Profile__c 
                            WHERE Id IN :EmployeeIdOldList])
            {
                if( tmpEmployee.Assistant__r.User_ID__c != null && 
                    EmployeeIdCallLogId_OldMap.get(tmpEmployee.Id) != null
                    )   
                {
                	CallLogIdEmployee_OldMap.put(EmployeeIdCallLogId_OldMap.get(tmpEmployee.Id), tmpEmployee);
                	EmployeeAssistantUserIdList.add(tmpEmployee.Assistant__r.User_ID__c);
                }
            }
        }
        // all users of Employee of Call_Log_Moelis_Attendee__c. to exclude duplicates of users in Shares (when delete from share, not detele user if hi is in List of users of Employee of Call_Log_Moelis_Attendee__c) 
        Set<Id> CallLogMoelisAttendeeEmployeeUserIDList = new Set<Id>();
        for (Call_Log_Moelis_Attendee__c cla : [SELECT Employee__r.User_ID__c From Call_Log_Moelis_Attendee__c Where Call_Log__c IN : trigger.old])
		{
			if(cla.Employee__r.User_ID__c != null)	CallLogMoelisAttendeeEmployeeUserIDList.add(cla.Employee__r.User_ID__c);
		}
		system.debug('ECallLogMoelisAttendeeEmployeeUserIDList --------------->'+CallLogMoelisAttendeeEmployeeUserIDList);		
        if(CallLogIdEmployee_OldMap.size() > 0)
        {   
            string sQuery = '';
            for(Id CLid : CallLogIdEmployee_OldMap.keySet()) 
            {
                if (sQuery == '') 
                {
                    if (CallLogIdEmployee_OldMap.get(CLid) != null && CallLogIdEmployee_OldMap.get(CLid).Assistant__r.User_ID__c != null) 
                        sQuery = '(ParentId = \''+CLid+'\' and UserOrGroupId = \''+CallLogIdEmployee_OldMap.get(CLid).Assistant__r.User_ID__c+'\' and RowCause = \'Manual\')';
                }
                else
                {
                    if (CallLogIdEmployee_OldMap.get(CLid) != null && CallLogIdEmployee_OldMap.get(CLid).Assistant__r.User_ID__c != null)
                        sQuery += ' or (ParentId = \''+CLid+'\' and UserOrGroupId = \''+CallLogIdEmployee_OldMap.get(CLid).Assistant__r.User_ID__c+'\' and RowCause = \'Manual\')';
                }
            }
            system.debug('Query str: Select id from Call_Log__Share where '+sQuery);
            List<Call_Log__Share> ipSharesForUsers;
            ipSharesForUsers = Database.query('Select id, UserOrGroupId, ParentId, Parent.OwnerId from Call_Log__Share where '+sQuery);
            system.debug('Query res: '+ipSharesForUsers);
            
            List<Call_Log__Share> ipSharesForDelete = new List<Call_Log__Share>();
            Map<ID,Map<ID,Call_Log__Share>> mapIPSObjs = new Map<ID,Map<ID,Call_Log__Share>>();
            Map<ID,Call_Log__Share> mapSubIPS;
            
            for(Call_Log__Share ipsItem : ipSharesForUsers) 
            {
                system.debug('does it contains:' + mapIPSObjs.containsKey(ipsItem.ParentId));            
                if(mapIPSObjs.containsKey(ipsItem.ParentId)) 
                {
                    mapIPSObjs.get(ipsItem.ParentId).put(ipsItem.UserOrGroupId,ipsItem);
                } else 
                {
                    mapSubIPS = new Map<ID,Call_Log__Share>();
                    mapSubIPS.put(ipsItem.UserOrGroupId,ipsItem);
                    mapIPSObjs.put(ipsItem.ParentId, mapSubIPS);
                }
            }
            
            Employee_Profile__c tmpEPBankerObj = null;
            map<ID,Call_Log__Share> ipSharesForDeleteMap = new map<ID,Call_Log__Share>();
            for(Id CLid : CallLogIdEmployee_OldMap.keySet()) 
            {
                tmpEPBankerObj = CallLogIdEmployee_OldMap.get(CLid);
                if (tmpEPBankerObj != null 
                    && tmpEPBankerObj.Assistant__r.User_ID__c != null
                    && mapIPSObjs.containsKey(CLid)
                    && !CallLogMoelisAttendeeEmployeeUserIDList.contains(tmpEPBankerObj.Assistant__r.User_ID__c)
                    && mapIPSObjs.get(CLid).containsKey(tmpEPBankerObj.Assistant__r.User_ID__c)
                    && mapIPSObjs.get(CLid).get(tmpEPBankerObj.Assistant__r.User_ID__c).Parent.OwnerId!= tmpEPBankerObj.Assistant__r.User_ID__c
                   ) 
                {
                    //ipSharesForDeleteMap.put(mapIPSObjs.get(pr.Call_Log__c).get(tmpEPBankerObj.User_Id__c).ID, mapIPSObjs.get(pr.Call_Log__c).get(tmpEPBankerObj.User_Id__c));
                    ipSharesForDeleteMap.put(mapIPSObjs.get(CLid).get(tmpEPBankerObj.Assistant__r.User_ID__c).ID, mapIPSObjs.get(CLid).get(tmpEPBankerObj.Assistant__r.User_ID__c));
                }
            }
    
            system.debug('Deleting ipSharesForDelete ' + ipSharesForDeleteMap.size());
            system.debug('Deleting ipSharesForDelete is: ' + ipSharesForDeleteMap);
            
            if(ipSharesForDeleteMap.size()>0){ 
                ipSharesForDelete = ipSharesForDeleteMap.values();
                system.debug('Deleting ipSharesForDelete ' + ipSharesForDelete.size());
                delete ipSharesForDelete;
            }
        }
    
    }
    
    
    
    
    
    
    
    if (trigger.isInsert || trigger.isUpdate) 
    {
        Set<Id> EmployeeIdList = new Set<Id>();
        Map<Id,Id> EmployeeIdCallLogId_Map = new Map<Id,Id>();
        List<Id> EmployeeAssistantUserIdList = new List<Id>();
        Map<Id,Employee_Profile__c> CallLogIdEmployee_Map = new Map<Id,Employee_Profile__c>();
        for (Call_Log__c pr : trigger.new) 
        {
            if (pr.Organizer__c != null)
            {
                EmployeeIdList.add(pr.Organizer__c);
                EmployeeIdCallLogId_Map.put(pr.Organizer__c,pr.Id);
            }
        }
        if(EmployeeIdList.size() > 0)
        {
            for(Employee_Profile__c tmpEmployee : [SELECT Id, Assistant__c, Assistant__r.User_ID__c,  Assistant__r.User_ID__r.IsActive 
                            FROM Employee_Profile__c 
                            WHERE Id in :EmployeeIdList])
            {
                if( tmpEmployee.Assistant__r.User_ID__c != null && 
                    tmpEmployee.Assistant__r.User_ID__r.IsActive && 
                    EmployeeIdCallLogId_Map.get(tmpEmployee.Id) != null
                    )   CallLogIdEmployee_Map.put(EmployeeIdCallLogId_Map.get(tmpEmployee.Id), tmpEmployee);
            }
        }
        Employee_Profile__c tmpEmployee = new Employee_Profile__c();
        if(CallLogIdEmployee_Map.size() > 0)
        {   
            List<Call_Log__Share> ipSharesForInsert = new List<Call_Log__Share>();
            Employee_Profile__c tmpEPBankerObj = null;
            for(Id CLid : CallLogIdEmployee_Map.keySet()) 
            {
                Call_Log__Share memberShare = new Call_Log__Share();
                memberShare.ParentId = CLid;
                memberShare.AccessLevel = 'Edit';
                memberShare.RowCause = 'Manual';
                if(CallLogIdEmployee_Map.get(CLid) != null)tmpEmployee = CallLogIdEmployee_Map.get(CLid);
                memberShare.UserOrGroupId = tmpEmployee.Assistant__r.User_ID__c;
                ipSharesForInsert.add(memberShare);
            }
    
            system.debug('List of shares to be inserted: ' + ipSharesForInsert);
            if(ipSharesForInsert.size()>0)
            { 
                insert ipSharesForInsert; 
            }
        }
    }
    */
}