/*
     * Name         : OLE_Login
     * JIRA Ticket  : 
     * Author       : F8 Dev Team
     * Description  : 

     * Maintenance History:
     * 30/10/2015 - 1.0 - Created    
*/ 

public class OLE_Login 
{   
    public String  username         {   get;set;    }
    public String  password         {   get;set;    }
    public List<Login_Page_Ad__c> lstAd {get; set;}
    
    String strRetURL = '';
    
    /* Start - constructor */
    public OLE_Login()
    {
        // Redirect URL
        strRetURL = URL.getCurrentRequestUrl().getQuery() != null ? URL.getCurrentRequestUrl().getQuery() : '';
        lstAd = new List<Login_Page_Ad__c>();
        getAds();
    }
    /* End - constructor */
    
    private void getAds()
    {
        lstAd = [Select Id, 
                        Ad_Description__c, 
                        Ad_Content__c 
                 From Login_Page_Ad__c
                 Where Active__c = True]; 
        System.debug('======lstAd'+lstAd);
    }
    /* Start - redirectAuthenticatedUser */
    public Pagereference redirectAuthenticatedUser()
    {   
        return OLE_CommonShare.redirectAuthenticatedUser(strRetURL);
    } 
    /* End - redirectAuthenticatedUser */
    
    /* Start - login */
    public pageReference login() 
    {
        String startUrl = '/Landing' + '?' + strRetURL;
        return Site.login(username, password, startUrl);
    }
    /* End - login */
}