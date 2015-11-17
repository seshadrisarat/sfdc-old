/*
*  PageName       : SL_AgentLoginController
*  CreatedOn      : 1/23/2015
*  ModifiedBy     : Kyle Lawson
*  Description    : A custom login page controller which will call the site.login method to validate the access of site.  
*/
public with sharing class SL_AgentLoginController 
{
    public String username {get; set;}
    public String password {get; set;}
    public Boolean isRememberUsername{get;set;}
    private static final String START_URL = '/BrokerHomePage';
    
    
    public SL_AgentLoginController()
    {
    	Cookie counter = ApexPages.currentPage().getCookies().get('counter');
    	
    	if (counter == null) {} 
        else {
        	counter = null;
        	ApexPages.currentPage().setCookies(new Cookie[]{counter});
        }
    }
    
    
    /*
        * MethodName        : login
        * param             : None
        * Description       : This function will be called on click of site login button and it will validate the username and password from database.
    */
    public PageReference login() 
    {
    	
        String startUrl = START_URL;
        String formattedUsername = username.replace('@', '.') + '@brokerview.pureinsurance.com';
        PageReference pr =  Site.login(formattedUsername, password, startUrl);
        
        return pr;
    }
}