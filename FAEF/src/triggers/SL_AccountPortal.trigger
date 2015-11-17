/**
 * @Author		: Jared Kass
 * @ClassName   : SL_AccountPortal
 * @CreatedOn   : 29 Dec 2014
 * @Test		: 
 * @Description : This is the trigger for the Account Portal object.
 */
trigger SL_AccountPortal on Account_Portal__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SL_TriggerFactory.createTriggerDispatcher(Account_Portal__c.sObjectType);
}