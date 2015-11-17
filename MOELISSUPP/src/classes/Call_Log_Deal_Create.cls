/**
* Test methods are in Test_CallLog.cls
**/
public with sharing class Call_Log_Deal_Create 
{
	public String CurCallLogId {get; set;}
	public Call_Log_Deal__c CurCallLogDeal {get; set;}
	public Call_Log_Deal_Create()
	{
		if(System.currentPageReference().getParameters().get('clid')!=null && System.currentPageReference().getParameters().get('clid')!='')
            this.CurCallLogId = System.currentPageReference().getParameters().get('clid');
        CurCallLogDeal = new Call_Log_Deal__c();
	}
  
	private Boolean saveObj()
	{
		if(CurCallLogId != null && CurCallLogId != '')
		{
			CurCallLogDeal.Call_Log__c = CurCallLogId;
			insert CurCallLogDeal;
			return true;
		}
		return false;
	}

    public PageReference save()
    {
        this.saveObj();
        PageReference pageRef = new PageReference('/'+CurCallLogId );
		pageRef.setRedirect(true);
        return pageRef;
     }
     
    public PageReference save_new()
    {
     	this.saveObj();
     	PageReference pageRef = new PageReference('/apex/Call_Log_Deal_Create?clid='+CurCallLogId );
		pageRef.setRedirect(true);
        return pageRef;
    }
	
	public PageReference cancel()
    {
    	PageReference pageRef = new PageReference('/'+CurCallLogId );
		pageRef.setRedirect(true);
        return pageRef;
    }
     
}