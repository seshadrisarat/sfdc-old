@isTest
private class SL_Test_Batch_ServiceLease {
	
	@isTest static void test_BackfillCaseLease() 
	{
		String strRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND  DeveloperName = 'Maintenance_Request'].Id;
	    Building__c objBuilding = new Building__c(Name='Test Building 1', Street_Address__c = 'Test Address New',
                                                   Zip_Code__c = '1232123', Community_ID__c = '4'); 
       
        insert objBuilding;
      	
        Apartment__c objApartment = new Apartment__c(Name = 'Test Property',Building__c = objBuilding.Id, Apartment_Number__c = '205' );
        insert objApartment;
     	
        Lease__c objLease = new Lease__c(Name='Test Lease' , Apartment__c=objApartment.Id , Start_Date__c=Date.today().addDays(-10),End_Date__c = Date.today().addDays(20));
        insert objLease;

        Case objCase = new Case(Subject = 'Test Subject',Description='Test Description',Status='New',Origin = 'Web',
        						RecordTypeId = strRecordTypeId,Building__c = objBuilding.Id,Apartment__c = objApartment.Id);
        insert objCase;
         
        test.startTest();
        Database.executeBatch(new SL_Batch_ServiceLease());
    	test.stopTest();  

    	system.assertEquals(objLease.Id , [Select Id, Lease__c from Case where Id=:objCase.Id LIMIT 1].Lease__c);
	}
	
}