/**
* \arg ClassName  : SL_IntranetSobjectController
* \arg JIRATicket : SOCINT-326
* \arg CreatedOn  : Lodhi, 24/Oct/2013 
* \arg ModifiedBy : 
* \arg Description: 
*/


public with sharing class SL_IntranetSobjectController extends ComponentControllerBase
{
	/* Start - Variables */
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_IntranetSobjectController() 
	{
		//Do-Nothing	
		
	}
	/* End - Constructor */
	
	/* 
     * Name: getMyImpl
     * Parameters: NA
     * Description: Function for implementing base class for this Controller.
     */
	public SL_IntranetSobject getMyImpl() 
	{
		return (SL_IntranetSobject)CompImpl;        
	}
	/* End */
	
	/* 
     * Name: getSobjectRecords
     * Parameters: NA
     * Description: to get records upto default value
     
     public void getSobjectRecords()
     {
     	getMyImpl().getInitialRecords(); 
     }
	 /* End */
	 
	 /* 
     * Name: showMoreRecords
     * Parameters: NA
     * Description: To Show more records
     */
	 public void showMoreRecords()
	{
		getMyImpl().showMoreRecords();
	}
	 /* End */
	 
	 /* 
     * Name: getSobjectRecords
     * Parameters: NA
     * Description: To view all records
     */
     public void gtListViewDetail()
     {
     	getMyImpl().gtListViewDetail();
     }
	 /* End */
	 
	 /* 
     * Name: getSobjectRecords
     * Parameters: NA
     * Description: To view all records
     */
     public void chatterTopicRecords()
     {
     	getMyImpl().chatterTopicRecords();
     }
	 /* End */
	 
}