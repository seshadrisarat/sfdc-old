/** 
* \author Vlad Gumenyuk 
* \date 10/09/2012
* \see https://silverline.jira.com/browse/WP-2
* \ Trigger on Contact after update to create Former Employee record
* \details Additional 
* \ Contact Trigger After Update:
* \ After a Contact is saved, if the Account field has been changed, this trigger will create a Former_Employee_c record.
* \ The mapping for the Former_Employee_c will be as follows:
* \ Account__c = Trigger.Old.Account
* \ Contact__c = Contact.ID
* \ End_Date__c = TODAY
* \ Title__c = Trigger.Old.Title
* \ 
* \ NOTE: This is the same functionality as in https://silverline.jira.com/browse/GTCR-2
*/

public without sharing class SL_handler_Contact
{
   private boolean m_isExecuting = false;
   private integer BatchSize = 0;
   private static boolean isFillIndexedFieldsInsRun = false;
   private static boolean isFillIndexedFieldsUpdRun = false;
   private static boolean isCreatedFormerEmployee = false;

   public SL_handler_Contact(boolean isExecuting, integer size)
   {
       m_isExecuting = isExecuting;
       BatchSize = size;
   }

    public void OnBeforeInsert(list<Contact> newlist_Contacts){ }

    public void OnAfterInsert(map<ID,Contact> newmap_Contacts)
    {
    	setRelatedContactUser(newmap_Contacts.values(), false); //WP-34
    } 
     
    @future public static void OnAfterInsertAsync(Set<ID> new_Contact_IDs){ }
     
    public void OnBeforeUpdate(map<ID,Contact> oldmap_Contacts, map<ID,Contact> newmap_Contacts){ }
     
    public void OnAfterUpdate(map<ID,Contact> oldmap_Contacts, map<ID,Contact> newmap_Contacts)
    { 
    	
    	//OnAfterUPdateAsync2(oldmap_Contacts, newmap_Contacts);
    	setRelatedContactUser(newmap_Contacts.values(), false); //WP-34
    	setDealWPSeniorTeamMemberGroup(oldmap_Contacts, newmap_Contacts );
    	//return;
       system.debug('!!!!!!!!!!!!!! OnAfterUpdate');
       if(!isCreatedFormerEmployee)
       {
           isCreatedFormerEmployee = true;
           system.debug('!!!!!!!!!!!!!! isCreatedFormerEmployee');
           CreateFormerEmployee(oldmap_Contacts, newmap_Contacts);
       }

    }
    
    @future public static void OnAfterUpdateAsync(Set<ID> updated_Contact_IDs){ }
     
    public void OnBeforeDelete(map<ID,Contact> oldmap_Contacts)
    {
    	setRelatedContactUser(oldmap_Contacts.values(), true); //WP-34
    }
     
    public void OnAfterDelete(map<ID,Contact> oldmap_Contacts){ }
     
    @future public static void OnAfterDeleteAsync(Set<ID> deleted_Contact_IDs){ }
     
    public void OnUndelete(list<Contact> restored_Contacts){ }
             
    public boolean IsTriggerContext{ get{ return m_isExecuting;} }
     
    public boolean IsVisualforcePageContext{ get{ return !IsTriggerContext;} }
     
    public boolean IsWebServiceContext{ get{ return !IsTriggerContext;} }
     
    public boolean IsExecuteAnonymousContext{ get{ return !IsTriggerContext;} }   
    
    private void setRelatedContactUser(list<Contact> newContacts, boolean isClearOnly)
    {
    	Id contactEmployeeRTId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1].Id;
    	
    	map<Id,Id> mapUserId_ContactId = new map<Id,Id> ();
    	set<ID> serContactIDs = new set<ID>();
    	
    	for(Contact item : newContacts)
    	{
    		serContactIDs.add(item.ID);
    		if(item.User_ID__c  != null && item.RecordTypeId == contactEmployeeRTId && item.Status__c == 'Active') mapUserId_ContactId.put(item.User_ID__c,item.Id);
    	}
    	
    	map<ID,User> users2Update = new map<ID, User>();
    	User tmp;
    	for(User item:[select ID,Related_Contact_Id__c from User where Related_Contact_Id__c in :serContactIDs limit 1000])
    	{
    		tmp = new User(Id = item.ID);
    		tmp.Related_Contact_Id__c = null;
    		users2Update.put(tmp.ID,tmp); 
    	}
    	
    	if(!isClearOnly && mapUserId_ContactId.keySet().size() > 0)
    	{
	    	
	    	
	    	String tmpStr = '';
	    	for(Id uId : mapUserId_ContactId.keySet())
	    	{
	    		tmp = new User(Id = uId);
    			tmp.Related_Contact_Id__c = mapUserId_ContactId.get(uId);
    			users2Update.put(tmp.ID,tmp); 
	    	}
    	}
    	
    	if(users2Update.size() > 0)
    	{
    		List<User> lst2Upd = new List<User>();
    		for(User item:[Select IsActive, Id From User where IsActive=true and Id in :users2Update.keySet() limit 1000])
    		{
    			lst2Upd.add(users2Update.get(item.id));
    		}
    		if(lst2Upd.size()>0) update lst2Upd;
    	}
    }
    
    private void setDealWPSeniorTeamMemberGroup(map<ID,Contact> oldmap_Contacts, map<ID,Contact> newmap_Contacts) 
    {
    	SL_handler_Deal_Team dt_handler = new SL_handler_Deal_Team(false, Trigger.size);
    	Set<Id> set_contact_ids = new Set<Id>(); 
    	    
    	for(Contact item : newmap_Contacts.values())
    	{
    		//Only update the team member if the precedence, employee level or group has changed
    		if((item.Employee_Level__c != oldmap_Contacts.get(item.id).Employee_Level__c) ||
    		  // (item.Employee_Level_Precedence__c != oldmap_Contacts.get(item.id).Employee_Level_Precedence__c) ||
    		   (item.WP_Group__c != oldmap_Contacts.get(item.id).WP_Group__c) ||
    		   (item.Status__c != oldmap_Contacts.get(item.id).Status__c)    		   
    		   )
    		{	
    			set_contact_ids.add(item.Id);
    		}
    	}
    
    	SL_Handler_Deal_Team.updDealWPSeniorTeamMemberByUserAsync(set_contact_ids);
    }
/*
* \ Contact Trigger After Update:
* \ After a Contact is saved, if the Account field has been changed, this trigger will create a Former_Employee_c record.
* \ The mapping for the Former_Employee_c will be as follows:
* \ Account__c = Trigger.Old.Account
* \ Contact__c = Contact.ID
* \ End_Date__c = TODAY
* \ Title__c = Trigger.Old.Title
*/
   private static void CreateFormerEmployee(map<Id,Contact> oldContacts, map<Id,Contact> newContacts)
   {
       if(!newContacts.isEmpty())
       {
               List<Former_Employee__c> list_FormerEmployeeToCreate = new List<Former_Employee__c>();
                for(Id contactId : newContacts.KeySet())
                {      
                        if(oldContacts.get(contactId).AccountId != null && newContacts.get(contactId).AccountId != oldContacts.get(contactId).AccountId)
                        {
                                Former_Employee__c newFormerEmployee = new Former_Employee__c();
                                        newFormerEmployee.Company__c = oldContacts.get(contactId).AccountId;
                                        newFormerEmployee.Contact__c = contactId;
                                        newFormerEmployee.End_Date__c = Date.today();
                                      if(oldContacts.get(contactId).Title != null)
                                        newFormerEmployee.Title__c = oldContacts.get(contactId).Title;
                                list_FormerEmployeeToCreate.add(newFormerEmployee);
                        }
                }
                
                if(list_FormerEmployeeToCreate.size() > 0) insert list_FormerEmployeeToCreate;
       }
   }

}