/**
	* \arg \b ClassName      : SL_Test_Batch_CreateProceedRecords
	* \arg \b JIRATicket     : FAEF-38
	* \arg \b CreatedOn      : 12/Sep/2014
	* \arg \b ModifiedBy     : Pankaj Ganwani
	* \arg \b Description    : This class serves as test class for SL_Batch_CreateProceedRecords batch process	
*/
@isTest
private class SL_Test_Batch_CreateProceedRecords 
{
    private static List<Letter_of_Intent__c> lstLOI;
    private static List<Schedule__c> lstSchedule;
    
    //Function to prepare data
    private static void createData()
    {
    	lstLOI = new List<Letter_of_Intent__c>{
    												new Letter_of_Intent__c(Facility_Rating__c = '1'),
    												new Letter_of_Intent__c(Facility_Rating__c = '2'),
    												new Letter_of_Intent__c(Facility_Rating__c = '3')
    										  };
    	insert lstLOI;
    	
    	lstSchedule = new List<Schedule__c>{
    											new Schedule__c(Letter_of_Intent__c = lstLOI[0].Id, 
    															Base_Lease_Termination_Date__c = Date.newInstance(2014, 05, 23),
    															Notice_Days_Required__c = 10,
    															Extension_Period_Months__c = 3,
    															Monthly_Lease_Rate_Factor__c = 2.5,
                                                                Payment_Amount__c = 2500),
    											new Schedule__c(Letter_of_Intent__c = lstLOI[1].Id, 
    															Base_Lease_Termination_Date__c = Date.newInstance(2014, 05, 24),
    															Notice_Days_Required__c = 20,
    															Extension_Period_Months__c = 4,
    															Monthly_Lease_Rate_Factor__c = 2.5,
                                                                Payment_Amount__c = 2500),
    											new Schedule__c(Letter_of_Intent__c = lstLOI[2].Id, 
    															Base_Lease_Termination_Date__c = Date.newInstance(2014, 05, 25),
    															Notice_Days_Required__c = 30,
    															Monthly_Lease_Rate_Factor__c = 2.5,
                                                                Payment_Amount__c = 2500),
    											new Schedule__c(Letter_of_Intent__c = lstLOI[0].Id, 
    															Base_Lease_Termination_Date__c = Date.newInstance(2014, 05, 26),
    															Notice_Days_Required__c = 40,
    															Monthly_Lease_Rate_Factor__c = 2.5,
                                                                Payment_Amount__c = 2500)
    									   };
    	insert lstSchedule;
    }
    
    //Function to check for schedule update
    static testMethod void checkForScheduleUpdate() 
    {
        createData();
        Test.startTest();
        Database.executeBatch(new SL_Batch_CreateProceedRecords(),200);
        Test.stopTest();   
    }
    //Function to check for proceed record creation
    static testMethod void checkForProceedCreation() 
    {
        createData();
        Test.startTest();
        Database.executeBatch(new SL_Batch_CreateProceedRecords(),200);
        Test.stopTest();
   }
}