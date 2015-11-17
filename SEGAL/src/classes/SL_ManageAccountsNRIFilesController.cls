/**
* \arg ClassName      : SL_ManageContactsNRIFilesController
* \arg JIRATicket     : SEGAL-4
* \arg CreatedOn      : 16/DEC/2014
* \arg LastModifiedOn : 16/DEC/2014
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : -
* \arg Description    : This class is used to related current Account record.
*/
public with sharing class SL_ManageAccountsNRIFilesController 
{
	/* Start - Variables */
    public String strAccountId                         		 {get;set;}   //variable to hold Account Id
    /* End - Variables */
    
    /* Start - Constructor */
    public SL_ManageAccountsNRIFilesController(Apexpages.standardcontroller objStandardController)
    {
		strAccountId = objStandardController.getId();
    }
    /* End - Constructor */

}