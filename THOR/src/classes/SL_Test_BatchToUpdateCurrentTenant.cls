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
public with sharing class SL_Test_BatchToUpdateCurrentTenant 
{
	static testMethod void test_BatchToUpdateCurrentTenant() 
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
        objOpportunity1.recordtypeId = TRANSFER_OPPORTUNITY_RECORDTYPEID;
        insert objOpportunity1;
        
        Contact_Role__c objContact_Role = new Contact_Role__c(Person_Account__c = objAccount.Id,Opportunity__c = objOpportunity1.Id,Status__c = 'Application Approved');
        insert objContact_Role;
        
        objOpportunity1.StageName = 'Lease Signed by Thor';
        update objOpportunity1;
        
        test.startTest();
        SL_BatchToUpdateCurrentTenantOnApartment objBatch = new SL_BatchToUpdateCurrentTenantOnApartment('SELECT Id,Apartment__c,AccountId FROM Opportunity WHERE StageName = ' + '\'' + 'Lease Signed by Thor' + '\'' + ' AND Apartment__c != null');
		Database.executeBatch(objBatch, 50);
        test.stoptest();
        
        system.assertEquals([SELECT Current_Tenant__c FROM Apartment__c WHERE Id =:objApartment1.Id].Current_Tenant__c,objAccount.Id);
    }
    
    ///Method to create an account record
    private static  Account createAccount()
    {
    	final Id CUSTOMER_ID = [SELECT Id FROM RecordType WHERE DeveloperName =: 'PersonAccount' LIMIT 1].Id;
    	Account objAccount = new Account(RecordTypeId = CUSTOMER_ID , LastName='Test Account For Docusign 1');
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