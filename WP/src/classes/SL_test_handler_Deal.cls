/**
 * This class contains unit tests for validating the behavior off trigger on Deal__c
 * author Vlad Gumenyuk 
 * date 10/16/2012
 * see https://silverline.jira.com/browse/WP-3
 * Test for Trigger on Deal__c
 */
@isTest(SeeAllData=true)
private class SL_test_handler_Deal {

   /* static testMethod void test_SL_handler_Deal () {
        
        //SL_handler_Deal.recTypeIdForPortfolioComp = null;

        RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Account' limit 1];
        
        // Create dummy account
        Account testAccount = new Account(
          Name='Test Account 001',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;
        
        Account testAccount2 = new Account(
          Name='Test Account 002',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount2;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
        Contact testContact = new Contact(
          AccountId = testAccount.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,LastName = 'Test Contact Name 2'
         ,Title = 'Principal'
         ,WP_Group__c = 'Test Group'
         ,Status__c = 'Active'
        );
        insert testContact;
        
        Test.startTest();
        
        list<Deal__c> listDeals = new list<Deal__c>();

        Deal__c testDeal = new Deal__c(
             Name = 'Test Deal 001'
           , Company__c = testAccount.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           //, Target_Sectors__c = 'Energy'
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Early - Prospect' 
           //, Expense_Code__c ='JAAUY'
        );
        insert testDeal;
        listDeals.add(testDeal);
        
        //delete testDeal;
        
////
// WP-70
/* */
       /* EMG_Paragraph__c testEMGParag = new EMG_Paragraph__c();
        testEMGParag.Deal__c = testDeal.ID;
        testEMGParag.EMG_Paragraph__c = 'test12345';
        testEMGParag.UNIQUE_KEY__c = '00011103022';
        insert testEMGParag;
        
        testEMGParag.EMG_Paragraph__c = 'test12345678';
        update testEMGParag;
        
        EMG_Comment__c testEMGParag1 = new EMG_Comment__c();
        testEMGParag1.Deal__c = testDeal.ID;
        testEMGParag1.EMG_Comment__c = 'test12346';
        testEMGParag1.UNIQUE_KEY__c = '00011103024';
        insert testEMGParag1;
        
        testEMGParag1.EMG_Comment__c = 'test12345679';
        update testEMGParag1;
        
/* */        
       /* Deal__c testDeal2 = new Deal__c(
             Name = 'Test Deal 002'
           , Company__c = testAccount2.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           //, Target_Sectors__c = 'Energy'
           , ISOPENSTAGE__c = 1
           , RecordTypeId = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Platform_Deal' AND r.SobjectType = 'Deal__c' LIMIT 1].Id
           , Stage__c = 'Deal Agreed - Deal Closed' 
           //, Expense_Code__c ='JAAUY'
        );
        insert testDeal2;
        
        //Fund_Ownership__c testOwnShip = new Fund_Ownership__c(
        //    Portfolio_Company__c = testAccount.Id,
        //    Deal__c = testDeal2.Id
        //);
        //insert testOwnShip;
        
        testDeal2.Stage__c = 'Early - Prospect';
        update testDeal2;
        
        //delete testDeal2;
        
        listDeals.add(testDeal2);

        // Not necessary part after WP-43
//      List<Deal__c> list_Deal = [Select Id, Name, Company__c, WP_Investment__c, WP_Ownership__c, Description__c, ISOPENSTAGE__c, Stage__c, Expense_Code__c,EMG_Last_Updated_Date__c,EMG_Last_Updated_By__c,EMG_Paragraph__c From Deal__c WHERE id = :testDeal.Id LIMIT 1];
//      System.assert(list_Deal.size()==1);
//      System.assert(list_Deal[0].EMG_Last_Updated_Date__c == Date.today());
//      System.assert(list_Deal[0].EMG_Last_Updated_By__c == UserInfo.getUserId());

////
        // WP-43
        List<Deal__c> list_Deal = [Select Id, Name, Company__c, WP_Investment__c, WP_Ownership__c, Description__c, ISOPENSTAGE__c, Stage__c, Expense_Code__c From Deal__c WHERE id = :testDeal.Id LIMIT 1];
        System.assert(list_Deal.size()==1);
// WP-70
/*
        List<EMG_Paragraph_History__c> list_EMG_Paragraph_History = [Select Id From EMG_Paragraph_History__c WHERE Deal__c = :list_Deal[0].Id LIMIT 1];
        //System.assert(list_EMG_Paragraph_History.size()==1);
        //System.assert(list_EMG_Paragraph_History[0].EMG_Last_Updated_Date__c == Date.today());
        //System.assert(list_EMG_Paragraph_History[0].EMG_Last_Updated_By__c == UserInfo.getUserId());
*/        
        /*// end of WP-43

        //testDeal.EMG_Paragraph__c = '11';*/
       /* update testDeal;

        list_Deal = [Select Id, Name, Company__c, WP_Investment__c, WP_Ownership__c, Description__c, ISOPENSTAGE__c, Stage__c, Expense_Code__c From Deal__c WHERE id = :testDeal.Id LIMIT 1];
        //System.assert(list_Deal[0].EMG_Paragraph__c == '11');
        //System.assert(list_Deal[0].EMG_Last_Updated_Date__c == Date.today());
        //System.assert(list_Deal[0].EMG_Last_Updated_By__c == UserInfo.getUserId());
        
        //testDeal.EMG_Paragraph__c = '22';
        //testDeal.Target_Sectors__c = null; 
        update testDeal;
        //--------------------------------------------------------
        
        
        //delete testDeal4;
        
        //list<SL_Buyside_Deals__c> BuysideDeals      = SL_Buyside_Deals__c.getall().values();
        //list<SL_Sellside_Deals__c> SellsideDeals    = SL_Sellside_Deals__c.getall().values();
        
        //List<RecordType> recType = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Portfolio_Company_wrong' AND r.SobjectType = 'Deal__c' LIMIT 1];
        
        //system.assert(recType.isEmpty());
        
        //if(!recType.isEmpty()){
        //    if(recType[0].Id != Null){
        //        Id recTypeIdForPortfolioDealWrong = recType[0].Id;
        //    }
        //}
        
        //list<RecordType> closedDealRecType = [Select Id From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Deal__c' limit 1];
        //list<RecordType> OpenedDealRecType = [Select Id From RecordType where DeveloperName = 'Portfolio_Company' and sObjectType = 'Deal__c' limit 1];
        
        //if(!closedDealRecType.isEmpty())
        //    testDeal2.Prior_Record_Type__c = closedDealRecType[0].Id;
            
        //testDeal2.Stage__c = 'Deal Agreed - Deal Closed';
        //update testDeal2;
        
        //Deal__c updatedDeal = [SELECT Id, Name, RecordTypeId FROM Deal__c WHERE Name = 'Test Deal 002'];
        
        //if(!closedDealRecType.isEmpty()){
        //    system.assert(updatedDeal.RecordTypeId == closedDealRecType[0].Id);
        //}
        
        //if(!closedDealRecType.isEmpty())
        //    testDeal2.Prior_Record_Type__c = closedDealRecType[0].Id;
        
        //SL_handler_Deal.recTypeIdForPortfolioComp = null; 
        //testDeal2.Stage__c = 'Early - Prospect';
        //update testDeal2;
        //SL_handler_Deal.recTypeIdForPortfolioComp = null;
        //delete testDeal2;
        
        //system.assert(closedDealRecType.isEmpty());
         
      Test.stopTest();
    }*/


   /* static testMethod void test_SL_handler_Deal_2 () {
       RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Account' limit 1];
      
        // Create dummy account
        Account testAccount = new Account(
          Name='Test Account 001',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;
        
        Account testAccount2 = new Account(
          Name='Test Account 002',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount2;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];

        Contact testContact = new Contact(
          AccountId = testAccount.Id
         ,LastName = 'Test Contact Name'
         ,Title = 'Managing Director'
         ,RecordTypeId = ContRecTypeId.Id
         ,WP_Group__c = 'Test Group'
         ,Status__c = 'Active'
        );
        insert testContact;

        //--------------------------------------------------------
        
        Id BuySide = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Platform_Deal' AND r.SobjectType = 'Deal__c' LIMIT 1].Id;
        Id SellSide = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Platform_Deal' AND r.SobjectType = 'Deal__c' LIMIT 1].Id;
        
        list<Deal__c> SideDeals = new list<Deal__c>();
        
        Deal__c testD1 = new Deal__c(
             Name = 'D1'
           , Company__c = testAccount.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , RecordTypeId = BuySide
           , Description__c = 'TestDescription'
           //, Target_Sectors__c = 'Energy'
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Early - Prospect'
           , Prior_Record_Type__c = BuySide
//           , Senior_Team_Member_Count__c=1  
           //, Expense_Code__c ='JAAUY'
        );
        
        Deal__c testD2 = new Deal__c(
             Name = 'D2'
           , Company__c = testAccount.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , RecordTypeId = SellSide
           , Description__c = 'TestDescription'
           //, Target_Sectors__c = 'Energy'
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Early - Prospect'
           , Prior_Record_Type__c = SellSide
//           , Senior_Team_Member_Count__c=1  
           //, Expense_Code__c ='JAAUY'
        );
        
        SideDeals.add(testD1);
        SideDeals.add(testD2);
        insert(SideDeals);
        
        Fund_Ownership__c NewFundOwnShip = new Fund_Ownership__c(Deal__c = testD1.Id, Portfolio_Company__c = testAccount.Id);
        insert(NewFundOwnShip);
        
        SideDeals.clear();
               
        Deal_Team__c deal_team1 = new Deal_Team__c(
           Deal__c = testD1.id
//          ,Status__c = 'Active'
          ,Employee__c = testContact.id
          ,Role__c = 'Senior Team Member'
        );
        insert deal_team1;

        Deal_Team__c deal_team2 = new Deal_Team__c(
           Deal__c = testD2.id
//          ,Status__c = 'Active'
          ,Employee__c = testContact.id
          ,Role__c = 'Team Member'
        );
        insert deal_team2;

       Test.startTest();

        testD1.Stage__c = 'Deal Agreed - Deal Closed';
        //testD2.Stage__c = 'Deal Agreed - Deal Closed';
        
        SideDeals.add(testD1);
        //SideDeals.add(testD2);
        update SideDeals;
        update testD2;
        
        testD1.Stage__c = 'Early - Prospect';
        //testD2.Stage__c = 'Early - Prospect';
        
        SideDeals.clear();
        
        SideDeals.add(testD1);
        //SideDeals.add(testD2);
        update SideDeals;
        update testD2;
        
        delete SideDeals;
        delete testD2;

       Test.stopTest();
    }*/

    
   /* static testMethod void test_SL_handler_Deal_Team () {
        RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Account' limit 1];

        // Create dummy account
        Account testAccount = new Account(
          Name='Test Account 003',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;

        Account testAccount2 = new Account(
          Name='Test Account 004',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount2;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];

        Contact testContact = new Contact(
          AccountId = testAccount.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,LastName = 'Test Contact Name 2'
//         ,Title = 'Test Title Contact 2'
         ,Title = 'Managing Director'
         ,WP_Group__c = 'Test Group'
         ,Status__c = 'Active'
        );
        insert testContact;

        Contact testContact2 = new Contact(
          AccountId = testAccount.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,LastName = 'Test Contact Name 3'
//         ,Title = 'Test Title Contact 3'
         ,Title = 'Managing Director'
        );
        insert testContact2;

        Deal__c testDeal = new Deal__c(
             Name = 'Test Deal 012'
           , Company__c = testAccount2.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           //, Target_Sectors__c = 'Energy'
           , RecordTypeId = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Platform_Deal' AND r.SobjectType = 'Deal__c' LIMIT 1].Id
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Early - Prospect' 
//           , Expense_Code__c ='JAAUY'
        );
        insert testDeal;
        
      Test.startTest();

       
        Deal_Team__c deal_team = new Deal_Team__c(
           Deal__c = testDeal.id
//           ,Status__c = 'Active'
          ,Employee__c = testContact.id
          ,Role__c = 'Team Member'
        );
        insert deal_team;
        
        Deal_Team__c deal_team1 = [SELECT ID,Deal__c,Employee__c,Company_Team_Member__c FROM Deal_Team__c WHERE Id = :deal_team.ID LIMIT 1];

        //System.assert(deal_team1.Company_Team_Member__c != null);
        
        //deal_team.Role__c = 'Team Member';
        //update deal_team;
        
        Deal_Team__c deal_team2 = new Deal_Team__c(
           Deal__c = testDeal.id
//           ,Status__c = 'Active'
          ,Employee__c = testContact.id
          ,Role__c = 'Team Member'
        );
        insert deal_team2;
        
        Deal_Team__c deal_team3 = [SELECT ID,Deal__c,Employee__c,Company_Team_Member__c FROM Deal_Team__c WHERE Id = :deal_team2.ID LIMIT 1];
        //System.assert(deal_team2.id != null);
        //System.assert(deal_team3.Company_Team_Member__c != null);
        //System.assert(deal_team3.Company_Team_Member__c != null && deal_team1.Company_Team_Member__c == deal_team3.Company_Team_Member__c);

        delete deal_team2;


        //deal_team2 = new Deal_Team__c(
        //   Deal__c = testDeal.id
        //  ,Employee__c = testContact.id
        //);
                
        Deal_Team__c deal_team4 = new Deal_Team__c(
           Deal__c = testDeal.id
//           ,Status__c = 'Active'
          ,Employee__c = testContact.id
          ,Role__c = 'Team Member'
        );
        list<Deal_Team__c> list_deal_team = new list<Deal_Team__c>();
//        list_deal_team.add(deal_team2); 
        list_deal_team.add(deal_team4); 
        insert list_deal_team;
        
        delete deal_team;
        undelete deal_team;
        delete deal_team;
        delete deal_team4;

      Test.stopTest();
    }*/
    
    
    /*static testMethod void test_SL_handler_DealAdvisor() {
      
//       RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Account' limit 1];
       RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Intermediary' and sObjectType = 'Account' limit 1];
      
        // Create dummy account
        Account testAccount = new Account(
          Name='Test Account 001',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;
        
        Account testAccount2 = new Account(
          Name='Test Account 002'
          ,RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount2;

        
        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
        
        Contact testContact = new Contact(
          AccountId = testAccount.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,LastName = 'Test Contact Name'
         ,Title = 'Test Title Contact'
         ,WP_Group__c = 'Test Group'
         ,Status__c = 'Active'
        );
        insert testContact;

        list<Deal__c> listDeals = new list<Deal__c>();

        Deal__c testDeal = new Deal__c(
             Name = 'Test Deal 001'
//           , Company__c = testAccount.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           //, Target_Sectors__c = 'Energy'
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Early - Prospect' 
           //, Expense_Code__c ='JAAUY'
        );
        insert testDeal;
        listDeals.add(testDeal);
        
        //delete testDeal;
        
        Deal__c testDeal2 = new Deal__c(
             Name = 'Test Deal 002'
         //  , Company__c = testAccount2.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           //, Target_Sectors__c = 'Energy'
           , ISOPENSTAGE__c = 1
           , RecordTypeId = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Platform_Deal' AND r.SobjectType = 'Deal__c' LIMIT 1].Id
           , Stage__c = 'Deal Agreed - Deal Closed' 
        );
        
        insert testDeal2;
        
      Test.startTest();
        
        Deal_Advisor__c testDealAdvisor2 = new Deal_Advisor__c (
             Deal__c = testDeal2.Id
//           , Name = 'Test Deal_Advisor 002'
           , Deal_Advisor__c = testAccount2.Id
        );
        insert testDealAdvisor2;
        
        testDealAdvisor2.Deal_Advisor__c = testAccount.Id;
        update testDealAdvisor2;
        
        delete testDealAdvisor2; 
    
      Test.stopTest();
    }*/
    
    
   /* static testMethod void test_SL_handler_DealAdvisorContact() {
      
       RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Intermediary' and sObjectType = 'Account' limit 1];
      
        // Create dummy account
        Account testAccount = new Account(
          Name='Test Account 001',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;
        
        Account testAccount2 = new Account(
          Name='Test Account 002'
          ,RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount2;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Contact' and sObjectType = 'Contact' limit 1];
        Contact testContact = new Contact(
          AccountId = testAccount2.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,LastName = 'Test Contact Name'
         ,Title = 'Test Title Contact'
         ,WP_Group__c = 'Test Group'
         ,Status__c = 'Active'
        );
        insert testContact;


        list<Deal__c> listDeals = new list<Deal__c>();

        Deal__c testDeal = new Deal__c(
             Name = 'Test Deal 001'
//           , Company__c = testAccount.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           //, Target_Sectors__c = 'Energy'
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Early - Prospect' 
           //, Expense_Code__c ='JAAUY'
        );
        insert testDeal;
        listDeals.add(testDeal);
        
        //delete testDeal;
        
        Deal__c testDeal2 = new Deal__c(
             Name = 'Test Deal 002'
         //  , Company__c = testAccount2.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           //, Target_Sectors__c = 'Energy'
           , ISOPENSTAGE__c = 1
           , RecordTypeId = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Platform_Deal' AND r.SobjectType = 'Deal__c' LIMIT 1].Id
           , Stage__c = 'Deal Agreed - Deal Closed' 
        );
        
        insert testDeal2;

      Test.startTest();
        
        Deal_Advisor_Contact__c testDealAdvisorContact = new Deal_Advisor_Contact__c (
             Deal__c = testDeal2.Id
//           , Name = 'Test Deal_Advisor_Contact 001'
           , Contact__c = testContact.Id
        );
        insert testDealAdvisorContact;
        
        delete testDealAdvisorContact; 
    
      Test.stopTest();
    }    */
    
    
   /* static testMethod void test_SL_handler_Bid() {
      
       RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Intermediary' and sObjectType = 'Account' limit 1];
      
        // Create dummy account
        Account testAccount = new Account(
          Name='Test Account 001',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;
        
        Account testAccount2 = new Account(
          Name='Test Account 002'
          ,RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount2;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
        Contact testContact = new Contact(
          AccountId = testAccount.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,LastName = 'Test Contact Name'
         ,Title = 'Test Title Contact'
         ,WP_Group__c = 'Test Group'
         ,Status__c = 'Active'
        );
        insert testContact;

        list<Deal__c> listDeals = new list<Deal__c>();

        Deal__c testDeal = new Deal__c(
             Name = 'Test Deal 001'
//           , Company__c = testAccount.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           //, Target_Sectors__c = 'Energy'
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Early - Prospect' 
           //, Expense_Code__c ='JAAUY'
        );
        insert testDeal;
        listDeals.add(testDeal);
        
        //delete testDeal;
        
        Deal__c testDeal2 = new Deal__c(
             Name = 'Test Deal 002'
         //  , Company__c = testAccount2.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           //, Target_Sectors__c = 'Energy'
           , ISOPENSTAGE__c = 1
           , RecordTypeId = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Platform_Deal' AND r.SobjectType = 'Deal__c' LIMIT 1].Id
           , Stage__c = 'Deal Agreed - Deal Closed' 
        );
        
        insert testDeal2;

      Test.startTest();
        
        //Select b.WP_Equity_Low__c, b.WP_Equity_Low_MM__c, b.WP_Equity_High__c, b.WP_Equity_High_MM__c, b.SystemModstamp, b.Name, b.LastModifiedDate, b.LastModifiedById, b.IsDeleted, b.Implied_Ent_Value_Low__c, b.Implied_Ent_Value_Low_MM__c, b.Implied_Ent_Value_High__c, b.Implied_Ent_Value_High_MM__c, b.Implied_Ent_Value_Avg__c, b.Implied_Ent_Value_Avg_MM__c, b.Id, b.Deal__c, b.CurrencyIsoCode, b.CreatedDate, b.CreatedById, b.Bid_Stage__c, b.Bid_Date__c, b.Bid_Comments__c From Bid__c b
        Bid__c testBid = new Bid__c (
             Deal__c = testDeal2.Id
           , Bid_Date__c = Date.today()
           , Bid_Stage__c = 'Round 1'  
//           , Name = 'Test Deal_Advisor_Contact 001'
        );
        insert testBid;
        
        testBid.Bid_Stage__c = 'Final';
        update testBid;
        
        delete testBid; 
    
      Test.stopTest();
    }*/
    
    
   /* static testMethod void test_SL_handler_FundOwnership() {
      
       RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Intermediary' and sObjectType = 'Account' limit 1];
      
        // Create dummy account
        Account testAccount = new Account(
          Name='Test Account 001',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;
        
        Account testAccount2 = new Account(
          Name='Test Account 002'
          ,RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount2;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
        Contact testContact = new Contact(
          AccountId = testAccount.Id
         ,RecordTypeId = ContRecTypeId.Id 
         ,LastName = 'Test Contact Name'
         ,Title = 'Test Title Contact'
         ,WP_Group__c = 'Test Group'
         ,Status__c = 'Active'
        );
        insert testContact;

        list<Deal__c> listDeals = new list<Deal__c>();

        Deal__c testDeal = new Deal__c(
             Name = 'Test Deal 001'
//           , Company__c = testAccount.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           //, Target_Sectors__c = 'Energy'
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Early - Prospect' 
           //, Expense_Code__c ='JAAUY'
        );
        insert testDeal;
        listDeals.add(testDeal);
        
        //delete testDeal;
        
        Deal__c testDeal2 = new Deal__c(
             Name = 'Test Deal 002'
         //  , Company__c = testAccount2.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           //, Target_Sectors__c = 'Energy'
           , ISOPENSTAGE__c = 1
           , RecordTypeId = [Select r.Id From RecordType r WHERE r.DeveloperName = 'Platform_Deal' AND r.SobjectType = 'Deal__c' LIMIT 1].Id
           , Stage__c = 'Deal Agreed - Deal Closed' 
        );
        
        insert testDeal2;

      Test.startTest();
        
        Fund__c testFund = new Fund__c(
             Name = 'Test Fund 001'
           , Acronym__c = 'test acro'
           , Description__c = 'test desc'
        );
        insert testFund;
        
        Fund_Ownership__c testFundOwnership = new Fund_Ownership__c (
             Deal__c = testDeal2.Id
           , Fund__c = testFund.Id
        );
        insert testFundOwnership;

        Fund_Ownership__c testFundOwnership2 = new Fund_Ownership__c (
             Deal__c = testDeal2.Id
           , Fund__c = testFund.Id
        );
        try {
          insert testFundOwnership2;
        } catch(Exception e) { }
        
        delete testFundOwnership; 
    
      Test.stopTest();
    }*/

    /*
    static testMethod void test_SL_handler_User() {
      
        Profile Prof1 = [Select id,name FROM Profile WHERE name = 'Standard User']; 

        User user_run1 = new User(
          Username='test211@testuser1.com',
          Alias='Test211',
          Email='test211@testuser1.com',
          LastName='Test LastV 211', 
          TimeZoneSidKey='Europe/Prague', 
          LocaleSidKey='uk', 
          EmailEncodingKey='ISO-8859-1', 
          ProfileId=Prof1.Id, 
          IsActive=true
          ,LanguageLocaleKey='sv'
          ,Initials__c = 'TUZ'
        );
     	Test.startTest();
        
        insert user_run1;
        System.debug('==========user_run1==================='+user_run1);
        List<Company_List__c> lstCL = [SELECT Id FROM Company_List__c where OwnerId =: user_run1.Id];
        System.assertEquals(lstCL.size(),1);

        user_run1.Initials__c = 'TUK';
        update user_run1;
    	System.debug('==========user_run1==================='+user_run1);
      Test.stopTest();
    }
    */

    static testMethod void SL_test_handler_ProcessQueue() {
      Test.startTest();
       String objectId = '123456789101123';
       String domainName ='Test Domain Name';
       String action = 'Test Action Name';
       String parameters ='ananta.risal@gmail.com';
      
      Process_Queue__c testQueue = new Process_Queue__c(
          Object_Id__c = objectId, 
          Domain__c = domainName, 
          Action__c = action, 
          Parameters__c = parameters
        );
        insert testQueue;
        
        List<Process_Queue__c> process_queue_list = [SELECT id, Object_Id__c, Domain__c, Action__c, Parameters__c
        				FROM Process_Queue__c
        				WHERE Object_Id__c =:objectId AND Domain__c =:domainName AND Action__c =:action AND Parameters__c =:parameters limit 1];
        if (process_queue_list.size()==1){
        	process_queue_list[0].Action__c = 'Test2 Action Name';
        	//Now update the record
        	update process_queue_list[0];
        	//Now delete the record
        	delete process_queue_list[0];
        }        
      Test.stopTest();
    }
          
}