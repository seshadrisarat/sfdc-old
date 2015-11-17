global class Batch_Nightly_Jobs implements Database.Batchable<sObject>{
	Public String query = 'select id from contact';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        	return Database.getQueryLocator(query);
            }
    global void execute(Database.BatchableContext BC, List<contact> lContactList) {
        list<id> idOut = new list<id>();
        for (contact c: lContactList){
            idOut.add(c.id);
        }
        Nightly_Jobs nightlyJobs = new Nightly_Jobs();        
        nightlyJobs.Sales_Rating(idOut);
    }
    global void finish(Database.BatchableContext BC) {
    }

}