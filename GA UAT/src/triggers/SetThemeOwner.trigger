trigger SetThemeOwner on Theme__c (before insert, before update) {
    for (Theme__c t : Trigger.new) {
        t.Owner__c = t.OwnerId;
    }
}