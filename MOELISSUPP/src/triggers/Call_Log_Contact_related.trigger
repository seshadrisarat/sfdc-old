trigger Call_Log_Contact_related on Call_Log_Contact__c (after delete, after insert, after update) {

	if (Trigger.isInsert) {
		Set<Id> callLogContactIds = new Set<Id>();
		Set<Id> callLogIds = new Set<Id>();
 		for (Call_Log_Contact__c item : Trigger.new) { 
 			callLogContactIds.add(item.Id); 
 			callLogIds.add(item.Call_Log__c);
 		}
		
		List<Call_Log_Contact__c> clcList = [SELECT Id,Call_Log__r.Name, Call_Log__r.Id, Call_Log__r.Date__c, Call_Log__r.Detailed_Description__c,
													Call_Log__r.HIDDEN_Email_Feild__c, Call_Log__r.Organizer__c, Call_Log__r.Send_Email__c,
													Call_Log__r.Subject__c, Call_Log__r.Type__c, Call_Log__r.Update_CallLog_Sharing__c,
													Contact__r.Account.Id,Contact__r.AccountId
											FROM Call_Log_Contact__c
											WHERE Id in :callLogContactIds];
		List<Call_Log_Contact__c> clcListClear = new List<Call_Log_Contact__c>();
		Boolean isInsert;
		for (Call_Log_Contact__c item: clcList) {
			isInsert = true;
			for (Call_Log_Contact__c subitem: clcListClear) {
				if (item.Call_Log__r.Id == subitem.Call_Log__r.Id && item.Contact__r.Account.Id == subitem.Contact__r.Account.Id) {
					isInsert = false;
				}
			}
			if (isInsert) {
				clcListClear.add(item);
			}
		}
		
		String whereStr = '';
		String queryStr = '';
		
		for (Call_Log_Contact__c item:clcListClear) {
			if (item.Call_Log__r.Id != null && item.Contact__r.Account.Id != null) {
				if (whereStr == '') {
					whereStr = '(Call_Log__r.Id = \''+item.Call_Log__r.Id+'\' AND Account__r.Id = \''+item.Contact__r.Account.Id+'\')';
				} else {
					whereStr += 'OR (Call_Log__r.Id = \''+item.Call_Log__r.Id+'\' AND Account__r.Id = \''+item.Contact__r.Account.Id+'\')';
				}
			}
		}
		queryStr = 'SELECT Call_Log__r.Id,Account__r.Id FROM Call_Log_related__c WHERE '+whereStr;
		system.debug('======== queryStr ======== >>>> '+queryStr);
		
		List<Call_Log_related__c> clrList = new List<Call_Log_related__c>();
		if (whereStr != '') {
			clrList = database.query(queryStr);
		}

		List<Call_Log_Contact__c> clcList_forCopy = new List<Call_Log_Contact__c>();
		
		Boolean insFlag;
		for (Call_Log_Contact__c item:clcListClear) {
			insFlag = true;
			for (Call_Log_related__c subitem:clrList) {
				if (item.Call_Log__r.Id == subitem.Call_Log__r.Id && item.Contact__r.AccountId == subitem.Account__r.Id) {
					insFlag = false;
				}
			}
			if (insFlag) {
				clcList_forCopy.add(item);
			}
		}
		
		/*
		List<Call_Log_related__c> clrList = [SELECT ID, Account__c, Call_Log__c FROM Call_Log_related__c WHERE Call_Log__c in :callLogIds];
		
		List<Call_Log_Contact__c> clcList_forCopy = new List<Call_Log_Contact__c>();
		for(Call_Log_Contact__c clcItem : clcList) {
			for(Call_Log_related__c clrItem : clrList) {
				if(clcItem.Call_Log__c == clrItem.Call_Log__c && clcItem.Contact__r.AccountId == clrItem.Account__c) {} 
				else clcList_forCopy.add(clcItem);
			}
		}*/
													
		List<Call_Log_related__c> toInsert = new List<Call_Log_related__c>();
		for (Call_Log_Contact__c item : clcList_forCopy) {
			Call_Log_related__c insertItem = new Call_Log_related__c();
			insertItem.Name                      = item.Call_Log__r.Name;
			insertItem.Account__c                = item.Contact__r.Account.Id;
			insertItem.Date__c                   = item.Call_Log__r.Date__c;
			insertItem.Detailed_Description__c   = item.Call_Log__r.Detailed_Description__c;
			insertItem.HIDDEN_Email_Feild__c     = item.Call_Log__r.HIDDEN_Email_Feild__c;
			insertItem.Organizer__c              = item.Call_Log__r.Organizer__c;
			insertItem.Send_Email__c             = item.Call_Log__r.Send_Email__c;
			insertItem.Subject__c                = item.Call_Log__r.Subject__c;
			insertItem.Type__c                   = item.Call_Log__r.Type__c;
			insertItem.Update_CallLog_Sharing__c = item.Call_Log__r.Update_CallLog_Sharing__c;
			insertItem.Call_Log__c               = item.Call_Log__r.Id;
			if (insertItem.Account__c != null) {
				toInsert.add(insertItem);
			}
		}
		
		system.debug('======== toInsert ======== >>>> '+toInsert);
		insert toInsert;
	}
	
	if (Trigger.isDelete) {
		Set<Id> callLogContactIds = new Set<Id>();
		Set<Id> callLogIds = new Set<Id>();
		List<Id> ContactIds = new List<Id>();
 		for (Call_Log_Contact__c item : Trigger.old) { 
 			callLogContactIds.add(item.Id); 
 			callLogIds.add(item.Call_Log__c);
 			ContactIds.add(item.Contact__c);
 		}
		
		//List<Call_Log_Contact__c> clcList = [SELECT Id,Call_Log__r.Id,Contact__r.Account.Id,Contact__r.AccountId
		//									FROM Call_Log_Contact__c
		//									WHERE Id in :callLogContactIds];
											
		List<Contact> contacts = [SELECT Id,AccountId,Account.Id FROM Contact WHERE Id in :ContactIds];
		List<List<Id>> clcList = new List<List<Id>>();
		List<Id> toAdd;
		for (Call_Log_Contact__c item:Trigger.old) {
			toAdd = new List<Id>();
			Id clcont = item.Call_Log__c;
			toAdd.add(clcont);
			for (Contact subitem: contacts) {
				Id cont = item.Contact__c;
				system.debug('======== item.Contact__c ======= >>>> '+item.Contact__c);
				system.debug('======== subitem.Id ======= >>>> '+subitem.Id);
				if (subitem.Id == cont) {
					toAdd.add(subitem.Account.Id);
					break;
				}
			}
			toAdd.add(item.Id);
			clcList.add(toAdd);
		}
		
		system.debug('======== clcList ======== >>>> '+clcList);
		String whereStr = '';
		for (List<Id> item:clcList) {
			if (whereStr == '') {
				whereStr = '(Call_Log__r.Id = \''+item[0]+'\' AND Contact__r.Account.Id = \''+item[1]+'\')';
			} else {
				whereStr += 'OR (Call_Log__r.Id = \''+item[0]+'\' AND Contact__r.Account.Id = \''+item[1]+'\')';
			}
		}
		List<Call_Log_Contact__c> allList = database.query('SELECT Id,Call_Log__r.Id,Contact__r.Account.Id,Contact__r.AccountId FROM Call_Log_Contact__c WHERE '+whereStr);
		system.debug('======== allList ======== >>>> '+allList);
		
		//List<Call_Log_Contact__c> toDelete = new List<Call_Log_Contact__c>();
		List<List<Id>> toDelete = new List<List<Id>>();
		List<Id> delIds = new List<Id>();
		Integer count;
		
		for (List<Id> subitem:clcList) {
			count = 0;
			for (Call_Log_Contact__c item: allList) {
				if (item.Call_Log__r.Id == subitem[0] && item.Contact__r.Account.Id == subitem[1]) {
					count ++;
				}
			}
			if (count == 0) {
				delIds.add(subitem[0]);
				delIds.add(subitem[1]);
				toDelete.add(delIds);
			}
		}
		
		if (toDelete.size() > 0) {
			whereStr = '';
			String queryStr = '';
			
			system.debug('======== toDelete ======== >>>> '+toDelete);
			for (List<Id> item:toDelete) {
				if (whereStr == '') {
					whereStr = '(Call_Log__r.Id = \''+item[0]+'\' AND Account__r.Id = \''+item[1]+'\')';
				} else {
					whereStr += 'OR (Call_Log__r.Id = \''+item[0]+'\' AND Account__r.Id = \''+item[1]+'\')';
				}
			}
			queryStr = 'SELECT Id FROM Call_Log_related__c WHERE '+whereStr;
			
			List<Call_Log_related__c> delList = database.query(queryStr);
			system.debug('======== delList ======== >>>> '+delList);
			if (delList.size() > 0) {
				delete delList;
			}
		}
	}
	
}