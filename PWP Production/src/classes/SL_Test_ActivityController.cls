/**
* \arg ClassName      : SL_Test_ActivityController
* \arg JIRATicket     : PWP-10, PWP-116
* \arg CreatedOn      : 15/JAN/2015
* \arg LastModifiedOn : 08/AUG/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani, Harsh
* \arg Description    : This class serves as test class for SL_ActivityController class.
*/
@isTest
private class SL_Test_ActivityController 
{
    static Event objEvent;
    static Task objTask;
    // static List<Coverage_Team_Members__c> lstCoverageTeamMember;
    static List<AccountTeamMember> lstAccountTeamMember;
    static List<Account> lstAccount;
    static List<User> lstUser;
    
    //calling method to prepare data
    private static void createData()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        lstUser = new List<User> {
                                    new User(Alias = 'User111', Email='user1@user.com', 
                                            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                            LocaleSidKey='en_US', ProfileId = p.Id, 
                                            TimeZoneSidKey='America/Los_Angeles', UserName='userTAC-01@user11.com'),
                                    new User(Alias = 'User211', Email='user2@user.com', 
                                            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                                            LocaleSidKey='en_US', ProfileId = p.Id, 
                                            TimeZoneSidKey='America/Los_Angeles', UserName='userTAC-02@user12.com')
                                };
        insert lstUser;
        
        lstAccount = new List<Account>{
                                        new Account(Name = 'Account1'),
                                        new Account(Name = 'Account2')
                                      };
        insert lstAccount;
        
        lstAccountTeamMember = new List<AccountTeamMember>{
                                                            new AccountTeamMember(AccountId = lstAccount[0].Id, UserId = lstUser[0].Id, TeamMemberRole = 'Coverage Team Member'),
                                                            new AccountTeamMember(AccountId = lstAccount[1].Id, UserId = lstUser[1].Id, TeamMemberRole = 'Coverage Team Member')
                                                          };
        insert lstAccountTeamMember;
        
        // Create Task Record
        objTask = new Task(Status = 'Open', Subject = 'test1', WhatId = lstAccount[0].Id, OwnerId = lstUser[0].Id);
        insert objTask;                                          
                                                    
        // Create Event Record
        objEvent = new Event(Subject = 'test2', WhatId = lstAccount[0].Id, StartDateTime = Datetime.now(), EndDateTime = Datetime.now(), OwnerId = lstUser[0].Id);
        insert objEvent;
        
        ApexPages.StandardController sc = new ApexPages.standardController(objEvent);  
        SL_ActivityController objController = new SL_ActivityController(sc);
        objController.ShowSubject();
    }
    
    static testMethod void checkForTask()
    {
        createData();
        System.runAs(lstUser[0])
        {
	        ApexPages.StandardController sc = new ApexPages.standardController(objTask);  
	        SL_ActivityController objController = new SL_ActivityController(sc);
	        System.assertEquals(objController.showSubject(),null);
        }
    }
    
    static testMethod void checkForEvent()
    {
        createData();
        System.runAs(lstUser[0])
        {
	        ApexPages.StandardController sc = new ApexPages.standardController(objEvent);  
	        SL_ActivityController objController = new SL_ActivityController(sc);
	        System.assertEquals(objController.showSubject(),null);
        }
    }
    
    static testMethod void checkForNullWhatId()
    {
    	Task objTask1 = new Task(Status = 'Open', Subject = 'test1', WhatId = null); 
        insert objTask1;
        System.runAs(new User(Id = Userinfo.getUserId()))
        {
	        ApexPages.StandardController sc = new ApexPages.standardController(objTask1);  
	        SL_ActivityController objController = new SL_ActivityController(sc);
        } 
    }
    
    static testMethod void ActivityNoAccess()
    {
    	createData(); 
	    Apexpages.currentPage().getParameters().put('Id', lstAccount[0].Id);
        SL_Activity_NoAccess objController = new SL_Activity_NoAccess();
        objController.cancel();
    }
}