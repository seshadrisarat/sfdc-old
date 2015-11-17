/**
* \arg ClassName      : SL_InvestorContact
* \arg JIRATicket     : OAKHILL-10
* \arg CreatedOn      : 08/OCT/2014
* \arg LastModifiedOn : 08/OCT/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This trigger is used to make inactive those Fund of interest records for which contact and fund is same as that of inserted investor contact's contact and related account respectively.
*/
trigger SL_InvestorContact on Investor_Contact__c (after insert) 
{
	SL_InvestorContactHandler objInvestorContactHandler = new SL_InvestorContactHandler();
	if(Trigger.isAfter && Trigger.isInsert)
		objInvestorContactHandler.onAfterInsert(Trigger.newMap);
}