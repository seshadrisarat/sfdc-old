global class SL_Batch_ConvertActivities implements Database.Batchable<sObject>
{	
	String query;
	Datetime lastRunDate;
	
	global SL_Batch_ConvertActivities()
	{
		lastRunDate = System.now().addMinutes(-15);

		query = 'Select Id,WhatId,WhoId,CallDisposition,CallObject,CallType,'+
               	'Description,ActivityDate,Count_Towards_SLA__c,'+
               	'Priority,Status,Subject,Type,RecurrenceInstance,'+
               	'RecurrenceMonthOfYear,RecurrenceTimeZoneSidKey,'+
               	'RecurrenceType,OwnerId,ReminderDateTime,'+
               	'RecurrenceEndDateOnly,RecurrenceStartDateOnly,'+
               	'Import_ID__c,Import_Text__c,(Select Id From Attachments) '+
               	'From Task '+
               	'WHERE CreatedDate >:lastRunDate';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope)
   	{
   		Task[] tempList = (Task[])scope;

   		List<Note__c> lstNote = new List<Note__c>();// list to hold the note records that need to be inserted.
      map<Id,Id> acctContMap = new map<Id,Id>();
      Set<Id> cIds = new Set<Id>();
      map<Id,Set<Id>> taskAttMap = new map<Id,Set<Id>>();
      Attachment[] attListMstr = new Attachment[]{};

      for(Task t : tempList)
      {
        if(t.WhoId != null)
        {
          cIds.add(t.WhoId);
        }

        if(!t.Attachments.isEmpty())
        {
          Set<Id> attIds = new Set<Id>();

          for(Attachment a : t.Attachments)
          {
            attIds.add(a.Id);
          }

          taskAttMap.put(t.Id,attIds);
        }
      }

      Account[] aList = [Select Id,PersonContactId From Account WHERE PersonContactId IN: cIds];

      for(Account a : aList)
      {
        acctContMap.put(a.PersonContactId,a.Id);
      }

        for(Task objTask : tempList)
        {
            if(objTask.Type!='To Do')
            {
                Id acctId;
                Id relGrpId;

                if(objTask.WhatId!=null)
                {
                  if(objTask.WhatId.getSobjectType() == Account.getSobjectType())
                  {
                    acctId = objTask.WhatId;
                  }else if(objTask.WhatId.getSobjectType() == Relationship_Group__c.getSobjectType())
                  {
                    relGrpId = objTask.WhatId;
                  }
                }

                if(objTask.WhatId == null && objTask.WhoId != null)
                {
                  acctId = acctContMap.get(objTask.WhoId);
                }

                lstNote.add(new Note__c(Account_Del__c = acctId,
                                        CallObject__c = objTask.CallObject, CallDisposition__c = objTask.CallDisposition,
                                        Relationship_Group__c = relGrpId,
                                        CallType__c = objTask.CallType, Description__c = objTask.Description, ActivityDate__c = objTask.ActivityDate,
                                        Count_Towards_SLA__c = objTask.Count_Towards_SLA__c, Import_ID__c = objTask.Id, Import_Text__c = objTask.Import_Text__c,
                                        Priority__c = objTask.Priority, Status__c = objTask.Status, Subject__c = objTask.Subject, Subject_Text__c = objTask.Subject,
                                        Type__c = objTask.Type, RecurrenceInstance__c = objTask.RecurrenceInstance, RecurrenceMonthOfYear__c = objTask.RecurrenceMonthOfYear,
                                        RecurrenceTimeZoneSidKey__c = objTask.RecurrenceTimeZoneSidKey, RecurrenceType__c = objTask.RecurrenceType, OwnerId = objTask.OwnerId,
                                        ReminderDateTime__c = objTask.ReminderDateTime, RecurrenceEndDateOnly__c = objTask.RecurrenceEndDateOnly, RecurrenceStartDateOnly__c = objTask.RecurrenceStartDateOnly,
                                        Create_Joiner_Records__c = true));
            }
        }

        insert lstNote;

        for(Note__c n : lstNote)
        {
          if(taskAttMap.containsKey(n.Import_ID__c))
          {
            Attachment[] attList = [Select Id,Name,Body
                                    From Attachment
                                    WHERE Id IN: taskAttMap.get(n.Import_ID__c)];

            for(Attachment a : attList)
            {
              a.Id = null;
              a.ParentId = n.Id;
            }

            attListMstr.addAll(attList);
          }
        }

        Task[] delList = new Task[]{};

        for(Task t : tempList)
        {
          if(t.Type != 'To Do')
          {
            delList.add(t);
          }
        }

        insert attListMstr;

        delete delList;
	}
	
	global void finish(Database.BatchableContext BC)
	{
		
	}
	
}