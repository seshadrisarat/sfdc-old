/**
* Test methods are in Tests_for_Multiedit.cls
**/
public class DealTeam_AddMultipleJSON {
	public String CurDealId {get; set;}
	public Boolean IsNoEmpty {get; set;}
	public boolean canDelete { get; set; }
    public list<Project_Resource__c> DealTeamList {get; set;}
    public String DealProjectName {get; set;}
    public String CurDealBankerPrefix {get; set;}
	public List<picklistItem> Status_values {get; set;}
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
    
    public DealTeam_AddMultipleJSON()
    {
        DealTeamList = new list<Project_Resource__c>();
        IsNoEmpty = false;
        if(System.currentPageReference().getParameters().get('did')!=null && System.currentPageReference().getParameters().get('did')!='')
        {
            CurDealId = System.currentPageReference().getParameters().get('did');

            Schema.DescribeSObjectResult R = Employee_Profile__c.SObjectType.getDescribe();
			this.CurDealBankerPrefix = R.getKeyPrefix();
            if(CurDealId!=null && CurDealId!='')
            {
				Ibanking_Project__c DealObj = [Select Name From Ibanking_Project__c WHERE Id=:CurDealId limit 1];
				this.DealProjectName = DealObj.Name;
				/*
				DealTeamList = [SELECT Id,Status__c, Role__c, Project__r.Name, Comments__c, Banker__r.Last_Name__c,Banker__r.First_Name__c
            				FROM Project_Resource__c
            				WHERE Project__c=:CurDealId 
            				ORDER BY Role__c 
            				LIMIT 200];
            	*/
            	for (Project_Resource__c temp :  [SELECT Id,Status__c, Role__c, Project__r.Name, Comments__c, Banker__r.Last_Name__c,Banker__r.First_Name__c
            				FROM Project_Resource__c
            				WHERE Project__c=:CurDealId 
            				ORDER BY Role__c 
            				LIMIT 200])
            	{
            		if (temp.Comments__c !=null)
            		{
	            		temp.Comments__c = temp.Comments__c.replaceAll('\r\n','#r#n');
	            		temp.Comments__c = temp.Comments__c.replaceAll('"','&quot;');
            		}
            		DealTeamList.add(temp);
            	}
            	if(DealTeamList.size()>0)IsNoEmpty = true;
            }
        }
        
        this.canDelete = true;
        Schema.DescribeFieldResult fieldResult = Project_Resource__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> PickilstValues = fieldResult.getPicklistValues();
        this.Status_values = new List<picklistItem>();
        //Status_values.add(new picklistItem('',''));
        for (Schema.PicklistEntry pVal : PickilstValues){Status_values.add(new picklistItem(pVal.value,pVal.label));}
        
        fieldResult = Project_Resource__c.Role__c.getDescribe();
        PickilstValues = fieldResult.getPicklistValues();
        this.Role_values = new List<picklistItem>();
        Role_values.add(new picklistItem('','--None--'));
        for (Schema.PicklistEntry pVal : PickilstValues){Role_values.add(new picklistItem(pVal.value,pVal.label));}
    }
    
    public static String getHint_Role(){
    	//Schema.DescribeFieldResult f = Schema.sObjectType.Project_Resource__c.fields.Role__c;
    	//String s = f.getInlineHelpText();
    	String s = '<b><u>Project Sponsor:</b></u> Manages overall client relationship\n'
				 + '<b><u>Project Director:</b></u> Manages execution of transaction\n'
				 + '<b><u>Project Administrator:</b></u> VP or Associate responsible for deal files\n'
				 + '<b><u>NOTE:</b></u> Every deal team should have at least a Project Sponsor, Project Director and Project Administrator.'
				 ;
    	s = s.replaceAll('\n', '<br>');
    	s = s.replaceAll('\r', '');
    	return s;
    }
    
    public static String getHint_Status(){
    	//Schema.DescribeFieldResult f = Schema.sObjectType.Project_Resource__c.fields.Status__c;
    	//return f.getInlineHelpText();
    	String s = '<b><u>Inactive:</b></u> Re-staffed, no longer on the deal team, etc.';
    	s = s.replaceAll('\n', '<br>');
    	s = s.replaceAll('\r', '');
    	return s;
    }
}