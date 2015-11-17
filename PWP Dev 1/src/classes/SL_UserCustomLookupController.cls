/**
* @ClassName    : SL_UserCustomLookupController
* @JIRATicket   : PWP-15
* @CreatedOn    : 05/Feb/2015
* @Description  : CustomLookUp controller for User object
*/

public with sharing class SL_UserCustomLookupController 
{
	
	public String strSearchText                {get;set;} // Used to Store search string
    public List<User> lstUsers                 {get;set;} // Used to Store Queried Users
	
	// Constructor
	public SL_UserCustomLookupController(ApexPages.StandardController controller)
	{
		lstUsers = new list<User>();  
		// Getting Search Parameter
		strSearchText = System.currentPageReference().getParameters().get('likestring');
		searchResult();
	}
	
	// Method used to perform search for active users
	public void searchResult()
    {
    	if(!String.isEmpty(strSearchText))
    	{
    		String strSearch = '%' + strSearchText + '%';
    		lstUsers = [ Select Id,IsActive,Name from User where Name LIKE :strSearch and IsActive = true ORDER BY Name limit 1000];
    	}
    	else
    	{
    		lstUsers = [Select Id,IsActive,Name from User where IsActive = true ORDER BY Name limit 1000];
    	}
    }
}