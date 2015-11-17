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
private class SL_TestMyBuildingServiceRequestBatch{
		   
		static testMethod void myUnitTest() 
    	{
         //TO DO: implement unit test   
			List<Building__c> lstBuilding = new List<Building__c>{new Building__c(Name='Test MyBuilding', Street_Address__c='123 ABCD', Zip_Code__c='10009'),
	    														  new Building__c(Name='Test MyBuilding1', Community_ID__c = '305', Street_Address__c='123 ABCDE', Zip_Code__c='100010')}; 
	    
	    	insert lstBuilding;
	    	
	    	SL_MyBuilding_Integration__c objCustomSetting = new SL_MyBuilding_Integration__c(Name = 'MyBuilding', app_Id__c = '7394d810', app_key__c = 'c1da437fc618e60ff8b2ec89c9dc8659',
	    																					 dateFrom__c = string.valueOfGmt(datetime.now()), dateTo__c = string.valueOfGmt(datetime.now().addHours(12)),
	    																					 groupId__c = '7394d810000', isAllDayEvent__c = 'A',EndPoint__c = 'https://api.mybuilding.org');
	    	insert objCustomSetting;
	    	
			Contact objContact = new Contact(LastName = 'TestContact01',
											 Email =  'test@contactemail.com',
											 Phone = '+12015198628');
			insert objContact;
	        
			/*Added for THOR-68*/	        
			Apartment__c objApartment = new Apartment__c(Name = 'Test Property',Building__c = lstBuilding[1].Id, Apartment_Number__c = '120-BS1' );
        	insert objApartment;

	        Lease__c objLease = new Lease__c(Name='Test Lease' , Apartment__c=objApartment.Id , Start_Date__c=Date.today().addDays(-10),End_Date__c = Date.today().addDays(20));
        	insert objLease;
	        /*Added for THOR-68*/	

	        String strFakeResponse = '{"response": {"requests": [{"requestId": "165889","unit": "120-BS1","contactName": "David Jimenez (Frontdesk)","contactPhone": "+13475010084",'+
										    '"contactEmail": "djiminez@myfrontdesk.org","status": "Resolved","statusId": "4","category": "Elevators","description": "elevator inspection",'+
										    '"photoSmallURL": null,"photoURL": null,"permissions": "Yes","submittedBy": "David Jimenez (Frontdesk)","dateSubmitted": "2014-11-06 13:35:51",'+
										    '"dateSubmittedFormatted": "11/6/14 1:35 PM"}],"totalItems": 100,"pageSize": 50,"pageCount": 2,"pageNumber": 1,'+
										  '"status": "success"}}';
        
  			SL_SingleRequestMockResponse fakeResponse = new SL_SingleRequestMockResponse(200,
                                                 'Complete',
                                                 strFakeResponse,
                                                 null);
        	Test.setMock(HttpCalloutMock.class, fakeResponse);
        	
        	Test.startTest();
	       	SL_MyBuildingServiceRequestBatch objBatch = new SL_MyBuildingServiceRequestBatch();      
	       	Database.executeBatch(objBatch);
	       	Test.stopTest();
	       	Integer i  = [SELECT COUNT() FROM Case WHERE ContactId =: objContact.Id];
	        system.assertEquals(i, 0);
    	}

    	static testMethod void test_CatchBlocks() 
    	{
    		Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount'].Id;
         	Account objDefaultAccount = new Account(FirstName = 'Default', LastName = 'Account', RecordTypeId = recordTypeId, Phone = 'Default', 
	                                                PersonEmail = 'defaultaccount@silverlinecrm.com', Description = 'Default Account Description'); 

         	insert objDefaultAccount;

         	insert new Default_Account_For_Maintainence_Cases__c(Name = 'Default Account', Default_Account_Id__c = objDefaultAccount.Id);

			List<Building__c> lstBuilding = new List<Building__c>{new Building__c(Name='Test MyBuilding', Street_Address__c='123 ABCD', Zip_Code__c='10009'),
	    														  new Building__c(Name='Test MyBuilding1', Community_ID__c = '305', Street_Address__c='123 ABCDE', Zip_Code__c='100010')}; 
	    
	    	insert lstBuilding;
	    	
	    	SL_MyBuilding_Integration__c objCustomSetting = new SL_MyBuilding_Integration__c(Name = 'MyBuilding', app_Id__c = '7394d810', app_key__c = 'c1da437fc618e60ff8b2ec89c9dc8659',
	    																					 dateFrom__c = string.valueOfGmt(datetime.now()), dateTo__c = string.valueOfGmt(datetime.now().addHours(12)),
	    																					 groupId__c = '7394d810000', isAllDayEvent__c = 'A',EndPoint__c = 'https://api.mybuilding.org');
	    	insert objCustomSetting;
	    	
			Contact objContact = new Contact(LastName = 'TestContact01',
											 Email =  'test@contactemail.com',
											 Phone = '+12015198628');
			insert objContact;
	        
			/*Added for THOR-68*/	        
			Apartment__c objApartment = new Apartment__c(Name = 'Test Property',Building__c = lstBuilding[1].Id, Apartment_Number__c = '120-BS1' );
        	insert objApartment;

	        Lease__c objLease = new Lease__c(Name='Test Lease' , Apartment__c=objApartment.Id , Start_Date__c=Date.today().addDays(-10),End_Date__c = Date.today().addDays(20));
        	insert objLease;
	        /*Added for THOR-68*/	

	        String strFakeResponse = '{"response": {"requests": [{"requestId": "165889","unit": "120-BS1","contactName": "null","contactPhone": "null",'+
										    '"contactEmail": "","status": "Resolved","statusId": "4","category": "Elevators","description": "elevator inspection",'+
										    '"photoSmallURL": null,"photoURL": null,"permissions": "Yes","submittedBy": "David Jimenez (Frontdesk)","dateSubmitted": "2014-11-06 13:35:51",'+
										    '"dateSubmittedFormatted": "11/6/14 1:35 PM"}],"totalItems": 100,"pageSize": 50,"pageCount": 2,"pageNumber": 1,'+
										  '"status": "success"}}';
        
  			SL_SingleRequestMockResponse fakeResponse = new SL_SingleRequestMockResponse(200,
                                                 'Complete',
                                                 strFakeResponse,
                                                 null);
        	Test.setMock(HttpCalloutMock.class, fakeResponse);
        	
        	Test.startTest();
	       	SL_MyBuildingServiceRequestBatch objBatch = new SL_MyBuildingServiceRequestBatch();      
	       	Database.executeBatch(objBatch);
	       	Test.stopTest();
	       	Integer i  = [SELECT COUNT() FROM Case WHERE ContactId =: objContact.Id];
	        system.assertEquals(i, 0);
    	}
}