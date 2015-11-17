/**
* @TriggerName 	: SL_UpdateAccountEmailAddress 
* @JIRATicket   : STONEPII-100
* @CreatedOn    : 16/july/12
* @ModifiedBy   : SL
* @Description  : This is the trigger before update on Account.
*/

trigger SL_UpdateAccountEmailAddress on Account (after update) 
{
	SL_UpdateAccountEmailAddressHandler objHandler = new SL_UpdateAccountEmailAddressHandler();
	objHandler.onBeforeUpdate(Trigger.newMap);
}