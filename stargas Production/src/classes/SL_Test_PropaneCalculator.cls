/**
*  ClassName      : SL_Test_PropaneCalculator
*  JIRATicket     : STARGAS-15
*  CreatedOn      : 14/AUG/2014
*  CreatedBy      : Pankaj Ganwani
*  Description    : Test class for SL_PropaneCalculator
*/
@isTest
private class SL_Test_PropaneCalculator 
{
    static Opportunity objOpportunity;
    static Apexpages.Standardcontroller objStandardController;
    static List<Propane_Route_Table__c> lstPropaneRouteTable;
    static List<Propane_Gallonage_Table__c> lstPropaneGallongeTable;
    static List<Propane_Calculator_Table__c> lstPropaneCalculator;
    //Function for creating data
    private static void prepareData()
    {
    	objOpportunity = new Opportunity(Name = 'Test Opportunity', Barbeque_Grill__c = true, Cooking_Range__c = true, CloseDate = Date.today(), StageName = 'Open', HHAU__c = 'AE njheatingoil.org');
    	insert objOpportunity; 
    	
    	lstPropaneRouteTable = new List<Propane_Route_Table__c>{
    																new Propane_Route_Table__c(Deliveries_Per_Year__c = 1, Description__c = 'April once a year', Route_Number__c = '170'),
    																new Propane_Route_Table__c(Deliveries_Per_Year__c = 4, Description__c = 'Four deliveries a year', Route_Number__c = '4'),
    																new Propane_Route_Table__c(Deliveries_Per_Year__c = 3, Description__c = 'Three deliveries a year', Route_Number__c = '3')
    															};
    	insert lstPropaneRouteTable;
    	
    	lstPropaneGallongeTable = new List<Propane_Gallonage_Table__c>{
    																		new Propane_Gallonage_Table__c(Gallonage_Breakdown_Type__c = 'Non-Employee', Gallonage_Breakdown__c = 0, BPC_Sublevel__c = '1'),
    																		new Propane_Gallonage_Table__c(Gallonage_Breakdown_Type__c = 'Non-Employee', Gallonage_Breakdown__c = 101, BPC_Sublevel__c = '3')
    																  };
    	insert lstPropaneGallongeTable;
    	
    	lstPropaneCalculator = new List<Propane_Calculator_Table__c>{
    																	new Propane_Calculator_Table__c(Type__c = 'Barbeque Grill',Estimated_Annual_Usage_Gal__c = 250, HWH__c = 'Yes', Normal_Tank_Size_Gal__c = 100, KFA__c = 12),
    																	new Propane_Calculator_Table__c(Type__c = 'Cooking Range',Estimated_Annual_Usage_Gal__c = 50, HWH__c = 'Yes', Normal_Tank_Size_Gal__c = 50, KFA__c = 3)
    																};
    	
		insert lstPropaneCalculator;
    	objStandardController = new Apexpages.Standardcontroller(objOpportunity);
    }
    //Function for testing functionality
    static testMethod void test_propaneCalculation() 
    {
       prepareData();
       SL_PropaneCalculatorController objPropaneCalculator = new SL_PropaneCalculatorController(objStandardController);
       
       Test.startTest();
       objPropaneCalculator.calculatePropane(); 
       Test.stopTest();
       
       System.assertEquals([SELECT Usage__c FROM Opportunity WHERE Id =: objOpportunity.Id].Usage__c, 300);
    }
}