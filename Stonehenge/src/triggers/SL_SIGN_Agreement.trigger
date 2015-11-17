/**
 
* \author Shailendra
 
* \date 02/07/2012
 
* \see http://silverline.jira.com/browse/STONEPII-97
 
* \brief SL_SIGN_Agreement_Trigger_Handler handler. Runs onAfterInsert, onAfterUpdate to update the status of Opportunity satge based on Agreement status.
 
* \test 
 
*/

trigger SL_SIGN_Agreement on echosign_dev1__SIGN_Agreement__c (after insert, after update) 
{
    // Initialize Class - SL_SIGN_Agreement_Trigger_Handler.
    SL_SIGN_Agreement_Trigger_Handler handler = new SL_SIGN_Agreement_Trigger_Handler(Trigger.isExecuting, Trigger.size);
      
    // Called on AfterInsert.
    if(trigger.IsInsert)
    {
        if(trigger.IsAfter)
        {
            handler.OnAfterInsert(trigger.new);
        }
    }
     
    // Called on AfterUpdate. 
    if(trigger.IsUpdate)
    {
        System.debug('=============== UPDATE =====>>>==========');
        if(trigger.IsAfter)
        {
            handler.OnAfterUpdate(trigger.oldMap,trigger.newMap);
        }
    }  
}