//tamarack - 2/3/15 update class to handle new changes

global class AnnualGoalsBatchSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc){      
    	String queryString = '';
    	queryString += 'SELECT Id FROM User ';
    	queryString += 'WHERE isActive = true AND Exclude_Dashboard__c != \'TRUE\' ';
    	queryString += 'AND Profile.Name != \'Sales - RVP\' ';
    	queryString += 'AND Profile.Name != \'Sales - RVP - Vendor\' ';
    	queryString += 'AND Profile.Name like \'Sales%\'';

    	if (Test.isRunningTest()) {
    		queryString += ' LIMIT 5'; 
    	}
    	
        Id batchInstanceId = Database.executeBatch(new AnnualGoalsBatch(queryString, 'dev+faef@sfdcdev.com,its@faef.com'), 5);
    }
}