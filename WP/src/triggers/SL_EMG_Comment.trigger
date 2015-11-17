/** 
* \author Vladislav Gumenyuk
* \date 03/04/2013
* \see https://silverline.jira.com/browse/WP-70
* \details LAST UPDATED BY AND DATE ARE UPDATED WHEN THERE IS A REAL CHANGE IN EMG COMMENT (identical to EMG_Paragraph object) 
*/
trigger SL_EMG_Comment on EMG_Comment__c (before insert, before update) {
    SL_handler_EMG_Comment handler = new  SL_handler_EMG_Comment(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert)
    {
        if(trigger.IsBefore)
        {
            handler.OnBeforeInsert(Trigger.new);
        }
    }
    else if(trigger.IsUpdate)
    {
        if(trigger.IsBefore)
        {
            handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
        else
        {    
            //handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap );
        }
    }  
     
}