@isTest
private class test_Call_Log_related_triggers {
	
	private static testMethod void test1() {
		// Creating test data
		List<Account> accList = new List<Account>();
		accList.add(new Account(Name = 'Test Company 1'));
		accList.add(new Account(Name = 'Test Company 2'));
		accList.add(new Account(Name = 'Test Company 3'));
		insert accList;
		system.debug('======== accList ========= >>>> '+accList);
		List<Id> accIds = new List<Id>();
		accIds.add(accList[0].Id);
		List<Contact> contList = new List<Contact>();
		contList.add(new Contact(FirstName = 'Test 1',LastName = 'L1',AccountId = accList[0].Id));
		contList.add(new Contact(FirstName = 'Test 2',LastName = 'L2',AccountId = accList[1].Id));
		contList.add(new Contact(FirstName = 'Test 3',LastName = 'L3',AccountId = accList[2].Id));
		insert contList;
		Employee_Profile__c emplObj = new Employee_Profile__c( Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        insert emplObj;
        Employee_Profile__c emplObj2 = new Employee_Profile__c( Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN2', Group__c='Capital Markets', First_Name__c='test FN2', Business_Function__c='Analyst');
        insert emplObj2;
		system.debug('======== contList ========= >>>> '+contList);
		List<Call_Log__c> callLogsList = new List<Call_Log__c>();
		callLogsList.add(new Call_Log__c(Date__c = Date.today(),Organizer__c = emplObj.Id));
		callLogsList.add(new Call_Log__c(Date__c = Date.today()));
		callLogsList.add(new Call_Log__c(Date__c = Date.today()));
		insert callLogsList;
		system.debug('======== callLogsList ========= >>>> '+callLogsList);
		// Insert a new Call Log Contacts
		List<Call_Log_Contact__c> clcList = new List<Call_Log_Contact__c>();
		clcList.add(new Call_Log_Contact__c(Contact__c = contList[0].Id,Call_Log__c = callLogsList[0].Id));
		clcList.add(new Call_Log_Contact__c(Contact__c = contList[1].Id,Call_Log__c = callLogsList[1].Id));
		clcList.add(new Call_Log_Contact__c(Contact__c = contList[1].Id,Call_Log__c = callLogsList[1].Id));
		clcList.add(new Call_Log_Contact__c(Contact__c = contList[2].Id,Call_Log__c = callLogsList[2].Id));
		clcList.add(new Call_Log_Contact__c(Contact__c = contList[2].Id,Call_Log__c = callLogsList[2].Id));
		insert clcList;
		callLogsList[0].Organizer__c = emplObj2.Id;
		update callLogsList;
		system.debug('======== clcList ========= >>>> '+clcList);
		// Delete one of two Call log Contacts
		List<Call_Log_Contact__c> delClcList = new List<Call_Log_Contact__c>();
		delClcList.add(clcList[4]);
		delete delClcList;
		delClcList = new List<Call_Log_Contact__c>();
		delClcList.add(clcList[3]);
		delete delClcList;
		// Werify work of bulk triggers
		delClcList = new List<Call_Log_Contact__c>();
		delClcList.add(clcList[2]);
		delClcList.add(clcList[1]);
		delete delClcList;
	}
}