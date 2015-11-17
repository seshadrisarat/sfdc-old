trigger SetConferenceOwner on Conference_Award__c (before insert, before update) {
    for (Conference_Award__c t : Trigger.new) {
        t.Owner__c = t.OwnerId;
    }
}