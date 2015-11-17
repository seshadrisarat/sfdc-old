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
public with sharing class SL_Test_BatchToUpdateOpportunityFields 
{
	static testMethod void test_BatchToUpdateOpportunityFields() 
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
        
        test.startTest();
        String strQuery =   'SELECT Id,AccountId,Account_Current_Address__c,Person_Account_Email__c,Account.ShippingStreet, Account.ShippingCity ,Account.RecordTypeId,' + 
                    		'Account.ShippingState,Account.ShippingPostalCode  , Account.ShippingCountry,Account.PersonEmail,Property_Manager_Email__c,Leasing_Agent_Title__c,' +
	                		'Apartment__r.Building__r.Building_Manager__r.Email,Leasing_Agent__r.Title,' +
	                		'Apartment__c,Apartment__r.Building__c,Apartment__r.Building__r.Building_Manager__c,Leasing_Agent__c ' +
                    		'FROM Opportunity WHERE (AccountId != null OR Apartment__r.Building__r.Building_Manager__c != null OR Leasing_Agent__c != null)';
					
		SL_BatchToUpdateOpportunityFields objBatch = new SL_BatchToUpdateOpportunityFields(strQuery);
		Database.executeBatch(objBatch, 50);
        test.stoptest();
        
        objOpportunity1 = [SELECT Account_Current_Address__c,Person_Account_Email__c FROM Opportunity WHERE Id =:objOpportunity1.Id];
        
        ///Check if values are populated correctly
        system.assertEquals(objOpportunity1.Account_Current_Address__c, '23rd,United States');
        system.assertEquals(objOpportunity1.Person_Account_Email__c, 'test123333@test.com');
    }
    
    ///Method to create an account record
    private static  Account createAccount()
    {
    	Id PersonAccountRecordTypeId = [SELECT Id FROM Recordtype WHERE SobjectType='Account' AND IsPersonType=True].Id;
    	Account objAccount = new Account(LastName = 'Test Account', ShippingStreet = '23rd', RecordTypeId  = PersonAccountRecordTypeId, PersonEmail = 'test123333@test.com');
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