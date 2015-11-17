/**
 
* \author Rahul Sharma
 
* \date 30/06/2011
 
* \see http://silverline.jira.com/browse/STONEPII-5
 
* \brief : Call a batch which Create New Renewal Opportunities 60 days prior to the Lease_End_Date__c with Same Contact roles
 
* \Schedulable Class
 
*/
 
global class SL_SchedulerToCreateRenewalOpportunity implements Schedulable
{
        /* Start        : Global Variables */
        global date PriorLeaseEndDate;
        global String strQuery;
        /* End          : Global Variables */
        
        
        /**
        
        * \Start Method
        
   * \Name             : execute
   
   * \Parameters   : SchedulableContext
   
   * \Description  : Call batch - SL_BatchToCreateRenewalOpportunity
   
   * \Return           : void
    
   */
   global void execute(SchedulableContext SC)
    {
            strQuery = '';
            
            // Added by Shailendra on 18/March/2013. 
            // Fetch the value from the custom settings. create a renewal opportunity when 
            // Property.Lease_end_date__c is within X number of days from today. X is defined using a custom setting.
            Prior_LeaseEndDate_Timespan__c cs_PriorLeaseEndDate = new Prior_LeaseEndDate_Timespan__c();
			cs_PriorLeaseEndDate = Prior_LeaseEndDate_Timespan__c.getInstance('NumberOfDays');
		
			if(cs_PriorLeaseEndDate == null || cs_PriorLeaseEndDate.Timespan__c == null)
				return;
				
            Decimal dec_NumberOfDays = cs_PriorLeaseEndDate.Timespan__c;
            
            PriorLeaseEndDate = system.today().addDays(Integer.valueOf(dec_NumberOfDays));  
            
            // Modified by Shailendra on 12/Feb/2013 as part of enhancement on STONEPII-111 and STONEPII-112
            /*strQuery = 'Select Previous_Opportunity__c, Property__c, Property__r.Name, Property_Name__c, Name, StageName, RecordTypeId, Property__r.Lease_Type__c, '+
                        'Lease_Start_date__c, Lease_End_Date__c, Id, Close_Date__c, CloseDate, AccountId, '+
                        '(Select name, Previous_Opportunity__c From Renewal_Opportunities__r where Previous_Opportunity__c !=null) From Opportunity Where '+
                        'StageName = \'Signed Lease\' and Lease_End_Date__c <= :PriorLeaseEndDate and Property__c != \'\' and Property__r.Lease_Type__c != \'RS\''; */
           strQuery =   'Select Account__c, Name, Id, Lease_End_Date__c, Building__r.Renewal_Leasing_Agent__c, Opportunity__c,'+
						'(Select Contact__c, Role__c From Current_Tenants__r) From Property__c where Lease_End_Date__c != null and Lease_Type__c != \'RS\'' +
						' and ' + 
						'Lease_End_Date__c = :PriorLeaseEndDate and Opportunity__r.StageName = \'Signed Lease\'';
                                                                 
   			SL_BatchToCreateRenewalOpportunity objBatchClass = new SL_BatchToCreateRenewalOpportunity(strQuery, PriorLeaseEndDate);
            database.executebatch(objBatchClass, 200); 
    }
        
        /*
                SL_SchedulerToCreateRenewalOpportunity obj = new SL_SchedulerToCreateRenewalOpportunity(); 
                String sch = '0 22 * * * ?' ;
                System.schedule('Renewal Opportunity Creation', sch, obj);
        */
        
    /*@isTest(seeAllData = true)
    private static void test_SL_SchedulerToCreateRenewalOpportunity()
    {
    	SL_SchedulerToCreateRenewalOpportunity obj = new SL_SchedulerToCreateRenewalOpportunity();
        String sch = '0 22 * * * ?' ;
        System.schedule('Renewal Opportunity Creation', sch, obj);
    }*/
}