/**
* \arg \b ClassName      : SL_LotHandler
* \arg \b JIRATicket     : FAEF-43
* \arg \b CreatedOn      : 8/10/2014
*/

public with sharing class SL_LotHandler extends SL_Paginator
{
	/* Start - Variables */
	public Lot__c objLot 						{	get;set;	}  // Used to store the Lot record from where page is launched.
	public List<LotWrapper> lstLotWrapper 		{	get;set;	}  // Used to store LotItems and its associated BidItem 
	public Bid__c objBidRecordAssociatedToLot	{	get;set;	}  // Used to store Bid record which was created by Logged in user and associated with current Lot record
	public Decimal decSumOfUnitPriceForAllBids  {   get;set;    } 
	public List<String> lstHeaders			    {	get;set;	}
	
	/* End - Variables */ 

	/* Start - Contructor */

	public SL_LotHandler(ApexPages.StandardController controller)
	{
		initialize(); // Method used to initialize Global Variables.
		Id idOfLotRecord = controller.getId(); // Getting the Cureent Lot__c object record Id from where page is launched.
		
		objLot = [ Select Id,Lot_Item_Count__c
				   from Lot__c where id=:idOfLotRecord];
		
		getBidRecordAsscWithLot(); // Calling this method to query Bid record created by Logged in user and associated with Current LOT record.
		initPagination();
	} 
	
	
	/* End - Constructor */
	
	/*!
      *  @MethodName: initialize
      *  @param None: None.
      *  @Description: This method is use to initalize global members.
    */
	
	private void initialize() 
	{
		lstLotWrapper = new List<LotWrapper>();
		objLot = new Lot__c();
		objBidRecordAssociatedToLot = new Bid__c();
		decSumOfUnitPriceForAllBids = 0.0;
		lstHeaders = new List<String>{'Equipment Name','Qty','Description', 'Bid'};
	}
	
	/*!
      *  @MethodName: initPagination
      *  @param None: None.
      *  @Description: This method will initalize the variables which is required in pagination.
    */
    private void initPagination() 
    {
        page=1;//initally page is 1. 
        
        FirstPage = 0; //first page index is initially 0
        
        TotalRows = lstLotWrapper.size();// total rows to be spanned across pages
        
        PageSize = 2;// no. of rows you want to show per page
        
        LastPage = Math.mod(TotalRows, PageSize) == 0 ? TotalRows / PageSize : TotalRows / PageSize + 1;// calculate the index of last page
            
        noOfPages = Math.mod(TotalRows, PageSize) > 0 ? TotalRows / PageSize + 1 : TotalRows / PageSize;
    }
	
	
	/*!
      *  @MethodName: getBidRecordAsscWithLot
      *  @param None: None.
      *  @Description:  Method used to query Bid record created by Logged in user and associated with Current LOT record 
    */
	
	private void getBidRecordAsscWithLot()
	{
		// Querying the Bid record which was created by Current logged in user and associated with Lot from where page is launched. 
		List<Bid__c> lstBidsAssWithLotCrtdByCurrtUser = [SELECT Id,Status__c
					   		   					   	     FROM Bid__c
					                                     WHERE Lot__c =: objLot.Id AND CreatedById =: UserInfo.getUserId()
					      	                             ORDER BY LastModifiedDate DESC LIMIT 1];
					      	                        
		// If there is any bid record mathes storing in bid object			       
		if(!lstBidsAssWithLotCrtdByCurrtUser.isEmpty())
			objBidRecordAssociatedToLot = lstBidsAssWithLotCrtdByCurrtUser[0];
			
		// Creating new Bid Object record 
		else
			objBidRecordAssociatedToLot = new Bid__c(Lot__c = objLot.Id);	
		
		// Calling method to get all the LotItems and its accociated Bid Items for the Lot record from where page is launched.
		lstLotWrapper = getLotItemWrapper(objLot.Id, objBidRecordAssociatedToLot.Id);
	}
	
	/* Start - Wrapper class for lot */      
	public class LotWrapper 
	{
		public Lot_Item__c lotItem 	{	get;set;	}
		public Bid_Item__c bidItem 	{	get;set;	}
		
		public LotWrapper(Lot_Item__c lotItem)
		{
			this.lotItem=lotItem;
			
			// Checking if there are any BidItems associated with LotItems
			if(!lotItem.Bid_Items__r.isEmpty())
				this.bidItem=lotItem.Bid_Items__r[0];
				
			// If there is no BidItem related to LotItem creating new BidItem for Lot Item 	
			else
				this.bidItem = new Bid_Item__c(	Bid_Item_Unit_Price__c = 0.0, Lot_Item__c = lotItem.Id);
				
			//decSumOfUnitPriceForAllBids = decSumOfUnitPriceForAllBids + this.bidItem.Bid_Item_Unit_Price__c;	
		}
	}
	/* End - Wrapper class for lot */
	
	/*!
      *  @MethodName: getLotItemWrapper
      *  @param None: Lot Id and associated Bid Id.
      *  @Description: This method is used to get all the Lot Items and Bid Items related to Lot Items of the Lot record from where page is launched.
    */
    
	public void upsertBidAndBidItemsassociatedwithLot()
	{
		upsert objBidRecordAssociatedToLot; // If there is no Bid record associated with LOT record creating New Bid record and asscoiating with Lot record.
		
		List<Bid_Item__c> lstBidItemToUpsert = new List<Bid_Item__c>();  // Used to insert or update BidItem records.
		
		// Iterating the LotItems associated with Lot
		for(LotWrapper objLW : lstLotWrapper)
		{
			if(objLW.bidItem.Bid_Item_Unit_Price__c > 0)
			{
				// Checking for newly creating BidItem and associating with Bid record.
				if(objLW.bidItem.Bid__c == null)
				{
					objLW.bidItem.Bid__c=objBidRecordAssociatedToLot.Id;
				}	
				lstBidItemToUpsert.add(objLW.bidItem);
			}
		}
		
		// Upserting BidItems related to LotItems of Lot record.
		if(!lstBidItemToUpsert.isEmpty())
			upsert lstBidItemToUpsert;
			
		lstLotWrapper = getLotItemWrapper(objLot.Id, objBidRecordAssociatedToLot.Id);
	}
	
	/*!
      *  @MethodName: getLotItemWrapper
      *  @param None: Lot Id and associated Bid Id.
      *  @Description: This method is used to get all the Lot Items and Bid Items related to Lot Items of the Lot record from where page is launched.
    */
    
	private List<LotWrapper> getLotItemWrapper(String lotId, String bidId)
	{
		decSumOfUnitPriceForAllBids = 0.0;
		List<LotWrapper> lstLotItemWrapper = new List<LotWrapper>(); // Wrapper Class Used to store LineItem and its associated Bid item.
		
		//Querying all the LotItems and associated BidItems of Lot record
		for(Lot_Item__c objLI : [SELECT Id, Quantity__c,Equipment__r.Name,Equipment_Description_Full__c, Lot__c,
									(SELECT Id,Bid_Item_Unit_Price__c,Bid__c FROM Bid_Items__r WHERE Bid__c =: bidId AND CreatedById=:UserInfo.getUserId() ORDER BY LastModifiedDate DESC LIMIT 1)
								 FROM Lot_Item__c WHERE Lot__c =:lotId		
								])
		{
			lstLotItemWrapper.add(new LotWrapper(objLI));
			
			if(!objLI.Bid_Items__r.isEmpty())
				decSumOfUnitPriceForAllBids = decSumOfUnitPriceForAllBids + objLI.Bid_Items__r[0].Bid_Item_Unit_Price__c;
			
		}
		return lstLotItemWrapper;
	}
}