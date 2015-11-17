//==============================================================================
// Class Name   : Wizard_CommitmentInvestmentsControllerTest
// Author       : Nikita Jain
// Created Date : 23/11/2012
// Description  : Test Class for Wizard_CommitmentInvestmentsController
//==============================================================================

@isTest
private class Wizard_CommitmentInvestmentTest {

    public static Account vehicle;
    public static Account investor;
    public static list<Investor_Commitment_Agreement__c> commitmentList;
    public static list<Commitment_Investment__c> CIlist;      
    public static Investment_Round__c ir;
    public static Investor_Commitment_Agreement__c conInv; 
     
    static testMethod void myUnitTest() {
        createDummyData();
        PageReference pageRef = Page.Wizard_CommitmentInvestments;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('vehicleId', vehicle.Id);
        ApexPages.currentPage().getParameters().put('selectedInvestor', ir.Id);
        Wizard_CommitmentInvestmentsController investCommInvestment = new Wizard_CommitmentInvestmentsController();
        
        system.assertEquals(investCommInvestment.listCommitmentWrapper.size() , 2);
        system.assertEquals(investCommInvestment.commitmentInvestments.size() , 1);
        system.assertEquals(investCommInvestment.investorRound.name, 'test IR');
         
        system.assertEquals(investCommInvestment.commitmentInvestments.get(0).size__c, 2); 
        investCommInvestment.commitmentInvestments.get(0).size__c = 12;
        investCommInvestment.saveRecord();        
        system.assertEquals(investCommInvestment.commitmentInvestments.get(0).size__c, 12);
                                
        investCommInvestment.searchName = 'test';
        investCommInvestment.selectedInvestor = 'Investor-LP';
        investCommInvestment.populateCommitmentWrapper();
        system.assertEquals(investCommInvestment.listCommitmentWrapper.size() , 1);
        
        investCommInvestment.searchName = '';
        investCommInvestment.populateCommitmentWrapper(); 
               
        investCommInvestment.deleteCIIndex = 0;
        investCommInvestment.deleteCI();
        system.assertEquals(investCommInvestment.commitmentInvestments.size() , 0);
        
        //Size of list of Partership company account
        system.assertEquals(investCommInvestment.listPartnerShipCompany.size() , 1);
        
        investCommInvestment.listPartnerShipCompany.get(0).isSelected = true;
        investCommInvestment.listCommitmentWrapper.get(1).isSelected = true;                
        investCommInvestment.addCommitmentInvestment();
        
        //Checking if the new commitment investment has been inserted
        list<Commitment_Investment__c> listCIInserted = [Select id 
                                                         from Commitment_Investment__c
                                                         where PartnerShip_Company__c = :investCommInvestment.listPartnerShipCompany.get(0).partnershipCompany.Id];
        System.assertEquals(listCIInserted.size() , 1);                                                  
                                                                 
        
    }
    
    private static void createDummyData() {
       
        conInv = new Investor_Commitment_Agreement__c();
        commitmentList = new list<Investor_Commitment_Agreement__c>();
        CIlist = new list<Commitment_Investment__c>();
        
        //Case 48779 - LSLEVIN - 6.4.2013-START
        //vehicle = Test_Utility.createAccount('V-1',null,'Vehicle-LP');
        vehicle = Test_Utility.createAccount('V-1',null,'Vehicle');
        //Case 48779 - LSLEVIN - 6.4.2013-END
        insert vehicle;
        
        investor = Test_Utility.createAccount('V-1',null,'Investor-LP');
        investor.parentId = vehicle.Id;
        insert investor;
               
        ir = new Investment_Round__c();
        ir.name = 'test IR';
        insert ir;
                
        Account parnershipCompany = Test_Utility.createAccount('V-1',null,'GA Partnership Company');
        parnershipCompany.CompanyID__c = vehicle.Id;
        insert parnershipCompany;
                       
        conInv.name = 'test';       
        conInv.Status__c = 'Active';  
        conInv.Investor__c = investor.Id;
        commitmentList.add(conInv);      
        Investor_Commitment_Agreement__c conInv1 = new Investor_Commitment_Agreement__c();
        conInv1.name = 'test1';       
        conInv1.Status__c = 'Active';
        conInv1.Investor__c = investor.Id;    
        commitmentList.add(conInv1);        
        Investor_Commitment_Agreement__c conInv2 = new Investor_Commitment_Agreement__c();
        conInv2.name = 'abc';
        conInv2.Status__c = 'Active'; 
        conInv2.Investor__c = investor.Id;
        commitmentList.add(conInv2);            
        insert commitmentList;
        
        Commitment_Investment__c ci = new Commitment_Investment__c();
        ci.Investment_Round__c = ir.Id;
        ci.Partnership_Company__c = parnershipCompany.Id;
        ci.Investor_Commitment_Agreement__c = conInv.Id;
        ci.size__c = 2;
        CIlist.add(ci);
        insert CIlist;               
    }
}