trigger DealTeamMembersRefresh_TeamMember on Team_Member__c (after insert, after update, after delete, after undelete) {
    Integer FIELD_LIMIT = 255;
    
    Map<Id, Set<Id>> dealUsers = new Map<Id, Set<Id>>();
    Map<Id, Deal__c> deals = new Map<Id, Deal__c>();
    for (Team_Member__c tm : (Trigger.isDelete ? Trigger.old : Trigger.new)) {
        if (dealUsers.containsKey(tm.Deal__c)) {
            dealUsers.get(tm.Deal__c).add(tm.User__c);
        } else {
            dealUsers.put(tm.Deal__c, new Set<Id> { tm.User__c });
        }
        deals.put(tm.Deal__c, new Deal__c(
            Id = tm.Deal__c,
            Deal_Team_Members__c = '',
            Deal_Mentors__c = '',
            MD_Principal_Members__c = ''
        ));
    }

    List<Deal__Share> dealShares = new List<Deal__Share>();
    for (Id dId : dealUsers.keySet()) {
        for (Id uId : dealUsers.get(dId)) {
            dealShares.add(new Deal__Share(
                ParentId = dId,
                UserOrGroupId = uId,
                AccessLevel = 'Read'
            ));
        }
    }
    if (!dealShares.isEmpty()) {
        Database.upsert(dealShares, false);
        if (Trigger.isDelete) {
            List<Deal__Share> deleteDealShares = new List<Deal__Share>();
            for (Deal__Share s : dealShares) {
                if (s.Id != null) {
                    deleteDealShares.add(new Deal__Share(
                        Id = s.Id
                    ));
                }
            }        
            Database.delete(deleteDealShares, false);
        }
    }
    
    for (Team_Member__c tm : [SELECT Deal__c, Deal_Mentor__c, User__r.Name, User__r.Title, User__r.Alias FROM Team_Member__c WHERE Deal__c IN :deals.keySet() ORDER BY User__r.Alias]) {
        Deal__c d = deals.get(tm.Deal__c);
        String strTitle=(tm.User__r.Title==null?'':tm.User__r.Title.toLowerCase());
        
        if (tm.Deal_Mentor__c) {
            d.Deal_Mentors__c = (d.Deal_Mentors__c == null ? tm.User__r.Alias : d.Deal_Mentors__c + ',' + tm.User__r.Alias);
        } else if (strTitle.startsWith('managing director') || strTitle.equalsIgnoreCase('Principal')) {
            d.MD_Principal_Members__c = (d.MD_Principal_Members__c == null ? tm.User__r.Alias : d.MD_Principal_Members__c + ',' + tm.User__r.Alias);
        } else {
            d.Deal_Team_Members__c = (d.Deal_Team_Members__c == null ? tm.User__r.Alias : d.Deal_Team_Members__c + ',' + tm.User__r.Alias);        
        }
    } 
    if (!deals.isEmpty()) {
        update deals.values();
    }
    
    
    Utilities.employeeRollup(null);
}