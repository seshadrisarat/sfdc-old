@isTest
private class Test_BatchEventConcat {
    static testMethod void mytest() {
        BatchEventConcat myBatch = new BatchEventConcat();
        myBatch.query = 'select id, subject, Type__c, event.who.name, Combined_Name_Subject_Type__c from event where Combined_Name_Subject_Type__c = null ORDER BY CreatedDate desc limit 20';
        test.startTest();
		database.executeBatch(myBatch);
        test.stopTest();
    }
}