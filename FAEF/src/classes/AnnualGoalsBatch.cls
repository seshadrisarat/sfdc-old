//tamarack 01-28-15
// added ShortTel stats calculation

//to run execute anonymous
//Database.executeBatch(new AnnualGoalsBatch('Select ID from User where isactive = true AND Exclude_Dashboard__c != \'TRUE\' AND Profile.Name != \'Sales - RVP\' AND Profile.Name != \'Sales - RVP - Vendor\' AND Profile.Name like \'Sales%\'', 'dev@sfdcdev.com', System.today()-60 ), 5);

global without sharing class AnnualGoalsBatch implements Database.Batchable<SObject>, Database.Stateful {
	public String query;
	public String email;
	public String error;
	public Integer goalsYear;
	public Date callStatsStartDate;
	
    global AnnualGoalsBatch(String query, String email){
    	this (query, email, System.today()-5);
    }


    //tamarack overload constructor to allow catch up stats for previous date/year
    global AnnualGoalsBatch(String query, String email, Date callStatsStartDate){
        this.query = query;
        this.email = email;
        this.error = '';
        this.callStatsStartDate = callStatsStartDate;
        this.goalsYear = callStatsStartDate.year();
    }
    
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext context, List<User> scope){
		List <Id> userIds = new List <Id> ();	
		try {	
			for(User u :scope) {			
				userIds.add(u.Id);
			}
	    	 
			if(userIds.size() > 0) {
				AnnualGoalsUtility.updateAnnualGoals(userIds, goalsYear);
				AnnualGoalsUtility.updateCareerToDateFundedCGM(userIds);
			}
		} catch(Exception ex){
			System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
			this.error += ex.getMessage() + ' ' + ex.getStackTraceString();
		}
    }
    
    global void finish(Database.BatchableContext context){
    	try {
    		if(this.error != null && this.error != ''){
		        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		        mail.setToAddresses(this.email.split(','));
		        mail.setReplyTo('dev+faef@sfdcdev.com');
		        mail.setSenderDisplayName('Annual Goals Batch Processing');
		        
		        
	        	mail.setSubject('Annual Goals Batch Process Completed w/ Errors');
		        mail.setPlainTextBody(error);
		        
		        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    		} else {
    			System.debug('Annual Goals Batch Process Completed Successfully');
    			if (!Test.isRunningTest()) {
    				//tamarack - piggy back on this batch and kickoff the team batch 
    				TC_ShoreTelDailyCallsBatch b = new TC_ShoreTelDailyCallsBatch (query, email, callStatsStartDate, goalsYear);
    				System.debug(LoggingLevel.INFO,  ' TC_ShoreTelDailyCallsBatch Process STARTED Successfully : ' + Database.executeBatch(b, 2));
    			}
    		}
    	}
    	catch(Exception ex) {
    		System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
    	}
    }
}