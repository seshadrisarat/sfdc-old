global class BatchLastNextTask implements Database.Batchable<sObject>{
    public String query = 'select id, whoId, ActivityDate, type__c, status, subject from task where isdeleted = false and subject in (\'call\',\'meeting\') ORDER BY ActivityDate ALL ROWS';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<task> ltaskList) {
        LastNextActivityTask TaskTools = new LastNextActivityTask();
        TaskTools.LastTasksUpdate(ltaskList);
    }
    global void finish(Database.BatchableContext BC) {
    }
}