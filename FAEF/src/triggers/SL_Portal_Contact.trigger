/**
 * @Author		: Jared Kass
 * @ClassName   : SL_Portal_Contact
 * @CreatedOn   : 29 Dec 2014
 * @Test		: 
 * @Description : This is the trigger for the Portal Contact object.
 */
trigger SL_Portal_Contact on Portal_Contact__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SL_TriggerFactory.createTriggerDispatcher(Portal_Contact__c.sObjectType);
}