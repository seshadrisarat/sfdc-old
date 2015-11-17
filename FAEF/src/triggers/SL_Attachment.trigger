/**
 * @Author		: Jared Kass
 * @ClassName   : SL_Attachment
 * @CreatedOn   : 19 Feb 2015
 * @Test		: 
 * @Description : This is the trigger for the Attachment object.
 */
trigger SL_Attachment on Attachment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SL_TriggerFactory.createTriggerDispatcher(Attachment.sObjectType);
}