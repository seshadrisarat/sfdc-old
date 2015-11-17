trigger standardResources on Projects__c (after insert) {
	//Eric Santiago; 9/19/08
	//create BurnReport/Resource records for a new Project based on picklist values in Burn_Report__c.Role__c
	for (Projects__c newProject: Trigger.New) {
		
		//list list of roles available in Burn_Report__c.Role__c
		Schema.DescribeFieldResult F = Burn_Report__c.Role__c.getDescribe();
        List<Schema.PicklistEntry> Roles = F.getPicklistValues();
	
		//create list of new burn report records
	    List<Burn_Report__c> resources = new List<Burn_Report__c>();   
	    
	    //create burn report record for each role available
	    for (PicklistEntry roleValue: Roles) {
	    resources.add(new Burn_Report__c(Role__c = roleValue.getLabel() ,Rate_hr__c=0,Forecast_Final_Hours__c=0,project__c=newProject.Id,Budget_Hrs__c = 0));
	    }
		
		try {	
			insert resources;
		} catch (exception e) {
			System.debug(e.getMessage());
		}
	}	
		
}