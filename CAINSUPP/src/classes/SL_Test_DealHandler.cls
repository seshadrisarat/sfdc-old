/**
* \arg ClassName      : SL_Test_DealHandler
* \arg JIRATicket     : CAINSUPPORT
* \arg CreatedOn      : 10/12/2013
* \arg CreatededBy    : Praful
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class works as testClass for SL_DealHandler.
*/
@isTest
public class SL_Test_DealHandler{

    @testSetup 
    public static void createTestData(){
        Account objAccount = new Account(Name = 'Cain Brothers', Sector__c = 'Pharmacy');
        insert objAccount;
        
        Opportunity objOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Open', 
                                                     AccountId = objAccount.Id, CloseDate = Date.today());
        insert objOpportunity;
        
        Opportunity objOpportunity1 = new Opportunity(Name = 'Test Opportunity SL', StageName = 'Open', 
                                                     AccountId = objAccount.Id, CloseDate = Date.today());
        insert objOpportunity1;
        
        
        Contact objContact = new Contact(FirstName = 'Court',LastName = 'Houseworth', AccountId = objAccount.Id, Status__c='Active');
        insert objContact;
        
        Cain_Opportunity_Team__c objCOT = new Cain_Opportunity_Team__c(Opportunity__c = objOpportunity.Id, Role__c = 'Other', 
                                                                       Team_Member__c = objContact.Id); 
        insert objCOT;
        
        Cain_Opportunity_Team__c objCOT1 = new Cain_Opportunity_Team__c(Opportunity__c = objOpportunity.Id, Role__c = 'Other', 
                                                                       Team_Member__c = objContact.Id); 
        insert objCOT1;
        
        Cain_Opportunity_Team__c objCOT2 = new Cain_Opportunity_Team__c(Opportunity__c = objOpportunity.Id, Role__c = 'Other', 
                                                                       Team_Member__c = objContact.Id); 
        insert objCOT2;
        
        
        Cain_Opportunity_Team__c objCOT3 = new Cain_Opportunity_Team__c(Opportunity__c = objOpportunity1.Id, Role__c = 'Other', 
                                                                       Team_Member__c = objContact.Id); 
        insert objCOT3;
        
        Cain_Opportunity_Team__c objCOT4 = new Cain_Opportunity_Team__c(Opportunity__c = objOpportunity1.Id, Role__c = 'Other', 
                                                                       Team_Member__c = objContact.Id); 
        insert objCOT4;
        
        Cain_Opportunity_Team__c objCOT5 = new Cain_Opportunity_Team__c(Opportunity__c = objOpportunity1.Id, Role__c = 'Other', 
                                                                       Team_Member__c = objContact.Id); 
        insert objCOT5;
         
        Deal__c objDeal1 = new Deal__c(Name = 'Test Deal1', Client_Name__c = objAccount.Id, Deal_Code__c = '20', 
                                      Status__c = 'In Progress', Product_Service_Type__c = 'Restructring', 
                                      Opportunity__c = objOpportunity1.Id);
        insert objDeal1;
        
        Deal__c objDeal2 = new Deal__c(Name = 'Test Deal2', Client_Name__c = objAccount.Id, Deal_Code__c = '21', 
                                      Status__c = 'In Progress', Product_Service_Type__c = 'Restructring', 
                                      Opportunity__c = objOpportunity1.Id);
        insert objDeal2;
        
        List<Potential_Buyer_Seller__c> lstPBS = new List<Potential_Buyer_Seller__c>{
                                                                                        new Potential_Buyer_Seller__c(Opportunity__c = objOpportunity.Id),
                                                                                        new Potential_Buyer_Seller__c(Opportunity__c = objOpportunity1.Id,Deal__c = objDeal1.Id),
                                                                                        new Potential_Buyer_Seller__c(Opportunity__c = objOpportunity1.Id,Deal__c = objDeal2.Id),
                                                                                        new Potential_Buyer_Seller__c(Deal__c = objDeal1.Id)
                                                                                    };
        insert lstPBS;
        
        Deal__c objDeal = new Deal__c(Name = 'Test Deal SL', Client_Name__c = objAccount.Id, Deal_Code__c = '23', 
                                      Status__c = 'In Progress', Product_Service_Type__c = 'Restructring', 
                                      Opportunity__c = objOpportunity.Id);
        insert objDeal;
    }

    @isTest
    static void test_DealHandler(){
    	Test.StartTest();
    	Deal__c testDeal = [select id from Deal__c where name = 'Test Deal SL'];
        Opportunity testOpp = [select id from Opportunity where name = 'Test Opportunity SL'];

        System.assertEquals([SELECT Id FROM Cain_Deal_Team__c WHERE Deal__c =: testDeal.Id].size(), 3);  
         
        Deal__c objDealToUpdate = new Deal__c(Id = testDeal.Id, Opportunity__c = testOpp.Id);
        update objDealToUpdate;
        
        System.assertEquals([SELECT Id FROM Cain_Deal_Team__c WHERE Deal__c =: testDeal.Id].size(), 3);   
        delete testDeal;
        
        Test.StopTest();
    }
}