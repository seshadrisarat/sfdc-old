/**
* Test methods are in Tests_for_Multiedit.cls
**/
public with sharing class DealContacts_AddMultipleJSON {
	public String CurDealId {get; set;}
	public Boolean IsNoEmpty {get; set;}
	public boolean canDelete { get; set; }
    public list<Project_Client_Contact__c> DealContactList {get; set;}
    public String DealProjectName {get; set;}
    public String CurDealContactPrefix {get; set;}
	public List<picklistItem> Role_values {get; set;}
	public class picklistItem {
        public string value {get; set;}
        public string label {get; set;}
        
        public picklistItem (string val, string lbl)
        {
            value = val;
            label = lbl;            
        }
    }
    public fieldLength FLength {get; set;} 
	public class fieldLength 
    {
        public Integer LengthTitle {get; set;}
        public Integer LengthPhone {get; set;}
        public Integer LengthEmail {get; set;}
        public Integer LengthCity {get; set;}
        public Integer LengthState {get; set;}
        public fieldLength(){}
    }
    public DealContacts_AddMultipleJSON()
    {
        DealContactList = new list<Project_Client_Contact__c>();
        
        if(System.currentPageReference().getParameters().get('did')!=null && System.currentPageReference().getParameters().get('did')!='')
        {
          
            CurDealId = System.currentPageReference().getParameters().get('did');
             
            Schema.DescribeSObjectResult R = Contact.SObjectType.getDescribe();
			this.CurDealContactPrefix = R.getKeyPrefix();
			
            if(CurDealId!=null && CurDealId!='')
            {
				Ibanking_Project__c DealObj = [Select Name From Ibanking_Project__c WHERE Id=:CurDealId limit 1];
				this.DealProjectName = DealObj.Name;
				/*
				DealContactList = [SELECT Role__c, Moelis_Project__r.Name, Id, Comments__c, Client_Contact__r.LastName, Client_Contact__r.FirstName
            				FROM Project_Client_Contact__c
            				WHERE Moelis_Project__c=:CurDealId 
            				ORDER BY Client_Contact__r.AccountId
            				LIMIT 200];
            		*/		
            	for (Project_Client_Contact__c temp :  [SELECT Role__c,Title__c,Company_Name__c,Company_Name__r.Name,Phone__c,Email__c,Business_City__c,Business_State_Province__c, Moelis_Project__r.Name, Id, Comments__c, Client_Contact__r.LastName, Client_Contact__r.FirstName
            				FROM Project_Client_Contact__c
            				WHERE Moelis_Project__c=:CurDealId 
            				ORDER BY Client_Contact__r.AccountId
            				LIMIT 200])
            	{
            		if (temp.Comments__c !=null)
            		{
	            		temp.Comments__c = temp.Comments__c.replaceAll('\r\n','#r#n');
	            		temp.Comments__c = temp.Comments__c.replaceAll('"','&quot;');
            		}
            		DealContactList.add(temp);
            	}		
            	if(DealContactList.size()>0)IsNoEmpty = true;		
            }
            
        }
        
        this.canDelete = false;
        list<Profile> prof = null;
        prof = [	Select Id 
           			From Profile 
           			Where (Name='SP Moelis IT' OR Name = 'System Administrator' OR Name='SP Moelis Mgmt Team' OR Name='SP Moelis Project Admin' OR Name='System Admin w/o IR permissions')
           					AND Id=:UserInfo.getProfileId() ];
        if(prof.size()>0) this.canDelete = true;
     
        Schema.DescribeFieldResult fieldResult = Project_Client_Contact__c.Role__c.getDescribe();
        List<Schema.PicklistEntry> PickilstValues = fieldResult.getPicklistValues();
        this.Role_values = new List<picklistItem>();
        Role_values.add(new picklistItem('','--None--'));
        for (Schema.PicklistEntry pVal : PickilstValues){Role_values.add(new picklistItem(pVal.value,pVal.label));}
        
        FLength = new DealContacts_AddMultipleJSON.fieldLength();
        FLength.LengthTitle = Project_Client_Contact__c.Title__c.getDescribe().getLength(); 
        FLength.LengthPhone = Project_Client_Contact__c.Phone__c.getDescribe().getLength();
        FLength.LengthEmail = Project_Client_Contact__c.Email__c.getDescribe().getLength();
        FLength.LengthCity = Project_Client_Contact__c.Business_City__c.getDescribe().getLength();
        FLength.LengthState = Project_Client_Contact__c.Business_State_Province__c.getDescribe().getLength();
    }
    
    
}