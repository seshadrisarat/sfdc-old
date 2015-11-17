trigger SetProjectTeamMembers on Project_Team_Member__c (after insert, after update, after delete, after undelete) {
    Map<Id, Set<Id>> projectTeamMembers = new Map<Id, Set<Id>>();
    for (Project_Team_Member__c ptm : (Trigger.isDelete ? Trigger.old : Trigger.new)) {
        projectTeamMembers.put(ptm.Project__c, new Set<Id>());
    }
    projectTeamMembers.remove(null);
    
    for (Project_Team_Member__c ptm : [SELECT Project__c, Team_Member__c FROM Project_Team_Member__c WHERE Team_Member__c<>NULL AND Project__c IN :projectTeamMembers.keySet() AND IsDeleted=FALSE]) {
        projectTeamMembers.get(ptm.Project__c).add(ptm.Team_Member__c);
    }
    
    List<Project__c> projects = new List<Project__c>();
    for (Id pId : projectTeamMembers.keySet()) {
        Project__c p = new Project__c(
            Id = pId,
            MemberIds__c = ''
        );
        for (Id uId : projectTeamMembers.get(pId)) {
            p.MemberIds__c += uId;
        }
        projects.add(p);
    }    
    if (!projects.isEmpty()) {
        update projects;
    }
}