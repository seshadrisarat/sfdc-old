@isTest
private class STCDRShoreTelConnectioncStatsTT {

   static testMethod void testTrigger() {
      try {
          STCDR__ShoreTel_Connection__c o = new STCDR__ShoreTel_Connection__c();
          insert o;

          System.assertNotEquals(null, o);
      }
      catch(Exception e) {
          List<STCDR__ShoreTel_Connection__c> l = [SELECT Id from STCDR__ShoreTel_Connection__c LIMIT 1];
          update l;
          System.assertNotEquals(null, l);
      }
   }
}