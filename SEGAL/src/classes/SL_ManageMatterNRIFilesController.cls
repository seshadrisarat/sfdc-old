/**
* \arg ClassName      : SL_ManageMatterNRIFilesController
* \arg JIRATicket     : SEGAL-4
* \arg CreatedOn      : 25/DEC/2014
* \arg LastModifiedOn : 25/DEC/2014
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : Sandeep
* \arg Description    : This class is used to related current Matter record.
*/
public with sharing class SL_ManageMatterNRIFilesController 
{
	/* Start - Variables */
    public String strMatterId                         		 {get;set;}   //variable to hold Matter record Id
    /* End - Variables */
    
    /* Start - Constructor */
    public SL_ManageMatterNRIFilesController(Apexpages.standardcontroller objStandardController)
    {
		strMatterId = objStandardController.getId();
    }
    /* End - Constructor */

}