/**
* \arg ClassName      : SL_OpportunityHandler
* \arg JIRATicket     : FAEF-4
* \arg CreatedOn      : 10/09/2013
* \arg CreatedBy      : Rahul 
* \arg ModifiedBy     : Lodhi
* \arg Description    : This is the handler class for opportunity trigger.
*/
public without sharing class SL_OpportunityHandler 
{
	private static boolean OpptyHandlerHasRun = false;
	//Constructor of handler class
	public SL_OpportunityHandler()
	{
		//Do nothing
	}
	
	
	/*!
        * MethodName : onAfterInsert
        * param      : Opportunity object's trigger.new values.
        * Description: This is the method that will be called on after insert of opportunity. This method calls createSobjectRecords method 
                        on SL_MappingTrigger_Handler class.
    */
	public void onAfterInsert(List<Opportunity> lstNewOpportunity)
	{
		if(!OpptyHandlerHasRun)
		{
			OpptyHandlerHasRun = true;
			Map<Id, Opportunity> mapIdToOpportunity = new Map<Id, Opportunity>(); /// create a map to put the filter opportunity records
			
			/// Grab the required opportunities
			for(Opportunity oppty:lstNewOpportunity)
			{
				if(((oppty.StageName == 'Approved') || (oppty.StageName == 'Awarded')) && 
					oppty.Opp_is_approved__c)
				{
					mapIdToOpportunity.put(oppty.Id, oppty);
				}
			}
			updateAccountMLN(mapIdToOpportunity);
			callMethodToCreateSobjectRecord(mapIdToOpportunity);
		}
	}
	
	/*!
        * MethodName : onAfterUpdate
        * param      : Opportunity object's trigger.newMap values and trigger.oldMap values.
        * Description: This is the method that will be called on after update of opportunity.This method calls createSobjectRecords method 
                       on SL_MappingTrigger_Handler class.
    */
	public void onAfterUpdate(Map<Id,Opportunity> mapNew, Map<Id,Opportunity> mapOld)
	{
		if(!OpptyHandlerHasRun)
		{
			OpptyHandlerHasRun = true;
			Map<Id, Opportunity> mapIdToOpportunity = new Map<Id, Opportunity>(); /// create a map to put the filter opportunity records
			
			/// Grab the required opportunities
			for(Id oppId : mapNew.keyset())
			{
				if(mapNew.get(oppId).Opp_is_approved__c == true &&
				   mapOld.get(oppId).Opp_is_approved__c == false &&
				   (mapNew.get(oppId).StageName == 'Approved' || mapNew.get(oppId).StageName == 'Awarded')
				  )
				{
					mapIdToOpportunity.put(oppId, mapNew.get(oppId));
				}
			}
			updateAccountMLN(mapIdToOpportunity);
			callMethodToCreateSobjectRecord(mapIdToOpportunity);
		}
	}
	
	/*!  
        * MethodName : callMethodToCreateSobjectRecord
        * param      : List of the filter Opportunity records to create the Sobject records on the basis of the Mapping object records. 
        * Description: This method is used to create the records on basis of the Mapping Sobject records.
    */
    private void callMethodToCreateSobjectRecord(Map<Id, Opportunity> mapIdToOpportunity)
    {
		if(!mapIdToOpportunity.isempty())
		{
			SL_MappingTrigger_Handler objMappingTriggerHandler = new SL_MappingTrigger_Handler();
			/// call createSobjectRecords method
			objMappingTriggerHandler.createSobjectRecords(mapIdToOpportunity,'Opportunity');
		}
    }
    private void updateAccountMLN(Map<Id, Opportunity> mapIdToOpportunity)
    {
		if(!mapIdToOpportunity.isempty())
		{
			// get a list of all the accounts that we might need to update.
			Set<Id> acctIds = new Set<Id>();
			for(Opportunity oppty : mapIdToOpportunity.values()){
				acctIds.add(oppty.AccountId);
			}
			Map<Id,Account> allAccounts = new Map<Id,Account>([Select Id, Master_Lease_Number__c from Account WHERE Id IN : acctIds]);

			// init a string to hold this years YYYY value in a string;
			// init a string to search for;
			// init a list of accounts to update.
			// init an integer to hold the latest # of accounts this year.
			// Get the latest account with a MLN from this year. 
			String thisYearString = String.valueOf(Datetime.Now().year());
			system.debug(LoggingLevel.ERROR,'thisYearString: ' +thisYearString);

			String thisYearSearchString = thisYearString + '%';
			List<Account> acctsToUpdate = new List<Account>();
			Integer thisYearsLatestInt = 0;
			List<Account> thisYearsAccts = new List<Account>([SELECT Id, Master_Lease_Number__c 
															 		FROM Account 
															 		WHERE Master_Lease_Number__c != null AND 
															 			  Master_Lease_Number__c LIKE :thisYearSearchString]);
			System.debug('========thisYearsAccts======'+thisYearsAccts.size());
			for(Account acc : thisYearsAccts)
			{
				String accMLNIndexString = String.valueof(acc.Master_Lease_Number__c).substringAfterLast(thisYearString);
				accMLNIndexString = accMLNIndexString.replaceAll('-', '').replaceAll(',', '').replaceAll(' ', '');
				Integer accMLNIndex = (accMLNIndexString == null?0:Integer.valueOf(accMLNIndexString));

				if(accMLNIndex > thisYearsLatestInt)
				{
					thisYearsLatestInt = accMLNIndex;
					system.debug(LoggingLevel.ERROR,'accMLNIndex: ' +accMLNIndex);
				}
			}

			// Loop through all the accounts that need to get updated,
			// add them to a

			for(Id accId : acctIds)
			{
				if(allAccounts.containsKey(accId) && allAccounts.get(accId).Master_Lease_Number__c == null)
				{
					acctsToUpdate.add(new Account(Id=accId,Master_Lease_Number__c=thisYearString + zeroFillInteger(thisYearsLatestInt + 1)));
					thisYearsLatestInt += 1;
				}
			}

			if(!acctsToUpdate.isEmpty())
				update acctsToUpdate;

			//system.debug(LoggingLevel.ERROR,'MLN: ' + String.valueof(thisYearsLatestAcct[0].Master_Lease_Number__c));
			//system.debug(LoggingLevel.ERROR,'MLN after year:' + String.valueof(thisYearsLatestAcct[0].Master_Lease_Number__c).substringAfterLast(thisYearString));
			//system.debug(LoggingLevel.ERROR,'typecasted MLN after year:' + Integer.valueOf(String.valueof(thisYearsLatestAcct[0].Master_Lease_Number__c).substringAfterLast(thisYearString)));
			//system.debug(LoggingLevel.ERROR,'thisYearsLatestIntZeroFilled' + thisYearsLatestIntZeroFilled);
		}
	}
	private String zeroFillInteger(Integer myInt)
	{
		String over99  = '';
		String under100 = '0';
		String under10  = '00';

		String outputString = String.valueOf(0);

		if(myInt > 0)
			outputString = (myInt > 9?(myInt > 99?over99:under100):under10) + String.valueOf(myInt);

		return outputString;
	}
}