/**
* \arg ClassName      : SL_ManageOppNRIFilesController
* \arg JIRATicket     : SEGAL-4
* \arg CreatedOn      : 22/DEC/2014
* \arg LastModifiedOn : 22/DEC/2014
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : Sandeep
* \arg Description    : This class is used to manage Opp NRI documents.
*/
public with sharing class SL_ManageOppNRIFilesController 
{
	/* Start - Variables */
    public String strOpportunityId                         		 {get;set;}   //variable to hold OpportunityId Id
    /* End - Variables */
    
    /* Start - Constructor */
    public SL_ManageOppNRIFilesController(Apexpages.standardcontroller objStandardController)
    {
		strOpportunityId = objStandardController.getId();
    }
    /* End - Constructor */

}