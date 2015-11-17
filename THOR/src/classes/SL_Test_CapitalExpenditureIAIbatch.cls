@isTest
private class SL_Test_CapitalExpenditureIAIbatch {

	private static testMethod void testBatch() 
	{
	    //createTestData(1 , 1);
	    Building__c objBuilding = new Building__c(Name='test Building' , Street_Address__c='test Address 1' , Zip_Code__c = '123456');
	    insert objBuilding;
	    
	    Apartment__c objApartment = new Apartment__c(Name='Test Apartment' , Building__c=objBuilding.Id);
	    insert objApartment;
	    
	    List<Capital_Expenditure__c> lstCaptialExpenditureToInsert = new List<Capital_Expenditure__c>(); 
	    for(Integer i=0;i<4;i++)
        {
            lstCaptialExpenditureToInsert.add(new Capital_Expenditure__c(Name='test Expenditure , ' + objApartment.Name + i,
                                                                         Building__c=objBuilding.Id , 
                                                                         Apartment__c=objApartment.Id , 
                                                                         Total_Costs_Bathroom__c = 1000,
                                                                         Total_Costs_Kitchen__c = 2000,
                                                                         Total_Costs_Other__c = 3000,
                                                                         Include_Exception__c = true));
        }
        insert lstCaptialExpenditureToInsert;
        system.assertNotEquals(null , lstCaptialExpenditureToInsert[0].Id);
        
        Test.startTest();    
    	    SL_CapitalExpenditureIAIbatch onjBatch = new SL_CapitalExpenditureIAIbatch();
    	    Id idBobId = Database.executeBatch(onjBatch , 1000);
	    Test.stopTest();
	    
	    system.assertEquals(400 , [Select Total_IAI_Rent_Increase__c from Apartment__c Limit 1].Total_IAI_Rent_Increase__c);
	}
	
	private static testMethod void testSchedulerCaller()
	{
	    //createTestData(2 , 100);
	    SL_Scheduler_CapitalExpenseBatch_Caller objCaller = new SL_Scheduler_CapitalExpenseBatch_Caller();
	}
}