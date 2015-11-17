@isTest
private class TestAnnualGoalsBatchSchedule {
	public static void removeCronTriggers() {

	    Set<Id> adminProfiles = new Set<Id>(); //set for holding the Ids of Profiles that have the PermissionsModifyAllData permission
	    for (Profile p : [SELECT Id FROM Profile WHERE PermissionsModifyAllData = true]) { 
        //for all profiles where the PermissionsModifyAllData permission is True
	       adminProfiles.add(p.Id); //add the Id to our Set
	    }
  	    User adminUser = [SELECT Id FROM User WHERE isActive = true AND ProfileId in : adminProfiles LIMIT 1]; //select an active user that has a valid admin profile
        System.runAs(adminUser) { //run as the selected User
		   List<CronTrigger> cronTriggersReadyToFireAgain = [SELECT Id FROM CronTrigger WHERE NextFireTime != null]; //create a list of CronTrigger records that are scheduled to fire again
		   if (!cronTriggersReadyToFireAgain.isEmpty()) 
		   { //if the list is not empty
			    for (CronTrigger t : cronTriggersReadyToFireAgain)
			     { //for each record
			     	System.abortJob(t.Id); //abort the job
			     }
		   }
	    }
    }
     
    static testMethod void testSchedule() {
    	//removeCronTriggers();
    	String cron = '0 0 0 1 1 ? 2050';
    	String jobId = null;
        CronTrigger ct = null;
        
        if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued')] < 5){
        	Test.startTest();
        		AnnualGoalsBatchSchedule agbs = new AnnualGoalsBatchSchedule();
       	 		jobId = System.schedule('Annual Goals Batch Schedule Test', cron, agbs);
       	 	Test.stopTest();
       	 	ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
       	
       		System.assertEquals(0, ct.TimesTriggered);
       		System.assertEquals('2050-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        } 
    }
}