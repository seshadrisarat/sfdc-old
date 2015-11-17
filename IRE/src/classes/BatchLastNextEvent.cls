global class BatchLastNextEvent implements Database.Batchable<sObject>{
    public String query = 'select id, whoId, ActivityDate, type__c, subject from event where isdeleted = false and subject in (\'call\',\'meeting\') ORDER BY ActivityDate ALL ROWS ';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<event> leventList) {
        LastNextActivityTask EventTools = new LastNextActivityTask();
        EventTools.LastEventsUpdate(leventList);
    }
    global void finish(Database.BatchableContext BC) {
        BatchLastNextTask myBatch4 = new BatchLastNextTask();
		database.executeBatch(myBatch4); 	
    }
}