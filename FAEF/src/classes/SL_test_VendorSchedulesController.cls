@isTest
private class SL_test_VendorSchedulesController {
	
	@isTest
    private static void SL_ctrl_VendorSchedules()
    {
        recordType objRecordType = [Select Id from RecordType where Name='Vendor Division' AND SobjectType ='Account' limit 1];
        
        Account objAccount = new Account(Name='TestJared',RecordTypeId = objRecordtype.Id, OwnerId = [Select Id from User where Name = 'Peter Dwyer' limit 1].Id);
        insert objAccount;
        Cookie accountCookie = new Cookie('accountCookie',objAccount.Id,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[] {accountCookie});        
       
        Contact objContact = new Contact();
    	objContact.LastName = 'TestContact';
    	objContact.AccountId = objAccount.Id;
    	insert objContact;
        
        Profile objCommunityUserProfile = [SELECT Id FROM Profile WHERE Name='Vendor - External' OR Name='Partner Community User' LIMIT 1];

        User objUser = new User(Email='standarduser@testorg.com', LastName='Testing',
                                 UserName='jaredTest@jaredTestOrg.com' , ContactID = objContact.Id,
                                 Alias = 'testu', ProfileId = objCommunityUserProfile.Id, EmailEncodingKey='UTF-8',
                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');              
                             
        insert objUser;

        Portal_Branding__c objBranding = new Portal_Branding__c(
            Name = 'TestBranding', 
            Unique_Id__c = 'test', 
            Font__c = 'Arial', 
            Schedule_Listview__c = 'faef_vendor_schedule_listview', 
            Opportunity_Listview__c = 'faef_vendor_opportunity_listview');
        insert objBranding;

        Account_Portal__c objAcctPortal = new Account_Portal__c(Portal__c = objBranding.Id, Account_Portal__c = objAccount.Id);
        insert objAcctPortal;

        String query = 'SELECT ';
        List<Schema.FieldSetMember> listViewFieldSet = SObjectType.Schedule__c.FieldSets.FAEF_Vendor_Schedule_Listview.getFields();
        for(Schema.FieldSetMember f : listViewFieldSet) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id FROM Schedule__c';

        System.runAs(objUser) 
        {
            SL_ctrl_VendorSchedules objScheds = new SL_ctrl_VendorSchedules();
            System.assertEquals(objScheds.scheduleRecordsJSON, JSON.serializePretty(Database.query(query)));
        }
    } 
	
}