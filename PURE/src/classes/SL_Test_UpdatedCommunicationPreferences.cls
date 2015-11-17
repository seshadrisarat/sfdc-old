@isTest
public with sharing class SL_Test_UpdatedCommunicationPreferences 
{
	static testMethod void updatedCommPreftest() 
    {
	    Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Pure Customer Community Login User'];
        
        RecordType objRecordtype = [Select Id from RecordType where SobjectType =:'Account' AND Name='Member' limit 1];
        
        List<Account> lstAccount = new List<Account>{new Account(Name = 'Test Account', RecordTypeId = objRecordtype.Id, Billing_Document_Delivery_Method__c = 'Electronic', OwnerId = [Select Id from User where UserRoleId != null limit 1].Id),
        											 new Account(Name = 'Test Account 1', RecordTypeId = objRecordtype.Id, Billing_Document_Delivery_Method__c = 'Paper', OwnerId = [Select Id from User where UserRoleId != null limit 1].Id)
        											};
        insert lstAccount;
        
        List<Contact> lstContact = new List<Contact>{new Contact(LastName = 'Test Contact', AccountId = lstAccount[0].Id),
        											 new Contact(LastName = 'Test Contact 1', AccountId = lstAccount[1].Id)
        											};
        insert lstContact;
        
        User objHpdProviderUser = new User(Alias = 'HPD4', Email='standarduser4@testorg.com', 
                                             EmailEncodingKey='UTF-8', LastName='Testing4', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = objCommunityUserProfile.Id, 
                                             TimeZoneSidKey='America/Los_Angeles', UserName='standarduser4@testorg.com' , ContactID = lstContact[0].Id);              
                             
        insert objHpdProviderUser;
        
        List<Contact_Info__c> lstContactInfo = new List<Contact_Info__c>{new Contact_Info__c(Phone__c = '304042',Email__c = 'test@silverlinecrm.com',Type__c = 'Email', Account__c = lstAccount[0].Id, Is_Primary__c = true, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Receive_Company_Updates__c = true, Receive_PURE_Press__c= true,Receive_PURE_Situation_Room__c= true,Receive_PURE_Prevention__c= true,Receive_Annual_Report__c= true,Receive_SSA_Statements__c= true,Receive_PURE_Events__c= true,Is_Updated__c =true),
        																  new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm.com',Type__c = 'Phone', Account__c = lstAccount[0].Id, Is_Primary__c = true, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Receive_Company_Updates__c = true, Receive_PURE_Press__c= true,Receive_PURE_Situation_Room__c= true,Receive_PURE_Prevention__c= true,Receive_Annual_Report__c= true,Receive_SSA_Statements__c= true,Receive_PURE_Events__c= true,Is_Updated__c =true),
        																  new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm.com',Type__c = 'Billing', Account__c = lstAccount[0].Id, Is_Primary__c = true, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Receive_Company_Updates__c = true, Receive_PURE_Press__c= true,Receive_PURE_Situation_Room__c= true,Receive_PURE_Prevention__c= true,Receive_Annual_Report__c= true,Receive_SSA_Statements__c= true,Receive_PURE_Events__c= true,Is_Updated__c =true),
        																  new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm.com',Type__c = 'Mailing', Account__c = lstAccount[0].Id, Is_Primary__c = true, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Receive_Company_Updates__c = true, Receive_PURE_Press__c= true,Receive_PURE_Situation_Room__c= true,Receive_PURE_Prevention__c= true,Receive_Annual_Report__c= true,Receive_SSA_Statements__c= true,Receive_PURE_Events__c= true,Is_Updated__c =true),
        																  new Contact_Info__c(Phone__c = '3040400',Email__c = 'test@silverlinecrm.com',Type__c = 'Mailing', Account__c = lstAccount[0].Id, Is_Primary__c = false, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Receive_Company_Updates__c = true, Receive_PURE_Press__c= true,Receive_PURE_Situation_Room__c= true,Receive_PURE_Prevention__c= true,Receive_Annual_Report__c= true,Receive_SSA_Statements__c= true,Receive_PURE_Events__c= true),
        																  new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm.com',Type__c = 'Phone-Home', Account__c = lstAccount[0].Id, Is_Primary__c = true, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Receive_Company_Updates__c = true, Receive_PURE_Press__c= true,Receive_PURE_Situation_Room__c= true,Receive_PURE_Prevention__c= true,Receive_Annual_Report__c= true,Receive_SSA_Statements__c= true,Receive_PURE_Events__c= true),
        																  new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm.com',Type__c = 'Billing', Account__c = lstAccount[0].Id, Is_Primary__c = true, Street__c = 'Broadway1', City__c = 'Los Angeles', State__c = 'CA', Zip__c = '039334', Street_2__c = '21th',Receive_Company_Updates__c= false, Receive_PURE_Press__c= false,Receive_PURE_Situation_Room__c= false,Receive_PURE_Prevention__c= false,Receive_Annual_Report__c= false,Receive_SSA_Statements__c= false,Receive_PURE_Events__c= false,Is_Updated__c =true)
        																};
        
        insert lstContactInfo;
         
        System.runAs(objHpdProviderUser)
        {
        	SL_UpdatedCommunicationPreferences objCommPref = new SL_UpdatedCommunicationPreferences();
        	objCommPref.getObjAccount();
        }
    } 
}