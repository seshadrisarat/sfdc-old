/**  
* \arg ClassName      : SL_Confirmation
* \arg JIRATicket     : STARGAS-12
* \arg CreatedOn      : 12/NOV/2014
* \arg LastModifiedOn : 12/NOV/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as controller for SL_Confirmation page
*/
public with sharing class SL_Confirmation 
{
	/* Start - Constructor */
	public SL_Confirmation()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	/*
		* MethodName        : redirectBack
		* param             : None
		* Description       : Moving to previous page
	*/
	public Pagereference redirectBack()
	{
		return new Pagereference('/apex/SL_ContractReview?oppid='+Apexpages.currentPage().getParameters().get('oppid')+'&id='+Apexpages.currentPage().getParameters().get('id'));
	}
}