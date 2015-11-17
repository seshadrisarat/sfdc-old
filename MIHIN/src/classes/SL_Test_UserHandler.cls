/*
*Class: SL_Test_UserHandler
*Description: This class is used as test class for user trigger and its corresponding handler.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
private class SL_Test_UserHandler 
{
    static testMethod void myUnitTest() 
    {
    	Map<String, String> mapProfileIdToName = new Map<String,String>();
        Id RecordTypeIdForPortalOrganization = [SELECT Id FROM RecordType WHERE DeveloperName =:'Provider_Organization'].Id;
        List<Account> lstAccount = new List<Account>{
        											 new Account(Name = 'Test Account', Portal_Licenses_Allocated__c = 5, 
        											 Portal_Licenses_Used__c = 2, RecordTypeId = RecordTypeIdForPortalOrganization,
        											 Population__c = 'Test1'),
        											 new Account(Name = 'Test Account1', Portal_Licenses_Allocated__c = 4, 
        											 Portal_Licenses_Used__c = 2, RecordTypeId = RecordTypeIdForPortalOrganization,
        											 Population__c = 'Test2')		
        										    };
        insert lstAccount;
        
        List<Contact> lstContact = new List<Contact>{ 
        											  new Contact(LastName = 'Test Contact', AccountId = lstAccount[0].Id),
        											  new Contact(LastName = 'Test Contact1', AccountId = lstAccount[1].Id),
        											  new Contact(LastName = 'Test Contact2', AccountId = lstAccount[1].Id),
        											  new Contact(LastName = 'Test Contact3', AccountId = lstAccount[0].Id),
        											  new Contact(LastName = 'Test Contact4', AccountId = lstAccount[0].Id)
        											};
        insert lstContact;
        
        List<Group> lstGroup = new List<Group>{ new Group(Name='Test1 Population Admins', DeveloperName = 'Test1_Population_Admins'),
        										new Group(Name='Test2 Population Admins', DeveloperName = 'Test2_Population_Admins')
    										  };
    	insert lstGroup;
        system.runAs(new User(Id = UserInfo.getUserId()))
        {
        	List<GroupMember> lstGM = new List<GroupMember>{ new GroupMember(GroupId = lstGroup[0].Id, UserOrGroupId = UserInfo.getUserId()),
        													 new GroupMember(GroupId = lstGroup[1].Id, UserOrGroupId = UserInfo.getUserId())
        												   }; 
    
    		insert lstGM;
        }
        for(Profile objProfile : [SELECT Id,Name FROM Profile WHERE Name IN ('MIHN - HPD Provider User','MIHN - HPD Organization Administrator','HPD - Population Admin')])
        {
        	mapProfileIdToName.put(objProfile.Name, objProfile.Id);
        }
        
        User objUser = [SELECT Id FROM User WHERE ProfileId=:mapProfileIdToName.get('HPD - Population Admin') AND isActive = true LIMIT 1];
        
        List<User> lstUser = new List<User>{new User	(Alias = 'puser', 
										                Email='Testportaluser@salesforce.com',
										                EmailEncodingKey='UTF-8', 
										                LastName='TestPortalUser',   
										                LanguageLocaleKey='en_US',
										                LocaleSidKey='en_US', 
										                ProfileId = mapProfileIdToName.get('MIHN - HPD Provider User'), 
										                TimeZoneSidKey='America/Los_Angeles',
										                ContactId = lstContact[0].Id,
										                PortalRole = 'Manager',
										                isActive = true,
										                UserName='Testportaluser@salesforce.com'),
									                
									         new User	(Alias = 'padmin', 
										                Email='Testportaladmin@salesforce.com',
										                EmailEncodingKey='UTF-8', 
										                LastName='TestPortalAdmin',   
										                LanguageLocaleKey='en_US',
										                LocaleSidKey='en_US', 
										                ProfileId = mapProfileIdToName.get('MIHN - HPD Provider User'), 
										                TimeZoneSidKey='America/Los_Angeles',
										                ContactId = lstContact[1].Id,
										                PortalRole = 'Manager',
										                isActive = true,
										                UserName='Testportaladmin@salesforce.com'),
									                
									         new User	(Alias = 'padmin1', 
										                Email='Testportaladmin1@salesforce.com',
										                EmailEncodingKey='UTF-8', 
										                LastName='TestPortalAdmin1',   
										                LanguageLocaleKey='en_US',
										                LocaleSidKey='en_US', 
										                ProfileId = mapProfileIdToName.get('MIHN - HPD Provider User'), 
										                TimeZoneSidKey='America/Los_Angeles',
										                ContactId = lstContact[2].Id,
										                PortalRole = 'Manager',
										                isActive = true,
										                UserName='Testportaladmin1@salesforce.com'),
										                
										     new User	(Alias = 'padmin2', 
										                Email='Testportaladmin2@salesforce.com',
										                EmailEncodingKey='UTF-8', 
										                LastName='TestPortalAdmin2',   
										                LanguageLocaleKey='en_US',
										                LocaleSidKey='en_US', 
										                ProfileId = mapProfileIdToName.get('MIHN - HPD Provider User'), 
										                TimeZoneSidKey='America/Los_Angeles',
										                ContactId = lstContact[3].Id,
										                PortalRole = 'Manager',
										                isActive = false,
										                UserName='Testportaladmin55@salesforce.com')
										   
        								   };
       insert lstUser;
       
       
       List<User> lstUsersTobeUpdated = new List<User>{
       													new User(Id = lstUser[0].Id,
       															Alias = 'puser', 
												                Email='Testportaluser@salesforce.com',
												                EmailEncodingKey='UTF-8', 
												                LastName='TestPortalUser',   
												                LanguageLocaleKey='en_US',
												                LocaleSidKey='en_US', 
												                ProfileId = mapProfileIdToName.get('MIHN - HPD Provider User'), 
												                TimeZoneSidKey='America/Los_Angeles',
												                ContactId = lstContact[0].Id,
												                PortalRole = 'Manager',
												                isActive = false,
												                UserName='Testportaluser@salesforce.com'),
									                
												       new User(Id = lstUser[1].Id,
												         		Alias = 'padmin', 
												                Email='Testportaladmin@salesforce.com',
												                EmailEncodingKey='UTF-8', 
												                LastName='TestPortalAdmin',   
												                LanguageLocaleKey='en_US',
												                LocaleSidKey='en_US', 
												                ProfileId = mapProfileIdToName.get('MIHN - HPD Provider User'), 
												                TimeZoneSidKey='America/Los_Angeles',
												                ContactId = lstContact[1].Id,
												                PortalRole = 'Manager',
												                isActive = false,
												                UserName='Testportaladmin@salesforce.com'),
												                
												      new User( Id = lstUser[2].Id,
												         		Alias = 'padmin1', 
												                Email='Testportaladmin1@salesforce.com',
												                EmailEncodingKey='UTF-8', 
												                LastName='TestPortalAdmin1',   
												                LanguageLocaleKey='en_US',
												                LocaleSidKey='en_US', 
												                ProfileId = mapProfileIdToName.get('MIHN - HPD Organization Administrator'), 
												                TimeZoneSidKey='America/Los_Angeles',
												                ContactId = lstContact[2].Id,
												                PortalRole = 'Manager',
												                isActive = true,
												                UserName='Testportaladmin1@salesforce.com'),
												                
											         new User	(Id = lstUser[3].Id,
											          			Alias = 'padmin2', 
												                Email='Testportaladmin2@salesforce.com',
												                EmailEncodingKey='UTF-8', 
												                LastName='TestPortalAdmin2',   
												                LanguageLocaleKey='en_US',
												                LocaleSidKey='en_US', 
												                ProfileId = mapProfileIdToName.get('MIHN - HPD Provider User'), 
												                TimeZoneSidKey='America/Los_Angeles',
												                ContactId = lstContact[3].Id,
												                PortalRole = 'Manager',
												                isActive = true,
												                UserName='Testportaladmin55@salesforce.com')											         											                
       												  };
      
      try
      {
      	System.runAs(objUser)
      	{
      	    update lstUsersTobeUpdated;
      		update lstUsersTobeUpdated;
      	}
      }
      catch(Exception e)
      {
      	Boolean expectedExceptionThrown =  e.getMessage().contains(Label.SL_UnauthorizedRecordEdit) ? true : false;
		System.AssertEquals(expectedExceptionThrown, true);
      }
    }
    
}