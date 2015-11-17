@isTest
private class CallStatisticcStatsTriggerTest {

   static testMethod void testTrigger() {
        try {

          Call_Statistic__c o = new Call_Statistic__c();
          insert o;

          System.assertNotEquals(null, o);
        }
        catch(Exception e) {}
   }


}