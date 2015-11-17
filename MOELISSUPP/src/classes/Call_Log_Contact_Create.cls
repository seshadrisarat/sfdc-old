/**
* Test methods are in Test_CallLog.cls
**/
public class Call_Log_Contact_Create 
{
	public String CurCallLogId {get; set;}
	public String CurCallLogContactId {get; set;}
	public Call_Log_Contact__c CurCallLogContact {get; set;}
	public Boolean isEdit {get; set;}

	public Call_Log_Contact_Create(ApexPages.StandardController stdController)		
	{
		Call_Log_Contact__c tmpObj = (Call_Log_Contact__c)stdController.getRecord();
		this.CurCallLogContactId = tmpObj.Id;
		if(this.CurCallLogContactId != null && this.CurCallLogContactId != '')
		{
	        this.isEdit = true;
	        this.CurCallLogContact = [	SELECT ID,Contact__c,Contact__r.Name,Call_Log__c,Title__c,Phone__c,Email__c,Business_State_Province__c,Business_City__c,Company__c,Company__r.Name,Notes__c 
	        							FROM Call_Log_Contact__c 
	        							WHERE ID = : this.CurCallLogContactId];
	        this.CurCallLogId = this.CurCallLogContact.Call_Log__c;
		}
		else
		{
			this.isEdit = false;
			if(System.currentPageReference().getParameters().get('clid')!=null && System.currentPageReference().getParameters().get('clid')!='')
	            this.CurCallLogId = System.currentPageReference().getParameters().get('clid');
	        this.CurCallLogContact = new Call_Log_Contact__c();
		}			
	}
   
	private void saveObj()
	{
		if(this.CurCallLogContactId != null && this.CurCallLogContactId != '')
		{
			update this.CurCallLogContact;
		}
		else
		{
			if(this.CurCallLogId != null && this.CurCallLogId != '')
			{
				this.CurCallLogContact.Call_Log__c = this.CurCallLogId;
				insert this.CurCallLogContact;
			}
		}
	}

    public PageReference save()
    {
        this.saveObj();
        PageReference pageRef = new PageReference('/'+this.CurCallLogId );
		pageRef.setRedirect(true);
        return pageRef;
     }
     
    public PageReference save_new()
    {
     	this.saveObj();
     	PageReference pageRef = new PageReference('/apex/Call_Log_Contact_Create?clid='+this.CurCallLogId );
		pageRef.setRedirect(true);
        return pageRef;
    }
	
	public PageReference cancel()
    {
    	PageReference pageRef = new PageReference('/'+this.CurCallLogId );
		pageRef.setRedirect(true);
        return pageRef;
    }
     
}