/**
* Test methods are in Test_CallLog.cls
**/
public with sharing class CallLogAttendees_AddMultipleJSON 
{
	public String CurCallLogId {get; set;}
	public Boolean IsNoEmpty {get; set;}
	public boolean canDelete { get; set; }
    public list<Call_Log_Moelis_Attendee__c > CallLogAttendeeList {get; set;}
    public String CurEmployeePrefix {get; set;}

    public CallLogAttendees_AddMultipleJSON()
    {
        CallLogAttendeeList = new list<Call_Log_Moelis_Attendee__c>();
        IsNoEmpty = false;
        if(System.currentPageReference().getParameters().get('clid')!=null && System.currentPageReference().getParameters().get('clid')!='')
        {
            CurCallLogId = System.currentPageReference().getParameters().get('clid');

            Schema.DescribeSObjectResult R = Employee_Profile__c.SObjectType.getDescribe();
			this.CurEmployeePrefix = R.getKeyPrefix();
            if(CurCallLogId!=null && CurCallLogId!='')
            {
            	for (Call_Log_Moelis_Attendee__c temp :  [SELECT Id,Notes__c,Employee__r.Title__c, Employee__r.Last_Name__c, Employee__r.First_Name__c, Employee__c
            				FROM Call_Log_Moelis_Attendee__c
            				WHERE Call_Log__c=:CurCallLogId
            				//ORDER BY Employee__r.Title__c
            				LIMIT 200])
            	{
            		if (temp.Notes__c !=null)
            		{
	            		temp.Notes__c = temp.Notes__c.replaceAll('\r\n','#r#n');
	            		temp.Notes__c = temp.Notes__c.replaceAll('"','&quot;');
            		}
            		CallLogAttendeeList.add(temp);
            	}
            	if(CallLogAttendeeList.size()>0)IsNoEmpty = true;
            }
        }
    }
}