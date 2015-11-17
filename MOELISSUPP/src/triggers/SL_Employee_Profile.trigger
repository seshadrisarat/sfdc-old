/*Trigger on Employee_Profile__c
* Trigger Name  : SL_Employee_Profile
* JIRA Ticket   : Moelis-116
* Created on    : 19/11/2013
* Created by    : Rahul Majumdar
* Jira ticket   :  http://silverline.jira.com/browse/Moelis-117
* Description   :  //Updating fields on User if corresponding fields have been changed on related Employee 
*/
trigger SL_Employee_Profile on Employee_Profile__c (after insert, after update) 
{
    // initialize the handler class Sl_Deal_Handler
    SL_EmployeeHandler handler = new SL_EmployeeHandler(Trigger.isExecuting, Trigger.size);
    
    // called on After Insert of Deal record. 
    if(Trigger.isInsert && Trigger.isAfter)
    {
        if(SL_RecursionHelper.getisInsert())
        {
            SL_RecursionHelper.setisInsert(false);
            handler.onAfterInsert(Trigger.NewMap); 
        }
    }
    // called on After Update of Deal record. 
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        if(SL_RecursionHelper.getisUpdate())
        {
            SL_RecursionHelper.setisUpdate(false);
            handler.onAfterUpdate( Trigger.NewMap,Trigger.OldMap);
        }
    }
}