/**
* Test methods are in Test_CallLog.cls
**/
public class CallLogContacts_AddMultipleJSON 
{
	public String CurCallLogId {get; set;}
	public Boolean IsNoEmpty {get; set;}
	public boolean canDelete { get; set; }
    public list<Call_Log_Contact__c> CallLogList {get; set;}
    public String CurContactPrefix {get; set;}

    public CallLogContacts_AddMultipleJSON()
    {
        CallLogList = new list<Call_Log_Contact__c>();
        IsNoEmpty = false;
        if(System.currentPageReference().getParameters().get('clid')!=null && System.currentPageReference().getParameters().get('clid')!='')
        {
            CurCallLogId = System.currentPageReference().getParameters().get('clid');

            Schema.DescribeSObjectResult R1 = Contact.SObjectType.getDescribe();
			this.CurContactPrefix = R1.getKeyPrefix();
            if(CurCallLogId!=null && CurCallLogId!='')
            {
			
            	for (Call_Log_Contact__c temp :  [SELECT Id,Notes__c,Title__c,Phone__c,Email__c,Company__c,Company__r.Name,Business_City__c,Business_State_Province__c, Contact__r.Account.Name, Contact__r.Name, Contact__c,Contact__r.FirstName,Contact__r.LastName
            				FROM Call_Log_Contact__c
            				WHERE Call_Log__c=:CurCallLogId
            				//ORDER BY Contact__r.Account.Name
            				LIMIT 200])
            	{
            		if (temp.Notes__c !=null)
            		{
	            		temp.Notes__c = temp.Notes__c.replaceAll('\r\n','#r#n');
	            		temp.Notes__c = temp.Notes__c.replaceAll('"','&quot;');
            		}
            		CallLogList.add(temp);
            		
            	}
            	if(CallLogList.size()>0)IsNoEmpty = true;
            }
        }
    }  
}