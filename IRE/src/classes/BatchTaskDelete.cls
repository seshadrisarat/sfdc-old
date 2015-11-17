global class BatchTaskDelete implements Database.Batchable<sObject>{
    Public String query = 'select id from task where isdeleted = false ALL ROWS';
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
    global void execute(Database.BatchableContext BC, List<task> ltaskList) {
        delete ltaskList;
        DataBase.emptyRecycleBin(ltaskList);
    }
    global void finish(Database.BatchableContext BC) {
    }

}