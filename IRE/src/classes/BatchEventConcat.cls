global class BatchEventConcat implements Database.Batchable<sObject>{
    Public String query = 'select id, subject, Type__c, event.who.name, Combined_Name_Subject_Type__c from event where Combined_Name_Subject_Type__c = null ORDER BY CreatedDate desc';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        string filler = 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        filler += 'filler';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<event> ltaskList) {
        LastNextActivityTask MyJobs = new LastNextActivityTask();
        MyJobs.CalendarConcatEvents(ltaskList);
    }
    global void finish(Database.BatchableContext BC) {
    }

}