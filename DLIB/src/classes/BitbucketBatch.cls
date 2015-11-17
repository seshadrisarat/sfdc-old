/**
 * \author Vladimir Dobrelya
 * \date Mar 2, 2014
 * \see https://silverline.jira.com/browse/SLFF-46
 * \brief The Batchable class to sync BitBucket commits with Salesforce
 */
global class BitbucketBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

	global String sProjectName, sNextEndpoint;

	global BitbucketBatch( String sProject, String sNextEndpoint ) {
		this.sProjectName = sProject;
		this.sNextEndpoint = sNextEndpoint;
	}

	global Database.QueryLocator start( Database.BatchableContext oContext ) {
		return Database.getQueryLocator( 'SELECT Id, JIRA_Project_Name__c FROM pse__Proj__c WHERE JIRA_Project_Name__c = \'' + this.sProjectName + '\' limit 1' );
	}

	global void execute( Database.BatchableContext oContext, List<pse__Proj__c> scope ) {
		BitbucketCommits.createSFCommits( sProjectName, sNextEndpoint );
		if ( Test.isRunningTest() && this.sNextEndpoint == BitbucketBatchTest.sStop ) {
            BitbucketRequest.nextEndpoint = BitbucketBatchTest.sStop;
        }
		this.sNextEndpoint = BitbucketRequest.nextEndpoint;
	}

	global void finish( Database.BatchableContext oContext ) {
		if ( this.sNextEndpoint != null ) {
			if ( Test.isRunningTest() && this.sNextEndpoint == BitbucketBatchTest.sStart ) {
				this.sNextEndpoint = BitbucketBatchTest.sStop;
			}
			Database.executeBatch( new BitbucketBatch( this.sProjectName, this.sNextEndpoint ) );
		}
	}
}