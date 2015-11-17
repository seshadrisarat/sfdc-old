@isTest(SeeAllData=true)
private class Test_BatchLastNextTask {
    static testMethod void mytest() {
		BatchLastNextTask myBatch = new BatchLastNextTask();
        myBatch.query = 'select id, whoId, ActivityDate, type__c, status, subject from task where ActivityDate > today ORDER BY CreatedDate desc limit 200';
		database.executeBatch(myBatch);
    }
}