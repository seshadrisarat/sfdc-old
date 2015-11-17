/*******************************************************************
* Author        :  Harshit Jain (Appirio Offshore)
* Name          :  Wizard_InvestorTest
* Date          :  Oct 29,2012
* Description   :  Verify functionality of Wizard_Investor class.                 
*******************************************************************/
@isTest
private class Wizard_InvestorControllerTest {
    
    public static Account vehicle;
    public static List<Account> investorList;       
    static testMethod void testInvestorController() {
        createDummyData();
        PageReference pageRef = Page.Wizard_Investor;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('Id', vehicle.Id);
        //ApexPages.StandardController stdController = new ApexPages.StandardController(vehicle);
        Wizard_InvestorController wizard_Investor = new Wizard_InvestorController();
         
        //Create new contact
        wizard_Investor.companyInvestor.Name = 'Inv-16';
        wizard_Investor.notifyAccountingInvestor = true;
        wizard_Investor.saveAddInvestor();
        system.assertEquals(getInvestors(vehicle.Id).size(), 6);
           
        //delete Investor
        wizard_Investor.deleteInvestorIndex = 0;
        wizard_Investor.deleteInvestor();
        system.assertEquals(getInvestors(vehicle.Id).size(), 5);
       
        //edit Investor
        wizard_Investor.editInvestorIndex = 0;
        wizard_Investor.editInvestor();
        system.assertNotEquals(wizard_Investor.companyInvestor.Name , null);
        wizard_Investor.clearInvestorFields();
                
        //Create one more Investor
        wizard_Investor.companyInvestor.Name = 'Inv-17';
        system.assertEquals(wizard_Investor.saveInvestor().getUrl(),new pageReference('/apex/Wizard_Commitment?Id='+wizard_Investor.companyInvestor.Id+'&vehicleId='+vehicle.Id).getURL());
        system.assertEquals(getInvestors(vehicle.Id).size(), 6);
        wizard_Investor.clearInvestorFields();
        system.assertEquals(wizard_Investor.redirectToCommitmentPage().getUrl() , new pageReference('/apex/Wizard_Commitment?Id='+wizard_Investor.companyInvestorList.get(0).Id+'&vehicleId='+vehicle.Id).getUrl());
        wizard_Investor.investorIndex = 1;
        system.assertEquals(wizard_Investor.pickInvestorIndex().getUrl(), new PageReference('/apex/Wizard_Commitment?id='+wizard_Investor.companyInvestorList.get(wizard_Investor.investorIndex).Id+'&vehicleId='+vehicle.Id).getUrl());
    }
    
    private static void createDummyData() {
      //Case 48779 - LSLEVIN - 6.4.2013-START
      //vehicle = Test_Utility.createAccount('V-1',null,'Vehicle-LP');
      vehicle = Test_Utility.createAccount('V-1',null,'Vehicle');
      //Case 48779 - LSLEVIN - 6.4.2013-END
      insert vehicle;
      investorList = new List<Account>();
      for(Integer index =1; index<=5; index++) {
          investorList.add(Test_Utility.createAccount('Inv-1', vehicle.Id, 'Investor-LP'));
      }
      insert investorList;
    }
    
    private static list<Account> getInvestors(Id vehicleId) {
        return [select Id,Name from Account where parentId =: vehicleId];
    }
}