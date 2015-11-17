public with sharing class MoveContactExtension {
    private Contact oldContact;
    public Contact newContact { get; private set; }
    public Employment_History__c employmentRecord { get; private set; }

    public MoveContactExtension(ApexPages.StandardController controller) {
        try {
            oldContact = (Contact) controller.getRecord();

            newContact = oldContact.clone(false, true);
            newContact.AccountId = null;

            employmentRecord = new Employment_History__c(
                Historical_Account__c = oldContact.AccountId,
                Historical_Contact__c = oldContact.Id,
                Move_Date__c = Date.today()
            );
        } catch(Exception e) {
            System.debug(e);
        }
    }

    public PageReference moveContact() {
        PageReference ref = null;

        Savepoint sp = Database.setSavePoint();
        try {
            List<Contact> contacts = new List<Contact>();
            contacts.add(newContact);
            contacts.add(new Contact(
                Id = oldContact.Id,
                LastName = oldContact.LastName + ' (HISTORICAL)',
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Contact' AND DeveloperName='Historical' LIMIT 1].Id
            ));
            upsert contacts;

            // Update employment history to point to new contact
            List<Employment_History__c> employmentHistory = [SELECT Id FROM Employment_History__c WHERE Current_Contact__c=:oldContact.Id AND IsDeleted=FALSE];
            employmentHistory .add(employmentRecord);
            for (Employment_History__c eh : employmentHistory) {
                eh.Current_Contact__c = newContact.Id;
            }
            upsert employmentHistory;

            ref = new PageReference('/' + newContact.Id);
        } catch(Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
        }

        return ref;
    }
}