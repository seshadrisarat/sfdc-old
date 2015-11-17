/**
* \arg ClassName      : SL_Test_WS_DeactivateGroupMembers
* \arg JIRATicket     : AMSEC-12
* \arg CreatedOn      : 06/APRIL/2015
* \arg LastModifiedOn : 06/APRIL/2015
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Lodhi
* \arg Description    : Test class for SL_WS_DeactivateGroupMembers class.
*/
@isTest
private class SL_Test_WS_DeactivateGroupMembers 
{
    static testMethod void Test_WS_DeactivateGroupMembers() 
    {
    	Id profileId = [SELECT Id From Profile WHERE Name = 'Standard User' LIMIT 1].Id;
	    Id roleIdRGM = [SELECT Id From UserRole WHERE Name = 'Resource Group Member' LIMIT 1].Id;
	    Id roleIdITM = [SELECT Id From UserRole WHERE Name = 'Investment Team Member' LIMIT 1].Id;
	    Id recordTypeId = [SELECT Id From RecordType WHERE Name = 'AS Employee' LIMIT 1].Id;
	    
	    List<user> lstUser = new List<User>{
	                                        new User(Lastname = 'TestUser-01', Email = 'testuser1245@yahoo.in', ProfileId = profileId, IsActive = true,
	                                                 Alias = 'tuser', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', UserName = 'testUser0254@sl.com',
	                                                 EmailEncodingKey = 'ISO-8859-1', UserRoleId = roleIdRGM, LanguageLocaleKey='en_US'),
	                                        new User(Lastname = 'TestUser-02', Email = 'testuser54321@yahoo.in', ProfileId = profileId, IsActive = true, 
	                                                 Alias = 'tuser', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', UserName = 'testUser9723@sl.com',
	                                                 EmailEncodingKey = 'ISO-8859-1', UserRoleId = roleIdITM, LanguageLocaleKey='en_US')
	    };
    	
    	Account objAccount = new Account(Name = 'TestAccount');
	    insert objAccount;
	    
	    List<Contact> lstContact = new List<Contact>{
	                                   new Contact(Lastname = 'TestCon-01', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[0].Id),
	                                   new Contact(Lastname = 'TestCon-02', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[0].Id),
	                                   new Contact(Lastname = 'TestCon-03', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[0].Id),
	                                   new Contact(Lastname = 'TestCon-04', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[0].Id),
	                                   new Contact(Lastname = 'TestCon-05', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[1].Id),
	                                   new Contact(Lastname = 'TestCon-06', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[1].Id),
	                                   new Contact(Lastname = 'TestCon-07', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[1].Id),
	                                   new Contact(Lastname = 'TestCon-07', RecordTypeId = recordTypeId, AccountId = objAccount.Id, Salesforce_User__c = lstUser[1].Id)
	    };
	    insert lstContact;
	    
        Industry_Group__c objIG = new Industry_Group__c(Name = 'TestIG');
        insert objIG;
        
        Deal__c objDeal = new Deal__c(Name = 'TestDeal', Industry_Deal__c = objIG.Id, Process_Status__c = 'Open',
                              Deal_Status__c = 'Idea', CA_Status__c = 'Pending');
        insert objDeal; 
        
        AS_Project__c objASP = new AS_Project__c(Name = 'TestASProject', Project_Type__c = 'Other', Project_Lead__c = 'DT', Portfolio_Company__c = objAccount.Id,
                                                 Project_Health__c = 'On Track', End_Date__c = Date.today(), Start_Date__c = Date.today());
        insert objASP; 
        
        List<External_Working_Group_Member__c> lstEWGM = new List<External_Working_Group_Member__c>{
															new External_Working_Group_Member__c(Deal__c = objDeal.Id, Contact__c = lstContact[0].Id),
															new External_Working_Group_Member__c(Deal__c = objDeal.Id, Contact__c = lstContact[1].Id),
															new External_Working_Group_Member__c(Deal__c = objDeal.Id, Contact__c = lstContact[2].Id),
                                                            new External_Working_Group_Member__c(AS_Project__c = objASP.Id, Contact__c = lstContact[4].Id)
        };
        insert lstEWGM;
        
        SL_WS_DeactivateGroupMembers objWSDeactivateMembers = new SL_WS_DeactivateGroupMembers();
	    SL_WS_DeactivateGroupMembers.deactivateGroupMembers(String.valueOf(lstEWGM[0].Id) +','+ String.valueOf(lstEWGM[1].Id) +','+ String.valueOf(lstEWGM[2].Id), objDeal.Id);
	    SL_WS_DeactivateGroupMembers.deactivateGroupMembers(String.valueOf(lstEWGM[0].Id) +','+ String.valueOf(lstEWGM[1].Id) +','+ String.valueOf(lstEWGM[2].Id), objAccount.Id);
	    SL_WS_DeactivateGroupMembers.deactivateGroupMembers(String.valueOf(lstEWGM[0].Id) +','+ String.valueOf(lstEWGM[1].Id) +','+ String.valueOf(lstEWGM[2].Id), objASP.Id);
    }
}