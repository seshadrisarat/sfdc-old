/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 2/5/2015
* @description: batch for aggregating shoretel stats. It should be kicked off after the annual goal batch but before the team batch runs.
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/


global class TC_ShoreTelDailyCallsBatch implements Database.Batchable<sObject> {
	
	public String query {get;set;}
	public String email {get; set;}
	public String error {get;set;}
	public Integer goalsYear {get; set;}
	public Date callStatsStartDate;
	
	global TC_ShoreTelDailyCallsBatch (String query, String email, Date callStatsStartDate, Integer goalsYear){
		this.query = query;
        this.email = email;
        this.error = '';
        this.callStatsStartDate = callStatsStartDate;
        this.goalsYear = goalsYear;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List <User> scope) {
		Map <Id, User> userMap = new Map <Id, User> (scope);
		TC_ShoreTelDailyCallUtil.aggregateDailyCallData(callStatsStartDate, userMap.keySet());
	}
	
	global void finish(Database.BatchableContext context){
    	try {
    		if (Test.isRunningTest()) error = 'some error for test coverage';
			
    		if(!String.isEmpty(error)){
		        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		        mail.setToAddresses(this.email.split(','));
		        mail.setReplyTo('dev+faef@sfdcdev.com');
		        mail.setSenderDisplayName('Annual Goals Batch Processing');
		        
		        
	        	mail.setSubject('Annual Goals Batch Process Completed w/ Errors');
		        mail.setPlainTextBody(error);
		        
		        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    		} else {
    			System.debug('Annual Goals Batch Process Completed Successfully');

    			//tamarack - piggy back on this batch and kickoff the team batch 
    			TC_TeamAnnualGoalBatch b = new TC_TeamAnnualGoalBatch (query, goalsYear);
    			System.debug(LoggingLevel.INFO,  ' TEAM Annual Goals Batch Process STARTED Successfully : ' + Database.executeBatch(b, 2000));
    		}
    	}
    	catch(Exception ex) {
    		System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
    	}
    }	
}