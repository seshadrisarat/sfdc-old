/*
*Trigger: SL_VerifyPartnerUserAndShareAccountContactRecords
*Description: Trigger to enable sharing of Account and Contact for Gold Partner users on creation of Users
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_VerifyPartnerUserAndShareAccountContactRecords on User (after insert) 
{
	SL_VerifyPartnerUserAndShareRecords objHandler = new SL_VerifyPartnerUserAndShareRecords();
	
	if(Trigger.isAfter && Trigger.isInsert)
	{
		// Call verifyPartnerUSerAndShareAccountContactRecords method
		// objHandler.verifyPartnerUSerAndShareAccountContactRecords(Trigger.newMap);  
	} 
}