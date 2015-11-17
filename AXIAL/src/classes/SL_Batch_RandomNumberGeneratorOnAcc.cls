/**
	* ClassName      : SL_Batch_RandomNumberGeneratorOnAcc
	* JIRATicket     : AXIAL-3
	* CreatedOn      : 29/Jun/2015
	* ModifiedBy     : Prakash
	* Description    : This Bacth class is used to update the Random_Number__c field on each account in a daily basis. 	
*/
global with sharing class SL_Batch_RandomNumberGeneratorOnAcc implements Database.Batchable<sObject>
{
	/*
        @MethodName: start 
        @param : Database.BatchableContext BC
        @Description: It is overriden method of Database.Batchable interface.
    */
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
    	String strQuery = 'Select Id, Random_Number__c From Account';
    	return Database.getQueryLocator(strQuery);
    }
    
    /*
        @MethodName: execute 
        @param : Database.BatchableContext BC,List<Account> lstAccounts
        @Description: It is overriden method of Database.Batchable interface and used to update the Account records.
    */
    global void execute(Database.BatchableContext BC,List<Account> lstAccounts) 
    {
    	updateAccRandomNumberField(lstAccounts);
    }
    
    private void updateAccRandomNumberField(List<Account> lstAccounts)
    {
    	List<Account> lstAccToUpdateRandomNumber = new List<Account>();
    	// Iterating over the Account records..
    	for(Account objAccount : lstAccounts){
    		objAccount.Random_Number__c = randomNumberGenerator(String.valueOf(objAccount.Id));
    		lstAccToUpdateRandomNumber.add(objAccount);
    	}
    	
    	Database.SaveResult[] dbsr =  Database.update(lstAccToUpdateRandomNumber, false); 
    	
    	Set<Id> setOfAccIds = new Set<Id>();
    	setOfAccIds = returnFailedRecordIds(dbsr);
    	
    	if(!setOfAccIds.isEmpty()){
    		prepareListOfAccounts(setOfAccIds);
    	}
    }
    
    
    private void prepareListOfAccounts(Set<Id> setOfAccIds){
    	List<Account> lstAcc = new List<Account>();
    	for(Id objAccId : setOfAccIds ){
    		Account objAccount = new Account(Id = objAccId);
    		lstAcc.add(objAccount);
    	}
    	
    	updateAccRandomNumberField(lstAcc);
    	
    }
    
    private Set<Id> returnFailedRecordIds(Database.SaveResult[] srList ){
    	Set<Id> setOfFailedRecordIds = new Set<Id>();
    	// Iterate through each returned result
		for (Database.SaveResult sr : srList) {
		    if (!sr.isSuccess()) {
		        setOfFailedRecordIds.add(sr.getId());
		    }
		}
		
		return setOfFailedRecordIds;
    }
    
    private decimal randomNumberGenerator(String strSFDCRecordId){
    	Decimal decRandomNumber = 0.0;
    	
    	// cheking if the oarameter is not blank
    	if(strSFDCRecordId != NULL && strSFDCRecordId != ''){
    		decRandomNumber = Decimal.valueOf(String.valueOf(strSFDCRecordId.hashCode()) + String.valueOf(math.random()));
    	}
    	
    	return decRandomNumber;
    }
    
    
    /*
        @MethodName: finish 
        @param : Database.BatchableContext BC
        @Description: It is overriden method of Database.Batchable interface.
    */
    global void finish(Database.BatchableContext BC)
    {
        //do the updates you want to do finally after the batch is finished.
    }
}