/**  
* \arg ClassName        : SL_BidToWon_WS 
* \arg JIRATicket       : FAEF-45
* \arg CreatedOn        : 12/NOV/2014
* \arg LastModifiedOn   : 13/NOV/2014
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : -
* \arg Description      : This class contains the webservice method which is taking the bid id when 
						  user click on custom java script detail page button.	
*/
global class SL_BidToWon_WS 
{
	/* Start - Variables */
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_BidToWon_WS()
	{
		//do nothing.
	}
	/* End - Constructor */
	
	/*
	    * MethodName 	: updateBidToWon.
	    * param 		: Bid id 
	    * Description	: This webservice method will call the SL_BidToWon class function to update the bid records.
    */
	Webservice static String updateBid(Id idBid)
	{
		return SL_BidToWon.updateBidRecords(idBid);
	}
	/* End */  
}
/* End */