/**
* Test methods are in Test_Deal.cls
**/
public class DealContacts_Create 
{
	public String CurDealId {get; set;}
	public String CurContactId {get; set;}
	public String CurDealContactId {get; set;}
	public String retURL {get; set;}
	public Project_Client_Contact__c CurDealContact {get; set;}
	public Boolean isEdit {get; set;}

	public DealContacts_Create(ApexPages.StandardController stdController)		
	{
		Project_Client_Contact__c tmpObj = (Project_Client_Contact__c)stdController.getRecord();
		this.CurDealContactId = tmpObj.Id;
		if(this.CurDealContactId != null && this.CurDealContactId != '')
		{
	        this.isEdit = true;
	        this.retURL = System.currentPageReference().getParameters().get('retURL');
	        this.CurDealContact = [	SELECT ID, Title__c, Role__c, Phone__c, Moelis_Project__c,Moelis_Project__r.Name, Email__c, Company_Name__c, Company_Name__r.Name, Comments__c, Client_Contact__c, Business_State_Province__c, Business_City__c 
	        						From Project_Client_Contact__c
	        						WHERE ID = : this.CurDealContactId];
	       	this.CurDealId = this.CurDealContact.Moelis_Project__c;
	       	this.CurContactId = this.CurDealContact.Client_Contact__c;
		}
		else
		{
			this.isEdit = false;
			this.retURL = '';
			if(System.currentPageReference().getParameters().get('did')!=null && System.currentPageReference().getParameters().get('did')!='')
	            this.CurDealId = System.currentPageReference().getParameters().get('did');
	        if(System.currentPageReference().getParameters().get('cid')!=null && System.currentPageReference().getParameters().get('cid')!='')
	            this.CurContactId = System.currentPageReference().getParameters().get('cid');
	        this.CurDealContact = new Project_Client_Contact__c(Moelis_Project__c = this.CurDealId, Client_Contact__c = this.CurContactId);
		}			
	}
   
	private void saveObj()
	{
		if(this.CurDealContactId != null && this.CurDealContactId != '')	update this.CurDealContact;
		else	insert this.CurDealContact;
	}

    public PageReference save()
    {
        this.saveObj();
        PageReference pageRef;
        if(this.retURL != null && this.retURL != '') pageRef = new PageReference(this.retURL);
        else if(this.CurDealId != null && this.CurDealId != '') pageRef = new PageReference('/'+this.CurDealId);
        else if(this.CurContactId != null && this.CurContactId != '') pageRef = new PageReference('/'+this.CurContactId);
		pageRef.setRedirect(true);
        return pageRef;
     }
     
    public PageReference save_new()
    {
     	this.saveObj();
        PageReference pageRef;
  		//if(this.retURL != null && this.retURL != '') pageRef = new PageReference(this.retURL );
       // else 
        if(this.CurDealId != null && this.CurDealId != '') pageRef = new PageReference('/apex/DealContacts_Create?did='+this.CurDealId+'&cid=');
        else if(this.CurContactId != null && this.CurContactId != '')  pageRef = new PageReference('/apex/DealContacts_Create?did=&cid='+this.CurContactId);
		pageRef.setRedirect(true);
        return pageRef;
    }
	
	public PageReference cancel()
    {
    	PageReference pageRef;
    	system.debug('this.CurContactId =====================================>'+this.CurContactId);
  		if(this.retURL != null && this.retURL != '') pageRef = new PageReference(this.retURL);
        else if(this.CurDealId != null && this.CurDealId != '') pageRef = new PageReference('/'+this.CurDealId);
        else if(this.CurContactId != null && this.CurContactId != '') pageRef = new PageReference('/'+this.CurContactId);
		pageRef.setRedirect(true);
        return pageRef;
    }
     
}