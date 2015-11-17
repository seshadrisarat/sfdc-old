/*
* Class Name    : SL_TestEmployeeProfileTrigger
* JIRA Ticket   : Moelis-116
* Created on    : 19/11/2013
* Created by    : Rahul Majumdar
* Jira ticket   : http://silverline.jira.com/browse/Moelis-116
* Description   : test class for SL_Employee_Profile trigger (trigger on Employee_Profile__c)
*/
@isTest(SeeAllData=false)
public class SL_TestEmployeeProfileTrigger 
{
    private final static String strProfileId = [Select Id From Profile Where name = 'System Administrator' limit 1].Id;
    //Test case I: On insert of EmployeeProfile where User_ID__c is not null and Status__c is active 
    static testMethod void SL_Test_CreateTransactionOnEmployeeInsert() 
    {
        
        User objUser = new User(alias = 'user', email='test@user.com', title='test',
        emailencodingkey='UTF-8', lastName='testUser', languagelocalekey='en_US', localesidkey='en_US', profileid = strProfileId, timezonesidkey='America/Los_Angeles', userName='UserAug01@test.com');
        insert objUser;
        system.runAs(objUser)
        {
            test.startTest();
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
            
            test.stopTest();
            
            User objUser1 = [select Id, title from User where Id =:objUser.Id];
            //On insert of EmployeeProfile where User_ID__c is not null and Status__c is active, user title should be updated 
            system.assertEquals(objUser1.title,'Managing Director' );
        }
    }
    
    //Test case II: On insert of EmployeeProfile where  Status__c is inactive, no transaction record is created 
    static testMethod void SL_TestInsertWithInactiveStatus() 
    {
        User objUser = new User(alias = 'user', email='test@user.com', title='test',
        emailencodingkey='UTF-8', lastName='testUser', languagelocalekey='en_US', localesidkey='en_US', profileid = strProfileId, timezonesidkey='America/Los_Angeles', userName='UserAug01@test.com');
        insert objUser;
        system.runAs(objUser)
        {
            test.startTest();
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
            
            test.stopTest();
            //On insert of EmployeeProfile where User_ID__c is not null and Status__c is inactive, user title should not be updated 
            User objUser1 = [select Id, title from User where Id =:objUser.Id];
            system.assertnotEquals(objUser1.title,'Managing Director' );
        }
    }
        
    //Test case III: On Update of EmployeeProfile where  Status__c is changed to active and one of the mentioned field has been changed 
    static testMethod void SL_Test_EmployeeUpdate() 
    {
        User objUser = new User(alias = 'user', email='test@user.com', title='test',
        emailencodingkey='UTF-8', lastName='testUser', languagelocalekey='en_US', localesidkey='en_US', profileid = strProfileId, timezonesidkey='America/Los_Angeles', userName='UserAug01@test.com');
        insert objUser;
        
        system.runAs(objUser)
        {
            test.startTest();
            //Creating Employee Data
            SL_RecursionHelper.setisUpdate(false);
            
            //Creating Assistant record 
            Employee_Profile__c objEmployee1 = new Employee_Profile__c(
            Title__c = 'Managing Director',
            MD_Promotion_Date__c = Date.today() + 1,
            Start_Date__c = Date.today(),
            Office_Location__c = 'New York',
            Last_Name__c = 'LTest', 
            Group__c = 'Restructuring & Recapitalization',
            First_Name__c = 'FTest', Name = 'LTest FTest',
            Status__c = 'Inactive' ); 
            insert objEmployee1;
            
            //Creating Employee record
            Employee_Profile__c objEmployee = new Employee_Profile__c(
            Title__c = 'Managing Director',
            MD_Promotion_Date__c = Date.today() + 1,
            Start_Date__c = Date.today(),
            Office_Location__c = 'New York',
            Last_Name__c = 'LTest', 
            Group__c = 'Restructuring & Recapitalization',
            First_Name__c = 'FTest',
            User_ID__c = objUser.Id, Assistant__c = objEmployee1.Id, Status__c = 'Inactive' );
            insert objEmployee;
            
            
            //On insert of EmployeeProfile where User_ID__c is not null and Status__c is inactive, user title should not be updated 
            User objUser1 = [select Id, title from User where Id =:objUser.Id];
            system.assertnotEquals(objUser1.title,'Managing Director' );
            
            SL_RecursionHelper.setisUpdate(true);
            objEmployee.Status__c = 'Active';
            objEmployee.Mobile_Phone__c = '476546758';
            update objEmployee;
            test.stopTest();
            //On insert of EmployeeProfile  Status__c is active and any one of the field mentioned is updated, user title should be updated 
            User objUser2 = [select Id, title ,Assistant_1__c from User where Id =:objUser.Id];
            system.assertEquals(objUser2.title,'Managing Director' );
            system.assertEquals(objUser2.Assistant_1__c,'FTest LTest' );
        }
    }
}