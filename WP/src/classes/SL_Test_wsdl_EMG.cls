/** 
* \author Greg Grinberg
* \date 3/12/2012
* \see https://silverline.jira.com/browse/WP-4
* \details test code for SL_wsdl_EMG
* \
*/
@isTest(seealldata=true)
private class SL_Test_wsdl_EMG {
	
	//asserts to actually test functionality need to be added.
	private static testMethod void test_SL_wsdl_EMG()
	{
		Id IntermediaryRecordTypeId = [SELECT ID,Name,SobjectType,DeveloperName  FROM RecordType WHERE DeveloperName = 'Intermediary' limit 1].get(0).ID;

    	list<Account> listAccs = new list<Account>();
    	for(Integer i = 0; i < 10; i++)	listAccs.add(new Account(Name = 'Test2Acc_'+i, RecordTypeId = IntermediaryRecordTypeId));
    	insert listAccs;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
        Contact objContact = new Contact(LastName = 'Test Contact 24', RecordTypeId = ContRecTypeId.Id,  User_ID__c = UserInfo.getUserId() );
        insert objContact;
    	
       	list<Deal__c> listDeals = new list<Deal__c>();
       	for(Integer s = 0; s < 10; s++)	
       	{
       		listDeals.add(new Deal__c(Name = 'Test2_'+s, Company__c = listAccs[0].Id, WP_Investment__c = 10, WP_Ownership__c = 10, Description__c = 'TestDescription', Is_Energy_Opportunity__c = 'No'));
       	}
       	insert listDeals;
		
		
		Test.startTest();
		//asserts to actually test functionality need to be added.
		//need to add code to test for when listdeal id is null
		//need to add code to test for when Emg_paragraphs are inserted (separate testmethod)
		string paragraphURL = SL_wsdl_EMG.EMG_Paragraph_from_Deal((string) listDeals[0].ID,'001');
		string commentURL = SL_wsdl_EMG.EMG_Comment_from_Deal((string) listDeals[1].ID,'002');
		Integer archivePage = SL_wsdl_EMG.is_show_EMG_Archive_Page();
		Id testConID = SL_wsdl_EMG.getContactID_by_current_User();
		Contact testCon = SL_wsdl_EMG.getContact_by_current_User();
		Test.stopTest();
		
	}

}