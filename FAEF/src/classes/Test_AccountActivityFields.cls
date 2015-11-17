@isTest
public with sharing class Test_AccountActivityFields {
    
    public static testmethod void test() {
        
        Id sysAdminProfileId = [select Id from Profile where Name = 'System Administrator' limit 1].Id;
        Id sysAdminRoleId = [select Id from UserRole where Name = 'System Administrator - IT' limit 1].Id;
        Id salesProfileId = [select Id from Profile where Name = 'Sales - CAO' limit 1].Id;
        Id salesRoleId = [select Id from UserRole where Name = 'Sales - CAO HealthCare - East' limit 1].Id;
        
        User adminUser = new User(
            FirstName = 'ADMxxxyyyzzztest',
            LastName = 'ADMxxxyyyzzztest',
            Email = 'ADMxxxyyyzzztest' + '@xxxyyyzzztesttest.com',
            Username = 'ADMxxxyyyzzztest' + '@xxxyyyzzztest.com',
            ProfileId = sysAdminProfileId,
            UserRoleId = sysAdminRoleId,
            Alias = 'ADM00001',
            TimeZoneSidKey = 'America/New_York  ',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
          
        insert adminUser;
        
        User salesUser = new User(
            FirstName = 'Sxxxyyyzzztest',
            LastName = 'Sxxxyyyzzztest',
            Email = 'Sxxxyyyzzztest' + '@xxxyyyzzztesttest.com',
            Username = 'Sxxxyyyzzztest' + '@xxxyyyzzztest.com',
            ProfileId = salesProfileId,
            UserRoleId = salesRoleId,
            Alias = 'S00002',
            TimeZoneSidKey = 'America/New_York  ',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        
        insert salesUser;
        
        Account a;
        Contact c;
        
        system.runAs(adminUser) {
            a = new Account(Name = 'Test');
            insert a;
            system.debug(a);
            
            AccountShare share = new AccountShare();
            share.AccountId = a.Id;
            share.UserOrGroupId = salesUser.Id;
            share.AccountAccessLevel = 'Read';
            share.OpportunityAccessLevel = 'Read';
            share.CaseAccessLevel = 'Read';
            
            Database.SaveResult sr = Database.insert(share, false);
            system.debug(sr.isSuccess());
            system.debug(sr.getErrors());
            system.debug(sr.getId());
        }
        
        system.runAs(salesUser) {
        
            Task t = new Task(
                WhatId = a.Id,
                Subject = 'Test',
                Status = 'Not Started',
                Priority = 'Normal',
                Type = 'ABC',
                ActivityDate = Date.today().addDays(5)
            );
            
            system.debug(t);
            
            insert t;  
            
            Task t2 = new Task(
                WhatId = a.Id,
                Subject = 'Test',
                Status = 'Completed',
                Priority = 'Normal',
                Type = 'XYZ',
                ActivityDate = Date.today().addDays(-10)
            );
            insert t2;
            
            a = [select Id, Next_Activity_Date__c, Last_Activity_Type2__c from Account where Id = :a.Id limit 1];
            system.debug(a);
            //system.assertEquals(a.Next_Activity_Date__c, Date.today().addDays(5));
            //system.assertEquals(a.Last_Activity_Type2__c, 'XYZ');
            
            Event e = new Event(  
                WhatId = a.Id,  
                Subject = 'Test',
                Type = 'AAA',
                DurationInMinutes = 60,
                ActivityDate = Date.today().addDays(2),  
                ActivityDateTime = DateTime.now().addDays(2)
            );    
            insert e;
            
            Event e2 = new Event(
                WhatId = a.Id,
                Subject = 'Test',
                Type = 'ZZZ',
                DurationInMinutes = 60,
                ActivityDate = Date.today().addDays(-5),
                ActivityDateTime = DateTime.now().addDays(-5)
            );
            insert e2;
            
            a = [select Id, Next_Activity_Date__c, Last_Activity_Type2__c from Account where Id = :a.Id limit 1];
            system.debug(a);
            //system.assertEquals(a.Next_Activity_Date__c, Date.today().addDays(2));
            //system.assertEquals(a.Last_Activity_Type2__c, 'ZZZ');
        
        }
        
        
    }
    
}