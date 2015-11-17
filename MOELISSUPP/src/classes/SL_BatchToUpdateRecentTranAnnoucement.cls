/*
* Class Name    : SL_BatchToUpdateRecentTranAnnoucement
* JIRA Ticket   : Moelis-119
* Created on    : 20/1/2014
* Created by    : Sruti
* Jira ticket   : http://silverline.jira.com/browse/Moelis-119
* Description   : It updates existing Recent_Transaction_Announcements__c records in sync with Deal records
*/
global without sharing class SL_BatchToUpdateRecentTranAnnoucement implements Database.Batchable<Sobject>
{
    /*  Start : Constructor */
    public SL_BatchToUpdateRecentTranAnnoucement( )   
    { 
    }

    /*
        @MethodName : start 
        @param      : Database.BatchableContext BC
        @Description: Queries the RecentTransactionAnnouncement records 
    */
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        string strQuery = 'select Id, Name, Project_Code__c, Company_Name__c, Client_Alias__c, Record_Type__c, Product_Type__c, Industry__c, Transaction_Sub_Type__c, Transaction_Type__c, Sub_Sector__c, Stage__c, Deal_Team_Region_s__c, Transaction_Announcement_Date__c, Announcement_Body__c, Deal_RTA__c'+
        ' From Recent_Transaction_Announcements__c ' ;
        return Database.getQueryLocator(strQuery);
    }
    
        /*
        @MethodName : execute 
        @param      : Database.BatchableContext BC, List<Recent_Transaction_Announcements__c> lstTransaction
        @Description: Processes the RecentTransactionAnnouncement records recieved from the Start method in batches
    */
    global void execute(Database.BatchableContext BC, List<Recent_Transaction_Announcements__c> lstTransaction)
    {
        manageRecentTranAnnouncementRec(lstTransaction); 
    }
    
	/** 
	* \author: Sruti srivastava
	* \date: 20/1/2014
	* \ http://silverline.jira.com/browse/Moelis-119
	* \Description://Syncing to fields on Recent Transaction Announcement records with the related Deal 
	*/
	private void manageRecentTranAnnouncementRec(List<Recent_Transaction_Announcements__c> lstTransaction)
	{  
		Map<Id, Ibanking_Project__c> MapNewIdToDeal = new Map<Id, Ibanking_Project__c>();// The Deal ids to Deal object to be used in Mapping
		Set<Id> setDeals = new Set<Id>(); //Set of related Deal Ids, used in Mapping the values 
		Map<Id, RecordType> MapRecordTypeIdToRecordType = new Map<Id, RecordType>(); // Map of Deal's record type id to record type Name
		MapRecordTypeIdToRecordType.putAll( [Select Id, Name from RecordType where sobjectType = 'Ibanking_Project__c' ]);
		List<Recent_Transaction_Announcements__c> lstRecentTransactionAnnToUpdate = new List<Recent_Transaction_Announcements__c>();
		//Storing all updated Deals into MapNewIdToDeal
		for(Recent_Transaction_Announcements__c objTransaction :lstTransaction)
		{
			//Comparing with oldMap and storing Deals into setDeals
			if(objTransaction.Deal_RTA__c != null )
			{
				setDeals.add(objTransaction.Deal_RTA__c);
			}
		}
		//Query all required fields for Mapping from Deal object
		if(!setDeals.isEmpty())
			MapNewIdToDeal.putAll([Select Id, Expense_Code__c, Transaction_Announcement_Date__c, Notes_4__c, Client__c, Client_Alias__c, RecordTypeId, Product_Type__c, 
								Industry__c, Transaction_Sub_Type__c, Transaction_Type__c, Sector__c, Stage__c, Deal_Team_Region_s__c
					From Ibanking_Project__c where Id In: setDeals]);
		//Syncing to fields on Recent Transaction Announcement records with the related Deal
		for(Recent_Transaction_Announcements__c objTransaction : lstTransaction)
		{
			// If the transaction is inserted or if the lookup field has updated with some other Deal in case of update
			if( objTransaction.Deal_RTA__c != null && setDeals.contains(objTransaction.Deal_RTA__c) && MapNewIdToDeal.containsKey(objTransaction.Deal_RTA__c))
			{
				objTransaction.Project_Code__c = MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Expense_Code__c;
				objTransaction.Company_Name__c = MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Client__c;
				objTransaction.Client_Alias__c = MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Client_Alias__c;
				objTransaction.Record_Type__c = MapNewIdToDeal.get(objTransaction.Deal_RTA__c).RecordTypeId !=null ? MapRecordTypeIdToRecordType.get(MapNewIdToDeal.get(objTransaction.Deal_RTA__c).RecordTypeId).Name:'';
				objTransaction.Product_Type__c = MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Product_Type__c;
				objTransaction.Industry__c = MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Industry__c;
				objTransaction.Transaction_Sub_Type__c = MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Transaction_Sub_Type__c ;
				objTransaction.Transaction_Type__c = MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Transaction_Type__c;
				objTransaction.Sub_Sector__c = MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Sector__c;
				objTransaction.Stage__c = MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Stage__c;
				objTransaction.Deal_Team_Region_s__c = MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Deal_Team_Region_s__c;
				objTransaction.Transaction_Announcement_Date__c = MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Transaction_Announcement_Date__c;
				objTransaction.Announcement_Body__c =  MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Notes_4__c;
				
				lstRecentTransactionAnnToUpdate.add(objTransaction);
			}
			//Making fields value on Recent Transaction Announcement records as null when no related Deal exist
			else if( objTransaction.Deal_RTA__c == null )
			{
				objTransaction.Project_Code__c = null;
				objTransaction.Company_Name__c = null;
				objTransaction.Client_Alias__c = null;
				objTransaction.Record_Type__c = '';
				objTransaction.Product_Type__c = null;
				objTransaction.Industry__c = null;
				objTransaction.Transaction_Sub_Type__c = null ;
				objTransaction.Transaction_Type__c = null;
				objTransaction.Sub_Sector__c = null;
				objTransaction.Stage__c = null;
				objTransaction.Deal_Team_Region_s__c = null;
				objTransaction.Transaction_Announcement_Date__c = null;
				objTransaction.Announcement_Body__c = null;
				
				lstRecentTransactionAnnToUpdate.add(objTransaction);
			}
		}
		//Updating user records where corresponding fields have been updated on related Employee
        if(!lstRecentTransactionAnnToUpdate.isEmpty())
            database.update(lstRecentTransactionAnnToUpdate,false);
	}
    
    
    /*
        @MethodName : finish 
        @param      : Database.BatchableContext BC
        @Description: Performs the post-execution steps
    */
    global void finish(Database.BatchableContext BC)
    {
        //Do nothing
    }
}