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
public with sharing class SL_Test_BatchToCreateEventInMyBuilding 
{
	static testMethod void test_BatchToCreateEventInMyBuilding() 
    {
    	String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and DeveloperName = 'Move_In_Process'].Id;
	    Building__c objBuilding = new Building__c(Name='Test Building 1', Street_Address__c = 'Test Address New',
                                                   Zip_Code__c = '1232123', Community_ID__c = '4'); 
       
        insert objBuilding;
      	
      	SL_MyBuilding_Integration__c objCustomSetting = new SL_MyBuilding_Integration__c(Name = 'MyBuilding', app_Id__c = '123',app_key__c = '123',dateFrom__c = '2014-12-12',
      	                                                dateTo__c = '2014-12-12',groupId__c = '2',isAllDayEvent__c = 'Y', EndPoint__c = 'https://api.mybuilding.org');
      	insert objCustomSetting;
      	
        Apartment__c objApartment = new Apartment__c(Name = 'Test Property',Building__c = objBuilding.Id, Apartment_Number__c = '205' );
        insert objApartment;
     
        Case objCase = new Case(Subject = 'Test Subject',Description='Test Description',Lease_Start_Date__c = Date.today(),Move_In_Date__c = Date.today(),
                                Status='New',Origin = 'Web',RecordTypeId = strRecordTypeId,Building__c = objBuilding.Id,Apartment__c = objApartment.Id, 
                                Date_From__c = datetime.newInstance(2014, 09, 09, 09, 00, 00),Date_To__c  = datetime.newInstance(2014, 09, 09, 12, 00, 00));
        insert objCase;
        
        List<Case> lstCase = new List<Case>();    
        lstCase.add(objCase);
        
    	// Call batch to call MyBuilding integration
        SL_BatchToCreateEventInMyBuilding objBatch = new SL_BatchToCreateEventInMyBuilding(lstCase);
         
        test.startTest();
        Database.executeBatch(objBatch, 1);
    	test.stopTest();  
    	
    	SL_Schedule_BatchToCreateEvent_Caller objScheduleBatchToCreateEventCaller = new SL_Schedule_BatchToCreateEvent_Caller();
    }
}