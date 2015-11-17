/*
* Class Name 	: SL_DealHandler
* JIRA Ticket   : Moelis-115
* Created on    : 18/11/2013
* Created by    : Rahul Majumdar
* Jira ticket   :  http://silverline.jira.com/browse/Moelis-115
* Description   : Handler for SL_Deal_trigger trigger (trigger on Ibanking_Project__c)
				//When a Deal record is inserted, insert an Recent_Transaction_Announcements__c record 
				// and When any of the following field is updated on Deal record , update the corresponding field in Recent_Transaction_Announcements__c record .
*/
public without sharing class SL_DealHandler 
{

	/* Start - Local and global variables*/
    private Integer intBatchSize = 0;
    private Boolean isExecuting = false;
    /* stop - Local and global variables*/
	
	//Constructor of the handler
	public SL_DealHandler(Boolean isExecuting, Integer intBatchSize)
    {
		//Intializing the variables
        this.isExecuting = isExecuting;
        this.intBatchSize = intBatchSize;
    }
	
	public void onAfterUpdate(Map<Id, Ibanking_Project__c> mapNewIdToDeal, Map<Id, Ibanking_Project__c> mapOldIdToDeal)
	{
		//Updating the Recent Transaction Announcement records related to Deal
		manageRecentTranAnnouncementRec(mapNewIdToDeal, mapOldIdToDeal);
	}
	
	public void onBeforeDelete(Map<Id, Ibanking_Project__c> mapOldIdToDeal)
	{
		//Updating the Recent Transaction Announcement records related to Deal
		updateRecentTransactionRecords(mapOldIdToDeal);
	}
	
	/** 
	* \author: Rahul Majumdar 
	* \date: 18/11/2013
	* \ http://silverline.jira.com/browse/Moelis-115
	* \Description: When a Deal record is inserted, inserting an Recent_Transaction_Announcements__c record and when any of the following field is updated on Deal record, updating the corresponding field in Recent_Transaction_Announcements__c record. Fields are Project_Code_c, Company_Name__c, Client_Alias__c, Record_Type__c, Product_Type__c, Industry__c , Transaction_Sub_Type__c , Sector__c,Stage__c, Deal_Team_Region_s__c
	*/
	private void manageRecentTranAnnouncementRec(Map<Id, Ibanking_Project__c> mapNewIdToDeal , Map<Id,  Ibanking_Project__c> mapOldIdToDeal)
	{  
		Map<Id, Ibanking_Project__c> mapNewDealIdToDeal = new Map<Id, Ibanking_Project__c>();// The Deal ids where the any of above mentioned fields have been updated
		List<Recent_Transaction_Announcements__c> lstRecentTransactionAnnouncements = new List<Recent_Transaction_Announcements__c>(); // list of Recent_Transaction_Announcements__c records to update		
		
		//Storing all updated Deals into mapNewDealIdToDeal
		if(mapOldIdToDeal != null && !mapOldIdToDeal.isEmpty())
		{
			for(Ibanking_Project__c objDeal :mapNewIdToDeal.values())
			{
				//Comparing with oldmap and storing Deals into mapNewDealIdToDeal if values are changed
				if( objDeal.Client__c != mapOldIdToDeal.get(objDeal.Id).Client__c
				|| objDeal.Expense_Code__c != mapOldIdToDeal.get(objDeal.Id).Expense_Code__c
				|| objDeal.Client_Alias__c != mapOldIdToDeal.get(objDeal.Id).Client_Alias__c 
				|| objDeal.RecordTypeId != mapOldIdToDeal.get(objDeal.Id).RecordTypeId  
				|| objDeal.Product_Type__c != mapOldIdToDeal.get(objDeal.Id).Product_Type__c 
				|| objDeal.Industry__c != mapOldIdToDeal.get(objDeal.Id).Industry__c 
				|| objDeal.Transaction_Type__c != mapOldIdToDeal.get(objDeal.Id).Transaction_Type__c 
				|| objDeal.Transaction_Sub_Type__c != mapOldIdToDeal.get(objDeal.Id).Transaction_Sub_Type__c 
				|| objDeal.Sector__c != mapOldIdToDeal.get(objDeal.Id).Sector__c 
				|| objDeal.Stage__c != mapOldIdToDeal.get(objDeal.Id).Stage__c 
				|| objDeal.Deal_Team_Region_s__c != mapOldIdToDeal.get(objDeal.Id).Deal_Team_Region_s__c  
				|| objDeal.Transaction_Announcement_Date__c != mapOldIdToDeal.get(objDeal.Id).Transaction_Announcement_Date__c
				|| objDeal.Notes_4__c != mapOldIdToDeal.get(objDeal.Id).Notes_4__c
				
				)
				{
					mapNewDealIdToDeal.put(objDeal.Id, objDeal);
				}
			}
		}
		
		//Querying Recent_Transaction_Announcements__c records related to updated Deal records
		if(mapNewDealIdToDeal != null && !mapNewDealIdToDeal.keyset().isEmpty())
		{
			lstRecentTransactionAnnouncements =  [ Select Project_Code__c ,Transaction_Type__c,Transaction_Announcement_Date__c, Announcement_Body__c, Company_Name__c ,Client_Alias__c ,Record_Type__c  ,Product_Type__c ,Industry__c ,
			Transaction_Sub_Type__c, Sub_Sector__c ,Stage__c, Deal_Team_Region_s__c,Deal_RTA__c  
			From Recent_Transaction_Announcements__c 
			where Deal_RTA__c IN: mapNewDealIdToDeal.keyset()];
			
			//Upserting the Recent_Transaction_Announcements__c records
			updateRecentTransactionRecords(mapNewDealIdToDeal, lstRecentTransactionAnnouncements);
			
		}
		
	}
	
	/** 
	* \author: Rahul Majumdar 
	* \date: 18/11/2013
	* \ http://silverline.jira.com/browse/Moelis-115
	* \Description: This is a generic method for updating and inserting transaction records. When a Deal record is inserted, insert an Recent_Transaction_Announcements__c record and When any of the following field is updated on Deal record, update the corresponding field in Recent_Transaction_Announcements__c record. 
	*/
	private void updateRecentTransactionRecords(Map<Id, Ibanking_Project__c> mapNewIdToDeal, List<Recent_Transaction_Announcements__c> lstRecentTransactionAnnouncements)
	{
		List<Recent_Transaction_Announcements__c> lstRecentTransAnnouncementsToUpdate = new List<Recent_Transaction_Announcements__c>();//List of Recent Transaction Announcements records to be upserted 
		Map<Id,RecordType> mapRecordTypeIdToRecordType = new Map<Id,RecordType>(); // Map of Deal's record type id to record type Name
		mapRecordTypeIdToRecordType.putAll( [Select Id,Name from RecordType where sobjectType = 'Ibanking_Project__c' ]);
		
		//For update case when a recent transaction record exists, updating its field values with corresponding field value of parent Deal 
		for(Recent_Transaction_Announcements__c objTransaction : lstRecentTransactionAnnouncements)
		{
			if(objTransaction.Deal_RTA__c != null && mapNewIdToDeal.containsKey(objTransaction.Deal_RTA__c))
			{
				lstRecentTransAnnouncementsToUpdate.add( new Recent_Transaction_Announcements__c(
				Id = objTransaction.Id,
				Project_Code__c = mapNewIdToDeal.get(objTransaction.Deal_RTA__c).Expense_Code__c,
				Company_Name__c = mapNewIdToDeal.get(objTransaction.Deal_RTA__c).Client__c,
				Client_Alias__c = mapNewIdToDeal.get(objTransaction.Deal_RTA__c).Client_Alias__c,
				Record_Type__c = mapNewIdToDeal.get(objTransaction.Deal_RTA__c).RecordTypeId !=null ?mapRecordTypeIdToRecordType.get(mapNewIdToDeal.get(objTransaction.Deal_RTA__c).RecordTypeId).Name:'',
				Product_Type__c = mapNewIdToDeal.get(objTransaction.Deal_RTA__c).Product_Type__c,
				Industry__c = mapNewIdToDeal.get(objTransaction.Deal_RTA__c).Industry__c,
				Transaction_Sub_Type__c = mapNewIdToDeal.get(objTransaction.Deal_RTA__c).Transaction_Sub_Type__c ,
				Transaction_Type__c = mapNewIdToDeal.get(objTransaction.Deal_RTA__c).Transaction_Type__c ,
				Sub_Sector__c = mapNewIdToDeal.get(objTransaction.Deal_RTA__c).Sector__c,
				Stage__c = mapNewIdToDeal.get(objTransaction.Deal_RTA__c).Stage__c,
				Deal_Team_Region_s__c = mapNewIdToDeal.get(objTransaction.Deal_RTA__c).Deal_Team_Region_s__c,
				Transaction_Announcement_Date__c = MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Transaction_Announcement_Date__c,
				Announcement_Body__c =  MapNewIdToDeal.get(objTransaction.Deal_RTA__c).Notes_4__c));
			}
		}
		
		//Upserting the Recent Transaction Announcement records stored in  lstRecentTransAnnouncementsToUpdate list
		if(lstRecentTransAnnouncementsToUpdate != null && !lstRecentTransAnnouncementsToUpdate.isEmpty())
			Database.Update(lstRecentTransAnnouncementsToUpdate, false);
	}
	
	/** 
	* \author: Rahul Majumdar 
	* \date: 18/11/2013
	* \ http://silverline.jira.com/browse/Moelis-115
	* \Description: This is a method for updating transaction records. When a Deal record is Deleted, update an Recent_Transaction_Announcements__c record. 
	*/
	private void updateRecentTransactionRecords(Map<Id, Ibanking_Project__c> mapOldIdToDeal)
	{
		List<Recent_Transaction_Announcements__c> lstRecentTransactionAnnouncements = new List<Recent_Transaction_Announcements__c>(); // list of Recent_Transaction_Announcements__c records to update
		List<Recent_Transaction_Announcements__c> lstRecentTransAnnouncementsToUpdate = new List<Recent_Transaction_Announcements__c>();//List of Recent Transaction Announcements records to be upserted 
		Map<Id,RecordType> mapRecordTypeIdToRecordType = new Map<Id,RecordType>(); // Map of Deal's record type id to record type Name
		
		mapRecordTypeIdToRecordType.putAll( [Select Id,Name from RecordType where sobjectType = 'Ibanking_Project__c' ]);
		
		lstRecentTransactionAnnouncements =  [ Select Project_Code__c ,Transaction_Type__c,Transaction_Announcement_Date__c, Announcement_Body__c, Company_Name__c ,Client_Alias__c ,Record_Type__c  ,Product_Type__c ,Industry__c ,
											   Transaction_Sub_Type__c, Sub_Sector__c ,Stage__c, Deal_Team_Region_s__c,Deal_RTA__c  
											   From Recent_Transaction_Announcements__c 
			                                   where Deal_RTA__c IN : mapOldIdToDeal.keyset()];
			                                   
		//For update case when a recent transaction record exists, updating its field values with corresponding field value of parent Deal 
		for(Recent_Transaction_Announcements__c objTransaction : lstRecentTransactionAnnouncements)
		{
			if(objTransaction.Deal_RTA__c != null && mapOldIdToDeal.containsKey(objTransaction.Deal_RTA__c))
			{
				lstRecentTransAnnouncementsToUpdate.add( new Recent_Transaction_Announcements__c(
				Id = objTransaction.Id,
				Project_Code__c = null,
				Company_Name__c = null,
				Client_Alias__c = null,
				Record_Type__c = '',
				Product_Type__c = null,
				Industry__c = null,
				Transaction_Sub_Type__c = null,
				Transaction_Type__c = null,
				Sub_Sector__c = null,
				Stage__c = null,
				Deal_Team_Region_s__c = null,
				Transaction_Announcement_Date__c = null,
				Announcement_Body__c =  null));
			}
		}
		
		//Upserting the Recent Transaction Announcement records stored in  lstRecentTransAnnouncementsToUpdate list
		if(lstRecentTransAnnouncementsToUpdate != null && !lstRecentTransAnnouncementsToUpdate.isEmpty())
			Database.Update(lstRecentTransAnnouncementsToUpdate, false);
	}
}