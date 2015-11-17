/**
*  ClassName      : SL_SchedulerToCreateRenewalOpportunity
*  JIRATicket     : THOR-42
*  CreatedOn      : 24/SEP/2014
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the scheduler class to schedule Renewal Batch Process
*/
global class SL_SchedulerToCreateRenewalOpportunity implements Schedulable
{
	global void execute(SchedulableContext SC)
    {
    	///Create variables
    	Date FAIRMARKET_NUMBEROFDAYS;
    	Date FAIRMARKET_RENEWAL_NUMBEROFDAYS;
    	Date RENT_STABILIZED_NUMBEROFDAYS;
    	Date RENT_STABILIZED_RENEWAL_NUMBEROFDAYS;
    	String strQuery; 
    	String strLeaseQuery = '';
    	String FAIR_MARKET = 'Fair Market';
    	String FAIR_MARKET_RENEWAL = 'Fair Market Renewal';
    	String RENT_STABILIZED = 'Rent Stabilized';
    	String RENT_STABILIZED_RENEWAL = 'Rent Stabilized Renewal';
    	Id NEW_LEASE_RECORDTYPE_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND  DeveloperName = 'New_Lease_Opportunity'].Id;
    	
   		SL_RenewalBatchTimeSpan__c objRenewalBatchTimeSpan = new SL_RenewalBatchTimeSpan__c();
   		objRenewalBatchTimeSpan = SL_RenewalBatchTimeSpan__c.getInstance('NumberOfDays');
   		
   		strQuery = 'SELECT Id,Name, StageName, CloseDate,Asking_Rent__c ,OwnerId, Lease_End_Date__c, Bed_Bug_Rider__c, Apartment__c, Lease__c,'
   		          + 'AccountId, Preferred_Apartment_Type__c, Best_Contact__c, Budget_Max__c, Budget__c, Comments_from_Website__c,Security_Deposit_Required__c ,Existing_Security_Deposit__c, First_Appointment_Date__c,' 
   		          + 'First_Call_Date__c, First_Email_Date__c, Last_Appointment_Date__c,Monthly_Rent__c ,LeadSource,  Payment_Method__c, Previous_Lease_Rent__c, Previous_Opportunity__c,'
   		          + 'Tenant_Referral__c, Type_of_Credit_Card__c, Amount, Lease_Type__c'
   		          +' FROM Opportunity'; 
   		          
   		if(objRenewalBatchTimeSpan.Fair_Market_Days__c != null)
   		{
   			FAIRMARKET_NUMBEROFDAYS = system.today().addDays(Integer.valueOf(objRenewalBatchTimeSpan.Fair_Market_Days__c));
   			strLeaseQuery += ' (Lease__r.End_Date__c =:FAIRMARKET_NUMBEROFDAYS AND Lease__r.Type__c =:FAIR_MARKET)';
   		}
   		
   		if(objRenewalBatchTimeSpan.Fair_Market_Renewal_Days__c != null)
   		{
   			FAIRMARKET_RENEWAL_NUMBEROFDAYS = system.today().addDays(Integer.valueOf(objRenewalBatchTimeSpan.Fair_Market_Renewal_Days__c));
   			if(strLeaseQuery != '')
   				strLeaseQuery += ' OR';
   			strLeaseQuery += ' (Lease__r.End_Date__c =:FAIRMARKET_RENEWAL_NUMBEROFDAYS AND Lease__r.Type__c =:FAIR_MARKET_RENEWAL)';
   		}
   		
   		if(objRenewalBatchTimeSpan.Rent_Stabilized_Days__c != null)
   		{
   			RENT_STABILIZED_NUMBEROFDAYS = system.today().addDays(Integer.valueOf(objRenewalBatchTimeSpan.Rent_Stabilized_Days__c));
   			if(strLeaseQuery != '')
   				strLeaseQuery += ' OR';
   			strLeaseQuery += ' (Lease__r.End_Date__c =:RENT_STABILIZED_NUMBEROFDAYS AND Lease__r.Type__c =:RENT_STABILIZED)';
   		}
   		
   		if(objRenewalBatchTimeSpan.Rent_Stabilized_Renewal_Days__c != null)
   		{
   			RENT_STABILIZED_RENEWAL_NUMBEROFDAYS = system.today().addDays(Integer.valueOf(objRenewalBatchTimeSpan.Rent_Stabilized_Renewal_Days__c));
   			if(strLeaseQuery != '')
   				strLeaseQuery += ' OR';
   			strLeaseQuery += ' (Lease__r.End_Date__c =:RENT_STABILIZED_RENEWAL_NUMBEROFDAYS AND Lease__r.Type__c =:RENT_STABILIZED_RENEWAL)';
   		}
   		
   		///Form a query to fetch lease records based on type and Enddate
   		if(strLeaseQuery != '')
   		   strQuery += ' WHERE ('+ strLeaseQuery  +')';
   		
   		SL_RenewalOpportunityBatch objRenewalOpportunityBatch = new SL_RenewalOpportunityBatch(strQuery,NEW_LEASE_RECORDTYPE_ID,FAIRMARKET_NUMBEROFDAYS,
                                                                                               FAIRMARKET_RENEWAL_NUMBEROFDAYS,RENT_STABILIZED_NUMBEROFDAYS,
                                                                                               RENT_STABILIZED_RENEWAL_NUMBEROFDAYS, FAIR_MARKET,
                                                                                               FAIR_MARKET_RENEWAL,RENT_STABILIZED,
                                                                                               RENT_STABILIZED_RENEWAL);
   		database.executebatch(objRenewalOpportunityBatch, 200); 
    }
}