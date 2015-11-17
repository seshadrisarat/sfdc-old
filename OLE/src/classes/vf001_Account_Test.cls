@isTest 
private class vf001_Account_Test {
    static testMethod void testInsertUpdate() {
        Account ac1=new Account(Name='Test Admin Account Half-Yearly', recordtypeid=F8_ScheduleImplementation.Account_RecordTypeId_AdminAcct, Payment_Frequency__c='Half-Yearly',MM_COCD__c='000001');
        insert ac1;
        ac1.Name='Name updated';
        update ac1;
    }
}