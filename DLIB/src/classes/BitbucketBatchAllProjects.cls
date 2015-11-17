/**
 * \author Julia Kolesnik
 * \date Jul 18, 2014
 * \see https://silverline.jira.com/browse/SLFF-42
 * \brief The Batchable class to sync all  BitBucket commits with Salesforce
 */
global class BitbucketBatchAllProjects implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

	global String sProjectName, sNextEndpoint;
	global Integer sStatusCode;

	global BitbucketBatchAllProjects( String sProject, String sNextEndpoint ) {
		this.sProjectName = sProject;
		this.sNextEndpoint = sNextEndpoint;
	}

	global Database.QueryLocator start( Database.BatchableContext oContext ) {
		string query = 'SELECT Id, JIRA_Project_Name__c, IsCommitRefreshed__c FROM pse__Proj__c WHERE JIRA_Project_Name__c!=null AND IsCommitRefreshed__c=false limit 1';
		if (this.sProjectName != '') {
			query = 'SELECT Id, JIRA_Project_Name__c, IsCommitRefreshed__c FROM pse__Proj__c WHERE JIRA_Project_Name__c = \'' + this.sProjectName + '\' limit 1';
		}
		return Database.getQueryLocator( query );
	}

	global void execute( Database.BatchableContext oContext, List<pse__Proj__c> scope ) {

		if (scope.size()>0) {
			this.sProjectName = scope[0].JIRA_Project_Name__c.toLowerCase();

			BitbucketCommits.createSFCommits( this.sProjectName, sNextEndpoint );
			this.sStatusCode = BitbucketRequest.statusCode;

			if ( Test.isRunningTest() && this.sNextEndpoint == BitbucketBatchTest.sStop ) {
	            BitbucketRequest.nextEndpoint = BitbucketBatchTest.sStop;
	        }
	        
			this.sNextEndpoint = BitbucketRequest.nextEndpoint;

			if (!scope[0].IsCommitRefreshed__c) {
				scope[0].IsCommitRefreshed__c = true;
				update scope;
			}
		} else {
			this.sProjectName = '';
		}
	}

	global void finish( Database.BatchableContext oContext ) {
		if ( this.sNextEndpoint != null ) {
			if ( Test.isRunningTest() && this.sNextEndpoint == BitbucketBatchTest.sStart ) {
				this.sNextEndpoint = BitbucketBatchTest.sStop;
			}
			Database.executeBatch( new BitbucketBatchAllProjects( this.sProjectName, this.sNextEndpoint ) );
		} else {
			if (this.sProjectName!='') {
				for (pse__Proj__c item:[Select Id, JIRA_Project_Name__c, IsCommitRefreshed__c, IsRefreshSucceeded__c FROM pse__Proj__c WHERE JIRA_Project_Name__c=:this.sProjectName limit 1]) {
					item.IsCommitRefreshed__c = true;
					if (this.sStatusCode==200) item.IsRefreshSucceeded__c = true;
					update item;
				}

				Database.executeBatch(new BitbucketBatchAllProjects('', null));
			}
		}
	}
}