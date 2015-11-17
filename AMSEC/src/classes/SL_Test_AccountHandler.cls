@isTest
private class SL_Test_AccountHandler {
	
	/*
        * MethodName : setup()
        * Param      : 
        * Description: Generic method to create Account, Contact and Deal records..
        */
        @testSetup static void setup() {
        // inserting the custom setting values..
        List<Status_Buckets__c> lstStatusBuckets = new List<Status_Buckets__c>{new Status_Buckets__c(Name = 'Active-1', Am_Sec_Status__c = 'Bid/Active'),
                                                                                new Status_Buckets__c(Name = 'Active-2', Am_Sec_Status__c = 'Idea')};
        insert lstStatusBuckets;
        }

        @isTest static void test_Deal_Folders() {
        	Id portFolioRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Portfolio Company').RecordTypeId;

                Id formerPortfolioRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Former_Portfolio'].Id;

                Account objAcc = new Account(Name = 'Test_New_Acc-00', Alt_Box_Folder_Name__c = 'Test New');
                insert objAcc;

                External_Working_Group_Member__c objWGM = new External_Working_Group_Member__c(Company__c = objAcc.Id);
                insert objWGM;
 
                // Inserting a single deal record..with out Company..
                Deal__c objDeal = new Deal__c(Box_ID__c =  '1231', Salesforce_Company__c = objAcc.Id, Name='testDeal-000', Process_Status__c = 'Open', Deal_Status__c = 'Idea');
                insert objDeal;


                Test.startTest();
                // Updating account RecordType and Name so the batch will get called.....
                objAcc.RecordTypeId = portFolioRecTypeId;
                update objAcc;

                // Updating account Alt_Box_Folder_Name__c and Name so the batch will get called.....
                objAcc.Alt_Box_Folder_Name__c = 'LLLAATTEESST';
                objAcc.RecordTypeId = portFolioRecTypeId;
                update objAcc;

                // making Alt_Box_Folder_Name to NULL, so the folder Name will be the Acc Name
                objAcc.Alt_Box_Folder_Name__c = NULL;
                objAcc.Name = 'Test_Test';
                update objAcc;

                delete objAcc;
                Test.stopTest();

                // Calling the undelete event of Account record..
                undelete objAcc;

                objAcc.RecordTypeId = formerPortfolioRecTypeId;
                update objAcc;
	}
	
	
}