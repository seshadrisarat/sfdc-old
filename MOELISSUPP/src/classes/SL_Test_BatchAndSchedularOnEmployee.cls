/*
* Class Name    : SL_Test_BatchAndSchedularOnEmployee
* JIRA Ticket   : Moelis-117
* Created on    : 20/11/2013
* Created by    : Sandeep
* Jira ticket   : http://silverline.jira.com/browse/Moelis-117
* Description   : test class for SL_BatchOnEmployee_SyncUser (Batch on Employee) and SL_SchedulerBatchOnEmployee 
*/
@isTest(SeeAllData=false)
public without sharing class SL_Test_BatchAndSchedularOnEmployee 
{
    private final static String strProfileId = [Select Id From Profile Where name = 'System Administrator' limit 1].Id;
    
    //Test case I: Batch on EmployeeProfile where User_ID__c is not null and Status__c is active 
    static testMethod void SL_Test_BatchEmployeeProfile() 
    {
        
        User objUser = new User(alias = 'user', email='test@user.com', title='test',
        emailencodingkey='UTF-8', lastName='testUser', languagelocalekey='en_US', localesidkey='en_US', profileid = strProfileId, timezonesidkey='America/Los_Angeles', userName='UserAug01@test.com');
        insert objUser;
        system.runAs(objUser)
        {
            test.startTest();
            SL_RecursionHelper.setisUpdate(false); //To avoid update via trigger
            SL_RecursionHelper.setisInsert(false); //To avoid User update after insert trigger
            //Creating Employee Data
            Employee_Profile__c objEmployee = new Employee_Profile__c(
            Title__c = 'Managing Director',
            MD_Promotion_Date__c = Date.today() + 1,
            Start_Date__c = Date.today(),
            Office_Location__c = 'New York',
            Last_Name__c = 'LTest', 
            Group__c = 'Restructuring & Recapitalization',
            First_Name__c = 'FTest',
            User_ID__c = objUser.Id, Status__c = 'Active' );
            insert objEmployee;
            
            SL_BatchOnEmployee_SyncUser objBatch = new SL_BatchOnEmployee_SyncUser();
            Database.executeBatch(objBatch, 100);
            
            test.stopTest();
            
            User objUser1 = [select Id, title from User where Id =:objUser.Id];
            //On insert of EmployeeProfile where User_ID__c is not null and Status__c is active, user title should be updated 
            system.assertEquals(objUser1.title,'Managing Director' );
        }
    }
    
    //Test case II: Batch on EmployeeProfile where  Status__c is inactive 
    static testMethod void SL_Test_BatchEmployee2() 
    {
        User objUser = new User(alias = 'user', email='test@user.com', title='test',
        emailencodingkey='UTF-8', lastName='testUser', languagelocalekey='en_US', localesidkey='en_US', profileid = strProfileId, timezonesidkey='America/Los_Angeles', userName='UserAug01@test.com');
        insert objUser;
        system.runAs(objUser)
        {
            test.startTest();
            SL_RecursionHelper.setisUpdate(false); //To avoid update via trigger
            SL_RecursionHelper.setisInsert(false); //To avoid User update after insert trigger
            //Creating Employee Data
            Employee_Profile__c objEmployee = new Employee_Profile__c(
            Title__c = 'Managing Director',
            MD_Promotion_Date__c = Date.today() + 1,
            Start_Date__c = Date.today(),
            Office_Location__c = 'New York',
            Last_Name__c = 'LTest', 
            Group__c = 'Restructuring & Recapitalization',
            First_Name__c = 'FTest',
            User_ID__c = objUser.Id, Status__c = 'Inactive' );
            insert objEmployee;
            
            SL_BatchOnEmployee_SyncUser objBatch = new SL_BatchOnEmployee_SyncUser();
            Database.executeBatch(objBatch, 100);
            
            test.stopTest();
            //On insert of EmployeeProfile where User_ID__c is not null and Status__c is inactive, user title should not be updated 
            User objUser1 = [select Id, title from User where Id =:objUser.Id];
            system.assertnotEquals(objUser1.title,'Managing Director' );
        }
    }
    

    //Test Shedular SL_SchedulerBatchOnEmployee
    static void SL_SchedulerBatchOnEmployee()
    {
        Test.startTest();
            
        SL_SchedulerBatchOnEmployee batchSchedule = new SL_SchedulerBatchOnEmployee();
        String scheduleBatch = '0 0 * * * ?';
        System.schedule('Sync User with Employee', scheduleBatch, batchSchedule);
        //To assert the schedular is scheduled 
        system.assertEquals(1,[select count() from AsyncApexJob where JobType = 'BatchApex' and status in ('Queued','Processing','Preparing')]);    
        Test.stopTest();
        
     }
}