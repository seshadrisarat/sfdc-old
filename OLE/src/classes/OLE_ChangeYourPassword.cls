/*
     * Name         : OLE_ChangeYourPassword
     * JIRA Ticket  : 
     * Author       : F8 Dev Team
     * Description  : Change Password controller

     * Maintenance History:
     * 30/10/2015 - 1.0 - Created    
*/ 

public class OLE_ChangeYourPassword
{
    public String strOldPassword                            {   get; set;   }
    public String strNewPassword                            {   get; set;   }
    public String strVerifyNewPassword                      {   get; set;   }    
    public Boolean isredirectedFromMyProfile                {   get; set;   }
    public Boolean isErrorPresent                           {   get; set;   }
    
    /* Start - redirectAuthenticatedUser */
    public Pagereference redirectUnAuthenticatedUser()
    {
       return OLE_CommonShare.redirectToSignInPage();
    }
    /* End - redirectAuthenticatedUser */
    
    public PageReference changePassword() 
    {
        String strRetURL;
        
        // Check if user is changing password from email link or from My Profile page
        strRetURL = Site.isPasswordExpired() ? '/Landing' : '/MyProfile';
            
        Pagereference prResultURL = Site.changePassword(strNewPassword, strVerifyNewPassword, strOldPassword); 
        
        // Check if any errors found in changing the password
        if(prResultURL == null)
        {
            isErrorPresent = true;
            return prResultURL;
        }
        return new Pagereference(strRetURL);
    }
}