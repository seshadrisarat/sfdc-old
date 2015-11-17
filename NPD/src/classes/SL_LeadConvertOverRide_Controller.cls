/**
*  ClassName      : SL_LeadConvertOverRide_Controller 
*  JIRATicket     : NPD-217
*  CreatedOn      : 14/OCT/2015
*  ModifiedBy     : Sanath
*  Description    : This class serves as controller for SL_LeadConvertOverRide page
*/
public with sharing class SL_LeadConvertOverRide_Controller {
    
    /***Global Variables Start***/
    
    public Id idSelectedId {get;set;}
    public Id idLeadId {get;set;}
    public String strURLtoRedirect {get;set;}
    
    /***Global Variables End ***/
    
    /* Constructor - Start*/
    public SL_LeadConvertOverRide_Controller(ApexPages.StandardController stdController) 
    {
        idLeadId = stdController.getId();
        strURLtoRedirect = '';
    }
    /* Constructor - End */
    
    /*
       * MethodName : reDirectToLeadConvertWithAccount
       * Param 		: -
       * Description: Shall redirect to Lead Convert Page with Account prepopulated
    */
    
    public PageReference reDirectToLeadConvertWithAccount()
    {
        if((String)idSelectedId == '')
            return null;
        return redirector(true);
    }
    
    /*
       * MethodName : reDirectToLeadConvertWithoutAccount
       * Param 		: -
       * Description: Shall redirect to Lead Convert Page without Account prepopulated
    */
    
    public PageReference reDirectToLeadConvertWithoutAccount()
    {
        return redirector(false);
    }
    
    /*
       * MethodName : redirector
       * Param 		: -
       * Description: Shall redirect to Lead Convert Page with or without Account prepopulated
    */
    
    private PageReference redirector(Boolean isAccountPopulated)
    {
        String strURL = '/lead/leadconvert.jsp?id=' + idLeadId + '&RetURL=' + idLeadId ;
        if(isAccountPopulated)
        {
            Account objAccount = [Select Id,Name from Account where Id =:idSelectedId LIMIT 1];
            strURL += '&acclkid_lkid=' + idSelectedId + '&acclkid_lkwgt=' + idSelectedId + '&accid=' + ((String)idSelectedId).substring(0,15) + '&noOverride=1' ;//((String)idSelectedId).substring(0,15)
        }
        PageReference redirect = new PageReference(strURL);
        redirect.setRedirect(true);
        return redirect;
    }
    
    /*
       * MethodName : navigateToAccount
       * Param 		: -
       * Description: Shall redirect to Selected Account
    */
    
    public void navigateToAccount()
    {
        if((String)idSelectedId != '')
        {
            strURLtoRedirect = URL.getSalesforceBaseUrl().toExternalForm() + '/' + idSelectedId;
        }
    }
}