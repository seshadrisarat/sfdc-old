global without sharing class RecordTouchBatch implements Database.Batchable<sObject> {
    public String soql { get; set;}
    public String email { get; set;}
    
    global RecordTouchBatch(String soql, String email){
        this.soql = soql;
        this.email = email;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(this.soql);
    }
    
    global void execute(Database.BatchableContext context, List<sObject> scope){
        update scope;
    }
    
    global void finish(Database.BatchableContext context){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {email});
        mail.setReplyTo('batch@salesforce.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Completed');
        mail.setPlainTextBody('Batch Process Has Completed');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
}