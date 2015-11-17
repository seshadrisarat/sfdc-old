/**
 
* \author Rahul Sharma
 
* \date 2nd August 2011
 
* \see http://silverline.jira.com/browse/stonePII-15
 
* \brief : Call a batch which creates Tenants with mapping provided in the ticket
 
* \Schedulable Class
 
*/
 
 
global class SL_SchedulerToCreateCurrentTenants implements Schedulable
{
        /* Start        : Global Variables */
        
        global String strQuery;
        
        /* End          : Global Variables */
        
        
        /**
        
        * \Start Method
         
   * \Name             : execute
   
   * \Parameters   : SchedulableContext
   
   * \Description  : Call batch - SL_BatchToCreateCurrentTenants
   
   * \Return           : void
     
   */
   global void execute(SchedulableContext SC)
        {
                /*  Update query for "Create Current Tenant" by adding condition on RecordType = New_Lease_Opportunity and 
                    OrderBy Oldest Close Date to Newest Close Date on the Opportunity (as per STONEPII-116) : Shailendra on 16/Aug/2013
                */
                strQuery = 'Select AccountId, Property__c, Tenants_Processed__c, StageName, Lease_Start_date__c, Lease_End_Date__c From Opportunity' + 
                			' where StageName = \'Signed Lease\' and (RecordType.DeveloperName = \'New_Lease_Opportunity\' OR RecordType.DeveloperName = \'Renewal_Opportunity\') AND Tenants_Processed__c = false And Property__c != \'\' ORDER BY Close_Date__c '; 
                			
       			SL_BatchToCreateCurrentTenants objBatchClass = new SL_BatchToCreateCurrentTenants(strQuery);
                Database.executeBatch(objBatchClass);
        }
        
        /* Start - Code in below comment is to schedule the Batch */
        /*
                SL_SchedulerToCreateCurrentTenants obj = new SL_SchedulerToCreateCurrentTenants();
                String sch = '0 0 1 * * ?' ;
                System.schedule('Current Tenants Creation', sch, obj);
        */
        /* End - Code in below comment is to schedule the Batch */
         
        /* Start - Test Method */
   public static testmethod void SL_SchedulerToCreateCurrentTenants()
   {
       Test.startTest();
       Account objAcc = new Account(Name = 'Test Account');
       insert objAcc;
       Property__c objProp = new Property__c(Name = 'Test Property 001');
       insert objProp;
       Opportunity objOpp = new Opportunity(Property__c = objProp.Id, Name = 'Test Opportunity 001', CloseDate = system.today(), StageName = 'Signed Lease', AccountId = objAcc.Id, Lease_Approved__c = true, Application_Approved__c = true);
       insert objOpp;
       SL_SchedulerToCreateCurrentTenants objSch = new SL_SchedulerToCreateCurrentTenants();
       SchedulableContext SC;
       objSch.execute(SC);
       Test.stopTest();            
   }           
   /* End - Test Method */
}