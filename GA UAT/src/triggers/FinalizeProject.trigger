trigger FinalizeProject on Project_Feedback_Form__c (after insert, after update) {
    Map<Id, Project__c> projects = new Map<Id, Project__c>();
    for (Project_Feedback_Form__c pff : Trigger.new) {
        if (pff.Completed_in_a_Timely_Manner__c != null &&
            pff.Data_Provided_Accurate__c != null &&
            pff.Overall_Project_Rating__c != null &&
            pff.Feedback_Role__c == 'Requestor') {
            projects.put(pff.Project__c, new Project__c(
                Id = pff.Project__c,
                Status__c = 'Finalized',
                Requestor_Rating__c = pff.Overall_Project_Rating_numeric__c
           ));
        }
        else if (pff.Completed_in_a_Timely_Manner__c != null &&
            pff.Data_Provided_Accurate__c != null &&
            pff.Overall_Project_Rating__c != null &&
            pff.Feedback_Role__c == 'Lead') {
            projects.put(pff.Project__c, new Project__c(
                Id = pff.Project__c,
                Status__c = 'Finalized',
                Lead_Rating__c = pff.Overall_Project_Rating_numeric__c
           ));            
        }
    }
    projects.remove(null);
    
    for (Project_Feedback_Form__c pff : [SELECT Project__c FROM Project_Feedback_Form__c WHERE Completed_in_a_Timely_Manner__c=NULL OR Data_Provided_Accurate__c=NULL OR Overall_Project_Rating__c=NULL]) {
        projects.remove(pff.Project__c);
    }
    
    if (!projects.isEmpty()) {
        update projects.values();
    }
}