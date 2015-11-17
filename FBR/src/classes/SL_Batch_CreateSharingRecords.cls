/**
* \arg ClassName        : SL_Batch_CreateSharingRecords
* \arg JIRATicket     	: FBR-2
* \arg CreatedOn      	: 20/MAR/2015
* \arg LastModifiedOn   : -
* \arg CreatededBy    	: Pankaj Ganwani
* \arg LastModifiedBy	: -
*/
global with sharing class SL_Batch_CreateSharingRecords implements Database.Batchable<Sobject>
{
	//start method of batch
	global Database.Querylocator start(Database.BatchableContext bc)
	{
		return Database.getQueryLocator('SELECT Related_Deal__c, FBR_Team_Member__r.User__c FROM Deal_Team_Member__c WHERE FBR_Team_Member__r.User__c!=null AND Status__c =\'Active\'');
	}
	
	//Execute method which calls createdealsharingrecords of util class
	global void execute(Database.BatchableContext BC, List<Deal_Team_Member__c> lstDealTeamMember)
	{
		SL_Util_CreateSharingRecords.createDealSharingRecords(lstDealTeamMember);
	}
	
	global void finish(Database.BatchableContext BC)
	{
		//Do Nothing
	}
}