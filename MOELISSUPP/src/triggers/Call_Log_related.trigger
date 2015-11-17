trigger Call_Log_related on Call_Log_related__c (after delete) {

	String whereStr = '';
	String queryStr = '';
	List<Call_Log_Contact__c> delList = new List<Call_Log_Contact__c>();
	if (Trigger.old.size() > 0) {
		for (Call_Log_related__c item:Trigger.old) {
			Id CallLogId = item.Call_Log__c;
			Id AccountId = item.Account__c;
			if (CallLogId != null && AccountId != null) {
				system.debug('======== CallLogId AccountId ======== >>>> '+CallLogId+' | '+AccountId);
				if (whereStr == '') {
					whereStr = '(Call_Log__r.Id = \''+CallLogId+'\' AND Contact__r.AccountId = \''+AccountId+'\')';
				} else {
					whereStr += 'OR (Call_Log__r.Id = \''+CallLogId+'\' AND Contact__r.AccountId = \''+AccountId+'\')';
				}
			}
		}
		if (whereStr != '') {
			queryStr = 'SELECT Id FROM Call_Log_Contact__c WHERE '+whereStr;
			delList = database.query(queryStr);
		}
	}
	if (delList.size() > 0) {
		delete delList;
	}

}