@isTest(SeeAllData = true)
private class SROC_CommunityHomeControllerTest 
{
    private static CORECONNECT__CC_System_Settings__c objSysSettings;
    //private static User objUser;
    private static void createData()
    {
    	Id srocNetworkId = [SELECT ID FROM Network WHERE Name = 'SROC'].Id;
    	Id profileId = [SELECT Id FROM Profile WHERE Name = 'SROC Dealer - CCL' LIMIT 1].Id;
    	
    	Account objAccount = new Account(Name = 'Test Account', ShippingCity  = 'New York');
    	insert objAccount;
    	
    	Contact objContact = new Contact(LastName = 'Test Contact', AccountId = objAccount.Id);
    	insert objContact;
    	
    	//objSysSettings = new CORECONNECT__CC_System_Settings__c(Name = 'SROC', CORECONNECT__Community_Path_Name__c = '/sroc', CORECONNECT__Guest_Profile_Name__c = 'SROC Profile', CORECONNECT__Show_Getting_Started_Link__c = true, CORECONNECT__Community_NetworkId__c = srocNetworkId);
    	//insert objSysSettings;
    	
    	//objUser = new User(ProfileId = profileId, ContactId = objContact.Id, Alias = 'standt', Email='standarduser@testorg.com', 
				            //EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
				            //LocaleSidKey='en_US', 
				            //TimeZoneSidKey='America/Los_Angeles', UserName='standard111user@testorg.com');
		//insert objUser;
    	
    	//name, value, path, maxAge, isSecure
		Cookie cookie = new Cookie('dismissHighlights', 'dismissed', null, -1, false);
		ApexPages.currentPage().setCookies(new Cookie[]{cookie});
    }
    
    static testMethod void myUnitTest() 
    {
        createData();
        
        User objUser = [SELECT id FROM User WHERE Profile.Name = 'SROC Dealer - CCL' AND IsActive = true LIMIT 1];
        System.runAs(objUser)
        {
        	SROC_CommunityHomeController objHomeController = new SROC_CommunityHomeController();
        	system.debug('===name====='+Site.getname());
        }
    }
}