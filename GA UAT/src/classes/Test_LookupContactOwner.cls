@isTest
private class Test_LookupContactOwner {
    @isTest
    static void Test_LookupContact(){
        Outlook_Contact__c  cont = new Outlook_Contact__c (Contact_Owner_Email__c = userinfo.getUserName(),GUID__c = 'test');
        insert cont;
        system.assertNotEquals(cont.id , null);
    }
}