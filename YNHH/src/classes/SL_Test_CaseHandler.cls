/**
* \arg ClassName		: SL_Case
* \arg JIRATicket     	: YNHH-110
* \arg CreatedOn      	: 17/JULY/2015
* \arg LastModifiedOn	: 24/JULY/2015
* \arg CreatededBy    	: Lodhi 
* \arg ModifiedBy     	: Sandeep
* \arg Description      : Test class for SL_CaseHandler 
*/
@isTest(seealldata=true)
private class SL_Test_CaseHandler 
{
    static List<Account> lstAccount;
    static List<Contact> lstContact;
    static List<Case> lstCase;
    static List<User> lstUser;
    
    private static void createData()
    {
        Id userRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'YNHH_Employee' LIMIT 1].Id;
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'YNHH Employee'].Id;
        lstUser = new List<User>{
            new User(UserRoleId = userRoleId, ProfileId = profileId, Username =  + 'test2test787@test87987.com', Employee_ID__c = 'Test Employee-01',
                     Alias = 'test', Email='test.wayne567547@test.com', EmailEncodingKey='UTF-8', Firstname='Test-02', Lastname='Last-02',
                     LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago'),
            new User(UserRoleId = userRoleId, ProfileId = profileId, Username =  + 'test787.test79879@test87987.com', Employee_ID__c = 'Test Employee-02',
                     Alias = 'test', Email='test.wayne567547@test.com', EmailEncodingKey='UTF-8', Firstname='Test-03', Lastname='Last-03',
                     LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago')                          
        };
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            Test.startTest();
            insert lstUser;
            system.assertEquals(lstUser.size(), 2);
            Test.stopTest();
        }    
        
        lstAccount = new List<Account>{
            new Account(Name = 'Test Account-01'),    
            new Account(Name = 'Test Account-02')
        };
        insert lstAccount;
        system.assertEquals(lstAccount.size(), 2);
        
        lstContact = [SELECT Id, Portal_User__c, Employee_Number__c FROM Contact];
        lstCase = new List<Case>{
            new Case(Status = 'New', Type = 'Payroll', ContactId = lstContact[0].Id),
            new Case(Status = 'New', Type = 'Payroll', ContactId = lstContact[0].Id),
            new Case(Status = 'New', Type = 'Other', ContactId = lstContact[1].Id),
            new Case(Status = 'Closed', Type = 'Other', ContactId = lstContact[1].Id)
        };
        System.debug('lstCase: '+lstCase);
        insert lstCase;
        //system.assertEquals(lstCase.size(), 2);
    }
    
	private static testMethod void Test_CaseHandler() 
	{
        createData();
        lstCase[0].ContactId = lstContact[1].Id;
        lstCase[2].ContactId = null;
        lstCase[3].Status = 'New';
        update lstCase;
	}
	
	private static testmethod void test_CaseBeforeTrigger()
	{
	    Id profileId = [SELECT Id FROM Profile WHERE Name = 'YNHH Employee'].Id;
	    
	    Contact objContact = new Contact();
	    
	    System.runAs(new User(Id = Userinfo.getUserId()))
	    {
	        objContact.Firstname = 'Test';
	        objContact.LastName = 'Contact';
	        objContact.Employee_Number__c = '123454412';
	        insert objContact;
	    }
	    
	    User objUser = new User( ProfileId = profileId, Username =  + 'test212121221test787@test87987.com', 
	                                    Employee_ID__c = '123454412', Alias = 'testtda',
	                                    Email='test.wayne567547@test.com', EmailEncodingKey='UTF-8',
	                                    Firstname='Test-02', Lastname='Last-02', 
                                        LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago');
        test.startTest();
        insert objUser;
        test.stopTest();
        List<Case>  lstCaseToInsert =new List<Case>();
	    system.runAs(objUser)
	    {
    	     lstCaseToInsert.add(new Case(Status = 'New', Type = 'Payroll'));
    	     insert lstCaseToInsert;
	    }
	    //System.assertEquals([SELECT contactId FROM Case WHERE Id =:lstCaseToInsert[0].Id].ContactId, objContact.Id);
	}
}