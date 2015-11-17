/** 
* \author Vladimir Prishlyak
* \date 10/26/2012
* \see https://silverline.jira.com/browse/WP-43
* \details LAST UPDATED BY AND DATE ARE UPDATED WHEN THERE IS A REAL CHANGE IN EMG PARAGRAPH 
* \
*/
trigger SL_EMS_Paragraph on EMG_Paragraph__c (before insert, before update)
{
    SL_handler_EMS_Paragraph handler = new  SL_handler_EMS_Paragraph(Trigger.isExecuting, Trigger.size);
     
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