@isTest(seeAllData = true)
public class SL_test_AccountChildrenActivities {
    static testmethod void testPage(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        List<User> lstTestUsers = new List<User>{new User(Alias = 'standt', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1.amps@testorg.com'),
            
            new User(Alias = 'standt', Email='standarduser2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2.amps@testorg.com'),
            
            new User(Alias = 'standt', Email='standarduser4@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser3.amps@testorg.com'),
            
            new User(Alias = 'standt', Email='standarduser4@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser4.amps@testorg.com'),
            
            new User(Alias = 'standt', Email='standarduser5@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser5.amps@testorg.com'),
            
            new User(Alias = 'standt', Email='standarduse6@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser6.amps@testorg.com'),
            
            new User(Alias = 'standt', Email='standarduser7@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduse7.amps@testorg.com')
        };
        
        insert lstTestUsers;
        
        Account objPractice = new Account(Name = 'Test');
        insert objPractice;
        
        List<Laser__c> lstLasersToInsert = new List<Laser__c>{
             new Laser__c(Name='Sculpsure Laser'),
             new Laser__c(Name='Ions Laser')
        };
        
        insert lstLasersToInsert;
        
        List<Laser_Owned__c> lstLaserOwned = new List<Laser_Owned__c>{
            new Laser_Owned__c(Practice__c = objPractice.Id , Laser__c = lstLasersToInsert[0].Id , User_1__c = lstTestUsers[0].Id , Purchase_Date__c = date.today()),
            new Laser_Owned__c(Practice__c = objPractice.Id , Laser__c = lstLasersToInsert[1].Id , User_1__c = lstTestUsers[0].Id , Purchase_Date__c = date.today())
        };
        
        insert lstLaserOwned;
        
        List<Task> lstTaskToInsert = new List<Task>{
            new Task(Subject = 'Test Subject - 1' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[0].Id),
            new Task(Subject = 'Test Subject - 2' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[0].Id),
            new Task(Subject = 'Test Subject - 3' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[0].Id),
            new Task(Subject = 'Test Subject - 4' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[0].Id),
            new Task(Subject = 'Test Subject - 5' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[0].Id),
            new Task(Subject = 'Test Subject - 6' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[1].Id),
            new Task(Subject = 'Test Subject - 7' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[1].Id),
            new Task(Subject = 'Test Subject - 8' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[1].Id),
            new Task(Subject = 'Test Subject - 9' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[1].Id),
            new Task(Subject = 'Test Subject - 10' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[1].Id)
        };
        
        insert lstTaskToInsert;
        
        List<Event> lstEventToInsert = new List<Event>{
            new Event(Subject = 'Test Subject Event - 1' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[0].Id ,
                      StartDateTime = Datetime.now() , EndDateTime = Datetime.now().addDays(10)),
            new Event(Subject = 'Test Subject Event - 2' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[0].Id ,
                      StartDateTime = DateTime.now() , EndDateTime = DateTime.now().addDays(10)),
            new Event(Subject = 'Test Subject Event - 3' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[0].Id ,
                      StartDateTime = DateTime.now() , EndDateTime = DateTime.now().addDays(10)),
            new Event(Subject = 'Test Subject Event - 4' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[1].Id ,
                      StartDateTime = DateTime.now() , EndDateTime = DateTime.now().addDays(10)),
            new Event(Subject = 'Test Subject Event - 5' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[1].Id ,
                      StartDateTime = DateTime.now() , EndDateTime = DateTime.now().addDays(10)),
            new Event(Subject = 'Test Subject Event - 6' , AMPS_Task_Type__c = 'New Customer Welcome' , WhatId = lstLaserOwned[1].Id ,
                      StartDateTime = DateTime.now() , EndDateTime = DateTime.now().addDays(10))
        };
        
        insert lstEventToInsert;
        
     	SL_ctrl_AccountChildrenActivities aca = new SL_ctrl_AccountChildrenActivities(new ApexPages.StandardController(objPractice));  
        aca.getItems();
        
        aca.strFilterOpt = 'AMPS Activities';
        aca.updatePage();
        
        aca.strFilterOpt = 'Sculpsure Activities';
        aca.updatePage();
        
        System.assert(aca.getLasersOwned().length() > 0);
    }
}