/**
 * This class contains unit tests for validating the behavior off class SL_DealSharingCompliance_Batch
 * author Vlad Gumenyuk 
 * date 12/20/2012
 * see https://silverline.jira.com/browse/WP-58
 * Test for SL_DealSharingCompliance_Batch and SL_DealSharingCompliance_Scheduler
 */
@isTest(SeeAllData=true)
private class SL_Test_DealSharingCompliance_Batch {

    static testMethod void test_DealSharingCompliance_Batch() {

        Profile Prof1 = [Select id,name FROM Profile WHERE name = 'Standard User']; 

        User user_run1 = new User(
          Username='test211@testuser1.com',
          Alias='Test211',
          Email='test211@testuser1.com',
          LastName='Test LastV 211', 
          TimeZoneSidKey='Europe/Prague', 
          LocaleSidKey='uk', 
          EmailEncodingKey='ISO-8859-1', 
          ProfileId=Prof1.Id, 
          IsActive=true
          ,LanguageLocaleKey='sv'
          ,Initials__c = 'TUZ'
        );
        insert user_run1;

        String user_run = UserInfo.getUserId();

       RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Account' limit 1];
      
        // Create dummy account
        Account testAccount = new Account(
          Name='Test Account 001',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;

            RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
        
        Contact testContact = new Contact(
          AccountId = testAccount.Id
         ,LastName = 'Test Contact Name'
         ,Title = 'Test Title Contact'
         ,RecordTypeId = ContRecTypeId.Id
         ,User_ID__c = UserInfo.getUserId()
        );
        insert testContact;
        
        Deal__c testDeal = new Deal__c(
             Name = 'Test Deal 012'
           , Company__c = testAccount.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           /*
           , Target_Sectors__c = 'Energy'
           , RecordTypeId = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Addon_Deal' AND r.SobjectType = 'Deal__c' LIMIT 1].Id
           */
           , RecordTypeId = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Portfolio_Company' AND r.SobjectType = 'Deal__c' LIMIT 1].Id
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Early-Prospect'
           , Is_Energy_Opportunity__c = 'No'
//           , Expense_Code__c ='JAAUY' 
        );
        insert testDeal;

       Test.startTest();
       
        SLDealSharingCompliance__c testDealSharingCompliance = new SLDealSharingCompliance__c(
//              SetupOwnerId = user_run.Id
              SetupOwnerId = user_run
            , Name = 'Test SLDealSharingCompliance'
//            , LastRunTime__c = DateTime.parse('10/14/2012 11:46 AM')   
            , LastRunTime__c = DateTime.now()
        );
        insert testDealSharingCompliance;
        
        List<Deal__Share> list_deal_share = new List<Deal__Share>();
        Deal__Share testDealShare = new Deal__Share(
              UserOrGroupId = user_run1.Id
//              UserOrGroupId = user_run
            , ParentId = testDeal.Id
            , RowCause = 'Manual'  
//            , AccessLevel = 'Edit'
            , AccessLevel = 'Read'
        );
        list_deal_share.add(testDealShare);
        insert list_deal_share;
/*
//         SL_DealSharingCompliance_Batch dscb2 = new SL_DealSharingCompliance_Batch('Select UserOrGroupId, ParentId, LastModifiedDate, LastModifiedById, Id From Deal__Share where RowCause=\'Manual\' and LastModifiedDate > 2012-12-12T00:00:00Z LIMIT 100');
         SL_DealSharingCompliance_Batch dscb2 = new SL_DealSharingCompliance_Batch('Select UserOrGroupId, ParentId, LastModifiedDate, LastModifiedById, Id From Deal__Share where RowCause=\'Manual\' and LastModifiedDate > YESTERDAY LIMIT 100');
         Database.executebatch(dscb2,400);
//         List<Deal_Share_Compliance_Email__c> list_dsce = new List<Deal_Share_Compliance_Email__c>([Select d.Shared_Type__c, d.Shared_To_User__c, d.Shared_To_Name__c, d.Shared_By_User__c, d.Name, d.Id, d.Deal__c, d.DateTime_Shared__c From Deal_Share_Compliance_Email__c d WHERE d.Deal__c = :testDeal.Id and d.Shared_To_User__c = :user_run1.Id Limit 100]);
         List<Deal_Share_Compliance_Email__c> list_dsce = new List<Deal_Share_Compliance_Email__c>([Select d.Shared_Type__c, d.Shared_To_User__c, d.Shared_To_Name__c, d.Shared_By_User__c, d.Name, d.Id, d.Deal__c, d.DateTime_Shared__c From Deal_Share_Compliance_Email__c d WHERE d.Deal__c = :testDeal.Id Limit 100]);
         System.assert( list_dsce.size() > 0 );
*/
         SL_DealSharingCompliance_Batch dscb = new SL_DealSharingCompliance_Batch();
         Database.executebatch(dscb,400);

         SL_DealSharingCompliance_Batch dscb3 = new SL_DealSharingCompliance_Batch('Select UserOrGroupId, ParentId, LastModifiedDate, LastModifiedById, Id From Deal__Share where RowCause=\'Manual\' LIMIT 100');
         Database.executebatch(dscb3,400);

       Test.stopTest();

    }

    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
 
    @isTest(SeeAllData=true)
    static void test_DealSharingCompliance_Scheduler() {
       Test.startTest();
         // Schedule the test job 
         String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new SL_DealSharingCompliance_Scheduler());
         // Get the information from the CronTrigger API object 
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
           NextFireTime
           FROM CronTrigger WHERE id = :jobId];
         // Verify the expressions are the same 
         System.assertEquals(CRON_EXP, 
           ct.CronExpression);
         // Verify the job has not run 
         System.assertEquals(0, ct.TimesTriggered);
       Test.stopTest();
    }
    
}