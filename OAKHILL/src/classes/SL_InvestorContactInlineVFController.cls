/**
* \arg ClassName      : SL_InvestorContactInlineVFController
* \arg JIRATicket     : OAKHILL-2
* \arg CreatedOn      : 30/SEP/2014
* \arg LastModifiedOn : 30/SEP/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class is used to show all the investor contact and fund of interest records related to current Contact record.
*/
public with sharing class SL_InvestorContactInlineVFController 
{
	/* Start - Variables */
    public String strContactId                         		 {get;set;}   //variable to hold contact id
    /* End - Variables */
    
    /* Start - Constructor */
    public SL_InvestorContactInlineVFController(Apexpages.standardcontroller objStandardController)
    {
		strContactId = objStandardController.getId();
    }
    /* End - Constructor */
}