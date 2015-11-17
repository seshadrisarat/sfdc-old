/*
*  PageName       : SL_ForgotPasswordPage
*  JIRATicket     : PURE-6
*  CreatedOn      : 12/26/2013
*  ModifiedBy     : Sandeep
*  Description    : A custom controller which  will validate the enter username and send a reset url to respective email to reset the password.  
*/
public with sharing class SL_ForgotPasswordPageController 
{
	public String username {get; set;} 
    public boolean isError {get;set;}//To show the error if username is not valid.
    
    /* Main constructor */
    public SL_ForgotPasswordPageController()
    {
    	isError = false;
    }
    
    
    /*
        * MethodName        : forgotPassword
        * param             : None
        * Description       : This function will validate the username if username is exists.
    */
  	public PageReference forgotPassword() 
  	{
  		if (Site.forgotPassword(username)) 
		  {        
 			  return new PageReference('/ForgotPasswordConfirm');
		  }
		  else
		  {
 			  isError = true;
		  }
  		
  		return null;
  	}
}