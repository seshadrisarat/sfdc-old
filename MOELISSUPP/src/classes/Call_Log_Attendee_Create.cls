/**
* Test methods are in Test_CallLog.cls
**/
public with sharing class Call_Log_Attendee_Create 
{
	public String CurCallLogId {get; set;}
	public Call_Log_Moelis_Attendee__c CurCallLogAttendee {get; set;}
	public Call_Log_Attendee_Create()
	{
		if(System.currentPageReference().getParameters().get('clid')!=null && System.currentPageReference().getParameters().get('clid')!='')
            this.CurCallLogId = System.currentPageReference().getParameters().get('clid');
        CurCallLogAttendee = new Call_Log_Moelis_Attendee__c();
	}
  
	private Boolean saveObj()
	{
		if(CurCallLogId != null && CurCallLogId != '')
		{
			CurCallLogAttendee.Call_Log__c = CurCallLogId;
			insert CurCallLogAttendee;
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
     	PageReference pageRef = new PageReference('/apex/Call_Log_Attendee_Create?clid='+CurCallLogId );
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