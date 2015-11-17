/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@isTest
private class SL_Test_UpdatedMemberContInfo 
{
	static testMethod void myUnitTest() 
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
        
        List<Contact_Info__c> lstContactInfo = new List<Contact_Info__c>{new Contact_Info__c(Phone__c = '304042',Email__c = 'test@silverlinecrm.com',Is_Primary__c =true,Type__c = 'Email', Account__c = lstAccount[0].Id, Is_Updated__c = true, Is_Primary_Changed__c = true,Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th'),
        															     new Contact_Info__c(Phone__c = '304042',Email__c = 'test@silverlinecrm.com',Type__c = 'Email', Account__c = lstAccount[0].Id, Is_Updated__c = true, Is_Primary_Changed__c = true,Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Was_Last_Primary__c = true),
        														    	 new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm1.com',Type__c = 'Billing', Account__c = lstAccount[0].Id, Is_Updated__c = false, Is_Primary_Changed__c = true,Was_Last_Primary__c = true,Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th'),
        																 new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm4.com',Type__c = 'Phone-Home', Is_Primary__c =true ,Is_Primary_Changed__c = true,Account__c = lstAccount[0].Id, Is_Updated__c = true, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th'),
        																 new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm4.com',Type__c = 'Phone-Home', Is_Primary_Changed__c = true,Was_Last_Primary__c = true,Account__c = lstAccount[0].Id, Is_Updated__c = true, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th'),
        																 new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm5.com',Type__c = 'Billing', Is_Primary__c =true,Account__c = lstAccount[0].Id, Is_Updated__c = false,Is_Primary_Changed__c = true,Street__c = 'Broadway1', City__c = 'Los Angeles', State__c = 'CA', Zip__c = '039334', Street_2__c = '21th'),
        																 new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm6.com',Type__c = 'Mailing', Account__c = lstAccount[0].Id, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Is_Primary__c = true,Is_Primary_Changed__c = true),
        																 new Contact_Info__c(Phone__c = '304041',Email__c = 'test@silverlinecrm7.com',Type__c = 'Mailing', Account__c = lstAccount[0].Id, Street__c = 'Broadway', City__c = 'New York City', State__c = 'NY', Zip__c = '03933', Street_2__c = '20th',Is_Primary__c = false,Is_Primary_Changed__c = true,Was_Last_Primary__c = true)
        																};
        
        insert lstContactInfo;
       
        
        System.runAs(objHpdProviderUser)
        {
        	SL_UpdatedMemberContactInfo objpdatedMemberContactInfo = new SL_UpdatedMemberContactInfo();
        	objpdatedMemberContactInfo.strMemberId = lstAccount[0].Id;
        	objpdatedMemberContactInfo.getObjAccount();
        	objpdatedMemberContactInfo.getlstPrimUpdatedContInfo();
        }
        
       // update lstContactInfo;
    }	    
    
    
}