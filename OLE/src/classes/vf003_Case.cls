global class vf003_Case {
    static boolean bCompleted=false;
    public static void tr_After_Update(List<Case> triggerNew, List<Case> triggerOld, Map<Id,Case> triggerNewMap, Map<Id,Case> triggerOldMap) {
        if(bCompleted==true) return; 
        Set<Id> st_CaseID=new Set<Id>();
        for(Case case_new: triggerNew) {
            Case case_old=triggerOldMap.get(case_new.Id);
            if(case_new.Status != case_old.Status && case_new.IsClosed==true) st_CaseID.add(case_new.Id);
        }
        //find any open tasks associated with the completed case(s)
        List<Task> lTask2Complete=new List<Task>([SELECT Id, WhatID, Status, ISRECURRENCE, RecurrenceActivityId, RecurrenceStartDateOnly, RecurrenceEndDateOnly FROM Task WHERE WhatID IN :st_CaseID AND ISRECURRENCE!=true AND IsClosed=false]);

        List<Task> lTask2Update=new List<Task>();
        List<Task> lTask2Delete=new List<Task>();

        for(Task tsk2Complete: lTask2Complete) {
            if(tsk2Complete.RecurrenceActivityId==null) { tsk2Complete.Status='Completed'; lTask2Update.add(tsk2Complete); } //complete regular open tasks 
            else if(tsk2Complete.RecurrenceActivityId!=null) { lTask2Delete.add(tsk2Complete); } // delete uncompleted future recurring tasks
        }
        if(!lTask2Update.isEmpty()) update lTask2Update;
        if(!lTask2Delete.isEmpty()) delete lTask2Delete;        
        bCompleted=true;
    }
}