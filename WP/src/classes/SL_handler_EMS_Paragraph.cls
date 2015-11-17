/** 
* \author Vladimir Prishlyak
* \date 10/26/2012
* \see https://silverline.jira.com/browse/WP-43
* \details LAST UPDATED BY AND DATE ARE UPDATED WHEN THERE IS A REAL CHANGE IN EMG PARAGRAPH 
* \
*/
public without sharing class SL_handler_EMS_Paragraph
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static boolean updatedByHasRun = false;
    Boolean isTriggerActive = true;
    
    public SL_handler_EMS_Paragraph(boolean isExecuting, integer size)
    {
    	  isTriggerActive = true;
        m_isExecuting = isExecuting;
        BatchSize = size;
        // Task: WP-81
        for(Disable_EMG__c cs_trigger : Disable_EMG__c.getall().values()) if(cs_trigger.Name == 'EMG Paragraph') { if(cs_trigger.Disabled__c) { isTriggerActive = false; } break; }
    } 
    
    public void OnBeforeInsert(list<EMG_Paragraph__c> newItems)
    {
    	 // Task: WP-81
		 if(!updatedByHasRun && isTriggerActive) setUpdatedBy(newItems, null);
	} 
    
	public void OnBeforeUpdate(map<ID,EMG_Paragraph__c> oldMapItems, map<ID,EMG_Paragraph__c> newMapItems)
	{
		  // Task: WP-81
        if(!updatedByHasRun && isTriggerActive) setUpdatedBy(newMapItems.values(),oldMapItems);
	}
	
	private void setUpdatedBy(list<EMG_Paragraph__c> newItems,map<ID,EMG_Paragraph__c> oldMapItems)
   {
      Id uContactId = getLastUpdatedByContact();
      for(EMG_Paragraph__c item : newItems)
      {
         if(oldMapItems==null || !(oldMapItems!=null && ( 
          (oldMapItems.get(item.Id).EMG_Paragraph_Last_Archive_Date__c!=null && item.EMG_Paragraph_Last_Archive_Date__c!=null && oldMapItems.get(item.Id).EMG_Paragraph_Last_Archive_Date__c != item.EMG_Paragraph_Last_Archive_Date__c)
        || (oldMapItems.get(item.Id).EMG_Paragraph_Last_Archive_Date__c!=null && item.EMG_Paragraph_Last_Archive_Date__c==null) 
        || (oldMapItems.get(item.Id).EMG_Paragraph_Last_Archive_Date__c==null && item.EMG_Paragraph_Last_Archive_Date__c!=null)
        ) ) )
         {
            if(item.EMG_Updated_on_behalf_of__c != null)
            {
               System.debug('#### setting UpdateBy to on behalf of value of ' + item.EMG_Updated_on_behalf_of__c + ' and blanking out EMG_Updated_on_behalf_of__c');
               item.EMG_Last_Updated_By__c = item.EMG_Updated_on_behalf_of__c;
               item.EMG_Updated_on_behalf_of__c = null;
            }
            else
            { 
            	System.debug('#### setting UpdateBy to CONTACT value of ' + uContactId);
            	item.EMG_Last_Updated_By__c = uContactId;
            }
            item.EMG_Last_Updated_Date__c = Datetime.now();
            System.debug('#### setting UpdateDate to Now ' + Datetime.now());
         }

      }   	
	  updatedByHasRun = true;
   }
	
    private ID getLastUpdatedByContact()
    {
      ID uContactId = null;
         RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
         Contact uCont = [Select id, RecordTypeId, User_ID__c From Contact where RecordTypeId = :ContRecTypeId.Id AND User_ID__c = :UserInfo.getUserId() limit 1];
         if(uCont != null && uCont.RecordTypeId != null && ContRecTypeId != null && uCont.RecordTypeId == ContRecTypeId.Id)
            uContactId = uCont.Id;
      
      return uContactId;
    }
	
}