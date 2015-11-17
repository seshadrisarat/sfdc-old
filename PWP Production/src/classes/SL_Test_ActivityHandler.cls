/**
* \arg ClassName      : SL_Test_ActivityHandler
* \arg JIRATicket     : PWP-20
* \arg CreatedOn      : 2015-03-9
* \arg LastModifiedOn : 
* \arg CreatededBy    : Edward Rivera
* \arg ModifiedBy     : 
* \arg Description    : This class serves as test class for SL_ActivityHandler class and the Activity triggers.
*/
@isTest
private class SL_Test_ActivityHandler
{
    static Event objEvent;
    static Task objTask;
    static List<Account> lstAccount;
    static List<User> lstUser;
    
    //calling method to prepare data
    static testmethod void testTaskAndEventTriggers()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        lstUser = new List<User> {
                                    new User(Alias = 'User111', Email='user1@user.com', 
                                            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                            LocaleSidKey='en_US', ProfileId = p.Id, 
                                            TimeZoneSidKey='America/Los_Angeles', UserName='user1kj1kj.212@user.com'),
                                    new User(Alias = 'User211', Email='user2@user.com', 
                                            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                                            LocaleSidKey='en_US', ProfileId = p.Id, 
                                            TimeZoneSidKey='America/Los_Angeles', UserName='userj11kj.464.2@user.com')
                                };
        insert lstUser;
        
        lstAccount = new List<Account>{
                                        new Account(Name = 'Account1'),
                                        new Account(Name = 'Account2')
                                      };
        insert lstAccount;
        
        // Create Task Record
        objTask = new Task(Status = 'Open', Subject = 'test1', WhatId = lstAccount[0].Id);
        insert objTask;                                          
                                                    
        // Create Event Record
        objEvent = new Event(Subject = 'test2', WhatId = lstAccount[0].Id, StartDateTime = Datetime.now(), EndDateTime = Datetime.now());
        insert objEvent;
        
        update objTask;
        update objEvent;

        delete objTask;
        delete objEvent;
    }
}