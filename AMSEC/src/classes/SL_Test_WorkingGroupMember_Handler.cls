@isTest
private class SL_Test_WorkingGroupMember_Handler {
    
    /*
        * MethodName : setup()
        * Param      : 
        * Description: Generic method to create Account, Contact and Deal records..
	*/
    @testSetup static void setup() {
        // Inserting Account record..
        Account objAcc = new Account(Name = 'TestAcc-001');
        insert objAcc;
        system.assert(objAcc.Id != NULL);

        // Inserting Contact record.
        Contact objCon = new Contact(LastName = 'Test - 00001', Email = 'Test@test.com', AccountId = objAcc.Id);
        insert objCon;
        system.assert(objCon.Id != NULL);

        // Inserting Deal record..
        Deal__c objDeal = new Deal__c(Box_ID__c = '12323',Deal_Status__c = 'Bid/Active', AS_Team_Rollup__c = 'New',  Name='Test Deal - 01', Salesforce_Company__c =objAcc.ID,  Close_Date__c = Date.today());
        insert objDeal;
        system.assert(objDeal.Id != NULL);
    }

    @isTest static void test_method_ForUpdatingTheOriginalCompany() {
    	Contact objCon = [Select Id From Contact Where LastName = 'Test - 00001' AND Email = 'Test@test.com' limit 1];

    	Test.startTest();
    	// Inserting External Group record...
        External_Working_Group_Member__c objWGMember = new External_Working_Group_Member__c(Contact__c = objCon.Id);
        insert objWGMember;

        // It should update the related Contact.Account's Name..
        system.assertEquals([Select Original_Company__c From External_Working_Group_Member__c Where Id =: objWGMember.Id].Original_Company__c, 'TestAcc-001');
        Test.stopTest();
    }

    @isTest static void test_method_ForSyncStatus() {
    	Deal__c objDeal = [Select Id From Deal__c Where Name = 'Test Deal - 01' limit 1];

    	// inserting the custom setting values..
    	List<Status_Buckets__c> lstStatusBuckets = new List<Status_Buckets__c>{new Status_Buckets__c(Name = 'Active-1', Am_Sec_Status__c = 'Bid/Active'),
    																			new Status_Buckets__c(Name = 'Active-2', Am_Sec_Status__c = 'Idea')};
    	insert lstStatusBuckets;

    	Test.startTest();
	    	// Inserting External Group record...
	        External_Working_Group_Member__c objWGMember = new External_Working_Group_Member__c(Deal__c = objDeal.Id);
	        insert objWGMember;
        Test.stopTest();
    }    
}