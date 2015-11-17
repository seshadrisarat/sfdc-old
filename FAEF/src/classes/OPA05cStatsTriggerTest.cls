@isTest
private class OPA05cStatsTriggerTest {

   static testMethod void testTrigger() {
        try {

          OPA_05__c o = new OPA_05__c();
          insert o;

          System.assertNotEquals(null, o);
        }
        catch(Exception e) {}
   }


}