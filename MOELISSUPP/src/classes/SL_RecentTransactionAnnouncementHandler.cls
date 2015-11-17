/*
* Class Name 	: SL_RecentTransactionAnnouncementHandler
* JIRA Ticket   : Moelis-115, Moelis-118
* Created on    : 18/11/2013
* Created by    : Rahul Majumdar
* Modified on    : 4/12/2013
* Modified by    : Sruti Srivastava
* Jira ticket   :  http://silverline.jira.com/browse/Moelis-115, http://silverline.jira.com/browse/Moelis-118
* Description   : Handler for SL_RecentTransactionAnnouncementHandler trigger (trigger on Recent_Transaction_Announcements__c), to Map the value from parent Deal
					// and to insert and update Recent Update records
*/
public without sharing class SL_RecentTransactionAnnouncementHandler  
{

	/* Start - Local and global variables*/
    private Integer intBatchSize = 0;
    private Boolean isExecuting = false;
    /* stop - Local and global variables*/
	
	//Constructor of the handler
	public SL_RecentTransactionAnnouncementHandler(Boolean isExecuting, Integer intBatchSize)
    {
		//Intializing the variables
        this.isExecuting = isExecuting;
        this.intBatchSize = intBatchSize;
    }
	
	public void onBeforeInsert(List<Recent_Transaction_Announcements__c> lstTransaction)
	{
		//Keeping fields on Recent Transaction Announcement records in sync with the related Deal
		manageRecentTranAnnouncementRec(lstTransaction, null);
	}

	public void onBeforeUpdate(List<Recent_Transaction_Announcements__c> lstTransaction, Map<Id, Recent_Transaction_Announcements__c> MapOldTransaction)
	{
		//Keeping fields on Recent Transaction Announcement records in sync with the related Deal
		manageRecentTranAnnouncementRec(lstTransaction, MapOldTransaction);
	}
	
	/*
		@MethodName : onAfterDelete 
		@param 	    : Map<Id, Transaction>
		@Description: This method will call after delete of the Content.
	*/
	public void onAfterDelete(Map<Id, Recent_Transaction_Announcements__c> MapTransactionDeleted)
	{
		//Deleting the list of Recent Updates
		deleteRecentUpdateRecords(MapTransactionDeleted);
	}
		
	/*
        @MethodName : onAfterUpdate 
        @param      : Map Of Id to Transaction
        @Description: Updating the list of Recent Updates
    */
    public void onAfterUpdate(Map<Id, Recent_Transaction_Announcements__c> MapNewTransaction)
    {
    	//Updating the list of Recent Updates
		upsertRecentUpdateRecords(MapNewTransaction, false);      
    }
    /* End */
	
	/*
        @MethodName : onAfterInsert 
        @param      : Map Of Id to Transaction
        @Description: Creating the list of Recent Updates
    */
    public void onAfterInsert(Map<Id, Recent_Transaction_Announcements__c> MapNewTransaction)
    {
    	//Creating the list of Recent Updates
		upsertRecentUpdateRecords(MapNewTransaction, true);      
    }
    /* End */
	
	/*
        @MethodName : deleteRecentUpdateRecords 
        @param      : Map Of Id to Transaction
        @Description: This method will call before delete of the Recent Transaction.
    */
	private void deleteRecentUpdateRecords(Map<Id, Recent_Transaction_Announcements__c> MapNewTransaction)
    {
		List<SLSI__Recent_Updates__c> lstRecentUpdatesToDelete = [SELECT Id FROM SLSI__Recent_Updates__c 
										WHERE SLSI__Related_To__c IN: MapNewTransaction.keyset()]; // Creating list of Recent Data records to delete 
		
    	
        //Deleting the list of Recent Data
        if(lstRecentUpdatesToDelete != null && !lstRecentUpdatesToDelete.isEmpty())
        	Database.delete(lstRecentUpdatesToDelete, false);	
    }
	
	/*
        @MethodName : upsertRecentUpdateRecords 
        @param      : Map Of Id to Transaction, Boolean value to check if its insert 
        @Description: This method will call before delete of the Recent Transaction.
    */
    private void upsertRecentUpdateRecords(Map<Id, Recent_Transaction_Announcements__c> MapNewTransaction, Boolean isInsert)
    {
    	Map<Id, Id> MapTransactionIdToRecentObjectId = new Map<Id, Id>();//Map of Recent Transaction Id to Recent Object Id, for storing existing Recent Data Record  
    	List<SLSI__Recent_Updates__c> lstRecentUpdatesToUpsert = new List<SLSI__Recent_Updates__c>();//List of Recent Data records to be upserted 
    	
    	//Querying existing Recent Update records 
		if(!isInsert)	
    	{
			for(SLSI__Recent_Updates__c objRecentUpdate : [SELECT Id, Name, SLSI__Last_Updated__c, SLSI__Related_To__c FROM SLSI__Recent_Updates__c 
														WHERE SLSI__Related_To__c IN: MapNewTransaction.keyset()])
			{
				MapTransactionIdToRecentObjectId.put(objRecentUpdate.SLSI__Related_To__c, objRecentUpdate.Id);
			}
    	}
		
		//This loop is used to create a list of Recent Update records to upsert
        for(Recent_Transaction_Announcements__c objTransaction : MapNewTransaction.values())
        {
            if(MapTransactionIdToRecentObjectId != null && MapTransactionIdToRecentObjectId.containskey(objTransaction.Id))
            {
            	//Adding Recent Update record to be inserted to the list
            	lstRecentUpdatesToUpsert.add(new SLSI__Recent_Updates__c(Name = objTransaction.Name, SLSI__Sobject_Type__c= 'Recent_Transaction_Announcements__c', 
            				Id= MapTransactionIdToRecentObjectId.get(objTransaction.Id), 
            				SLSI__Last_Updated__c = Datetime.now(), SLSI__Related_To__c= objTransaction.Id));
            }
            else if(MapTransactionIdToRecentObjectId == null || !MapTransactionIdToRecentObjectId.containskey(objTransaction.Id))
            {
            	//Adding Recent Update record to be updated to the list
            	lstRecentUpdatesToUpsert.add(new SLSI__Recent_Updates__c(Name = objTransaction.Name, SLSI__Sobject_Type__c= 'Recent_Transaction_Announcements__c', 
            									SLSI__Last_Updated__c = Datetime.now(), SLSI__Related_To__c= objTransaction.Id));
            }
        }
        
        //Upsertig the list of Recent Data
        if(!lstRecentUpdatesToUpsert.isEmpty())
        	Database.upsert(lstRecentUpdatesToUpsert, false);	
    }
	
	/** 
	* \author: Rahul Majumdar 
	* \date: 18/11/2013
	* \ http://silverline.jira.com/browse/Moelis-115
	* \Description://Syncing to fields on Recent Transaction Announcement records with the related Deal 
	*/
	private void manageRecentTranAnnouncementRec(List<Recent_Transaction_Announcements__c> lstTransaction,  Map<Id, Recent_Transaction_Announcements__c> MapOldTransaction)
	{  
		Map<Id, Ibanking_Project__c> MapNewIdToDeal = new Map<Id, Ibanking_Project__c>();// The Deal ids to Deal object to be used in Mapping
		Set<Id> setDeals = new Set<Id>(); //Set of related Deal Ids, used in Mapping the values 
		Map<Id, RecordType> MapRecordTypeIdToRecordType = new Map<Id, RecordType>(); // Map of Deal's record type id to record type Name
		MapRecordTypeIdToRecordType.putAll( [Select Id, Name from RecordType where sobjectType = 'Ibanking_Project__c' ]);
		
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
			if( objTransaction.Deal_RTA__c != null && 
			( (MapOldTransaction == null && MapNewIdToDeal != null && MapNewIdToDeal.containsKey(objTransaction.Deal_RTA__c ) ) 
			|| (MapOldTransaction != null &&  MapOldTransaction.containsKey(objTransaction.Id) && isFieldUpdated(MapOldTransaction, lstTransaction) ))) 
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
			}
			//Making fields value on Recent Transaction Announcement records as null when no related Deal exist
			else if((MapOldTransaction == null && objTransaction.Deal_RTA__c == null ) || (MapOldTransaction != null &&  
			MapOldTransaction.containsKey(objTransaction.Id) && objTransaction.Deal_RTA__c == null &&
					isFieldUpdated(MapOldTransaction, lstTransaction)))
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
			}
		}
	}
	
	//Chceking whether the fields has been updated, in case of update 
	private boolean isFieldUpdated(Map<Id, Recent_Transaction_Announcements__c> MapOldTransaction, List<Recent_Transaction_Announcements__c> lstTransaction)
	{
		for(Recent_Transaction_Announcements__c objTransaction :lstTransaction)
		{
			if(objTransaction.Id != null &&  (objTransaction.Project_Code__c != MapOldTransaction.get(objTransaction.Id).Project_Code__c
				|| objTransaction.Company_Name__c != MapOldTransaction.get(objTransaction.Id).Company_Name__c
				|| objTransaction.Client_Alias__c != MapOldTransaction.get(objTransaction.Id).Client_Alias__c
				|| objTransaction.Record_Type__c != MapOldTransaction.get(objTransaction.Id).Record_Type__c 
				|| objTransaction.Product_Type__c != MapOldTransaction.get(objTransaction.Id).Product_Type__c
				|| objTransaction.Industry__c != MapOldTransaction.get(objTransaction.Id).Industry__c
				|| objTransaction.Transaction_Sub_Type__c != MapOldTransaction.get(objTransaction.Id).Transaction_Sub_Type__c 
				|| objTransaction.Transaction_Type__c != MapOldTransaction.get(objTransaction.Id).Transaction_Type__c
				|| objTransaction.Sub_Sector__c != MapOldTransaction.get(objTransaction.Id).Sub_Sector__c
				|| objTransaction.Stage__c != MapOldTransaction.get(objTransaction.Id).Stage__c
				|| objTransaction.Deal_Team_Region_s__c != MapOldTransaction.get(objTransaction.Id).Deal_Team_Region_s__c
				|| objTransaction.Transaction_Announcement_Date__c != MapOldTransaction.get(objTransaction.Id).Transaction_Announcement_Date__c
				|| objTransaction.Announcement_Body__c != MapOldTransaction.get(objTransaction.Id).Announcement_Body__c
				|| objTransaction.Deal_RTA__c != MapOldTransaction.get(objTransaction.Id).Deal_RTA__c))
			{
				return true;
			}
			else
			return false;
		}
		return false;
	}
}