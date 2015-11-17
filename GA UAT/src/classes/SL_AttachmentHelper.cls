/**  
* \arg ClassName        : SL_AttachmentHelper
* \arg JIRATicket       : 
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : 
* \arg ModifiedBy       : 
* \arg Description      : Helper class
*/
public with sharing class SL_AttachmentHelper
{

	/*BEGIN PROPERTIES*/

	/*END PROPERTIES*/

	/***************************************************
	*	SHARED METHODS    					   		   *
	***************************************************/

	public static void setAttFlagOnActivity(map<Id,sObject> oldMap, map<Id,sObject> newMap, Boolean isDelete)
	{
		Attachment[] attList = isDelete ? (Attachment[]) oldMap.values() : (Attachment[]) newMap.values();
		Set<Id> tIds = new Set<Id>();
		Set<Id> eIds = new Set<Id>();
		//map<Id,Set<String>> tAttNameMap = new map<Id,Set<String>>();
		//map<Id,Set<String>> eAttNameMap = new map<Id,Set<String>>();

		for(Attachment a : attList)
		{
			if(a.ParentId.getSobjectType() == Schema.Task.SObjectType)
			{
				tIds.add(a.ParentId);

				/*if(tAttNameMap.containsKey(a.ParentId))
				{
					tAttNameMap.get(a.ParentId).add(a.Name);
				}else
				{
					tAttNameMap.put(a.ParentId, new Set<String>{a.Name});
				}*/
			}

			if(a.ParentId.getSobjectType() == Schema.Event.SObjectType)
			{
				eIds.add(a.ParentId);

				/*if(eAttNameMap.containsKey(a.ParentId))
				{
					eAttNameMap.get(a.ParentId).add(a.Name);
				}else
				{
					eAttNameMap.put(a.ParentId, new Set<String>{a.Name});
				}*/
			}
		}

		Task[] tList = [Select Id,Has_Attachment__c,Attachment_Names__c,
					   (Select Id,Name From Attachments)
						From Task
						WHERE Id IN: tIds];

		Event[] eList = [Select Id,Has_Attachment__c,Attachment_Names__c,
						(Select Id,Name From Attachments)
					   	 From Event
					   	 WHERE Id IN: eIds];

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
			}else
			{
				t.Has_Attachment__c = false;
				t.Attachment_Names__c = '';
			}
		}

		for(Event e : eList)
		{
			if(e.Attachments != null && !e.Attachments.isEmpty())
			{
				e.Has_Attachment__c = true;
				e.Attachment_Names__c = '';

				for(Attachment a : e.Attachments)
				{
					e.Attachment_Names__c = e.Attachment_Names__c + a.Name + '\n';				
				}
			}else
			{
				e.Has_Attachment__c = false;
				e.Attachment_Names__c = '';
			}
		}

		if(SL_TaskHandler.runOnce())
		{
			update tList;
		}

		if(SL_EventHandler.runOnce())
		{
			update eList;
		}

	}
    
    public static void setCurrentResume(map<Id,sObject> oldMap, map<Id,sObject> newMap)
    {
        Set<Id> contIds = new Set<Id>();
        Attachment[] attList = (Attachment[]) newMap.values();
        
        for(Attachment a : attList)
        {
            if(a.ParentId.getSobjectType() == Schema.Contact.SObjectType)
            {
                contIds.add(a.ParentId);
            }
        }
        
        Contact[] cList = [Select Id,Most_Recent_Resume__c,
                           (Select Id From Attachments WHERE (Name Like '%resume%' OR Name LIKE '%.pdf') ORDER BY CreatedDate DESC LIMIT 1)
                           From Contact
                           WHERE (RecordType.Name = 'Candidate' OR GA_Talent_Bank__c = true) AND Id IN: contIds];
        
        for(Contact c : cList)
        {
            if(c.Attachments != null && !c.Attachments.isEmpty())
            {
                c.Most_Recent_Resume__c = System.Url.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + c.Attachments[0].Id;
			}else
            {
                c.Most_Recent_Resume__c = System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + c.Id;
            }
        }
        
        update cList;
    }

	/***************************************************
	*	BEFORE INSERT METHODS    					   *
	***************************************************/

	/***************************************************
	*	BEFORE UPDATE METHODS    					   *
	***************************************************/

	/***************************************************
	*	BEFORE DELETE METHODS    					   *
	***************************************************/

	/***************************************************
	*	AFTER INSERT METHODS    					   *
	***************************************************/

	public static void afterInsert(map<Id,sObject> newMap)
	{
		setAttFlagOnActivity(null, newMap, false);
        setCurrentResume(null, newMap);
	}

	/***************************************************
	*	AFTER UPDATE METHODS    					   *
	***************************************************/

	public static void afterUpdate(map<Id,sObject> oldMap,map<Id,sObject> newMap)
	{
		setAttFlagOnActivity(oldMap, newMap, false);
        setCurrentResume(oldMap, newMap);
	}

	/***************************************************
	*	AFTER DELETE METHODS    					   *
	***************************************************/

	public static void afterDelete(map<Id,sObject> oldMap,map<Id,sObject> newMap)
	{
		setAttFlagOnActivity(oldMap, newMap, true);
        setCurrentResume(oldMap, newMap);
	}

	/***************************************************
	*	AFTER UNDELETE METHODS    					   *
	***************************************************/

}