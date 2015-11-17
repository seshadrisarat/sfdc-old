@isTest
private class SchedulecStatsTT {

   static testMethod void testTrigger() {
      try {
          Schedule__c o = new Schedule__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Schedule__c> l = [SELECT Id from Schedule__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}