trigger ContactUpdate on Contact (after insert, after update) {
    list<contact> ContactsUpdated = new list<contact>();
    
    if (Trigger.IsUpdate) {
        for (contact c: trigger.new){
            contact oldContact = trigger.oldmap.get(c.id);
            //Update TGC and other info
            if ((c.MailingPostalCode != oldContact.MailingPostalCode) ||
                (c.MailingCity != oldContact.mailingcity) ||
                (c.MailingState != oldContact.MailingState) ||
            	(c.AccountId != oldContact.AccountId) ||
                (c.status__c != oldContact.status__c) ||
               	(c.Contact_Type__c != oldContact.Contact_Type__c)) {
                ContactsUpdated.add(c);
            }
        }
    }
    else
    {
        ContactsUpdated = trigger.new;
    }
    TGCUpdateClass UpdateTGC = new TGCUpdateClass();
    UpdateTGC.UpdateContactInfo(ContactsUpdated);
}