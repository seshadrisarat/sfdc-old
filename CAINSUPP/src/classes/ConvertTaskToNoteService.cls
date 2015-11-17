/*****
    Hourly Scheduling: System.schedule('TaskToCaseService', '0 0 * * * ?', new ConvertTaskToNoteService() );
    One-Time Execution: database.executebatch(new ConvertTaskToNoteService(),1);
*****/ 
global without sharing class ConvertTaskToNoteService implements Database.Batchable<sObject>,Schedulable {

    string prefixAccount = '001';
    string prefixContact = '003';
    
    /* Batchable Methods */
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator([select id, Subject, Description, WhoId, WhatId, OwnerId
											from Task 
											where Task_To_Note_Processed__c = false
                                            and CreatedDate >= 2014-05-01T00:00:00Z]);
												 	
    }  

    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	
        // pull the task record for processing
        Task t = ((list<Task>)scope)[0];
        
        // extract all account and contact relationships
        set<id> setRelationshipIds = new set<id>();
        if (t.WhatId!=null && string.valueOf(t.WhatId).startsWith(this.prefixAccount)) setRelationshipIds.add(t.WhatId);
        if (t.WhoId!=null && string.valueOf(t.WhoId).startsWith(this.prefixContact)) setRelationshipIds.add(t.WhoId);
        for(TaskRelation tr : [select RelationId from TaskRelation where TaskId=:t.Id])
            if(tr.RelationId!=null && string.valueOf(tr.RelationId).startsWith(this.prefixAccount)) setRelationshipIds.add(tr.RelationId);
        for(TaskWhoRelation tr : [select RelationId from TaskWhoRelation where TaskId=:t.Id]) 
            if(tr.RelationId!=null && string.valueOf(tr.RelationId).startsWith(prefixContact)) setRelationshipIds.add(tr.RelationId);
        
        // create the note if relationships exist
        if(!setRelationshipIds.isEmpty()) {
            
            // find the user's default folder, create it if it does not exist
            cpnp__Folder__c folder = null;
            list<cpnp__Folder__c> folders = [select id from cpnp__Folder__c where cpnp__Default__c = true and OwnerId=:t.OwnerId];
            if (folders.size()==0) {
                folder = new cpnp__Folder__c();
                folder.Name = 'My Note Folder';
                folder.OwnerId = t.OwnerId;
                folder.cpnp__Default__c = true;
                insert folder;
            } else folder = folders[0];
            
            
            // generate the note
        	cpnp__Note__c note = new cpnp__Note__c();
            boolean subjectLongerThan80 = t.Subject.length()>80;
			note.Name = subjectLongerThan80 ? t.Subject.left(80) : t.Subject;
            string body = (subjectLongerThan80 ? t.Subject + '/r/n/r/n' : '') + t.Description;
            body = body.replace('/r/n','<br/>');
            body = body.replace('/n/r','<br/>');
            body = body.replace('/r','<br/>');
            body = body.replace('/n','<br/>');
            note.cpnp__Note__c = body;
            note.cpnp__Folder__c = folder.Id;
            insert note;
            
            // create the links
            list<cpnp__Link__c> links = new list<cpnp__Link__c>();
            for(id i : setRelationshipIds) {
                cpnp__Link__c link = new cpnp__Link__c();
                link.cpnp__Note__c = note.Id;
                link.cpnp__LinkToId__c = i;
                links.add(link);
            }
            if(!links.isEmpty()) insert links;
        
        }
        
        // update the task as processed
        t.Task_To_Note_Processed__c = true;
        update t;
        
    }

    global void finish(Database.BatchableContext BC) { }

	/* Schedulable Methods */
	global void execute(SchedulableContext sc) {
      	database.executebatch(new ConvertTaskToNoteService(),1);
    }
    
}