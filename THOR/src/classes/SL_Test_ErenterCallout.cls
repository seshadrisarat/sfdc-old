@isTest
private class SL_Test_ErenterCallout 
{
	static final Id CUSTOMER_ID = [SELECT Id FROM RecordType WHERE DeveloperName =: 'PersonAccount' LIMIT 1].Id;
	static final Id RENEWAL_OPPORTUNITY_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Renewal_Lease_Opportunity'].Id;
    static Contact_Role__c objContactRole;
    static Contact_Role__c objContactRole1;
    static Contact_Role__c objContactRole2;
    static List<SL_ERenterCustomSetting__c> lstERenterCredentials;
    
    static void createData()
    {
    	lstERenterCredentials = new List<SL_ERenterCustomSetting__c>{
    																	new SL_ERenterCustomSetting__c(Name = 'test1', endpoint__c = 'https://commercial.e-renter.com/soap_server.php?wsdl', password__c = 'sreftplug', username__c = 'thorequities', product_ID__c = '46'),
    																	new SL_ERenterCustomSetting__c(Name = 'test2', endpoint__c = 'https://commercial.e-renter.com/soap_server.php?wsdl', password__c = 'sreftplug', username__c = 'thorequities', product_ID__c = '60'),
    																	new SL_ERenterCustomSetting__c(Name = 'test3', endpoint__c = 'https://commercial.e-renter.com/soap_server.php?wsdl', password__c = 'sreftplug', username__c = 'thorequities', product_ID__c = '61')
    																};
    	insert lstERenterCredentials;
    	
    	Account objAccount = new Account(LastName = 'Test Account - sndApp',RecordTypeId=CUSTOMER_ID,PersonEmail = 'test@test1.com');
    	insert objAccount;
    	
    	 ///Get Opportunity record
        Opportunity objOpportunity = new Opportunity(StageName = 'Closed', Name='test');
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.RecordTypeId = RENEWAL_OPPORTUNITY_ID;
        objOpportunity.CloseDate = date.today();
        insert objOpportunity;
    	
    	objContactRole = new Contact_Role__c(Person_Account__c = objAccount.Id, Status__c = 'Application Approved',Opportunity__c = objOpportunity.Id,DOB__c = Date.today(),
    										 Current_Address_Country__c = 'United States',
                                             Role__c = 'Tenant',Email__c = 'test@test1232.com');
        insert objContactRole;
        
        objContactRole1 = new Contact_Role__c(Person_Account__c = objAccount.Id, Status__c = 'Application Approved',Opportunity__c = objOpportunity.Id,DOB__c = Date.today(),
    										 Current_Address_Country__c = 'UK',
                                             Role__c = 'Tenant',Email__c = 'test@test1232.com', SSN_C__c = '000000000');
        insert objContactRole1;
        
        objContactRole2 = new Contact_Role__c(Person_Account__c = objAccount.Id, Status__c = 'Application Approved',Opportunity__c = objOpportunity.Id,DOB__c = Date.today(),
    										 Current_Address_Country__c = 'UK',
                                             Role__c = 'Tenant',Email__c = 'test@test1232.com', SSN_C__c = '000');
        insert objContactRole2;
        
    }
    
    static testMethod void test_ErenterCallOut() 
    {
        createData();
        
        Test.startTest();
        SL_ErenterCallout.sendErenterRequest(objContactRole.Id);
        Test.stopTest();
    }
    
    static testMethod void test_ErenterCallOut1() 
    {
        createData();
        
        Test.startTest();
        SL_ErenterCallout.sendErenterRequest(objContactRole1.Id);
        Test.stopTest();
    }
    
    static testMethod void test_ErenterCallOut2() 
    {
        createData();
        
        Test.startTest();
        SL_ErenterCallout.sendErenterRequest(objContactRole2.Id);
        Test.stopTest();
    }
}