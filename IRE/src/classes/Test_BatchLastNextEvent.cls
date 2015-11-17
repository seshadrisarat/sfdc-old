@isTest(SeeAllData=true)
private class Test_BatchLastNextEvent {
    static testMethod void mytest() {
		BatchLastNextEvent myBatch = new BatchLastNextEvent();
        myBatch.query = 'select id, whoId, ActivityDate, type__c, subject from event where ActivityDate > today ORDER BY CreatedDate desc limit 200';
		database.executeBatch(myBatch);
    }
}