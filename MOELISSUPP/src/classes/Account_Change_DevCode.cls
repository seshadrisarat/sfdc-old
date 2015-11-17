/**
* Test methods are in Test_Account.cls
**/
public without sharing class Account_Change_DevCode 
{
	public String AccountId {get; set;}
	public Account_Change_DevCode () 
	{
		 if(System.currentPageReference().getParameters().get('aid')!=null && System.currentPageReference().getParameters().get('aid')!='') 
			AccountId = System.currentPageReference().getParameters().get('aid'); 
	}
	
	public PageReference autoRun()
    {
     	if (this.AccountId != null && this.AccountId != '')
     	{
     		Account AccountO = [SELECT Id, Client_Code__c, Business_Development_Code__c FROM Account WHERE Id =: AccountId limit 1];
     		system.debug(AccountO);
     		if(AccountO != null && (AccountO.Business_Development_Code__c == null || AccountO.Business_Development_Code__c == '') && AccountO.Client_Code__c != null && AccountO.Client_Code__c != '')
     		{
     			AccountO.Business_Development_Code__c = AccountO.Client_Code__c+ '_NB_000';
     			update AccountO;
     		}
     	}
     	PageReference pageRef = new PageReference('/'+this.AccountId);
		pageRef.setRedirect(true);
        return pageRef;
    }
}