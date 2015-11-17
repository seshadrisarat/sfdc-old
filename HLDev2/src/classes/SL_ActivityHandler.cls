/*
    JIRA Ticket   : LIB-184
    Created on    : May-19-2014
    Created by    : Praful
    Description   : Trigger handler for SL_Event and SL_Task, and purpose is to delete the child activities on deletion of parent activity.
*/
public with sharing class SL_ActivityHandler {
    
    public void onAfterDelete(List<sObject> lstActivity) {
        
        Set<Id> setActivitiesIds = new Set<Id>(); // To hold the set of parent activities Ids
        List<sObject> lstChildActivitiesToDelete = new List<sObject>(); // To hold the list of child activities to delete

        // Iterating over list of activity
        for(sObject obj : lstActivity)
        {
            // Checking parent activity and collecting in set of activities ids
            if(obj.get('IsParent__c') == true)
                setActivitiesIds.add((Id)obj.get('Id'));
        }

        for(Event objEvent : [SELECT Id FROM Event WHERE ParentId__c IN: setActivitiesIds]){
            lstChildActivitiesToDelete.add(objEvent);
        }

        for(Task objTask : [SELECT Id FROM Task WHERE ParentId__c IN: setActivitiesIds]) {        
            lstChildActivitiesToDelete.add(objTask);
        }

        if(!lstChildActivitiesToDelete.isEmpty()) {
            delete lstChildActivitiesToDelete;
        }
    }
}