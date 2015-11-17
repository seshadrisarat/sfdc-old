/**
*  Class Name     : SL_Batch_ServiceLease
*  JIRATicket     : THOR-68
*  CreatedOn      : 10/July/2015
*  ModifiedBy     : SANATH
*  Description    : one time script for backfilling Maintenance Cases with Lease records
*/
global class SL_Batch_ServiceLease implements Database.Batchable<sObject> {
	
	global static Id MAINTANENCE_CASE_ID = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND  DeveloperName = 'Maintenance_Request'].Id;
	
	 /*
        @MethodName : start   
        @param      : Database.BatchableContext BC
        @Description: Collects all Maintanenece cases created after 2/25/2015 for backfilling Leases
    */

	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
        Date dtTargetDate = Date.newInstance(2015, 2, 26);
		String query = 'Select Id,CreatedDate,Apartment__c from Case where Apartment__c!=null AND Lease__c = null AND RecordTypeId=\'' + MAINTANENCE_CASE_ID + '\' AND CreatedDate >= :dtTargetDate';
		return Database.getQueryLocator(query);
	}

	/*
        @MethodName : execute   
        @param      : Database.BatchableContext BC , List<Case>
        @Description: Backfilles Cases with thier appropriate Leases
    */

   	global void execute(Database.BatchableContext BC, List<Case> scope) 
   	{
        List<Lease__c> lstLease = new List<Lease__c>();
        List<Case> lstCasesToUpdateLease = new List<Case>();
        map<Id , Case> mapIdToCase = new map<Id , Case>(); 
        set<Id> setApartmentId = new set<Id>();

        for(Case objCase : scope)
        {
        	setApartmentId.add(objCase.Apartment__c);
        }
        for(Lease__c objLease : [SELECT Id,Start_Date__c,End_Date__c,Apartment__c From Lease__c where Apartment__c IN:setApartmentId])
        {
            lstLease.add(objLease);
        }
        mapIdToCase = new map<Id , Case>(scope);
        if(!lstLease.isEmpty())
            for(Case objCase : scope)
            {
	            for(Lease__c objLease : lstLease)
	            {
	                if(objLease.Start_Date__c <= mapIdToCase.get(objCase.Id).CreatedDate && objLease.End_Date__c >= mapIdToCase.get(objCase.Id).CreatedDate && objCase.Apartment__c == objLease.Apartment__c)
	                {
	                    objCase.Lease__c = objLease.Id;
	                    objCase.Lease_Start_Date__c = objLease.Start_Date__c;
	                    lstCasesToUpdateLease.add(objCase);
	                    break;
	                }
	            }
            }
        if(!lstCasesToUpdateLease.isEmpty())
            upsert lstCasesToUpdateLease;
	}
	
	/*
        @MethodName : finish   
        @param      : Database.BatchableContext BC 
        @Description: 
    */

	global void finish(Database.BatchableContext BC) 
	{
		//Do Nothing	
	}
	
}