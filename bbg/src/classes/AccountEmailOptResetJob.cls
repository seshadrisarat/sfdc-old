global class AccountEmailOptResetJob implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    public static boolean isBulkAccountUpdate = false;
    private DateTime startDateTime = DateTime.now();
    
    global Database.QueryLocator start(Database.BatchableContext context){
        system.debug('In QueryLocator.getQueryLocator');

        if(Test.isRunningTest()) {
            return Database.getQueryLocator([Select o.Owner__r.Id, HIN_Number__r.Owner_Email_Opt_Out__c From Owner_Boat_Relationship__c o Where Status__c = 'Active' And o.Owner__r.IsPersonAccount = true And o.Owner__r.Entry_Source__c != 'SROC' LIMIT 20]);
        } else {
            return Database.getQueryLocator([Select o.Owner__r.Id, HIN_Number__r.Owner_Email_Opt_Out__c From Owner_Boat_Relationship__c o Where Status__c = 'Active' And o.Owner__r.IsPersonAccount = true And o.Owner__r.Entry_Source__c != 'SROC']);
        }
    }
    
    global void execute(Database.BatchableContext context, List<sObject> obrs){
        system.debug('In execute ');
        isBulkAccountUpdate = true;
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        
        //Iterate through the owner boat releationships and update the account email opt in / out flags as needed
        for (sObject sOBR : obrs) {
            Owner_Boat_Relationship__c obr = (Owner_Boat_Relationship__c) sOBR; 

            system.debug('Going to update account id: ' + obr.Owner__r.Id + ' and set the email opt values based on ' + obr.HIN_Number__r.Owner_Email_Opt_Out__c);

            //Get the account associated with the Id
            Account account = new Account(
                Id = obr.Owner__r.Id,
                PersonHasOptedOutOfEmail = obr.HIN_Number__r.Owner_Email_Opt_Out__c == 'NO' ? true : false,
                Customer_Wants_Mailings__c = obr.HIN_Number__r.Owner_Email_Opt_Out__c == 'NO' ? false : true
            );
            
            accountsToUpdate.put(account.Id, account);

        }
        update accountsToUpdate.values();
    }
    
    global void finish(Database.BatchableContext context){
        //Send out email
        DateTime endDateTime = DateTime.now();
        String formattedStartDT = startDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String formattedEndDT = endDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =
            :context.getJobId()];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Account Email Opt Reset Job: ' + a.Status);
        mail.setPlainTextBody('The account email opt reset job ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n'
            + '\nStart datetime: ' + formattedStartDT
            + '\nEnd datetime: ' + formattedEndDT
        );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}