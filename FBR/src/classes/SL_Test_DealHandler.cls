/**
* \arg ClassName        : SL_Test_DealHandler
* \arg JIRATicket     	: FBR-1
* \arg CreatedOn      	: 19/MAR/2015
* \arg LastModifiedOn   : 10/APR/2015
* \arg CreatededBy    	: Nrusingh
* \arg LastModifiedBy	: Pankaj Ganwani
*/
@isTest
private class SL_Test_DealHandler
{
	static final Id employeeRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType =: 'Contact' AND DeveloperName =: 'Employee'].Id;
    static testMethod void SL_Test_DealHandler() 
    {
        Id CustomProfileId;
        Id SandradProfileId;
        User objUserCustom;
        
        // Fetch Custom Profile
        for(Profile objProfile : [SELECT Id FROM Profile WHERE Name='IB Administration' LIMIT 1])
        {
        	CustomProfileId = objProfile.Id;
        }
		
		// Insert user based on the profile	        
        if(CustomProfileId != null){
        	objUserCustom = new User(Alias = 'test1234', Email='test123@test123.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = CustomProfileId, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test123@test123nrus.com');
            
            insert objUserCustom;
        }
        	
        // Fetch System Admin profile id
        SandradProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id;
        
        // Fetch System Admin
        User objUserAdmin = [SELECT Id FROM User WHERE ProfileId =: SandradProfileId LIMIT 1];
        
        // Insert Contact
        Contact objContact = new Contact(LastName = 'Test' ,User__c = objUserAdmin.Id, RecordTypeId = employeeRecordTypeId);
        insert objContact;
        
        // Insert Account
        Account objAccount  = (new Account (Name = 'TestAccount', Stock_Exchange__c = 'NYSE', Primary_Relationship_Banker__c = objContact.Id, Priority_Ranking__c = 'Not Ranked', Sector__c = 'Insurance'));
        insert objAccount;
        
        // Insert Deal
        Deals__c objDeals = new Deals__c (Name = 'TestDeal', Company__c = objAccount.Id, Lead_Banker__c = objContact.Id, Transaction_Type__c = 'IPO', FBR_Role__c = 'Advisor',
        								Est_Deal_Size__c = 10.0, Estimated_Deal_Fees__c = 100.00, Probability__c = 'Low', Deal_Stage__c = 'Pitch' , Engagement_Status__c = 'Not Engaged');
        insert objDeals;
        
        Id dealOwnerId;
        
        // Fetch the newly inserted Deal record
        for(Deals__c objDeal : [SELECT OwnerId FROM Deals__c WHERE Id =:objDeals.Id LIMIT 1])
        {
        	dealOwnerId = objDeal.OwnerId;
        }
        
        // Inserted Deal Id should be Admin user Id
        system.assertEquals(dealOwnerId, objUserAdmin.Id);
        
        // Insert another Contact with other custom User 
        Contact objContactSecond = new Contact(LastName = 'Test-1', User__c = objUserCustom.Id, RecordTypeId = employeeRecordTypeId);
        insert objContactSecond;
        
        // Update the Lead_Banker
        objDeals.Lead_Banker__c = objContactSecond.Id;
        update objDeals; 
        
        // Fetch the newly updated Deal record
        for(Deals__c objDeal : [SELECT OwnerId FROM Deals__c WHERE Id =:objDeals.Id LIMIT 1])
        {
        	dealOwnerId = objDeal.OwnerId;
        }
        
        // updated Deal Id should be updated as Custom user Id
        system.assertEquals(dealOwnerId,objUserCustom.Id);
    }
}