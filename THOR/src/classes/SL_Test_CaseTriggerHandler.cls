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
	    String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and DeveloperName = 'Move_In_Process'].Id;
	    String strRecordTypeId_MoveOut = [Select Id From RecordType Where SobjectType = 'Case' and DeveloperName = 'Move_Out_Process'].Id;
	    
	    Building__c objBuilding = new Building__c(Name='Test Building 1', Street_Address__c = 'Test Address New',
                                                   Zip_Code__c = '1232123', Community_ID__c = '4'); 
       
        insert objBuilding;
        
        Apartment__c objApartment = new Apartment__c(Name = 'Test Property',Building__c = objBuilding.Id, Apartment_Number__c = '205' );
        insert objApartment;
            
        Case objCase = new Case(Subject = 'Test Subject',Description='Test Description',Lease_Start_Date__c = Date.today() ,
                Status='New',Origin = 'Web',RecordTypeId = strRecordTypeId,Building__c = objBuilding.Id,Apartment__c = objApartment.Id, Date_From__c = datetime.newInstance(2014, 09, 09, 09, 00, 00),Date_To__c  = datetime.newInstance(2014, 09, 09, 12, 00, 00));
        
        Case objCase_MVOT = new Case(Subject = 'Test Subject MV OT',Description='Test Description',Lease_Start_Date__c = Date.today().addDays(-100) , Move_Out_Date__c  = date.today(),
                Status='In Progress',Origin = 'Web',RecordTypeId = strRecordTypeId_MoveOut,Building__c = objBuilding.Id,Apartment__c = objApartment.Id, Date_From__c = datetime.newInstance(2014, 09, 09, 09, 00, 00),Date_To__c  = datetime.newInstance(2014, 09, 09, 12, 00, 00));
                
        test.startTest();
        List<Case> lstCaseToInsert = new List<Case>();
        lstCaseToInsert.add(objCase);
        lstCaseToInsert.add(objCase_MVOT);
        //insert objCase;
        insert lstCaseToInsert;
        
        String strFakeResponse = '{ "response": { "total_items": 1,"page_size": "1","page_count": 1,"page_number": "1","events": {"event":[{"eventId": "21081","communityId": "4","eventCategoryId": null,"title": "Furniture Delivery - 2L - Michael Picarello","text": "", "dateStart": "2014-09-09 09:00:00","dateEnd": "2014-09-09 12:00:00"}]}}, "status": "success"}';
                
        SL_SingleRequestMockResponse fakeResponse = new SL_SingleRequestMockResponse(200,
                                                 'Complete',
                                                 strFakeResponse,
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
         
    
        Case objUpdateCase = [select Mybuilding_Event_Creation_Status__c,Mybuilding_Event_Id__c
                from Case where Id=:objCase.Id ];
        
        Lease__c objLease = new Lease__c(Name='Test Lease - 01' , Apartment__c = objApartment.Id ,  Start_Date__c = date.today().addDays(-10) , End_Date__c = date.today().addDays(-2));
        insert objLease;
        objCase_MVOT.Lease__c = objLease.Id;
        objCase_MVOT.Status = 'Closed';
        objCase_MVOT.Move_Out_Date__c = date.today().addDays(-10);
        update objCase_MVOT;
                
        test.stopTest();         
    }
}