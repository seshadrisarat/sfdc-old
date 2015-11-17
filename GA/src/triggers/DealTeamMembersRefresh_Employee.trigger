trigger DealTeamMembersRefresh_Employee on Employee__c (after update, after delete, after undelete) {
    Boolean refresh = false;
    if (Trigger.isUpdate) {
        for (Employee__c e : Trigger.new) {
            refresh |= (e.Initials__c != Trigger.oldMap.get(e.Id).Initials__c);
        }
    } else {
        refresh = true;
    }
        
    if (refresh) {
        Utilities.employeeRollup(null);
    }
}