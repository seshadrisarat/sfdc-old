trigger SetProjectCompletedDate on Project__c (before insert, before update) {
    for (Project__c p : Trigger.new) {
        if (p.Status__c == 'Approved' && p.Date_Completed__c == null) {
            p.Date_Completed__c = Date.today();
        }
    }
}