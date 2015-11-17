trigger SpawnProjectFeedbackForms on Project__c (after update) {
    Map<Id, Project__c> projects = new Map<Id, Project__c>();
    
//Do not generate Feedback records for Quick Company Profile and Company Add record types
    for (Project__c p : Trigger.new) {
        if (p.Status__c == 'Approved' && p.RecordTypeID  != '012G0000000yDzS' && p.RecordTypeID != '012G00000010hkF') {
            projects.put(p.Id, new Project__c(
                Id = p.Id,
                Status__c = 'Awaiting Feedback',
                Feedback_Forms_Sent__c = Date.today()
            ));
        }
    }
    projects.remove(null);

    for (Project_Feedback_Form__c pff : [SELECT Project__c FROM Project_Feedback_Form__c WHERE Project__c IN :projects.keySet() AND Project__c<>NULL]) {
        projects.remove(pff.Project__c);    
    }
    
    if (!projects.isEmpty()) {
        List<Project_Feedback_Form__c> forms = new List<Project_Feedback_Form__c>();
        for (Id pId : projects.keySet()) {
            Project__c p = Trigger.newMap.get(pId);
            forms.add(new Project_Feedback_Form__c(
                Project__c = p.Id,
                OwnerId = p.OwnerId,
                Feedback_Role__c = 'Requestor'
            ));
            if (p.Team_Lead__c != null) {
                forms.add(new Project_Feedback_Form__c(
                    Project__c = p.Id,
                    OwnerId = p.Team_Lead__c,
                    Feedback_Role__c = 'Lead'
                ));
            }
        }
        insert forms;
        update projects.values();
    }
}