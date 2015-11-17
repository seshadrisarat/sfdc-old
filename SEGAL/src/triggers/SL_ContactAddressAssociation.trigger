/**  
*  Trigger Name   : SL_ContactAddressAssociation
*  JIRATicket     : SEGAL-6
*  CreatedOn      : 19/JAN/2015
*  ModifiedBy     : Pradeep
*  Description    : This is the trigger on Contact Address object to ensure there is only one primary Contact Address for contact and the Contact Address which is marked as primary is mapped to contact Mailing address.
*/

trigger SL_ContactAddressAssociation on Contact_Address__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
    // Creating object for handler class
    SL_ContactAddressAssociationHandler objContactAddressHandler = new SL_ContactAddressAssociationHandler();
    //SL_RecursionHelper.setisAfterInsert(true);
    
    // Calling handler class method on after insert of Contact_Address__c
    if(trigger.isAfter && trigger.isInsert)
    {
        if(SL_RecursionHelper.getisAfterInsert())
        {
            SL_RecursionHelper.setisAfterInsert(false);
            objContactAddressHandler.onAfterInsert(trigger.newMap);     
        }   
    }
    
    // Calling handler class method on after update of Contact_Address__c 
    if(trigger.isAfter && trigger.isUpdate)
    {
        if( SL_RecursionHelper.getisAfterInsert() && SL_RecursionHelper.getisAfterUpdate())
        {
            SL_RecursionHelper.setisAfterUpdate(false);
            objContactAddressHandler.onAfterUpdate(trigger.oldMap, trigger.newMap);
        }
    }
    
    // Calling handler class method on after Delete of Contact_Address__c record 
    if(trigger.isAfter && trigger.isDelete)
    {
        objContactAddressHandler.onAfterDelete(trigger.oldMap);
    }
}