/**
* @ClassName   :   SL_AccountCustomLookupController
* @JIRATicket   :  SEGAL-7
* @CreatedOn    :  5th/Feb/2015
* @Description  :  Controller for SL_AccountCustomLookUp page to display custom look up for selecting Accounts.
*/

public with sharing class SL_AccountCustomLookupController
{
	public String strSearchText                {get;set;}
    public List<Account> lstAccounts           {get;set;}
    
	//Constructor
    public SL_AccountCustomLookupController(ApexPages.StandardController controller)
    {
    	lstAccounts = new List<Account>();
    	strSearchText = System.currentPageReference().getParameters().get('likestring');
    	searchResult();
    }
    
    public void searchResult()
    {
    	if(!String.isEmpty(strSearchText))
    	{
    		String strSearch = '%' + strSearchText + '%';
    		lstAccounts = [ Select Id,Name from Account where Name LIKE :strSearch ORDER BY Name limit 1000];
    	}
    	else
    	{
    		lstAccounts = [Select Id, Name from Account ORDER BY Name limit 1000];
    	}
    }
}