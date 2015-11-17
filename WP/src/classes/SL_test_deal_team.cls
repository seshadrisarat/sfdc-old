@isTest(SeeAllData=true)
private class SL_test_deal_team {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        SL_handler_Deal_Team x = new SL_handler_Deal_Team(false,1);
      
      Deal_Team__c fo = new Deal_Team__c();
     Contact emp = [Select Id from Contact where lastname = 'Chiu' limit 1];
      Deal__c dlX = [Select Id From Deal__c limit 1];
      //insert dlX;
      //Fund__c fX = [Select Id From Fund__c limit 1];
      fo.Employee__c=emp.Id;
      fo.Deal__c = dlX.Id;
      //fo.Fund__c = fX.Id;
      //fo.Fund__c
      insert fo;
    }
    
    
}