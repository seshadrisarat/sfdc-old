/**  
* \arg ClassName      : SL_Test_InstallationAdjustmentHandler
* \arg JIRATicket     : STARGAS-45
* \arg CreatedOn      : 27/JULY/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as test class for SL_InstallationAdjustment trigger and is used to check its functionality.
*/
@isTest
private class SL_Test_InstallationAdjustmentHandler 
{
    static Opportunity objOpportunity;
    static List<Installation_Job__c> lstInstallationJob;
    static List<Installation_Adjustments__c> lstInstallationAdjustements;
    
    @testSetup
    static void setup()
    {
    	objOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Open', HHAU__c = 'Email', CloseDate=Date.today());
    	insert objOpportunity;
    	
    	lstInstallationJob = new List<Installation_Job__c>{
    														  new Installation_Job__c(Name = 'Test Job 01', Opportunity__c = objOpportunity.Id),
    														  new Installation_Job__c(Name = 'Test Job 02', Opportunity__c = objOpportunity.Id)
    													  };
    	insert lstInstallationJob;
    	
    	lstInstallationAdjustements = new List<Installation_Adjustments__c>{
    																			new Installation_Adjustments__c(Installation_Job__c = lstInstallationJob[0].Id, Major_Materials__c = 190, Manf_Rebate_Allowance__c = 1000, Apply__c = true),
    																			new Installation_Adjustments__c(Installation_Job__c = lstInstallationJob[0].Id, Major_Materials__c = 100, Manf_Rebate_Allowance__c = 1100, Apply__c = true),
    																			new Installation_Adjustments__c(Installation_Job__c = lstInstallationJob[1].Id, Major_Materials__c = 90, Manf_Rebate_Allowance__c = 1200, Apply__c = true),
    																			new Installation_Adjustments__c(Installation_Job__c = lstInstallationJob[1].Id, Major_Materials__c = 1100, Manf_Rebate_Allowance__c = 1300, Apply__c = true)    																	  
    																	   };
    	insert lstInstallationAdjustements;    	
    }
    
    static testMethod void checkForInsert() 
    {
        System.assertEquals([SELECT Adj_Major_Materials__c FROM Installation_Job__c WHERE Name=:'Test Job 01' LIMIT 1].Adj_Major_Materials__c,100);
    }
    
    static testMethod void checkForUpdate() 
    {
        Test.startTest();
        Installation_Adjustments__c objIA = [SELECT Apply__c FROM Installation_Adjustments__c LIMIT 1];
        objIA.Apply__c = false;
        update objIA;
        Test.stopTest();
        
        System.assertEquals([SELECT Adj_Major_Materials__c FROM Installation_Job__c WHERE Name=:'Test Job 01' LIMIT 1].Adj_Major_Materials__c,100);
    }
    
    static testMethod void checkForDelete()
    {
    	Test.startTest();
    	Installation_Adjustments__c objIA = [SELECT Apply__c FROM Installation_Adjustments__c LIMIT 1];
        delete objIA;
        Test.stopTest();
        
        System.assertEquals([SELECT Adj_Major_Materials__c FROM Installation_Job__c WHERE Name=:'Test Job 01' LIMIT 1].Adj_Major_Materials__c,100);
    }
    
     static testMethod void checkForNull()
     {
    	Test.startTest();
    	delete [SELECT Apply__c FROM Installation_Adjustments__c LIMIT 2];
        Test.stopTest();
        
        System.assertEquals([SELECT Adj_Major_Materials__c FROM Installation_Job__c WHERE Name=:'Test Job 01' LIMIT 1].Adj_Major_Materials__c,NULL);
     }
}