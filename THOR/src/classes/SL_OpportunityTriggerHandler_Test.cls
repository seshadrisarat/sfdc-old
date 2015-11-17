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
private class SL_OpportunityTriggerHandler_Test 
{
    static testMethod void test_CheckReferencedApartmentAvailability() 
    {
    	
    	///Create account record
    	Account objAccount = createAccount();
    	
    	///Create a Building record
    	Building__c objBuilding = createBuilding();
    	
    	///Create an Apartment record
        Apartment__c objApartment1 = createApartment(objBuilding,'Leased - Not Available');
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        
        
        ///Get Opportunity record
        Opportunity objOpportunity1 = createOpportunity(objApartment1,'Closed-Won');
        
        try
        {
    		insert objOpportunity1;
        }	
        catch(DmlException e)
        {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Conflict with Apartment availability') ? true : false;
        }
        
        ///Create an Apartment record
        Apartment__c objApartment2 = createApartment(objBuilding,'Leased - Available');
        
        ///Get Opportunity record
        Opportunity objOpportunity2 = createOpportunity(objApartment2,'Closed-Won');
		insert objOpportunity2;
		
		objOpportunity2.Apartment__c = objApartment2.Id;
		
		test.startTest();
		try
        {
    		update objOpportunity2;
        }	
        catch(DmlException e)
        {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Conflict with Apartment availability') ? true : false;
        }
        
        test.stopTest();
    }
    
    
    static testMethod void test_setOpportunityStageBasedOnContactRoleStatus() 
    {
    	///Create account record
    	Account objAccount = createAccount();
    	
    	///Create a Building record
    	Building__c objBuilding = createBuilding();
    	
    	///Create an Apartment record
        Apartment__c objApartment1 = createApartment(objBuilding,'Leased - Available');
        
        ///Get Opportunity record
        Opportunity objOpportunity1 = createOpportunity(objApartment1,'Closed-Won');
        insert objOpportunity1;
        
        objOpportunity1.StageName = 'Lease Sent';
        
        try
        {
        	update objOpportunity1;
        }
        catch(DmlException e)
        {
			Boolean expectedExceptionThrown =  e.getMessage().contains('No Associated Contact Role to this Opportunity') ? true : false;
        }
        
        Contact_Role__c objContact_Role = new Contact_Role__c(Person_Account__c = objAccount.Id,Opportunity__c = objOpportunity1.Id);
        insert objContact_Role;
        
        objOpportunity1.StageName = 'Lease Signed by Tenants';
        
        test.startTest();
        
        try
        {
        	update objOpportunity1;
        }
        catch(DmlException e)
        {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Invalid Opportunity Stage For Related Contact Role Status') ? true : false;
        }
        
        test.stopTest();
    }
    
    static testMethod void test_MoveInCase() 
    {
    	Id TRANSFER_OPPORTUNITY_RECORDTYPEID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Transfer_Opportunity'].Id;
    	
    	///Create account record
    	Account objAccount = createAccount();
    	
    	///Create a Building record
    	Building__c objBuilding = createBuilding();
    	
    	///Create an Apartment record
        Apartment__c objApartment1 = createApartment(objBuilding,'Leased - Available');
        
        ///Get Opportunity record
        Opportunity objOpportunity1 = createOpportunity(objApartment1,'Closed-Won');
        objOpportunity1.AccountId = objAccount.Id;
        insert objOpportunity1;
        
        Contact_Role__c objContact_Role = new Contact_Role__c(Person_Account__c = objAccount.Id,Opportunity__c = objOpportunity1.Id,Status__c = 'Application Approved');
        insert objContact_Role;
        
        test.startTest();
        objOpportunity1.StageName = 'Lease Signed by Thor';
        objOpportunity1.RecordtypeId = TRANSFER_OPPORTUNITY_RECORDTYPEID;
        update objOpportunity1;
        
        test.stopTest();
        
    }
    
    static testMethod void test_populateOldApartmentStatus() 
    {
    	String MOVEOUT_CASE_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Case' AND DeveloperName = 'Move_Out_Process'].Id;
    	
    	///Create account record
    	Account objAccount = createAccount();
    	
    	///Create a Building record
    	Building__c objBuilding = createBuilding();
    	
    	///Create an Apartment record
        Apartment__c objApartment1 = createApartment(objBuilding,'Leased - Available');
        
        Apartment__c objApartment2 = createApartment(objBuilding,'Leased - Available');
        
        Lease__c objLease = new Lease__c(Name = 'Test Lease' ,Apartment__c = objApartment1.Id,Start_Date__c = date.today() -5,End_Date__c = date.today() - 4);
        insert objLease;
        
        Case objCase = new Case(RecordTypeId = MOVEOUT_CASE_RECORDTYPE_ID,
    	                        Subject = 'Test',Lease_Start_Date__c = date.today(),Description = 'Test description');
        insert objCase;
        
        ///Get Opportunity record
        Opportunity objOpportunity1 = createOpportunity(objApartment1,'Closed-Won');
        objOpportunity1.AccountId = objAccount.Id;
        objOpportunity1.Lease_Start_date__c = date.today().addDays(2);
        insert objOpportunity1;
        
        test.startTest();
        objOpportunity1.Apartment__c = objApartment2.Id;
        update objOpportunity1;
    }
    
    
    static testMethod void test_updateTransferToApartmentFieldOnRenewalOpportunity() 
    {
    	Id TRANSFER_OPPORTUNITY_RECORDTYPEID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Transfer_Opportunity'].Id;
    	
    	///Create account record
    	Account objAccount = createAccount();
    	
    	///Create a Building record
    	Building__c objBuilding = createBuilding();
    	
    	///Create an Apartment record
        Apartment__c objApartment1 = createApartment(objBuilding,'Leased - Available');
        
        ///Create an Apartment record
        Apartment__c objApartment2 = createApartment(objBuilding,'Leased - Available');
        
        ///Get Opportunity record
        Opportunity objOpportunity1 = createOpportunity(objApartment1,'Closed-Won');
        objOpportunity1.AccountId = objAccount.Id;
        objOpportunity1.RecordTypeId = TRANSFER_OPPORTUNITY_RECORDTYPEID;
        insert objOpportunity1;
        
        Opportunity objOpportunity2 = createOpportunity(objApartment1,'Closed-Won');
        insert objOpportunity2;
        
        Contact_Role__c objContact_Role = new Contact_Role__c(Person_Account__c = objAccount.Id,Opportunity__c = objOpportunity1.Id,Status__c = 'Application Approved');
        insert objContact_Role;
        
        test.startTest();
        
        objOpportunity1.Apartment__c = objApartment2.Id;
        objOpportunity1.Previous_Opportunity__c  = objOpportunity2.Id;
        update objOpportunity1;
        
        test.stopTest();
    }
    
    static testMethod void test_createMoveOutCases() 
    {
    	Id RENEWAL_OPPORTUNITY_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Renewal_Lease_Opportunity'].Id;
    	
    	///Create account record
    	Account objAccount = createAccount();
    	
    	///Create a Building record
    	Building__c objBuilding = createBuilding();
    	
    	///Create an Apartment record
        Apartment__c objApartment1 = createApartment(objBuilding,'Leased - Available');
        
        ///Get Opportunity record
        Opportunity objOpportunity1 = createOpportunity(objApartment1,'Closed-Won');
        objOpportunity1.AccountId = objAccount.Id;
        objOpportunity1.RecordTypeId = RENEWAL_OPPORTUNITY_ID;
        insert objOpportunity1;
        
        Contact_Role__c objContact_Role = new Contact_Role__c(Person_Account__c = objAccount.Id,Opportunity__c = objOpportunity1.Id,Status__c = 'Application Approved');
        insert objContact_Role;
        
        test.startTest();
        objOpportunity1.StageName = 'Closed Lost';
        update objOpportunity1;
        
        test.stopTest();
    }
    
    static testMethod void test_createNewLeaseOpportunity() 
    {
    	Id RENEWAL_OPPORTUNITY_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Renewal_Lease_Opportunity'].Id;
    	
    	///Create account record
    	Account objAccount = createAccount();
    	
    	///Create a Building record
    	Building__c objBuilding = createBuilding();
    	
    	///Create an Apartment record
        Apartment__c objApartment1 = createApartment(objBuilding,'Leased - Available');
        
        ///Get Opportunity record
        Opportunity objOpportunity1 = createOpportunity(objApartment1,'Closed-Won');
        objOpportunity1.AccountId = objAccount.Id;
        objOpportunity1.RecordTypeId = RENEWAL_OPPORTUNITY_ID;
        objOpportunity1.CloseDate = date.today();
        insert objOpportunity1;
        
        Contact_Role__c objContact_Role = new Contact_Role__c(Person_Account__c = objAccount.Id,Opportunity__c = objOpportunity1.Id,Status__c = 'Application Approved');
        insert objContact_Role;
        
        test.startTest();
        objOpportunity1.StageName = 'Closed Lost';
        objOpportunity1.Lost_Reason__c = 'Thor Relocation LED';
        objOpportunity1.CloseDate = date.today();
    	database.update(objOpportunity1,false);
    	test.stopTest();
    }
    
    
    static testMethod void test_updateParentLease() 
    {
    	Id RENEWAL_OPPORTUNITY_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Renewal_Lease_Opportunity'].Id;
    	
    	///Create account record
    	Account objAccount = createAccount();
    	
    	///Create a Building record
    	Building__c objBuilding = createBuilding();
    	
    	///Create an Apartment record
        Apartment__c objApartment1 = createApartment(objBuilding,'Leased - Available');
        
        Lease__c objLease = new Lease__c(Name = 'Test Lease' ,Apartment__c = objApartment1.Id,Start_Date__c = date.today(),End_Date__c = date.today() + 1);
        insert objLease;
        
        test.startTest();
        ///Get Opportunity record
        Opportunity objOpportunity1 = createOpportunity(objApartment1,'Renewal Approved');
        objOpportunity1.AccountId = objAccount.Id;
        objOpportunity1.RecordTypeId = RENEWAL_OPPORTUNITY_ID;
        objOpportunity1.CloseDate = date.today();
        objOpportunity1.Lease__c = objLease.Id;
        insert objOpportunity1;
        test.stopTest();
    }
    
    
    static testMethod void test_fetchRelatedContactRole() 
    {
    	Id RENEWAL_OPPORTUNITY_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Renewal_Lease_Opportunity'].Id;
    	
    	///Create account record
    	Account objAccount = createAccount();
    	
    	///Create a Building record
    	Building__c objBuilding = createBuilding();
    	
    	///Create an Apartment record
        Apartment__c objApartment1 = createApartment(objBuilding,'Leased - Available');
        
        ///Get Opportunity record
        Opportunity objOpportunity1 = createOpportunity(objApartment1,'Closed-Won');
        objOpportunity1.AccountId = objAccount.Id;
        objOpportunity1.RecordTypeId = RENEWAL_OPPORTUNITY_ID;
        objOpportunity1.CloseDate = date.today();
        insert objOpportunity1;
        
        Contact_Role__c objContact_Role = new Contact_Role__c(Person_Account__c = objAccount.Id,Opportunity__c = objOpportunity1.Id,Status__c = 'Application Approved',
                                                              Role__c = 'Tenant',Email__c = 'test@test1232.com');
        insert objContact_Role;
        objContact_Role.Email__c = 'test@test1232.com';
        update objContact_Role;
        
        test.startTest();
        objOpportunity1.Application_Status__c = 'Application Pending Guarantor';
        update objOpportunity1;
        test.stopTest();
    }
    
    ///Method to create an account record
    private static  Account createAccount()
    {
    	final Id CUSTOMER_ID = [SELECT Id FROM RecordType WHERE DeveloperName =: 'PersonAccount' LIMIT 1].Id;
    	Account objAccount = new Account(LastName = 'Test Account - sndApp',RecordTypeId=CUSTOMER_ID,PersonEmail = 'test@test1.com');
    	insert objAccount;
    	return objAccount;
    }
    
    ///Method to create a building record
    private static  Building__c createBuilding()
    {
    	Building__c objBuilding = new Building__c(Name = 'Test Building', Street_Address__c = 'Test Address',Zip_Code__c = '97654');
    	insert objBuilding;
    	return objBuilding;
    }
    
    ///Method to create an apartment record
    private static  Apartment__c createApartment(Building__c objBuilding,String strApartmentStatus)
    {
    	Apartment__c objApartment = new Apartment__c(Name = 'Test Unit-01',Apartment_Status__c = strApartmentStatus,Building__c = objBuilding.Id);
        insert objApartment;
        return objApartment; 
    }
    
    ///Method to create an opportunity record
    private static  Opportunity createOpportunity(Apartment__c objApartment,String StageName)
    {
    	Opportunity objOpportunity = new Opportunity(Name = 'Test Opportunity-01', Apartment__c = objApartment.Id,StageName = StageName,CloseDate = Date.today());
    	return objOpportunity;
    }
}