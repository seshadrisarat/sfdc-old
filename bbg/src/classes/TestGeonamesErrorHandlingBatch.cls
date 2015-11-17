@isTest
private class TestGeonamesErrorHandlingBatch {
	
	static final Integer SUCCESS_LEADS = 1;
	static final Integer FAIL_LEADS = 1;

	static List<Lead> successLeads;
	static List<Lead> failLeads;
	
	static RecordType recType;
    

    static{
        recType=[SELECT Id, developerName from RecordType where SObjectType='Lead' and isActive=true LIMIT 1];
    }


	static void setup(String code){
		DisableLeadRoutingTrigger__c dlrt= new DisableLeadRoutingTrigger__c ();
        dlrt.Name='LeadRouting';
        insert dlrt;

       Id allowedRecordTypesId=recType.Id;

        insert new LeadRoutingAllowedRecordTypes__c(Name=recType.developerName);
        
        LeadServices.isBatch = true;

        successLeads = TestUtilities.createLeads(allowedRecordTypesId, SUCCESS_LEADS, false);
        failLeads = TestUtilities.createLeads(allowedRecordTypesId, FAIL_LEADS, false);

        for(Lead l : successLeads){
        	l.postalcode = code;
        	l.Country_ISO_Code__c = 'CA';
        	l.Geonames_Retry__c = true;
        }

        insert successLeads;

        for(Lead l : failLeads){
        	l.postalcode = code;
        	l.Country_ISO_Code__c = 'CA';
        	l.Geonames_Retry__c = false;
        }

        insert failLeads;
	}

    static testMethod void testBatchSuccess() {
		setup(TestLeadServices.SUCCESS_CODE);

		test.startTest();
			GeonamesErrorHandlingBatch geoBatch = new GeonamesErrorHandlingBatch();
			Id batchId = Database.executeBatch(geoBatch);
		test.stopTest();

		successLeads = [	SELECT Id, Longitude__c, Latitude__c, Geonames_Retry__c 
							FROM Lead 
							WHERE Id IN :successLeads];

		failLeads = [	SELECT Id, Longitude__c, Latitude__c, Geonames_Retry__c 
						FROM Lead 
						WHERE Id IN :failLeads];

		System.assert(successLeads.size() == SUCCESS_LEADS);
		for(Lead l : successLeads){
			System.assert(!l.Geonames_Retry__c, 'This checkbox should have been cleared.');
			System.assert(l.Latitude__c != null, 'Latitude should have been populated');
			System.assert(l.Longitude__c != null, 'Longitude should have been populated');
		}

		System.assert(failLeads.size() == FAIL_LEADS);
		for(Lead l : failLeads){
			System.assert(!l.Geonames_Retry__c, 'This checkbox should still be false.');
			System.assert(l.Latitude__c == null, 'These leads should not have been processed');
			System.assert(l.Longitude__c == null, 'These leads should not have been processed');
		}

    }

    static testMethod void testBatchError() {
        setup(TestLeadServices.ERROR_CODE);

        test.startTest();
			GeonamesErrorHandlingBatch geoBatch = new GeonamesErrorHandlingBatch();
			Id batchId = Database.executeBatch(geoBatch);
		test.stopTest();

		successLeads = [	SELECT Id, Longitude__c, Latitude__c, Geonames_Retry__c 
							FROM Lead 
							WHERE Id IN :successLeads];

		failLeads = [	SELECT Id, Longitude__c, Latitude__c, Geonames_Retry__c 
						FROM Lead 
						WHERE Id IN :failLeads];

		System.assert(successLeads.size() == SUCCESS_LEADS);
		for(Lead l : successLeads){
			System.assert(l.Geonames_Retry__c, 'This checkbox should still be true.');
			System.assert(l.Latitude__c == null, 'These leads should have failed to succesfully process');
			System.assert(l.Longitude__c == null, 'These leads should have failed to succesfully process');
		}

		System.assert(failLeads.size() == FAIL_LEADS);
		for(Lead l : failLeads){
			System.assert(!l.Geonames_Retry__c, 'This checkbox should still be false.');
			System.assert(l.Latitude__c == null, 'These leads should not have been processed');
			System.assert(l.Longitude__c == null, 'These leads should not have been processed');
		}
    }
    
     static testmethod void TestSchedulableExec() {
	   Test.startTest();
	
	      // Schedule the test job
		 String CRON_EXP = '0 0 0 3 9 ? 2022';	
			
	      String jobId = System.schedule('Test GeoNames error',
	      CRON_EXP, 
	         new GeonamesErrorHandlingBatch());
	
	      // Get the information from the CronTrigger API object
	      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
	         NextFireTime
	         FROM CronTrigger WHERE id = :jobId];
	
	      // Verify the expressions are the same
	      System.assertEquals(CRON_EXP, 
	         ct.CronExpression);
	
	      // Verify the job has not run
	      System.assertEquals(0, ct.TimesTriggered);
	
	      // Verify the next time the job will run
	      System.assertEquals('2022-09-03 00:00:00', 
	         String.valueOf(ct.NextFireTime));
	
	   Test.stopTest();

   }
}