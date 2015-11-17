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
@isTest(SeeAllData = true)
private class SL_Test_CaseTriggerHandler {

    static testMethod void test_CaseTrigger()
    {
    	// Start of preparing test data.
    	String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Move In Process'].Id;
    	Building__c objBuilding = new Building__c(Name='Test Building 1', Street_Address__c = 'Test Address New',
                                                   Zip_Code__c = '1232123', Studio_Units__c = 12,  Studio_Plus_Units__c = 12,
                                                   One_Bedroom_Units__c = 12, One_Bedroom_Plus_Units__c = 12,
                                                   Two_Bedroom_Units__c = 12, Two_Bedroom_Plus_Units__c = 12, 
                                                   Three_Bedroom_Units__c = 12, Three_Bedroom_Plus_Units__c = 12,
                                                   Four_Bedroom_Units__c = 12, Four_Bedroom_Plus_Units__c = 12,
                                                   Penthouse_Units__c = 12,
                                                   Community_ID__c = '115' ); 
    	
    	insert objBuilding;
    	
    	Property__c objProperty = new Property__c(Name = 'Test Property',Building__c = objBuilding.Id );
 		insert objProperty;
 		
		Case objCase = new Case(Subject = 'Test Subject',Description='Test Description',Move_In_Date__c = Datetime.newInstance(2014, 11, 10, 10, 11, 39),
								Status='New',Origin = 'Web',RecordTypeId = strRecordTypeId,Property_Lookup__c =objProperty.Id);
								
		String strFakeResponse = '{ "response": { "total_items": 1,"page_size": "1","page_count": 1,"page_number": "1","events": {"event":[{"eventId": "21081","communityId": "4","eventCategoryId": null,"title": "Furniture Delivery - 2L - Michael Picarello","text": "", "dateStart": "2014-09-09 09:00:00","dateEnd": "2014-09-09 12:00:00"}]}}, "status": "success"}';
								
		SL_SingleRequestMockResponse fakeResponse = new SL_SingleRequestMockResponse(200,
                                                 'Complete',
                                                 strFakeResponse,
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        test.startTest();
			insert objCase;
		test.stopTest();	
		
		Case objUpdateCase = [select Mybuilding_Event_Creation_Status__c,Mybuilding_Event_Id__c
							  from Case where Id=:objCase.Id ];
							  
		// Verifying Expected test results.					  
		//system.assertEquals(objUpdateCase.Mybuilding_Event_Creation_Status__c,'Successfully created event in MyBuilding App');					  
								
    }
}