/**  
* \arg ClassName      : SL_IdVerification
* \arg JIRATicket     : STARGAS-12
* \arg CreatedOn      : 25/JUL/2014
* \arg LastModifiedOn : 28/JUL/2014
* \arg CreatededBy    : SRUTI
* \arg ModifiedBy     : SRUTI
* \arg Description    : This is controller is used for SL_IdVerification page
*/
public without sharing class SL_IdVerification 
{
    public Welcome_Kit__c objWelcomeKit             {get; set;} // Welcome Kit binded with page
    public SL_ContractReviewDoc__c objContractReview{get; set;}//Contract review record binded with page
    private String strWelcomeKitId = '';			// Welcome Kit Id
    
    //Constructor
    public SL_IdVerification()
    {
        try
        {
            strWelcomeKitId = ApexPages.currentPage().getParameters().get('id');
            
            //Query all the values store in custom setting SL_ContractReviewDoc__c
            List<SL_ContractReviewDoc__c> lstContractReview = SL_ContractReviewDoc__c.getall().values();
            
            if(lstContractReview != null && !lstContractReview.isEmpty())
                objContractReview = lstContractReview[0];
                
            //Query Welcome Kit object
            if(strWelcomeKitId != null && !String.isEmpty(strWelcomeKitId))
                objWelcomeKit = [Select Sent_Delivery_City_State_Zip__c, Sent_Delivery_Address_text__c, Name, Client_Name__c, Opportunity__c From Welcome_Kit__c where Id =: strWelcomeKitId ];
                                
        }
        catch(Exception e)
        {
            system.debug(e.getMessage()+'===============Error==@'+e.getLineNumber());
        }
    }
    /*
        * MethodName        : proceed
        * param             : None
        * Description       : Moving to next page(SL_ContractReview) on click of proceed
    */
    public PageReference proceed()
    {
        PageReference pgRef = new PageReference('/apex/SL_ContractReview?oppid='+objWelcomeKit.Opportunity__c+'&id='+strWelcomeKitId);
        pgRef.setRedirect(true);
        return pgRef;
    }
        
}