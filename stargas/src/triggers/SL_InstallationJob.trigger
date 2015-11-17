/**  
* \arg ClassName      : SL_InstallationJob
* \arg JIRATicket     : STARGAS-45
* \arg CreatedOn      : 5/NOV/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Sanath
* \arg ModifiedBy     : -
* \arg Description    : -
*/
trigger SL_InstallationJob on Installation_Job__c (before update) 
{
	if(Trigger.isUpdate)
	{
		if(Trigger.isBefore)
			SL_InstallationJobHandler.onBeforeUpdate(Trigger.new);
	}
}