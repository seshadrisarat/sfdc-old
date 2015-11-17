/**
* \arg ClassName      : SL_ManageContactsNRIFilesController
* \arg JIRATicket     : SEGAL-4
* \arg CreatedOn      : 16/DEC/2014
* \arg LastModifiedOn : 16/DEC/2014
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : -
* \arg Description    : This class is used to related current Contact record.
*/
public with sharing class SL_ManageContactsNRIFilesController 
{
	/* Start - Variables */
    public String strContactId                         		 {get;set;}   //variable to hold contact id
    /* End - Variables */
    
    /* Start - Constructor */
    public SL_ManageContactsNRIFilesController(Apexpages.standardcontroller objStandardController)
    {
		strContactId = objStandardController.getId();
    }
    /* End - Constructor */
	

}