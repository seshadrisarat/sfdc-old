global class updateContactsBatchable implements Database.Batchable<sObject>
{
    global List<id> Query;
    global updateContactsBatchable(List<id> q)
    {
        Query=q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([SELECT Id,Additional_Account_Notes__c,Account.BD_Specific_Info__c,AccountId FROM Contact WHERE Id IN:Query]);
    }

    global void execute(Database.BatchableContext BC,List<Contact> scope)
    {
        List <Contact> lstContact = new list<Contact>();
        for(Sobject s : scope)
        {
            Contact c = (Contact)s;
            String text = c.Account.BD_Specific_Info__c;
            c.Additional_Account_Notes__c = text;
            lstContact.add(c);
        }
        Update lstContact;
    }

    global void finish(Database.BatchableContext BC)
    {
                
    }
}