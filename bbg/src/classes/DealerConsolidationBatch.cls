public class DealerConsolidationBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable
{
	public static final String BATCH_NAME = 'Dealer Consolidation Re-Proccessing Batch';
	public static final String BASE_QUERY = 'SELECT Id, RecordTypeId, Consolidated_To_Dealer_Number__c, Consolidated_To_Dealer_Datetime__c FROM Account WHERE Re_Process_Consolidation__c = true AND RecordTypeId = :VALID_RECORD_TYPE';
	public static final List<String> ERROR_EMAILS = new List<String>{ 'jay.jackson@bluewolfgroup.com', 'jheston@bluewolfgroup.com', Label.DC_Batch_Email };
	
	public static final Id VALID_RECORD_TYPE = DealerServices.DEALER_RECORD_TYPE_ID;

	private String query;
	public String errors = '';
	public DealerConsolidationBatch()
	{
		query = BASE_QUERY;
	}
	
	public void execute( SchedulableContext sc )
	{
		DealerConsolidationBatch batch = new DealerConsolidationBatch();
		Database.executeBatch( batch );
	}
	
	public Database.QueryLocator start( Database.BatchableContext BC )
	{
		return Database.getQueryLocator( query );
	}
	
	public void execute( Database.BatchableContext BC, List<sObject> scope)
	{
		List<Account> castedScope = (List<Account>)scope;
		Set<Id> accountsWithErrors = Pluck.ids( DealerServices.consolidateDealer(castedScope) );
		
		List<Account> successfulAccountsToUpdate = new List<Account>();
		for( Account act : castedScope )
		{
			if( !accountsWithErrors.contains( act.Id ) )
			{
				act.Re_Process_Consolidation__c = false;
				successfulAccountsToUpdate.add( act );
			}
		}
		
		Database.SaveResult[] resultList = Database.update( successfulAccountsToUpdate, false );
		//Get Accounts that have errors so we can append them to the list
		if( resultList != null ){
			for( Database.SaveResult sr : resultList ){
				if( !sr.isSuccess() )
					accountsWithErrors.add( sr.getId() );
			}
		}
		
		errors += String.join( new List<Id>(accountsWithErrors), ', ' );
	}
		
	public void finish( Database.BatchableContext BC )
	{
		AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
							JobItemsProcessed, TotalJobItems,
							CreatedBy.Email
							FROM AsyncApexJob
							WHERE Id =:bc.getJobId()];
	
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
		mail.setToAddresses( ERROR_EMAILS );
		mail.setSubject( 'Batch to ' + BATCH_NAME + ' ' + job.Status );
		
		String emailBody = 'Batch to ' + BATCH_NAME + ' processed '
						  + job.TotalJobItems
						  + ' batches with '
						  + job.NumberOfErrors
						  + ' failures.';
		if( errors != '' )
		{
			emailBody += '\n\n\nThe following Accounts had errors:\n'+ errors;
		}
		
		mail.setPlainTextBody( emailBody );
		if( job.NumberOfErrors > 0 || !String.isBlank( errors ) )
			Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );
	}
}