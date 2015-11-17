global class BatchClearLastNext implements Database.Batchable<sObject>{
    public String query = 'select id from contact';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<contact> listIDlist) {
        set<id> setIDlist = new set<id>();
        for(contact c: listIDlist){
            if(c.id != null){
                setIDlist.add(c.id);
            }
        }
        LastNextActivityTask ContactTools = new LastNextActivityTask();
        ContactTools.ClearLastNextDates(setIDlist);
    }
    global void finish(Database.BatchableContext BC) {
    }
}