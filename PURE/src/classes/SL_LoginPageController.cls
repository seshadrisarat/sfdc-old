/*
*  PageName       : SL_LoginPageController
*  JIRATicket     : PURE-3
*  CreatedOn      : 12/26/2013
*  ModifiedBy     : Sandeep
*  Description    : A custom loginPageController which will call the site.login method to validate the access of site.  
*/
public with sharing class SL_LoginPageController 
{
    public String username {get; set;}
    public String password {get; set;}
    public Boolean isRememberUsername{get;set;}
    private static final String START_URL = '/MemberHomePage';
    
    
    public SL_LoginPageController()
    {
    	isRememberUsername = false;
    	Cookie counter = ApexPages.currentPage().getCookies().get('counter');
    	
    	if (counter == null) {
        } 
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
    	/*if(isRememberUsername)
    	{
    		
    		Cookie usernameRemember = new Cookie('username',username,null,1000,false);
    		ApexPages.currentPage().setCookies(new Cookie[]{usernameRemember});
    	}
    	*/
    	
        String startUrl = START_URL; 
        PageReference pr =  Site.login(username, password, startUrl);
        
        return pr;
    }
    
    
    
}