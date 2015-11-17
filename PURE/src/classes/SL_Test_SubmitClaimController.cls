@isTest
private class SL_Test_SubmitClaimController 
{
    static testMethod void myUnitTest() 
    {
        Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Pure Customer Community Login User'];
        
        Profile objStandardUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        Profile objGuestUserProfile = [Select Id From Profile WHERE Name = 'Guest License User'];
        
        Profile objBrokerViewProfile = [Select Id From Profile WHERE Name = 'PURE Broker View Partner Login User'];
        
        RecordType objRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Member' limit 1];
        RecordType objRecordtypeBroker = [Select Id from RecordType where SobjectType =:'Account' AND Name='Broker' limit 1];

        Account objAccount1 = new Account(Name='TestSandeep1', RecordTypeId = objRecordtypeBroker.Id, Broker_Status__c = 'Suspended With Access', OwnerId = UserInfo.getUserId());
        insert objAccount1;
        
        List<Account> lstAccount = new List<Account>{new Account(Name = 'Test Account', RecordTypeId = objRecordtype.Id, Broker_Status__c = 'Suspended With Access', OwnerId = [Select Id from User where UserRoleId != null limit 1].Id),
                                                     new Account(Name = 'Test Account 1', RecordTypeId = objRecordtype.Id,Broker__c = objAccount1.Id,Broker_Status__c = 'Suspended With Access',  OwnerId = [Select Id from User where UserRoleId != null limit 1].Id)
                                                    };
        insert lstAccount;
        
        List<Contact> lstContact = new List<Contact>{new Contact(LastName = 'Test Contact', AccountId = lstAccount[0].Id),
                                                     new Contact(LastName = 'Test Contact 1', AccountId = lstAccount[1].Id)
                                                    };
        insert lstContact;
        
        List<PortalURLMap__c> lstPortalURlMap = new List<PortalURLMap__c>{new PortalURLMap__c(Name = 'SubmitClaim', URL__c = 'https://soartest.glassclaim.com/v1/Default.aspx?ClientTag=031B743C-23A1-4D98-A24B-E2D68FC330BA')
                                                                         };
        insert lstPortalURlMap;
        
        List<Policy__c> lstPolicy = new List<Policy__c>{new Policy__c(Member__c = lstAccount[0].Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c=true, Policy_Number__c='1222'),
                                                        new Policy__c(Member__c = lstAccount[0].Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c = true, Policy_Number__c='1223'),
                                                        new Policy__c(Member__c = lstAccount[0].Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c=true, Policy_Number__c='1224'),
                                                        new Policy__c(Member__c = lstAccount[1].Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c=true, Policy_Number__c='1225'),
                                                        new Policy__c(Member__c = lstAccount[1].Id,Policy_Status__c='In-Force',User_Description__c = 'Test User Description',Integration_Description__c='Test Integration Description',IsIndividuallyBilled__c=true, Policy_Number__c='1226')
                                                        };
                                                    
        insert lstPolicy; 
        
        List<Vehicle__c> lstVehicle = new List<Vehicle__c>{new Vehicle__c(Name = 'Test Vehicle 1', Make__c = 'Test Make', Model__c = 'Test Model', VIN__c = 'Test VIN', Year__c = 1990, Policy__c = lstPolicy[0].Id),
                                                           new Vehicle__c(Name = 'Test Vehicle 1', Make__c = 'Test Make1', Model__c = 'Test Model1', VIN__c = 'Test VIN1', Year__c = 1991, Policy__c = lstPolicy[1].Id)
                                                          };
        insert lstVehicle;
                                                            
        List<Covered_Vessels__c> lstCoveredVessels = new List<Covered_Vessels__c>{new Covered_Vessels__c(Name = 'Test Vessel', Horsepower__c = 1220, Hull_Value__c = 1220, Length__c = '12', Make__c = 'Test Make', Model__c = 'Test Model', Year__c = 1990, Policy__c = lstPolicy[0].Id),
                                                                                  new Covered_Vessels__c(Name = 'Test Vessel1', Horsepower__c = 1220, Hull_Value__c = 1220, Length__c = '12', Make__c = 'Test Make', Model__c = 'Test Model1', Year__c = 1990, Policy__c = lstPolicy[0].Id),
                                                                                  new Covered_Vessels__c(Name = 'Test Vessel2', Horsepower__c = 1220, Hull_Value__c = 1220, Length__c = '12', Make__c = 'Test Make', Model__c = 'Test Model2', Year__c = 1990, Policy__c = lstPolicy[0].Id)
                                                                                 };
        insert lstCoveredVessels;
        
        User objHpdProviderUser = new User(Alias = 'HPD2', Email='standarduser2@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@testorg.com' , ContactID = lstContact[0].Id);              
                             
        
        
        User objStandardUser = new User(Alias = 'HPD5', Email='standarduser5@testorg.com', 
                                        EmailEncodingKey='UTF-8', LastName='Testing5', LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', ProfileId = objStandardUserProfile.Id, 
                                        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser5@testorg.com');
        
        
        User objGuestUser = new User(Alias = 'HPD6', Email='standarduser6@testorg.com', 
                                                 EmailEncodingKey='UTF-8', LastName='Testing6', LanguageLocaleKey='en_US', 
                                                 LocaleSidKey='en_US', ProfileId = objGuestUserProfile.Id, 
                                                 TimeZoneSidKey='America/Los_Angeles', UserName='guestuseree6@testorg.com');
        
        User objBrokerUser = new User(Alias = 'HPD6', Email='standarduser6@testorg.com', 
                                                 EmailEncodingKey='UTF-8', LastName='Testing6', LanguageLocaleKey='en_US', 
                                                 LocaleSidKey='en_US', ProfileId = objBrokerViewProfile.Id, ContactId = lstContact[1].Id,
                                                 TimeZoneSidKey='America/Los_Angeles', UserName='guestu22seree6@testorg.com');
        
        system.runAs(new User(Id=UserInfo.getUserId()))
        {
            Test.startTest();
                insert objHpdProviderUser;
                insert objStandardUser;
            Test.stopTest();
        }   
       
        System.runAs(objHpdProviderUser) 
        {   
            SL_SubmitClaimController objSL_SubmitClaimController = new SL_SubmitClaimController();
            objSL_SubmitClaimController.pageAction();
            objSL_SubmitClaimController.strFileName = 'Test File';
            objSL_SubmitClaimController.emailSend();
            objSL_SubmitClaimController.selectedClaimType = 'homeowners';
            objSL_SubmitClaimController.emailSend();
            objSL_SubmitClaimController.selectedClaimType = 'collections';
            objSL_SubmitClaimController.emailSend();
            objSL_SubmitClaimController.selectedClaimType = 'watercraft';
            objSL_SubmitClaimController.emailSend();
            objSL_SubmitClaimController.selectedClaimType = 'flood';
            objSL_SubmitClaimController.emailSend();
            objSL_SubmitClaimController.selectedClaimType = 'auto';
            objSL_SubmitClaimController.emailSend();
            objSL_SubmitClaimController.selectedClaimType = 'workers_compensation';
            objSL_SubmitClaimController.emailSend();
            objSL_SubmitClaimController.dummyfunction();
        }
        /*Added by Sanath*/
       /* System.runAs(new User(Id=UserInfo.getUserId())) 
        {
            insert new Agency_Contact__c(Contact__c=lstContact[0].Id , User_Status__c = 'Active',Agency__c=lstAccount[0].Id);
            SL_SubmitClaimController objSL_SubmitClaimController = new SL_SubmitClaimController();
            objSL_SubmitClaimController.pageAction();
        }*/
        /*Added by Sanath*/
        
        System.runAs(objStandardUser) 
        {
            insert new Agency_Contact__c(Contact__c=lstContact[0].Id , User_Status__c = 'Active',Agency__c=lstAccount[0].Id);
            Apexpages.currentPage().getParameters().put('mId',lstAccount[0].Id);
            SL_SubmitClaimController objSL_SubmitClaimController = new SL_SubmitClaimController();
            objSL_SubmitClaimController.memberName = 'Test';
            objSL_SubmitClaimController.memberNumber = '234444';
            objSL_SubmitClaimController.imageSize = 8900;
            objSL_SubmitClaimController.pageAction();
        }
        
        insert new Agency_Contact__c(Contact__c=lstContact[1].Id , User_Status__c = 'Active',Agency__c=lstAccount[0].Id);
        System.runAs(objBrokerUser)
        {  
            Apexpages.currentPage().getParameters().put('mId',lstAccount[0].Id);
            SL_SubmitClaimController objSL_SubmitClaimController = new SL_SubmitClaimController();
            objSL_SubmitClaimController.pageAction();
        }
        
        /* Start - Added by Pankaj Ganwani on 15/JUNE/2015 */
        System.runAs(objGuestUser)
        {
            SL_SubmitClaimController objSL_SubmitClaimController = new SL_SubmitClaimController();
            objSL_SubmitClaimController.pageAction();
        }
        /* End - Added by Pankaj Ganwani on 15/JUNE/2015 */
    }
}