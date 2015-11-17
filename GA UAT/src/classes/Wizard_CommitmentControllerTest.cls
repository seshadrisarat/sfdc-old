/*******************************************************************
* Author        :  Harshit Jain (Appirio Offshore)
* Name          :  Wizard_CommitmentTest
* Date          :  Oct 29,2012
* Description   :  Verify functionality of Wizard_Commitment class.                 
*******************************************************************/
@isTest
private class Wizard_CommitmentControllerTest {
        public static Account vehicle;
        public static List<Account> investorList;
        public static List<Investor_Commitment_Agreement__c> commitmentList;
        
    static testMethod void testCommitmentController() {
        createDummyData();
      PageReference pageRef = Page.Wizard_Commitment;
      Test.setCurrentPageReference(pageRef);
      ApexPages.currentPage().getParameters().put('Id', investorList.get(0).Id);
      ApexPages.currentPage().getParameters().put('vehicleId', vehicle.Id);
     Wizard_CommitmentController commitmentCon = new Wizard_CommitmentController();        
      
      //Create new commitment
      commitmentCon.commitment.Name = 'comm-Inv-16';
      commitmentCon.commitment.Investor__c = investorList.get(0).Id;
      commitmentCon.notifyAccountingCommitment = true;
      commitmentCon.saveAddCommitment();
      commitmentCon.selectedCommitment = 'All';
      commitmentCon.populateCommitmentList();
      system.assertEquals(commitmentCon.commitmentList.size(), 2);
      
      //delete contact
      commitmentCon.deleteCommitmentIndex = 0;
      commitmentCon.deleteCommitment();
      system.assertEquals(commitmentCon.commitmentList.size(), 1); 
      
      //edit contact
      commitmentCon.editCommitmentIndex = 0;
      commitmentCon.editCommitment();
      system.assertNotEquals(commitmentCon.commitment.Name , null);
        commitmentCon.clearCommitmentFields();  
        
         //Create one more Commitment
       commitmentCon.commitment.Name = 'comm-Inv-16';
       commitmentCon.commitment.Investor__c = investorList.get(0).Id;
       system.assertEquals(commitmentCon.saveCommitment().getUrl(),new pageReference('/apex/Wizard_Contact?id='+vehicle.Id).getURL());
       //Story # S-105960 Start
       //system.assertEquals(commitmentCon.redirectToContactPage().getUrl() , new pageReference('/apex/Wizard_Contact?id='+vehicle.Id).getUrl());
       system.assertEquals(commitmentCon.redirectToContactPage().getUrl() , new pageReference('/apex/Wizard_Contact?commitmentId='+commitmentCon.commitment.Id+'&Id='+vehicle.Id).getUrl());
       //Story # S-105960 End
    }
    
     private static void createDummyData() {
     //Case 48779 - LSLEVIN - 6.4.2013-START
        // vehicle = Test_Utility.createAccount('V-1',null,'Vehicle-LP');
        vehicle = Test_Utility.createAccount('V-1',null,'Vehicle');
     //Case 48779 - LSLEVIN - 6.4.2013-END   
      insert vehicle;
      investorList = new List<Account>();
        for(Integer index =1; index<=5; index++) {
            investorList.add(Test_Utility.createAccount('Inv-1'+index, vehicle.Id, 'Investor-LP')); 
        }
        insert investorList;
        commitmentList = new List<Investor_Commitment_Agreement__c>();
        for(Integer index =0; index<=4; index++) {
            commitmentList.add(Test_Utility.createCommitment('comm-Inv-1'+index, investorList.get(index).Id));  
        }
        insert commitmentList;
    }
}