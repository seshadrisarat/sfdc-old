/**
* \arg ClassName      : SL_ManageClientNRIFilesController
* \arg JIRATicket     : SEGAL-4
* \arg CreatedOn      : 25/DEC/2014
* \arg LastModifiedOn : 25/DEC/2014
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : -
* \arg Description    : This class is used to related current Client record.
*/
public with sharing class SL_ManageClientNRIFilesController 
{
	/* Start - Variables */
    public String strClientId                         		 {get;set;}   //variable to hold client Id
    /* End - Variables */
    
    /* Start - Constructor */
    public SL_ManageClientNRIFilesController(Apexpages.standardcontroller objStandardController)
    {
		strClientId = objStandardController.getId();
    }
    /* End - Constructor */

}