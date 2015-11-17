/*
    @Trigger Name  : SL_Contact 
    @JIRA Ticket   : AEW-12
    @Created on    : 07/02/2015
    @Modified by   : Harsh
    @Description   : Trigger on Contact records
*/
trigger SL_Contact on Contact (before update) {
    // instantiating the object 
    SL_Contact_Handler objHandler = new SL_Contact_Handler();
    
    // calling on Before Update
    if(trigger.isBefore && trigger.Isupdate)
        objHandler.onBeforeUpdate(trigger.oldMap, trigger.newMap);

}