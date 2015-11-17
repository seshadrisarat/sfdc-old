@isTest
private class Test_BatchFillerDelete {
    static testMethod void mytest() {
		BatchFillerDelete myBatch = new BatchFillerDelete();
        myBatch.query = 'select id from Event limit 10';
		database.executeBatch(myBatch);
        
        BatchTaskDelete myBatch2 = new BatchTaskDelete();
        myBatch2.query = 'select id from task limit 10';
		database.executeBatch(myBatch2);
        
        BatchLitRequestsDelete myBatch3 = new BatchLitRequestsDelete();
        myBatch3.query = 'select id from literature_Requests__c limit 10';
		database.executeBatch(myBatch3);
        
        BatchContactDelete myBatch4 = new BatchContactDelete();
        myBatch4.query = 'select id from contact limit 10';
		database.executeBatch(myBatch4);
        
        BatchAccountDelete myBatch5 = new BatchAccountDelete();
        myBatch5.query = 'select id from account limit 10';
		database.executeBatch(myBatch5);
    }
}