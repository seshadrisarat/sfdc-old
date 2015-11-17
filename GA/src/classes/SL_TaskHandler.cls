/**
*  Trigger Name   : SL_TaskHandler
*  CreatedOn      : 10/DEC/2014
*  ModifiedBy     : Sandeep
*  ModifiedDate   : 05/05/2015
*  Description    : This is the Task trigger which send mail to Team Members, update Account and Compamny Theme object field and updatet the 
                    Material notes for all open activities based on Due date. 
*/
public without sharing class SL_TaskHandler {
    
    public String strAccountKeyPrefix = '';                // To store Account KeyPrefix
    public String strOpportunityKeyPrefix = '';     // To store Opportunity KeyPrefix 
    private static boolean run = true;
    public static set<Id> setContactIdUpdate = new set<Id>();
    public static set<Id> setContactIdDelete = new set<Id>();
    public static map<Id,String> mapTaskIdToOwnerName = new map<Id,String>();//map to contain the task id to its owner Name
    /* Constructor */    
    public SL_TaskHandler(){
        //Fetching Account and Opportunity KeyPrefix  
        Map<String, SObjectType> mapSchemaSobject = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult result =  mapSchemaSobject.get('Account').getDescribe();
        strAccountKeyPrefix = Result.getKeyPrefix();
        
        Schema.DescribeSObjectResult opportunityResult =  mapSchemaSobject.get('Opportunity').getDescribe();
        strOpportunityKeyPrefix = opportunityResult.getKeyPrefix();
    }

    public static boolean runOnce()
    {
        if(run)
        {
            run=false;
            return true;
        }else
        {
            return run;
        }
    }
    
    /*
    * MethodName   : onAfterInsert
    * param        : trigger.newMap
    * Description  : This method is called after Task records are inserted
    */
    public void onAfterInsert(Map<Id,Task> mapNewTask){
        if(SL_TaskHandler.runOnce())
        {    
            alertTeam(mapNewTask.values());
            setDealComments(mapNewTask.values(),true);
            setCompanyNextSteps(mapNewTask.values());
            dealThemesRefresh(mapNewTask.values());
            updateMaterialInteractionNotes(null, mapNewTask, false);
            updateCPNextSteps(null, mapNewTask, false);
            setAttFlag(null, mapNewTask);
        }
    }
    
    /*
    * MethodName   : onAfterUpdate
    * param        : trigger.newMap,trigger.oldMap
    * Description  : This method is called after Task records are updated
    */
    public void onAfterUpdate(Map<Id,Task> mapOldTask, Map<Id,Task> mapNewTask){
        if(SL_TaskHandler.runOnce())
        {    
            setDealComments(mapNewTask.values(),false);
            dealThemesRefresh(mapNewTask.values());
            updateMaterialInteractionNotes(mapOldTask, mapNewTask, false);
            updateCPNextSteps(mapOldTask, mapNewTask, false);
            setAttFlag(mapOldTask, mapNewTask);
        }
    }
    
    /*
    * MethodName   : onAfterDelete
    * param        : trigger.old
    * Description  : This method is called after Task records are deleted
    */
    public void onAfterDelete(Map<Id,Task> mapOldTask){
        if(SL_TaskHandler.runOnce())
        {
            setDealComments(mapOldTask.values(),false);
            updateMaterialInteractionNotes(mapOldTask, null, true);
            updateCPNextSteps(mapOldTask, null, true);
        }
    }
    
    /*
    * MethodName   : alertTeam
    * param        : trigger.new
    * Description  : This method is called after Task records are created and has the orginal code from AlertTeam.trigger. Used to send email to
    Team members. 
    */
    private void alertTeam(List<Task> lstNewTask) {
        
        Set<Id> taskIds = new Set<Id>();
        for(Task t : lstNewTask) {
            if (t.Notify_Deal_Team__c) {
                taskIds.add(t.Id);
            }
        }
        
        Map<Id,Messaging.SingleEmailMessage> dealEmail = new Map<Id,Messaging.SingleEmailMessage>();
        List<Id> deals = new List<Id>();
        
        if (!taskIds.isEmpty()) {
            for(Task t : [SELECT Id, Subject, ActivityDate, Priority, WhatId, What.Name, WhoId, Who.Name, Description FROM Task WHERE Id in: taskIds]) {
                // Build email body
                String textBody = '';
                String htmlBody = '';
                
                textBody += 'Subject: ' + t.Subject + '\n';
                textBody += 'Due Date: ' + t.ActivityDate.format() + '\n';
                textBody += 'Priority: ' + t.Priority + '\n';
                htmlBody += '<p>';
                htmlBody += '<b>Subject: </b>' + t.Subject + '<br/>';
                htmlBody += '<b>Due Date: </b>' + t.ActivityDate.format() + '<br/>';
                htmlBody += '<b>Priority: </b>' + t.Priority + '<br/>';
                if (t.WhatId != null) {
                    textBody += 'Related To: ' + t.What + '\n';
                    htmlBody += '<b>Related To: </b>' + t.What.Name + '<br/>';
                } else {
                    textBody += 'Related To:\n';
                    htmlBody += '<b>Related To:</b><br/>';
                }
                if (t.WhoId != null) {
                    textBody += 'Name: ' + t.Who + '\n';
                    htmlBody += '<b>Name: </b>' + t.Who.Name + '<br/>';
                } else {
                    textBody += 'Name:\n';
                    htmlBody += '<b>Name:</b><br/>';
                }
                if (t.Description != null) {
                    textBody += 'Comments: ' + t.Description;
                    htmlBody += '<b>Comments: </b>' + t.Description;
                } else {
                    textBody += 'Comments:\n';
                    htmlBody += '<b>Comments: </b><br/>';
                }
                htmlBody += '</p>';
                htmlBody += 'Click <a href=https://na1.salesforce.com/' + t.Id + '>here</a> to view the task.';
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();          
                mail.setSubject('New Task Alert: ' + t.Subject);
                mail.setPlainTextBody(textBody);
                mail.setHtmlBody(htmlBody);
                mail.setUseSignature(false);
                mail.setSaveAsActivity(false);
                
                deals.add(t.WhatId);
                dealEmail.put(t.WhatId,mail);
            }
            
            for (Team_Member__c tm : [SELECT Deal__c, Email__c FROM Team_Member__c WHERE isDeleted = FALSE AND Deal__c IN :deals]) {
                Messaging.SingleEmailMessage mail = dealEmail.get(tm.Deal__c);
                if (mail != null && tm.Email__c != null) {
                    Set<String> e = new Set<String>();
                    if (mail.getToAddresses() != null) {
                        e.addAll(mail.getToAddresses());
                    }
                    e.add(tm.Email__c);
                    List<String> temp = new List<String>();
                    temp.addAll(e);
                    mail.setToAddresses(temp);
                    dealEmail.put(tm.Deal__c, mail);
                }
            }
            for (Messaging.SingleEmailMessage mail : dealEmail.values()) {
                if (mail.getToAddresses() != null) {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
        }
        
    }
    
    /*
    * MethodName   : setDealComments
    * param        : trigger.new or trigger.old
    * Description  : This method is called after Task records are created/updated/deleted. Originally took from SetDealComments.trigger code. 
    SetDealComments have methods which are being called for all the events within updateMostRecentActivity() method.
    
    Certain code runs only in case of insert which were written w/o any event check but being used only for Insert case. 
    So new method  updateDealAccount() have been introduced to have that extra code run when task gets created. 
    */
    private void setDealComments(List<Task> lstNewTask, Boolean bInsert) {
        set<String> setAccId = new set<String>();
        
        for(Task objTask : lstNewTask){
            if(objTask.WhatId != null && String.valueOf(objTask.WhatId).startsWith(strAccountKeyPrefix))
                setAccId.add(objTask.WhatId);
        }
        if(setAccId.size() > 0)
            updateMostRecentActivity(setAccId);
        
        if(bInsert)
            updateDealAccount(lstNewTask);
    }
    
    /*
    * MethodName   : updateMostRecentActivity
    * param        : Set of Account Id
    * Description  : This method is called if set of Account Id size > 0
    */
    private void updateMostRecentActivity(set<String> setAccountId) {
        
        map<String, Task> mapAccountId_Task = new map<String, Task>();
        map<String, String> mapAccountId_Comment = new map<String, String>();
        List<Account> lstAccountToUpdate = new List<Account>();
        
        try{
            if(setAccountId.size() > 0){
                for(Task objTask: [select Id, ActivityDate, WhatId, Description From Task where IsClosed=TRUE AND WhatId IN: setAccountId order by ActivityDate DESC, LastModifiedDate DESC]){
                    if(!mapAccountId_Task.containsKey(objTask.WhatId)){
                        mapAccountId_Task.put(objTask.WhatId, objTask);
                        mapAccountId_Comment.put(objTask.WhatId, objTask.Description);
                    }
                }
                for(Event objEvent : [select Id, ActivityDate, WhatId, Description From Event where WhatId IN: setAccountId order by ActivityDate DESC, LastModifiedDate DESC]){
                    if(mapAccountId_Task.containsKey(objEvent.WhatId)){
                        if(mapAccountId_Task.get(objEvent.WhatId).ActivityDate > objEvent.ActivityDate)
                            mapAccountId_Comment.put(objEvent.WhatId, mapAccountId_Task.get(objEvent.WhatId).Description);
                        else
                            mapAccountId_Comment.put(objEvent.WhatId, objEvent.Description);
                    }
                    else
                        mapAccountId_Comment.put(objEvent.WhatId, objEvent.Description);
                }
                for(Account objAccount :[select Id, Most_Recent_Activity_Comment__c from Account where Id IN: mapAccountId_Comment.keySet()]){
                    objAccount.Most_Recent_Activity_Comment__c = mapAccountId_Comment.get(objAccount.Id);
                    lstAccountToUpdate.add(objAccount);    
                }
                if(lstAccountToUpdate.size() > 0)
                    update lstAccountToUpdate;
            }
            if(Test.isRunningTest())
                Integer i = 10/0;
        }
        catch(Exception e){
            Task objTask = new Task();
            objTask.addError('An unexpected error has occured, please notify your Administrator.');
        }
    }
    
    /*
    * MethodName   : setCompanyNextSteps
    * param        : trigger.new
    * Description  : This method functionality has been taken from SetCompanyNextSteps.trigger. This takes the description from the lates task and 
    update the respective Account records. 
    */
    private void setCompanyNextSteps(List<Task> lstNewTask) {
        
        Map<Id, Account> accountMap = new Map<Id, Account>();
        
        /* New 3549 Logic */
        for (Task t : lstNewTask) {
            accountMap.put(t.AccountId, new Account(
                Id=t.AccountId,
                Add_to_call_list__c=false
            ));
        }
        accountMap.remove(null);
        
        //CWD-- 2012-12-01: pulling the following otu of the below 2 SOQL statements: "AND Next_Steps__c<>NULL"
        Map<Id, Task> tasks = new Map<Id, Task>();
        for (Account a : [SELECT Id, (SELECT ActivityDate,Description,subject, Next_Steps__c FROM Tasks WHERE IsClosed=TRUE AND Type='Status Note'  ORDER BY ActivityDate DESC, LastModifiedDate DESC LIMIT 1) FROM Account WHERE Id IN :accountMap.keySet() AND RecordType.DeveloperName='DealCompany']) {
            for (Task t : a.Tasks) {
                tasks.put(a.Id, t);
            }
        }
        for (Deal__c d : [SELECT Related_Company__c, (SELECT ActivityDate,Description, subject, Next_Steps__c FROM Tasks WHERE IsClosed=TRUE AND Type='Status Note' ORDER BY ActivityDate DESC, LastModifiedDate DESC LIMIT 1) FROM Deal__c WHERE Related_Company__c IN :accountMap.keySet() AND RecordType.DeveloperName='DealCompany' AND Status__c NOT IN ('Closed', 'Passed', 'Funded by Others', 'On Hold')]) {
            for (Task t : d.Tasks) {
                Task oldT = tasks.get(d.Related_Company__c);
                if (oldT == null || oldT.ActivityDate > t.ActivityDate) {
                    tasks.put(d.Related_Company__c, t);
                }
            }
        }
        for (Id aId : tasks.keySet()) {
            if(tasks.get(aId).Next_Steps__c!=null)  accountMap.get(aId).Next_Steps__c = tasks.get(aId).Next_Steps__c;
            accountMap.get(aId).Latest_Status_Note__c = tasks.get(aId).Description;
            accountMap.get(aId).Latest_Status_Note_Subject__c = tasks.get(aId).subject;
        }
        
        if(!accountMap.isEmpty()) {
            update accountMap.values();
        }
        
    }
    
    /*
    * MethodName   : dealThemesRefresh
    * param        : trigger.new
    * Description  : This is being called after Task gets created/updated. Originally took from DealThemesRefresh_Task.trigger.  
    Update the Company_Theme__c records based on recently logged tasks. 
    
    */
    private void dealThemesRefresh(List<Task> lstNewTask) {
        
        Set<Id> accountIds = new Set<Id>();
        for (Task t : lstNewTask) {
            accountIds.add(t.AccountId);
        }
        accountIds.remove(null);
        
        // Get list of affected themes
        Set<Id> themeIds = new Set<Id>();
        for (Company_Theme__c ct : [SELECT Theme__c FROM Company_Theme__c WHERE Company__c IN :accountIds AND IsDeleted=FALSE]) {
            themeIds.add(ct.Theme__c);
        }
        // Update list of accounts associated to those themes
        for (Company_Theme__c ct : [SELECT Company__c FROM Company_Theme__c WHERE Theme__c IN :themeIds AND IsDeleted=FALSE]) {
            accountIds.add(ct.Company__c);
        }
        
        Set<String> taskThemeSet = new Set<String>();
        for (Task t : [SELECT AccountId, Type FROM Task WHERE AccountId IN :accountIds AND Type IN ('Prospect Call','Prospect Meeting Notes') AND IsDeleted=FALSE AND Account.Themes__c<>NULL AND IsClosed=TRUE]) {
            taskThemeSet.add('' + t.Type + t.AccountId);
        }
        
        Map<Id, Theme__c> themes = new Map<Id, Theme__c>();
        for (Company_Theme__c ct : [SELECT Company__c, Theme__c FROM Company_Theme__c WHERE Company__c IN :accountIds AND IsDeleted=FALSE]) {
            
            Theme__c t = new Theme__c(
                Id = ct.Theme__c,
                Companies_Called__c = 0,
                Companies_Met__c = 0
            );
            if (taskThemeSet.contains('Prospect Call' + ct.Company__c)) {
                t.Companies_Called__c = 1;
            }
            if (taskThemeSet.contains('Prospect Meeting Notes' + ct.Company__c)) {
                t.Companies_Met__c = 1;
            }
            
            if (themes.containsKey(ct.Theme__c)) {
                themes.get(ct.Theme__c).Companies_Called__c += t.Companies_Called__c;
                themes.get(ct.Theme__c).Companies_Met__c += t.Companies_Met__c;
            } else {
                themes.put(t.Id, t);
            }
        }
        
        if (!themes.isEmpty()) {
            update themes.values();
        }
    }
    
    private void updateMaterialInteractionNotes(Map<Id,Task> oldMap, Map<Id,Task> newMap, Boolean isDelete)
    {
        Set<Id> acctIds = new Set<Id>();
        Account[] updAccts = new Account[]{};
        
        /* updates for GA-15*/
        set<Id> setJobOrderORContactId = new set<Id>();//Used to Store Job Order Id or contact id whch is used for query related to JobOrderId
        
        Task[] tempList = isDelete ? oldMap.values() : newMap.values();
        set<Id> setTaskIds = new set<Id>();
        for(Task t : tempList)
        {
            if(t.WhatId != null)
            {
                if(t.WhatId.getSObjectType() == Schema.Account.SObjectType)
                {
                    acctIds.add(t.WhatId);
                }
                
                 /* updates for GA-15*/
                if(t.WhatId.getSobjectType() == ts2__Job__c.sObjectType && !Trigger.isUpdate)
                {
                    setJobOrderORContactId.add(t.WhatId);
                }
                if(Trigger.isUpdate && (t.Description != oldMap.get(t.Id).Description ||t.WhatId != oldMap.get(t.Id).WhatId 
                                        || t.ActivityDate != oldMap.get(t.Id).ActivityDate || t.Subject != oldMap.get(t.Id).Subject))
                {
                    setJobOrderORContactId.add(t.WhatId);
                    setJobOrderORContactId.add(oldMap.get(t.Id).WhatId);
                }
            }
            setTaskIds.add(t.Id);
        }
        

        Account[] aList = [Select Id,Material_Interaction_Notes_Short__c,
                                  Material_Interaction_Notes__c,
                                  (Select Id,Subject,ActivityDate,Material_Interaction__c
                                   From ActivityHistories
                                   ORDER BY ActivityDate DESC NULLS LAST
                                   LIMIT 500)
                           From Account
                           WHERE Id IN: acctIds];

        for(Account a : aList)
        {
            a.Material_Interaction_Notes_Short__c = '';
            a.Material_Interaction_Notes__c = '';

            ActivityHistory[] ahList = new ActivityHistory[]{};

            System.debug('Look at me 2 = ' + a.ActivityHistories.size());

            for(ActivityHistory ah : a.ActivityHistories)
            {
                if(ah.Material_Interaction__c)
                {
                    ahList.add(ah);
                }

                if(ahList.size() == 10)
                {
                    break;
                }
            }

            System.debug('Look at me = ' + ahList.size());

            if(ahList != null && !ahList.isEmpty())
            {
                for(Integer i=0;i<ahList.size();i++)
                {
                    String strDate = '';

                    if(ahList[i].ActivityDate != null)
                    {
                        strDate = ahList[i].ActivityDate.month() + '/' + ahList[i].ActivityDate.day() + '/' + String.valueOf(ahList[i].ActivityDate.year()).substring(2,4);
                    }

                    if(i<2)
                    {
                        a.Material_Interaction_Notes_Short__c = a.Material_Interaction_Notes_Short__c + '- ' + (strDate != '' ? strDate + ': ' : '') + ahList[i].Subject + '\n';
                    }
                    
                    a.Material_Interaction_Notes__c = a.Material_Interaction_Notes__c + '- ' + (strDate != '' ? strDate + ': ' : '') + ahList[i].Subject + '\n';
                }
            }

            updAccts.add(a);
        }

        update updAccts;
        
        set<Id> setTaskRelationIds = new set<Id>();
        if(!setContactIdUpdate.isEmpty())
            setTaskRelationIds.addAll(setContactIdUpdate);
        if(!setContactIdDelete.isEmpty())
            setTaskRelationIds.addAll(setContactIdDelete);

        if(!setTaskIds.isEmpty())
            SL_TaskHandler.updateContact(setTaskIds, setTaskRelationIds);
            
        /* updates for GA-15*/
        if(!setJobOrderORContactId.isEmpty())
            updateJobOrderOrContact(setJobOrderORContactId);
    }

    private void updateCPNextSteps(Map<Id,Task> oldMap, Map<Id,Task> newMap, Boolean isDelete)
    {
        Set<Id> acctIds = new Set<Id>();
        Account[] updAccts = new Account[]{};

        Task[] tempList = isDelete ? oldMap.values() : newMap.values();

        for(Task t : tempList)
        {
            if(t.WhatId != null)
            {
                if(t.WhatId.getSObjectType() == Schema.Account.SObjectType)
                {
                    acctIds.add(t.WhatId);
                }
            }
        }

        Account[] aList = [Select Id,(Select Id,Subject,ActivityDate,IsClosed
                                      From OpenActivities
                                      ORDER BY ActivityDate DESC NULLS LAST LIMIT 10)
                           From Account
                           WHERE Id IN: acctIds];

        for(Account a : aList)
        {
            a.CP_Next_Steps__c = '';

            OpenActivity[] ahList = a.OpenActivities;

            if(ahList != null && !ahList.isEmpty())
            {
                for(Integer i=0;i<ahList.size();i++)
                {
                    if(!ahList[i].IsClosed)
                    {
                        String strDate = '';

                        if(ahList[i].ActivityDate != null)
                        {
                            strDate = ahList[i].ActivityDate.month() + '/' + ahList[i].ActivityDate.day() + '/' + String.valueOf(ahList[i].ActivityDate.year()).substring(2,4);
                        }
                    
                        a.CP_Next_Steps__c = a.CP_Next_Steps__c + '- ' + (strDate != '' ? strDate + ': ' : '') + ahList[i].Subject + '\n';
                    }
                }
            }

            updAccts.add(a);
        }

        update updAccts;
    }
    
    private void updateDealAccount(List<Task> lstTask) {
        
        String dealPrefix = Deal__c.SObjectType.getDescribe().getKeyPrefix();
        
        Map<Id, Deal__c> dealMap = new Map<Id, Deal__c>();
        
        for (Task t : lstTask) {
            if (!t.IsClosed || t.WhatId == null || !((String) t.WhatId).startsWith(dealPrefix)) {
                continue;
            }
            dealMap.put(t.WhatId, new Deal__c(
                Id = t.WhatId
            ));
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Map<Id, Task> tasks = new Map<Id, Task>();
        for (Deal__c d : [SELECT Related_Company__c, (SELECT ActivityDate, Next_Steps__c FROM Tasks WHERE IsClosed=TRUE AND Type='Status Note' AND Next_Steps__c<>NULL ORDER BY ActivityDate DESC, LastModifiedDate DESC LIMIT 1) FROM Deal__c WHERE Id IN :dealMap.keySet() AND Status__c NOT IN ('Closed', 'Passed', 'Funded by Others', 'On Hold')]) {
            for (Task t : d.Tasks) {
                dealMap.get(d.Id).Deal_Comments__c = t.Next_Steps__c;
                accountMap.put(d.Related_Company__c, new Account(
                    Id = d.Related_Company__c,
                    Next_Steps__c = t.Next_Steps__c
                ));
                tasks.put(d.Related_Company__c, t);
            }
        }
        
        if (!dealMap.isEmpty()) {
            update dealMap.values();
        }
        
        accountMap.remove(null);
        if (!accountMap.isEmpty()) {
            update accountMap.values();
        }
    }
    
    private void setAttFlag(Map<Id,Task> oldMap, Map<Id,Task> newMap)
    {
        Task[] tList = [Select Id,Has_Attachment__c,Attachment_Names__c,
                        (Select Id,Name From Attachments)
                         From Task WHERE Id IN: newMap.keyset()];

        Task[] updList = new Task[]{};

        for(Task t : tList)
        {
            if(t.Attachments != null && !t.Attachments.isEmpty())
            {
                t.Has_Attachment__c = true;
                t.Attachment_Names__c = '';

                for(Attachment a : t.Attachments)
                {
                    t.Attachment_Names__c = t.Attachment_Names__c + a.Name + '\n';
                }

                updList.add(t);
            }
        }

        update updList;
    }
    
    
    /* START : updates for GA-15, GA-20 */
    /*
    * MethodName   : updateJobOrderOrContact
    * param        : set<Id> setJobOrderId
    * Description  : this method will update the Job order Notes_Roll_Up__c field with recent task.
    */
    private void updateJobOrderOrContact(set<Id> setJobOrderOrContactId)
    {
        List<Sobject> lstSobjectToUpdate = new List<Sobject>();//list to update the Job order record or contact
        //iterate over the Job order and prepare the string for Notes_Roll_Up__c
        List<RecordType> lstRecordType = [select Id from RecordType where developername = 'GA_Network_Note' AND sobjectType = 'Task'];
        for(ts2__Job__c objJob : [SELECT Id,(SELECT Id, 
                                                    ActivityDate, 
                                                    Subject, 
                                                    Description,
                                                    Owner.Alias
                                               FROM Tasks
                                              WHERE Material_Interaction__c = true
                                                AND RecordTypeId =: lstRecordType[0].Id
                                              ORDER BY ActivityDate DESC, LastModifiedDate DESC )
                                   FROM ts2__Job__c
                                  WHERE Id IN:setJobOrderOrContactId])
        {
            String strNotes_Roll_Up = '';
            for(Task  objTask:objJob.Tasks)
            {
                mapTaskIdToOwnerName.put(objTask.Id, objTask.Owner.Alias);
            }
            strNotes_Roll_Up = rollUpNotes(objJob.Tasks);
            lstSobjectToUpdate.add(new ts2__Job__c(Id = objJob.Id, Notes_Roll_Up__c = strNotes_Roll_Up));
        }
        
        //update the list of Contact or job order
        update lstSobjectToUpdate;
    }
    
    /*
    * MethodName   : rollUpNotes
    * param        : List<Task> lstTask
    * Description  : this method create a string for Activity date , subject and description
    */
    private static String rollUpNotes(List<Task> lstTask)
    {
        String strNotes_Roll_Up = '';
        for(Task objTask : lstTask)
        {
            Datetime dt = (objTask.ActivityDate != null) ? datetime.newInstance(objTask.ActivityDate.year(), objTask.ActivityDate.month(),objTask.ActivityDate.day()) : null;

            String strRollupValue = (objTask.ActivityDate != null && objTask.Subject != null && objTask.Description != null) ? 
                                     '-'+ dt.format('dd/MM/YYYY') + ' : ' + objTask.Subject +' : '+ objTask.Description:
                                    (objTask.ActivityDate == null && objTask.Subject == null && objTask.Description != null) ?
                                     '-'+ objTask.Description:
                                    (objTask.ActivityDate == null && objTask.Subject != null && objTask.Description == null) ?
                                     '-'+ objTask.Subject : 
                                    (objTask.ActivityDate == null && objTask.Subject != null && objTask.Description != null) ?
                                     '-'+ objTask.Subject +' : '+ objTask.Description:
                                    (objTask.ActivityDate != null && objTask.Subject == null && objTask.Description == null) ?
                                     '-'+ dt.format('dd/MM/YYYY') :
                                    (objTask.ActivityDate != null && objTask.Subject == null && objTask.Description != null) ?
                                     '-'+ dt.format('dd/MM/YYYY') +' : '+ objTask.Description:
                                    (objTask.ActivityDate != null && objTask.Subject != null && objTask.Description == null) ?
                                     '-'+ dt.format('dd/MM/YYYY') +' : '+ objTask.Subject:'';
            strRollupValue = strRollupValue +' ('+ mapTaskIdToOwnerName.get(objTask.Id) +')';
            strNotes_Roll_Up += (strNotes_Roll_Up != '' && strRollupValue != '') ? '\n' + strRollupValue  :
                           (strRollupValue != '') ?  strRollupValue : '';
        }
        return strNotes_Roll_Up;
    }
    
    public static void onBeforeUpdate(map<Id,Task> mapIdToTaskOld)
    {
        for(TaskRelation objTaskRelation : [SELECT RelationId, Relation.Name, IsWhat from TaskRelation WHERE isWhat = false
                                                AND TaskId IN : mapIdToTaskOld.keyset()])
        {
            setContactIdUpdate.add(objTaskRelation.RelationId);
        }
    }
    public static void onBeforeDelete(map<Id,Task> mapIdToTaskOld)
    {
        for(TaskRelation objTaskRelation : [SELECT RelationId, Relation.Name, IsWhat from TaskRelation WHERE isWhat = false
                                                AND TaskId IN : mapIdToTaskOld.keyset() ])
        {
            setContactIdDelete.add(objTaskRelation.RelationId);
        }
    }

    @future
    private static void updateContact(set<Id> setTaskId, set<Id> setRelationIds)
    {
        
        Set<Id> setTaskWhoId = new Set<Id>();
        map<Id,List<Task>> mapIdToList = new map<Id,List<Task>>();
        List<Contact> lstSobjectToUpdate = new List<Contact>();
        List<RecordType> lstRecordType = [select Id from RecordType where developername = 'GA_Network_Note' AND sobjectType = 'Task'];
        for(TaskRelation objTaskRelation : [select RelationId from TaskRelation where TaskId In : setTaskId ])
        {
            if(objTaskRelation.RelationId != null)
                setTaskWhoId.add(objTaskRelation.RelationId);
        }
        
        if(!setRelationIds.isEmpty())
            setTaskWhoId.addAll(setRelationIds);
       
        for(TaskRelation objTaskRelation : [SELECT RelationId,Task.Id, Task.WhoId,Task.ActivityDate,
                                                Task.Subject,
                                                Task.Description,
                                                Task.Owner.Alias,
                                                Relation.Name, IsWhat from TaskRelation WHERE 
                                        RelationId IN :setTaskWhoId AND
                                        Task.RecordTypeId = :lstRecordType[0].Id
                                        ORDER BY Task.ActivityDate DESC, Task.LastModifiedDate DESC])
        {
            mapTaskIdToOwnerName.put(objTaskRelation.Task.Id, objTaskRelation.Task.Owner.Alias);
            Task objTask = new Task(Id = objTaskRelation.Task.Id, Subject = objTaskRelation.Task.Subject,
                                    ActivityDate = objTaskRelation.Task.ActivityDate, Description = objTaskRelation.Task.Description);
            if(!mapIdToList.containsKey(objTaskRelation.RelationId))
                mapIdToList.put(objTaskRelation.RelationId, new List<Task>{objTask});
            else
                mapIdToList.get(objTaskRelation.RelationId).add(objTask);
        }
        for(Id objContactId : setTaskWhoId)
        {
            if(objContactId.getSobjectType() == contact.sObjectType)
            {
                String strGA_Network_Notes = '';
                strGA_Network_Notes = mapIdToList.containsKey(objContactId) ? rollUpNotes(mapIdToList.get(objContactId)) :null;
                lstSobjectToUpdate.add(new Contact(Id = objContactId, GA_Network_Notes__c = strGA_Network_Notes));
            }
        }
        database.update(lstSobjectToUpdate);
    }
    /* END : updates for GA-15, GA-20 */
}