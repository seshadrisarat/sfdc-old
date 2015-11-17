global class SL_Util_Approvals {

    Webservice static String reassign(Id objId, Id newAssignId){
        String retVal = 'false';
        List<ProcessInstanceWorkItem> workItemList = [SELECT Id, OriginalActor.Name,ActorId 
                                              FROM ProcessInstanceWorkItem
                                              WHERE ProcessInstance.TargetObjectId = :objId
                                              ORDER BY CreatedDate DESC];
         
        if(!workItemList.isEmpty())
        {
            ProcessInstanceWorkItem piwi = workItemList.get(0);
            if(piwi.OriginalActor.Name == 'Credit Preparers')
            {
                retVal = 'prep';
            }
            else if(piwi.OriginalActor.Name == 'Credit Recommenders')
            {
                retVal = 'rec';
            }
            piwi.ActorId = newAssignId;

            update piwi;
        }
        return retVal;
    }

    /*// Retrieves the User Id and Name of the user who originally submitted the credit request for approval
    public static Map<Id, String> retrieveSubmitter(Id objId){
        List<ProcessInstance> approvalProcess = [SELECT Id, (SELECT OriginalActorId, OriginalActor.Name
                                                             FROM StepsAndWorkItems 
                                                             WHERE StepStatus = 'Started')
                                                  FROM ProcessInstance
                                                  WHERE TargetObjectId = :objId
                                                  ORDER BY CreatedDate DESC 
                                                  LIMIT 1];
        if(approvalProcess.size() == 0)
            return null;

        ProcessInstanceHistory approvalHistory = approvalProcess[0].StepsAndWorkItems;

        return new Map<Id, String>{approvalHistory.OriginalActorId => approvalHistory.OriginalActor.Name};
    }*/

    // Retrieves the User Id and Name of the user who is currently the approver of the record
    public static Map<Id, String> retrievePreviousApprover(Id objId){
        List<ProcessInstanceWorkItem> workItemList = [SELECT ActorId, Actor.Name
                                                      FROM ProcessInstanceWorkItem
                                                      WHERE ProcessInstance.TargetObjectId = :objId
                                                      ORDER BY CreatedDate DESC];
        if(!workItemList.isEmpty())
            return new Map<Id, String>{workItemList.get(0).ActorId => workItemList.get(0).Actor.Name};
        else
            return null;
    }
}