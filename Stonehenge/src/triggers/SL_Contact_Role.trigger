/**
 
* \author Rahul Sharma
 
* \date 22/06/2011
 
* \see http://silverline.jira.com/browse/STONEPII-1
 
* \brief SL_Contact_Role: Avoid Duplicate Contact Role for a Opportunity (i.e. - with same Opportunity, Contact and Role)
 
* \test 
 
*/

trigger SL_Contact_Role on Contact_Role__c (before insert, before update)
{
    //    Initialize Class - SL_Contact_Role_Trigger_Handler handler
    SL_Contact_Role_Trigger_Handler handler = new SL_Contact_Role_Trigger_Handler(Trigger.isExecuting, Trigger.size);  
    if(trigger.IsInsert)
    {
        if(trigger.IsBefore)
        {
            set<Id> setParentIds = new set<Id>();
            //    Call OnBeforeInsert
            for(Contact_Role__c cr : Trigger.new)
            {
            	setParentIds.add(cr.Contact__c);
            }
            handler.OnBeforeInsert(trigger.new, setParentIds);
        }
    }
     
    else if(trigger.IsUpdate)
    {
        if(trigger.IsBefore)
        {
            //    Call OnBeforeUpdate
            handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
    }  
    /** Modify trigger
	* @JIRATicket   : STONEPII-100
	* @CreatedOn    : 16/july/12
	* @ModifiedBy   : SL
	*/
    //Update the Email of Contact Role with related Person Account Email.
    SL_ChangeContactRoleEmailAddressHandler objHandler = new SL_ChangeContactRoleEmailAddressHandler();
	objHandler.onInsertAndUpdate(Trigger.new); 
}