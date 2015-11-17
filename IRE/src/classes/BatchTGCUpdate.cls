global class BatchTGCUpdate implements Database.Batchable<sObject>{
    public String query = 'select id from contact ORDER BY MailingState desc';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<contact> lContacts) {
        TGCUpdateClass UpdateTGC = new TGCUpdateClass();
    	UpdateTGC.UpdateContactInfo(lContacts);
    }
    global void finish(Database.BatchableContext BC) {
    }
}