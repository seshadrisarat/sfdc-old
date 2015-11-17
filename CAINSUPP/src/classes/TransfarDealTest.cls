@isTest
Public Class TransfarDealTest {
     public static TestMethod void TestTransferDeal(){
         List<Banker_Allocation__c> lstNewBankerAllocation = new List<Banker_Allocation__c>();   
         date mydate = date.parse('12/27/2009');
         
         Deal__c objDeal = new Deal__c();
         objDeal.Name='testDeal 188';
         objDeal.Client_Name__c='001d000001bhvU5';
         objDeal.Deal_Code__c='1148';
         objDeal.Status__c='Closed';
         objDeal.Product_Service_Type__c='Restructuring';
         objDeal.Actual_Closing_Date__c = mydate;
         Insert objDeal;
         
         Opportunity objOpp = new Opportunity();
         objOpp.Name='tesOpp 188';
         objOpp.StageName='Open';
         objOpp.Estimated_Fee_Budget__c=5;
         objOpp.AccountID='001d000001bhvU5';
         objOpp.Projected_Closing_Date__c = mydate;
         objOpp.CloseDate = mydate;
         Insert objOpp;
         
         Banker_Allocation__c objBanker = new Banker_Allocation__c();
         objBanker.Deal_Name__r = objDeal ;
         objBanker.Opportunity__r =  objOpp;
         objBanker.Percentage_bank_alloc__c = 25;
         Insert objBanker;
         
         Banker_Allocation__c objBanker1 = new Banker_Allocation__c();
         objBanker1.Deal_Name__c = objDeal.ID ;
         objBanker1.Opportunity__c =  objOpp.ID;
         objBanker1.Percentage_bank_alloc__c = 25;
         Insert objBanker1;
         
         ApexPages.StandardController sc = new ApexPages.standardController(objDeal);
         TransfarDeal objTransfarDeal = new TransfarDeal(sc);
         ApexPages.CurrentPage().getparameters().put('newid',objDeal.ID);
         ApexPages.CurrentPage().getparameters().put('oid',objOpp.id);
         objTransfarDeal.SaveCloneDeal();
         lstNewBankerAllocation = [select ID from Banker_Allocation__c where Deal_Name__c =: objDeal.ID AND Opportunity__c =: objOpp.ID ];
         System.debug('lstNewBankerAllocation.size()'+lstNewBankerAllocation.size());
         System.assertEquals(2,lstNewBankerAllocation.size());          
         
         
     }
}