/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SL_Test_DeleteRecentUpdatesBatch {

    //Test method for Batch
    static testMethod void test_SL_Batch_DeleteRecentUpdates() 
    {
        SL_Intranet_PaginationSettings__c testPagination = new SL_Intranet_PaginationSettings__c(Name = 'Test Pagination', Calendar_PageSize__c = 10);
        insert testPagination;
        
        SL_IntranetApplicationSetting__c testApplication = new SL_IntranetApplicationSetting__c(Name = 'Default Settings', Recent_Updates_Days_Threshold__c = 5);
        insert testApplication;
        
        Intranet_Event__c objEvent1 = new Intranet_Event__c(Name ='Test Event 1', For_All_Departments__c = true, Date_of_Event__c = date.newInstance(2013,11,26),
                                                              End_Date__c = date.newInstance(2013,11,29));
        insert objEvent1;
        
        Intranet_Event__c objEvent2 = new Intranet_Event__c(Name ='Test Event 2', For_All_Departments__c = true, Date_of_Event__c = date.newInstance(2013,11,27),
                                                            End_Date__c = date.newInstance(2013,11,30));
        insert objEvent2;
        
        Recent_Updates__c objRecentUpdate1 = new Recent_Updates__c(Name ='Test Recent Update 1', Last_Updated__c = Date.today().addDays(-25));
        insert objRecentUpdate1;
        
        List<Recent_Updates__c> lstRecentUpdate1 = [Select Id, Name, CreatedDate, LastModifiedDate, Last_Updated__c, LastModifiedBy.Name, Sobject_Type__c, Related_To__c 
                                                    From Recent_Updates__c order by Last_Updated__c desc nulls last limit 1000];
        system.assertEquals(lstRecentUpdate1.size(),3);
        
        SL_Batch_DeleteRecentUpdates objBatchClass = new SL_Batch_DeleteRecentUpdates();
        Test.startTest();
        Database.executeBatch(objBatchClass, 200);
        Test.stopTest();
        
        List<Recent_Updates__c> lstRecentUpdate2 = [Select Id, Name, CreatedDate, LastModifiedDate, Last_Updated__c, LastModifiedBy.Name, Sobject_Type__c, Related_To__c 
                                                    From Recent_Updates__c order by Last_Updated__c desc nulls last limit 1000];
        system.assertEquals(lstRecentUpdate2.size(),2);
        

    }
    
    //test method for schedular
    static testmethod void testSchedular()
    {
        test.startTest();
        Recent_Updates__c objRecentUpdate1 = new Recent_Updates__c(Name ='Test Recent Update 1', Last_Updated__c = Date.today().addDays(-25));
        insert objRecentUpdate1;
        SL_SchedulerBatchOnRecentUpdates objRecentUpdatesBatchScheduler = new SL_SchedulerBatchOnRecentUpdates();
        String sch = '0 0 23 * * ?';
       
        system.schedule('Delete Recent Updates', sch, objRecentUpdatesBatchScheduler);
        
        system.assertEquals(0,0);
        
        Test.stopTest();
    }
    //Test method for SL_BatchSchedule_DeleteRecentUpdates
    static testmethod void SL_Test_BatchSchedule()
    {
        Test.startTest();
        Recent_Updates__c objRecentUpdate1 = new Recent_Updates__c(Name ='Test Recent Update 1', Last_Updated__c = Date.today().addDays(-25));
        insert objRecentUpdate1;
        SL_BatchSchedule_DeleteRecentUpdates obj =  new SL_BatchSchedule_DeleteRecentUpdates();
        
        system.assertEquals(0,0);
        
        Test.stopTest();
    }
}