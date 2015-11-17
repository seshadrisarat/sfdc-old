/*
 * \author Vladimir Dobrelya
 * \date Feb 7, 2014
 * \see https://silverline.jira.com/browse/SLFF-18
 */
global class psaBatchProjectRefresh implements Database.Batchable<sObject> {
	
	global psaBatchProjectRefresh() { }
	
	global Database.QueryLocator start( Database.BatchableContext BC ) {
		return Database.getQueryLocator( 'SELECT Id FROM pse__Proj__c WHERE pse__Is_Active__c = true' );
	}

   	global void execute( Database.BatchableContext BC, List<sObject> aScope ) {
		psaProjectRefesh.psaRefreshProject( getIds( aScope ) );
	}
	
	global void finish( Database.BatchableContext BC ) { }
	
	private static Set<ID> getIds( List<sObject> aObjects ) {
		Set<ID> aResult = new Set<ID>();
		for ( sObject oItem : aObjects ) {
			aResult.add( oItem.Id );
		}
		return aResult;
	}
}