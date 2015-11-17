@isTest(SeeAllData=true)
private class Test_BatchTaskConcat {
    static testMethod void mytest() {
        BatchTaskConcat myBatch = new BatchTaskConcat();
        myBatch.query = 'select id, subject, Type__c, task.who.name, Combined_Name_Subject_Type__c from task where Combined_Name_Subject_Type__c = null ORDER BY CreatedDate desc limit 200';
		database.executeBatch(myBatch);
    }
}