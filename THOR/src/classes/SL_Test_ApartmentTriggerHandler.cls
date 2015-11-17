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
public with sharing class SL_Test_ApartmentTriggerHandler
{
	static testMethod void testApartmentTriggerHandler() 
    {
    	test.startTest();
    	
    	///Create a Building record
	    Building__c objBuilding = new Building__c(Name='Test Building 1', Street_Address__c = 'Test Address New',
                                                   Zip_Code__c = '1232123'); 
        insert objBuilding;
      
      	///Create an Apartment record
        Apartment__c objApartment = new Apartment__c(Name = 'Test Property',Building__c = objBuilding.Id, Apartment_Status__c = 'Available - On Hold' );
        insert objApartment;
        
        objApartment.Apartment_Status__c = 'Available - Vacant';
        update objApartment;
        
        test.stopTest();
    }
}