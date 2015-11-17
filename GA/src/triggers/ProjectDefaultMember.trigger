trigger ProjectDefaultMember on Project__c (after insert) {
    List<Communication_Team_Member__c> members = new List<Communication_Team_Member__c>();
    for (Project__c p : Trigger.new) {
        members.add(new Communication_Team_Member__c(
            Project__c = p.Id,
            Team_Member__c = p.OwnerId
        ));
    }
    if (!members.isEmpty()) {
        Database.insert(members, false);
    }
}