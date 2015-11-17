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
public with sharing class SL_Test_CapitalExpenditureHandler 
{
	static testMethod void test_CapitalExpenditureHandler() 
    {
    	///Create account record
    	Account objAccount = createAccount();
    	
    	///Create a Building record
    	Building__c objBuilding = createBuilding();
    	
    	///Create an Apartment record
        Apartment__c objApartment1 = createApartment(objBuilding,'Leased - Available');
        
        Id CapitalExpenditureRecordTypeId = [SELECT Id FROM Recordtype WHERE SobjectType='Capital_Expenditure__c' AND DeveloperName='IAI'].Id;
        
        
        test.startTest();
        
        Capital_Expenditure__c objCapitalExpenditure = new Capital_Expenditure__c(Name = 'Test Exp', Recordtypeid = CapitalExpenditureRecordTypeId,
                                        Building__c = objBuilding.Id,Apartment__c = objApartment1.Id,Total_Costs_Other__c = 100.00,Include_Exception__c = true);
        insert objCapitalExpenditure;
        
        objCapitalExpenditure.Total_Costs_Other__c = 200.00;
        update objCapitalExpenditure;
        
        delete objCapitalExpenditure;
        
        objCapitalExpenditure = [SELECT Id,Total_Costs_Other__c FROM Capital_Expenditure__c WHERE isDeleted = true ALL ROWS];
        undelete objCapitalExpenditure;
        
        test.stopTest();
        
        ///Check if value on Capital Expenditure is correct
        system.assertEquals(objCapitalExpenditure.Total_Costs_Other__c,200);
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
}