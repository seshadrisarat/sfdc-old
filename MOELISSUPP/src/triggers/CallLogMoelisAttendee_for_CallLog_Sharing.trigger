trigger CallLogMoelisAttendee_for_CallLog_Sharing on Call_Log_Moelis_Attendee__c (before delete, after insert, before update)
{
	List<Call_Log_Moelis_Attendee__c> List_Call_Log_Moelis_Attendee = new List<Call_Log_Moelis_Attendee__c>();
	List<Call_Log_Moelis_Attendee__c> Trigger_list;
	if(trigger.isInsert || trigger.isUpdate) Trigger_list = Trigger.new;
	if(trigger.isDelete) Trigger_list = Trigger.old;
	Boolean isFireTrigger = false;
	Id oneEmployee_Id;
	Id secondEmployee_Id;
	for (Call_Log_Moelis_Attendee__c item : Trigger_list) 
	{
		if(trigger.isInsert || trigger.isUpdate) oneEmployee_Id = Trigger.newMap.get(item.Id).Employee__c;
		if(trigger.isDelete)	oneEmployee_Id = null;
		if(trigger.isDelete || trigger.isUpdate) secondEmployee_Id = Trigger.oldMap.get(item.Id).Employee__c;
		if(trigger.isInsert)	secondEmployee_Id = null;
		
		if (oneEmployee_Id != secondEmployee_Id) 
		{	
			isFireTrigger = true;	
			List_Call_Log_Moelis_Attendee.add(item);
		}
	}
	if (isFireTrigger) 
	{
		List<Id> List_CallLogId = new List<Id>();
		for(Call_Log_Moelis_Attendee__c item : List_Call_Log_Moelis_Attendee)
		{
			List_CallLogId.add(item.Call_Log__c);
		}
		if(List_CallLogId.size() > 0)
		{
			List<Schedule_Data__c> List_toInsert = new List<Schedule_Data__c>();
			for(Id itemId : List_CallLogId)
			{
				Schedule_Data__c newSD = new Schedule_Data__c();
				newSD.Object_Id__c = itemId;
				newSD.Type__c = 'Call Log';
				List_toInsert.add(newSD);
			}
			if(List_toInsert.size() > 0) insert List_toInsert;
			/*
			Batch_CallLogShareUPD batch = new Batch_CallLogShareUPD(List_CallLogId);
			Database.executeBatch(batch, 100);
			//CallLogSharingRules.Set_UpdateCallLogSharing_True(List_CallLogId);
			*/
		}
	}
	
	
/*
MOELIS-20:
Create a trigger on Call Log Moelis Attendees (insert, update, delete) that maintains sharing rules on Call Log object. 
The logic should work exactly as current logic for Deal Team trigger on Deal.

    //system.debug('CallLogMoelisAttendee_for_CallLog_Sharing=== BEGIN ------------------------->');
    List<Employee_Profile__c> EmployeeList;
    List<Id> EmployeeIdList = new List<Id>();
    List<Id> CallLogIDList = new List<Id>();
  	Set<Id> EmployeeUserIDOtherIDList = new Set<Id>();
  	
    if (trigger.isInsert || trigger.isUpdate) { 
        for (Call_Log_Moelis_Attendee__c pr : trigger.new) {
            EmployeeIdList.add(pr.Employee__c);
            CallLogIDList.add(pr.Call_Log__c);
        }
    } 
    if (trigger.isDelete || trigger.isUpdate) {
        for (Call_Log_Moelis_Attendee__c pr : trigger.old) {
            EmployeeIdList.add(pr.Employee__c);
            CallLogIDList.add(pr.Call_Log__c);
        }
    	for (Call_Log_Moelis_Attendee__c cla : [SELECT Employee__r.User_ID__c From Call_Log_Moelis_Attendee__c Where Id NOT IN : trigger.old AND Call_Log__c IN : CallLogIDList])
		{
			if(cla.Employee__r.User_ID__c != null)	EmployeeUserIDOtherIDList.add(cla.Employee__r.User_ID__c);
		}
		for (Call_Log__c cla : [SELECT Organizer__r.Assistant__r.User_ID__c From Call_Log__c Where Id IN : CallLogIDList])
		{
			if(cla.Organizer__r.Assistant__r.User_ID__c != null) EmployeeUserIDOtherIDList.add(cla.Organizer__r.Assistant__r.User_ID__c);
		}
    }
   // system.debug('CallLogIDList===' + CallLogIDList);
   // system.debug('EmployeeUserIDOtherIDList===' + EmployeeUserIDOtherIDList);
   // system.debug('trigger.old===' + trigger.old);
  //  system.debug('trigger.new===' + trigger.new);
  //  system.debug('EmployeeIdList.size===' + EmployeeIdList.size());
    
    EmployeeList = [SELECT Id, User_Id__c,User_ID__r.IsActive 
			        FROM Employee_Profile__c 
        			WHERE Id in :EmployeeIdList];
    
  //  system.debug('EmployeeList List: ' + EmployeeList);
  //  system.debug('trigger.old List: ' + trigger.old);

    if (trigger.isUpdate) 
    {
        List<Call_Log__Share> ipSharesForUsers;
        List<Id> userIdList = new List<Id>(); 
        for(Employee_Profile__c item : EmployeeList)  userIdList.add(item.User_ID__c);
 
        string sQuery;
        if (trigger.old.size()>0) {
            sQuery = '(ParentId = \''+trigger.old.get(0).Call_Log__c+'\' and UserOrGroupId = \''+getBankerByProjResourceId(trigger.old.get(0).Employee__c).User_Id__c+'\')';
        }
        for (integer i = 1; i<trigger.old.size(); i++) {
            sQuery += ' or (ParentId = \''+trigger.old.get(i).Call_Log__c+'\' and UserOrGroupId = \''+getBankerByProjResourceId(trigger.old.get(i).Employee__c).User_Id__c+'\')';
        }

        system.debug('Query str: Select id from Call_Log__Share where '+sQuery);
        ipSharesForUsers = Database.query('Select id, UserOrGroupId, ParentId, Parent.OwnerId from Call_Log__Share where '+sQuery);
        system.debug('Query res: '+ipSharesForUsers);

        List<Call_Log__Share> ipSharesForDelete = new List<Call_Log__Share>();
        // ID = ParentId(Call_Log), ID - UserOrGroupId(UserID)
        Map<ID,Map<ID,Call_Log__Share>> mapIPSObjs = new Map<ID,Map<ID,Call_Log__Share>>();
        Map<ID,Call_Log__Share> mapSubIPS;
        
        for(Call_Log__Share ipsItem : ipSharesForUsers) {
            system.debug('does it contains:' + mapIPSObjs.containsKey(ipsItem.ParentId));            
            if(mapIPSObjs.containsKey(ipsItem.ParentId)) {
                mapIPSObjs.get(ipsItem.ParentId).put(ipsItem.UserOrGroupId,ipsItem);
            } else {
                mapSubIPS = new Map<ID,Call_Log__Share>();
                mapSubIPS.put(ipsItem.UserOrGroupId,ipsItem);
                mapIPSObjs.put(ipsItem.ParentId, mapSubIPS);
            }
        }
        
        Employee_Profile__c tmpEPBankerObj = null;
        map<ID,Call_Log__Share> ipSharesForDeleteMap = new map<ID,Call_Log__Share>();
        for(Call_Log_Moelis_Attendee__c pr : trigger.old) {
            tmpEPBankerObj = getBankerByProjResourceId(pr.Employee__c);
           // system.debug('tmpEPBankerObj.User_Id__c---->'+tmpEPBankerObj.User_Id__c);
        //    system.debug('EmployeeUserIDOtherIDList---->'+EmployeeUserIDOtherIDList);
       //     system.debug('EmployeeUserIDOtherIDList.contains(tmpEPBankerObj.User_Id__c)---->'+EmployeeUserIDOtherIDList.contains(tmpEPBankerObj.User_Id__c));
            if (pr.Employee__c!=null 
                && tmpEPBankerObj != null 
                && tmpEPBankerObj.User_Id__c != null
                && !EmployeeUserIDOtherIDList.contains(tmpEPBankerObj.User_Id__c)
                && mapIPSObjs.containsKey(pr.Call_Log__c)
                && mapIPSObjs.get(pr.Call_Log__c).containsKey(tmpEPBankerObj.User_Id__c)
                && mapIPSObjs.get(pr.Call_Log__c).get(tmpEPBankerObj.User_Id__c).Parent.OwnerId!= tmpEPBankerObj.User_Id__c

               ) {
                ipSharesForDeleteMap.put(mapIPSObjs.get(pr.Call_Log__c).get(tmpEPBankerObj.User_Id__c).ID, mapIPSObjs.get(pr.Call_Log__c).get(tmpEPBankerObj.User_Id__c));
            }
        }

     //   system.debug('Deleting ipSharesForDelete ' + ipSharesForDeleteMap.size());
    //    system.debug('Deleting ipSharesForDelete is: ' + ipSharesForDeleteMap);
        
        if(ipSharesForDeleteMap.size()>0){ 
            ipSharesForDelete = ipSharesForDeleteMap.values();
       //     system.debug('Deleting ipSharesForDelete ' + ipSharesForDelete.size());
            delete ipSharesForDelete;
        }
    
    }
    
    if(trigger.isDelete) 
    {
        Map<ID,ID> mapCallLogs = new Map<ID,ID>();
        List<Id> userIdList = new List<Id>(); 
        for(Employee_Profile__c item : EmployeeList) userIdList.add(item.User_ID__c);
        
//system.debug('userIdList ' + userIdList);

        List<Call_Log__Share> ipSharesForUsers = [
        		SELECT Id, ParentId, UserOrGroupId, Parent.OwnerId 
            	FROM Call_Log__Share 
            	WHERE UserOrGroupId in :userIdList and ParentId in :CallLogIDList and RowCause = 'Manual'];
        
        List<Call_Log__Share> ipSharesForDelete = new List<Call_Log__Share>();
        // ID = ParentId(Deal), ID - UserOrGroupId(UserID)
        Map<ID,Map<ID,Call_Log__Share>> mapIPSObjs = new Map<ID,Map<ID,Call_Log__Share>>();
        Map<ID,Call_Log__Share> mapSubIPS;
        
        for(Call_Log__Share ipsItem : ipSharesForUsers) {
            //system.debug('does it contains:' + mapIPSObjs.containsKey(ipsItem.ParentId));            
            if(mapIPSObjs.containsKey(ipsItem.ParentId)) {
                mapIPSObjs.get(ipsItem.ParentId).put(ipsItem.UserOrGroupId,ipsItem);
            } else {
                mapSubIPS = new Map<ID,Call_Log__Share>();
                mapSubIPS.put(ipsItem.UserOrGroupId,ipsItem);
                mapIPSObjs.put(ipsItem.ParentId, mapSubIPS);
            }
        }
        
        map<ID,Call_Log__Share> ipSharesForDeleteMap = new map<ID,Call_Log__Share>();
        Employee_Profile__c tmpEPBankerObj = null;
        for(Call_Log_Moelis_Attendee__c pr : trigger.old) {
        	tmpEPBankerObj = getBankerByProjResourceId(pr.Employee__c);
            if (pr.Employee__c!=null 
                && tmpEPBankerObj != null 
                && tmpEPBankerObj.User_Id__c != null
                && !EmployeeUserIDOtherIDList.contains(tmpEPBankerObj.User_Id__c)
                && mapIPSObjs.containsKey(pr.Call_Log__c)
                && mapIPSObjs.get(pr.Call_Log__c).containsKey(tmpEPBankerObj.User_Id__c)
               ) {
                ipSharesForDeleteMap.put(mapIPSObjs.get(pr.Call_Log__c).get(tmpEPBankerObj.User_Id__c).ID, mapIPSObjs.get(pr.Call_Log__c).get(tmpEPBankerObj.User_Id__c));
            }
        }

       // system.debug('Deleting ipSharesForDelete ' + ipSharesForDeleteMap.size());
        if(ipSharesForDeleteMap.size()>0){
        	ipSharesForDelete = ipSharesForDeleteMap.values();
         //   system.debug('Deleting ipSharesForDelete ' + ipSharesForDeleteMap.size());
            delete ipSharesForDelete;
        }
    }

    if((trigger.isInsert || trigger.isUpdate) && CallLogIDList.size()>0) 
    {
        Map<ID,ID> mapCallLogs = new Map<ID,ID>();

        for(Call_Log__c IPObj:[SELECT i.OwnerId, i.Id FROM Call_Log__c i WHERE id in :CallLogIDList])
		{
            mapCallLogs.put(IPObj.ID,IPObj.OwnerId);
        }
        
        List<Call_Log__Share> ipSharesForInsert = new List<Call_Log__Share>();
        Employee_Profile__c tmpEPBankerObj = null;
        for(Call_Log_Moelis_Attendee__c pr : trigger.new) {
            Call_Log__Share memberShare = new Call_Log__Share();
            tmpEPBankerObj = getBankerByProjResourceId(pr.Employee__c);
	
            memberShare.ParentId = pr.Call_Log__c;
            memberShare.AccessLevel = 'Edit';
            memberShare.RowCause = 'Manual';//Schema.Ibanking_Project__Share.RowCause.Hiring_Manager_Access__c;
	            
            if (pr.Call_Log__c!=null 
                && pr.Employee__c!=null 
                && mapCallLogs.containsKey(pr.Call_Log__c)
                && tmpEPBankerObj!=null 
                && tmpEPBankerObj.User_Id__c!=null
                && mapCallLogs.get(pr.Call_Log__c)!=tmpEPBankerObj.User_Id__c) 
			{
                memberShare.UserOrGroupId = tmpEPBankerObj.User_Id__c;
                if(tmpEPBankerObj.User_Id__r.IsActive) ipSharesForInsert.add(memberShare);
            }
        }

      //  system.debug('List of shares to be inserted: ' + ipSharesForInsert);
        if(ipSharesForInsert.size()>0){ 
            insert ipSharesForInsert; 
        }
        
    }
    
   private Employee_Profile__c getBankerByProjResourceId(Id Call_LogId) 
   {
        for(Employee_Profile__c item : EmployeeList) {
            if (item.Id == Call_LogId) {
                return item;
                break;
            }
        }
        return null;
    }
    */
}