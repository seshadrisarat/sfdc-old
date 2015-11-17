/*************************************************************************
Name : BatchSetTieredStatusOfAccount 
Author : Jyoti Singh
Date : 15 Nov, 2013
Usage : This batch is used to set Tiered Status for existing Account 
**************************************************************************/
global class BatchSetTieredStatusOfAccount implements Database.Batchable<SObject> {
    public string query {get;set;}
    
    global database.querylocator start(Database.BatchableContext BC) {
        //query = 'Select Id,Status__c, Tiered_Status__c From Account where Status__c !=  Null || Status__c != \'\'';

        // update jfavors - 12/11/13 - fix "unexpected token: '||'" error
        query = 'Select Id, Status__c, Tiered_Status__c From Account where Status__c !=  null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, LIST<SObject> listData) {
        List<Account> accListToUpdate = new List<Account>();
        List<Account> accList = (List<Account>)listData;
        
        for (Account a : accList) {
            if (a.Status__c == 'Early Investigation') {
                a.Tiered_Status__c = 'Tier 0 - Early Investigation'; 
            }
            else if (a.Status__c == 'Monitor') {
                a.Tiered_Status__c = 'Tier 1 - Monitor';
            }
            else if (a.Status__c == 'Top Prospect') {
                a.Tiered_Status__c = 'Tier 2 - Top Prospect';
            }
            else if (a.Status__c == 'Primary Target') {
                a.Tiered_Status__c = 'Tier 3 - Primary Target';
            }
            else if (a.Status__c == 'Live Deal') {
                a.Tiered_Status__c = 'Tier 4 - Live Deal';
            }
            else {
                a.Tiered_Status__c = a.Status__c;
            }

            accListToUpdate.add(a);
        }

        if (accListToUpdate.size() > 0) {
            update accListToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}