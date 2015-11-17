/**
* \arg \b ClassName      : SL_BidJoinerUpsertPageController
* \arg \b JIRATicket     : FAEF-43
* \arg \b CreatedOn      : 8/10/2014
*/

public without sharing class SL_BidJoinerUpsertPageController extends SL_Paginator
{
	/* Start - Variables */
	public Lot__c objLot 						{	get;set;	}  // Used to store the Lot record from where page is launched.
	public List<LotWrapper> lstLotWrapper 		{	get;set;	}  // Used to store LotItems and its associated BidItem 
	public Bid__c objBidRecordAssociatedToLot	{	get;set;	}  // Used to store Bid record which was created by Logged in user and associated with current Lot record
	public List<String> lstHeaders			    {	get;set;	}
	public Integer intNoOfBids                  {   get;set;    }
	private Id accountId                        {   get;set;    } // Used to store accountId of Logged In User.
	public Boolean isSuccessfulSave             {   get;set;    }
	public Boolean isSubmitButtonClicked        {   get;set;    }
	
	public decimal decBidTotal                  {   get;set;    }
	public string strSitePrefix                 {   get;set;    }
	public string errormsg                      {   get;set;    }
	public static final String SUBMITTED_BID_RECORDTYPE_ID = [Select Id From RecordType Where SobjectType='Bid__c' AND Name = 'Submitted Bid'].Id;	 
	
	/* End - Variables */ 

	/* Start - Contructor */

	public SL_BidJoinerUpsertPageController(ApexPages.StandardController controller)
	{
		initialize(); // Method used to initialize Global Variables.
		Id idOfLotRecord = controller.getId(); // Getting the Current Lot__c object record Id from where page is launched.
		
		try
	    {
			objLot = [ Select Id,Lot_Item_Count__c,Auction__r.Do_Not_Allow_Bids__c
				      from Lot__c where id=:idOfLotRecord];
	    }
	     
	    catch(Exception e)
        {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Insufficient Parameters.'));
			return;
        }	
        
        getNoOfBidsAsscToUsersRelatedToLoggedInUserAcc();  // Method used to calculate no of Bids associated to Users of Logged In User account.
		getBidRecordAsscWithLot();                         // Calling this method to query Bid record created by Logged in user and associated with Current LOT record.
		calculateBidTotal();
		initPagination();                                  // Method Used to initialize all the pagination required variables.      
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
		lstHeaders = new List<String>{'Equipment Name','Qty','Description', 'Bid Unit Price'};
		intNoOfBids = 0;
		isSuccessfulSave = false;
		strSitePrefix = Site.getPathPrefix();
		errormsg = '';
		isSubmitButtonClicked = false;
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
        
        PageSize = 5;// no. of rows you want to show per page
        
        LastPage = Math.mod(TotalRows, PageSize) == 0 ? TotalRows / PageSize : TotalRows / PageSize + 1;// calculate the index of last page
            
        noOfPages = Math.mod(TotalRows, PageSize) > 0 ? TotalRows / PageSize + 1 : TotalRows / PageSize;
    }
	
	/*!
      *  @MethodName: getNoOfBidsAsscToUsersRelatedToLoggedInUserAcc
      *  @param None: None.
      *  @Description:  Method used to calculate no of Bids associated to Users of Logged In User account.
    */
    
	private void getNoOfBidsAsscToUsersRelatedToLoggedInUserAcc()
	{
     	accountId = [Select AccountId from User where Id=:UserInfo.getUserId()].AccountId; // Querying the Account of Logged In User
     	
     	if(accountId != null)
     	{
     		set<Id> setUsersIdsRelatedToAccount = new set<Id>();
     		
     		// Querying all the users related to Account
			for(User objUser: [Select Id,AccountId from User where AccountId = :accountId])
			{
				setUsersIdsRelatedToAccount.add(objUser.Id);
			}
			
			// Calculating no of Bids related to Users of Logged in User Account
			intNoOfBids = [ Select count() from Bid__c
	 		 				Where Lot__c =:objLot.Id AND CreatedById IN:setUsersIdsRelatedToAccount ];
     		
     	}
     	
     	// If there is no Account related to logged in user displaying No of Bids created by logged in user are associated with Lot.
     	else
     	{
     		intNoOfBids = [ SELECT count()
   		   					FROM Bid__c
                            WHERE Lot__c =: objLot.Id AND CreatedById =: UserInfo.getUserId() ];
     	}
	}
	/*!
      *  @MethodName: getBidRecordAsscWithLot
      *  @param None: None.
      *  @Description:  Method used to query Bid record created by Logged in user and associated with Current LOT record 
    */
	
	private void getBidRecordAsscWithLot()
	{
		// Querying the Bid record which was created by Current logged in user and associated with Lot from where page is launched. 
		List<Bid__c> lstBidsAssWithLotCrtdByCurrtUser = [SELECT Id,Status__c,RecordTypeId
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
			// Displaying only first 200 Characters from Lot Item Description in Page.  
			if( lotItem.Equipment_Description_Full__c != null && String.valueOf(lotItem.Equipment_Description_Full__c).length() > 200)	
				lotItem.Equipment_Description_Full__c = String.valueOf(lotItem.Equipment_Description_Full__c).substring(0,200) + ' ...';
				
			this.lotItem=lotItem;
			
			// Checking if there are any BidItems associated with LotItems
			if(!lotItem.Bid_Items__r.isEmpty())
				this.bidItem=lotItem.Bid_Items__r[0];
				
			// If there is no BidItem related to LotItem creating new BidItem for Lot Item 	
			else
				this.bidItem = new Bid_Item__c(	Bid_Item_Unit_Price__c = 0.00, Lot_Item__c = lotItem.Id);
				
		}
	}
	/* End - Wrapper class for lot */
	
	/*!
      *  @MethodName: upsertBidAndBidItemsassociatedwithLot
      *  @Description: This method is used to update or insert bid items related to Lot Items of Lot.
    */
    
	public void upsertBidAndBidItemsassociatedwithLot()
	{
		try
		{
			isSuccessfulSave = true;  
			errormsg = '';
			Boolean isSubForApp = false;
			
			if(objBidRecordAssociatedToLot.Id == null )
			{
				objBidRecordAssociatedToLot.Bidder_Account__c = (accountId != null) ? accountId : null;
				insert objBidRecordAssociatedToLot;
			}	
			
			List<Bid_Item__c> lstBidItemToUpsert = new List<Bid_Item__c>();  // Used to insert or update BidItem records.
			
			// Iterating the LotItems associated with Lot
			for(LotWrapper objLW : lstLotWrapper)
			{
				if(objLW.bidItem.Bid_Item_Unit_Price__c > 0)
				{
					// Checking for newly creating BidItem and associating with Bid record.
					if(objLW.bidItem.Bid__c == null)
					{
						objLW.bidItem.Bid__c = objBidRecordAssociatedToLot.Id;
					}	
					lstBidItemToUpsert.add(objLW.bidItem);
				}
			}
			
			// Upserting BidItems related to LotItems of Lot record.
			if(!lstBidItemToUpsert.isEmpty())
				upsert lstBidItemToUpsert;
				
			if(!lstLotWrapper.isEmpty())
			{
				if( (objBidRecordAssociatedToLot.Status__c == 'Saved' || objBidRecordAssociatedToLot.Status__c == null) && isSubmitButtonClicked)	
				{
					objBidRecordAssociatedToLot.Status__c = 'Submitted';
					isSubForApp = true;
				}	
			
			    else if( objBidRecordAssociatedToLot.Status__c == null)
					objBidRecordAssociatedToLot.Status__c = 'Saved';
					
				upsert objBidRecordAssociatedToLot; // If there is no Bid record associated with LOT record creating New Bid record and asscoiating with Lot record.
				
				// Checking entry criteria for approval process and triggering approval process for bid record
				if(isSubForApp && objBidRecordAssociatedToLot.Status__c == 'Submitted' && objBidRecordAssociatedToLot.Won_Lost_Date__c == null && objBidRecordAssociatedToLot.RecordTypeId != SUBMITTED_BID_RECORDTYPE_ID)
					submitForApproval();
			}		
				
			lstLotWrapper = getLotItemWrapper(objLot.Id, objBidRecordAssociatedToLot.Id);
			isSubmitButtonClicked = false;
		}
		
		catch(DmlException dmlex)
		{
			isSuccessfulSave = false;
			errormsg = dmlex.getMessage();
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, dmlex.getMessage()));
			//return;
		}
	}
	
	
	/*!
      *  @MethodName: submitForApproval
      *  @Description: This method is used to submit the Bid record for Approval when status is changed to submitted
    */
    private void submitForApproval()
    {
    	try
    	{
			Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval');
            req1.setObjectId(objBidRecordAssociatedToLot.Id);
            Approval.ProcessResult processResult = null;
            processResult = Approval.process(req1, true);
            
        }
        catch (System.DmlException ex) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getMessage()));
			return;
        }
    }
    
	
	/*!
      *  @MethodName: getLotItemWrapper
      *  @param None: Lot Id and associated Bid Id.
      *  @Description: This method is used to get all the Lot Items and Bid Items related to Lot Items of the Lot record from where page is launched.
    */
    
	private List<LotWrapper> getLotItemWrapper(String lotId, String bidId)
	{
		List<LotWrapper> lstLotItemWrapper = new List<LotWrapper>(); // Wrapper Class Used to store LineItem and its associated Bid item.
		
		//Querying all the LotItems and associated BidItems of Lot record
		for(Lot_Item__c objLI : [SELECT Id, Quantity__c,Equipment__r.Name,Equipment_Description_Full__c, Lot__c,
									(SELECT Id,Bid_Item_Unit_Price__c,Bid__c FROM Bid_Items__r WHERE Bid__c =: bidId AND CreatedById=:UserInfo.getUserId() ORDER BY LastModifiedDate DESC LIMIT 1)
								 FROM Lot_Item__c WHERE Lot__c =:lotId		
								])
		{
			lstLotItemWrapper.add(new LotWrapper(objLI));
		}
		return lstLotItemWrapper; 
	}
	
	
	/*!
      *  @MethodName: calculateBidTotal
      *  @Description: This method is used to calculate the sum of Unit Price of all Bid items.
    */
    
	public void calculateBidTotal()
	{
		decBidTotal = 0.00;
		for( LotWrapper objLotWrapper : lstLotWrapper)
		{
			Decimal decBidUnitPrice = objLotWrapper.bidItem.Bid_Item_Unit_Price__c * objLotWrapper.lotItem.Quantity__c ;
			decBidTotal = decBidTotal + decBidUnitPrice;
		}
		decBidTotal = decBidTotal.setScale(2);
	}
}