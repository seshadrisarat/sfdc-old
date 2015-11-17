global class BatchFillerDelete implements Database.Batchable<sObject>{
    Public String query = 'select id from event where isdeleted = false ALL ROWS';
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
        delete ltaskList;
        DataBase.emptyRecycleBin(ltaskList);
    }
    global void finish(Database.BatchableContext BC) {
    }

}