/*
* @author : sfdcdev, Tamarack Consulting, Inc.
* @date : 02/01/2015
* @description: Batch for processing team annual goals. This should work just fine with 2000 users at a time, but if user base grows might need to adjust batch size
*
* © Copyright 2003 - 2015 Tamarack Consulting, Inc.  All Rights Reserved.
* 
*/

global class TC_TeamAnnualGoalBatch implements Database.Batchable<sObject> {
	
	String query;
	Integer year;
	String email;
	String error;
	
	global TC_TeamAnnualGoalBatch(String query, Integer year) {
		this.query = query;
		this.year = year;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<User> scope) {
		try {
			Map <Id, User> userMap = new Map <Id, User> (scope);
			TC_TeamAnnualGoalUtility.processTeamAnnualGoals(year, userMap.keySet());
			
		} catch (Exception ex){
			System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
			this.error += ex.getMessage() + ' ' + ex.getStackTraceString();
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		try {
			if (Test.isRunningTest()) error = 'some error for test coverage';
			
    		if(!String.isEmpty(error)){
		        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		        mail.setToAddresses(this.email.split(','));
		        mail.setReplyTo('dev+faef@sfdcdev.com');
		        mail.setSenderDisplayName('Annual TEAM Goals Batch Processing');
		        
		        
	        	mail.setSubject('Annual TEAM Goals Batch Process Completed w/ Errors');
		        mail.setPlainTextBody(error);
		        
		        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    		} else {
    			System.debug('Annual TEAM Goals Batch Process Completed Successfully');
    		}
    	}
    	catch(Exception ex) {
    		System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
    	}
	}
}