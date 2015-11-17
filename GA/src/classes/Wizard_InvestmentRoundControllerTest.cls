//==============================================================================
// Class Name   : Wizard_InvestmentRoundControllerTest
// Author       : Nikita Jain
// Created Date : 23/11/2012
// Description  : Test Class for Wizard_InvestmentRound
//==============================================================================
@isTest
private class Wizard_InvestmentRoundControllerTest {

    public static Account vehicle;
    public static Account investor;
    public static list<Investment_Round__c> IRlist;
    public static Investment_Round__c ir;
     
    static testMethod void testInvestmentRound() {
        createDummyData();
        
        PageReference pageRef = Page.Wizard_InvestmentRound;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('vehicleId', vehicle.Id);
        Wizard_InvestmentRound investRound = new Wizard_InvestmentRound();
        
        integer totalPage = investRound.totalPage; 
        boolean isMorePrevious = investRound.isMorePrevious;
        boolean inMoreNext = investRound.isMoreNext;
        String recordNumbering = investRound.recordNumbering ;
        String pageNumbering = investRound.pageNumbering;
        List<Integer> testList = investRound.listOfLinks;
        
        system.assertEquals(investRound.investmentRoundlist.size() , 2);
        //Testing edit method 
        system.assertEquals(ir.name, 'test');
        ir.name = 'test Edit';
        investRound.editId = ir.Id;
        investRound.SaveIR();
        system.assertEquals(ir.name, 'test Edit');
         
        //Testing search method  
        investRound.searchByName = 'test';
        investRound.getVehicleInvestmentRound();
        system.assertEquals(investRound.investmentRoundlist.size() , 1);
        
        investRound.searchByName = '';
        investRound.getVehicleInvestmentRound();
        
        //Testing delete method 
        investRound.deleteInvestentRoundIndex = 0;       
        investRound.deleteIR();   
        system.assertEquals(1, investRound.investmentRoundlist.size());   
        
        investRound.CIIndex = 0;
        investRound.redirectToCI();                    
    }
    
    private static void createDummyData() {
        //Case 48779 - LSLEVIN - 6.4.2013-START
        //vehicle = Test_Utility.createAccount('V-1',null,'Vehicle-LP');
        vehicle = Test_Utility.createAccount('V-1',null,'Vehicle');
        //Case 48779 - LSLEVIN - 6.4.2013-END
        insert vehicle;
        
        investor = Test_Utility.createAccount('V-1',null,'Investor-LP');
        investor.parentId = vehicle.Id;
        insert investor;
              
        IRlist = new list<Investment_Round__c>();
        ir = new Investment_Round__c();  
        ir.name = 'test';  
        IRlist.add(ir);
        
        Investment_Round__c ir1 = new Investment_Round__c();
        ir1.name = 'test1';  
        IRlist.add(ir1);
               
        insert IRlist;                                      
    }
}