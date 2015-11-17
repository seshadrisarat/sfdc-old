public class Account_CallLog_Link 
{
    private final Call_Log_related__c curAccount;

    public Account_CallLog_Link(ApexPages.StandardController stdController) 
    {
        curAccount = (Call_Log_related__c)stdController.getRecord();
    }
    
    public PageReference autoReload()
    {
        PageReference pageRef = new PageReference('/'+curAccount.Id);
		pageRef.setRedirect(true);
        return pageRef;
     }
}