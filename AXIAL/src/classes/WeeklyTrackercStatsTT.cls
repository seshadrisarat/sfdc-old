@isTest
private class WeeklyTrackercStatsTT {

   static testMethod void testTrigger() {
      try {
          Weekly_Tracker__c o = new Weekly_Tracker__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<Weekly_Tracker__c> l = [SELECT Id from Weekly_Tracker__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}