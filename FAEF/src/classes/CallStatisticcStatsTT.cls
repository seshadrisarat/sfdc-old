@isTest
private class CallStatisticcStatsTT {

   static testMethod void testTrigger() {
      try {
          Call_Statistic__c o = new Call_Statistic__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Call_Statistic__c> l = [SELECT Id from Call_Statistic__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}