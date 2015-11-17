/**
 * On an Account, when ProspectStatus is set to 'Qualified Prospect' or 'Contact',
 * on either an insert or an update, 
 * set the respective prospective communication date, 
 * to start the 90-day and 180-day timers.
 * See also: NU_TaskProspectCommunication.tigger, NU_90DayProspectTime, NU_180DayProspectTimer.
 * @author thusted@nimbluser.com   
 **/
trigger NU_AccountProspectDate on Account (before insert, before update) {
	private Date TODAY = Date.today();

	for (Account a : Trigger.new)
	{
		// System.debug(LoggingLevel.ERROR,'**** ACCOUNT LOOP BEGINS ****');
		boolean isQP = false;
		boolean isCP = false;
		if (Trigger.isInsert)
		{
			isQP = (NU.QUALIFIED_PROSPECT == a.Prospect_Status__c);
			isCP = (NU.CONTACT == a.Prospect_Status__c);
			// System.debug(LoggingLevel.ERROR,'**** INS ' + setQP + ', ' + setCP);
		}
		else if (Trigger.isUpdate)
		{			
			Account beforeUpdate = Trigger.oldMap.get(a.Id);
			isQP = (NU.QUALIFIED_PROSPECT != beforeUpdate.Prospect_Status__c) && (NU.QUALIFIED_PROSPECT == a.Prospect_Status__c);
			isCP = (NU.CONTACT != beforeUpdate.Prospect_Status__c) && (NU.CONTACT == a.Prospect_Status__c);
			// System.debug(LoggingLevel.ERROR,'**** UPD ' + setQP + ', ' + setCP);
		}		
		if (isQP) 
		{
			a.QualifiedProspectDate__c = TODAY;
			// System.debug(LoggingLevel.ERROR,'**** QP ' + a.QualifiedProspectDate__c);
		}
		if (isCP) 
		{
			a.ContactLastContactDate__c = TODAY;
			// System.debug(LoggingLevel.ERROR,'**** CP ' + a.ContactLastContactDate__c);
		}
		// System.debug(LoggingLevel.ERROR,'**** LOOP ENDS ****');	
	}	
}