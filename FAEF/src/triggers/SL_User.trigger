/**
 * @Author		: Jared Kass
 * @ClassName   : SL_User
 * @CreatedOn   : 29 Dec 2014
 * @Test		: 
 * @Description : This is the trigger for the User object.
 */
trigger SL_User on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SL_TriggerFactory.createTriggerDispatcher(User.sObjectType);
}