/*
     * Name         : OLE_Login
     * JIRA Ticket  : 
     * Author       : F8 Dev Team
     * Description  : 

     * Maintenance History:
     * 30/10/2015 - 1.0 - Created    
*/ 

public class OLE_ForgotYourPassword
{
    public String strUsername                  {   get;set;    } 
    
    /* Start - constructor */
    public OLE_ForgotYourPassword()
    {
        
    }
    /* End - constructor */
    
    /* Start - redirectAuthenticatedUser */
    public Pagereference redirectAuthenticatedUser()
    {
        return OLE_CommonShare.redirectAuthenticatedUser('');
    }
    /* End - redirectAuthenticatedUser */
    
    public PageReference forgotPassword() 
    {
        Boolean isSuccess = Site.forgotPassword(strUsername);
        PageReference pageRef = Page.ForgotYourPasswordConfirm;
        pageRef.setRedirect(true);
        return isSuccess ?pageRef : null;
    }
}