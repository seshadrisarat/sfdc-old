/*
*Class: SL_Scheduler_UpdateProviderAccountAddres
*Description: This is the scheduler class for SL_Batch_UpdateProviderAccountAddress.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
global class SL_Scheduler_UpdateProviderAccountAddres implements Schedulable
{
	/*
        @MethodName: execute 
        @param : SchedulableContext sc
        @Description: It is overriden method of Schedulable interface.
    */
	global void execute(SchedulableContext sc)
	{
		//Getting how many jobs are there in pipeline
		Integer intJobs = [SELECT COUNT() FROM AsyncApexJob WHERE ( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )]; 
		//Checking if count is less than or equal to 9
		if(intJobs <= 9)
		{
			//Invoking the batch process
			Database.executeBatch(new SL_Batch_UpdateProviderAccountAddress('SELECT Id, Name, Street_Address_1__c, Street_Address_2__c, Street_Address_3__c, City__c, Country__c, State__c, Postal_Code__c, Type__c, Provider__c FROM Provider_Address__c WHERE Primary__c = true ORDER BY Name'), 100);
			Database.executeBatch(new SL_Batch_UpdateProviderAccountAddress('SELECT Id, Name, Street_Address_1__c, Street_Address_2__c, Street_Address_3__c, City__c, County__c, State__c, Postal_Code__c, Type__c, Organization__c FROM Organization_Address__c WHERE Primary__c = true ORDER BY Name'), 100);
		}
	}
}