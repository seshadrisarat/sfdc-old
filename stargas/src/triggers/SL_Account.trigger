/**
* \arg ClassName      : SL_Account
* \arg JIRATicket     : STARGAS-25
* \arg CreatedOn      : 29/Aug/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This trigger is used to associate all service contract records related to source client account with inserted Account where record type is Prospect
*/
trigger SL_Account on Account (after insert) 
{
	SL_AccountHandler objAccounthandler = new SL_AccountHandler();
	if(Trigger.isAfter )
	{
		if(Trigger.isInsert)
			objAccounthandler.onAfterInsert(Trigger.new);
	}
}