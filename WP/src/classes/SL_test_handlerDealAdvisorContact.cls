@isTest(SeeAllData=true)
private class SL_test_handlerDealAdvisorContact 
{

    static testMethod void myUnitTest() 
    {
    	Id IntermediaryRecordTypeId;
    	Id ContactRecordTypeId;
    	for(RecordType item : [SELECT ID,Name,SobjectType,DeveloperName  FROM RecordType WHERE DeveloperName = 'Intermediary' OR  DeveloperName = 'Contact'])
    	{
    		if(item.DeveloperName == 'Intermediary' && item.SobjectType == 'Account') IntermediaryRecordTypeId = item.Id;
    		else if(item.DeveloperName == 'Contact' && item.SobjectType == 'Contact') ContactRecordTypeId = item.Id;
    	}
    	list<Account> listAccs = new list<Account>();
    	for(Integer i = 0; i < 10; i++)	listAccs.add(new Account(Name = 'Test2Acc_'+i, RecordTypeId = IntermediaryRecordTypeId));
    	insert listAccs;
    	list<Contact> listContacts = new list<Contact>();
    	for(Integer i = 0; i < 10; i++)	
    	{
    		for(Integer j = 0; j < 5; j++)	
    		{
    			listContacts.add(new Contact(Title = 'Test2Acc_'+i+'_Contact_'+j, FirstName = 'Test', LastName = 'TestAcc_'+i+'_Contact_'+j, AccountId = listAccs[i].Id, RecordTypeId = ContactRecordTypeId));
    		}
    	}
    	insert listContacts;
       	list<Deal__c> listDeals = new list<Deal__c>();
       	for(Integer s = 0; s < 10; s++)	
       	{
       		listDeals.add(new Deal__c(Name = 'Test2_'+s, Company__c = listAccs[0].Id, WP_Investment__c = 10, WP_Ownership__c = 10, Description__c = 'TestDescription', Is_Energy_Opportunity__c = 'No'));
       	}
       	insert listDeals;
       	/*
       	list<Deal_Advisor__c> listDealAdvisors = new list<Deal_Advisor__c>();
       	for(Integer i = 0; i < 5; i++)	
    	{
    		listDealAdvisors.add(new Deal_Advisor__c(Deal__c = listDeals[i].Id, Deal_Advisor__c = listAccs[i].Id));
    	}
    	system.debug(' >>>>>>>>>>>>>>> '+listDealAdvisors);
    	insert listDealAdvisors;
    	*/
       	list<Deal_Advisor_Contact__c> listDealAdvisorContacts = new list<Deal_Advisor_Contact__c>();
       	
       	test.startTest();
	       	Integer k = 0;
	       	for(Integer i = 5; i < 10; i++)	
	    	{
	    		k = 5*i;
	    		listDealAdvisorContacts.add(new Deal_Advisor_Contact__c(Deal__c = listDeals[i].Id, Contact__c = listContacts[k].Id));
	    	}
	    	insert listDealAdvisorContacts;
	    	system.assertEquals([SELECT ID FROM Deal_Advisor__c WHERE Deal__c =: listDeals[5].Id AND Deal_Advisor__c =: listAccs[5].Id].size(), 1);
	    	list<Deal_Advisor_Contact__c> newDealAdvisorContacts = new list<Deal_Advisor_Contact__c>();
	    	newDealAdvisorContacts.add(new Deal_Advisor_Contact__c(Deal__c = listDeals[4].Id, Contact__c = listContacts[25].Id));
//	    	newDealAdvisorContacts.add(new Deal_Advisor_Contact__c(Deal__c = listDeals[5].Id, Contact__c = listContacts[25].Id));
//	    	newDealAdvisorContacts.add(new Deal_Advisor_Contact__c(Deal__c = listDeals[5].Id, Contact__c = listContacts[25].Id));
	    	insert newDealAdvisorContacts;
	    	
	    	newDealAdvisorContacts[0].Role__c = 'IT';
	    	update newDealAdvisorContacts;
	    	
	    	delete newDealAdvisorContacts;
	    	//delete listDealAdvisorContacts[0];
	    	//system.assertEquals([SELECT ID FROM Deal_Advisor__c WHERE Deal__c =: listDeals[5].Id AND Deal_Advisor__c =: listAccs[5].Id].size(), 0);
       	test.stopTest();
    }
}