/**
* Test methods are in Test_Employee.cls
**/
public class EmployeeMoelisRelationsh_AddMultipleJSON {

	public String CurEmployeeId {get; set;}
	public Boolean IsNoEmpty {get; set;}
	public boolean canDelete { get; set; }
    public list<Employee_Relationships__c> EmpRelationshipList {get; set;}
    public String CurEmployeeName {get; set;}
    public String CurEmployeePrefix {get; set;}
	public String CurContactPrefix {get; set;}
    public List<picklistItem> Type_values {get; set;}
	public List<picklistItem> Strength_values {get; set;}
	public class picklistItem {
        public string value {get; set;}
        public string label {get; set;}
        
        public picklistItem (string val, string lbl)
        {
            value = val;
            label = lbl;            
        }
    }
    public EmployeeMoelisRelationsh_AddMultipleJSON()
    {
        EmpRelationshipList = new list<Employee_Relationships__c>();
        IsNoEmpty = false;
        
        if(System.currentPageReference().getParameters().get('did')!=null && System.currentPageReference().getParameters().get('did')!='')
        {
            CurEmployeeId = System.currentPageReference().getParameters().get('did');
            Schema.DescribeSObjectResult R = Employee_Profile__c.SObjectType.getDescribe();
			this.CurEmployeePrefix = R.getKeyPrefix();
			Schema.DescribeSObjectResult R1 = Contact.SObjectType.getDescribe();
			this.CurContactPrefix = R1.getKeyPrefix();
            if(CurEmployeeId!=null && CurEmployeeId!='')
            {
				Employee_Profile__c CObj = [Select Name From Employee_Profile__c WHERE Id=:CurEmployeeId limit 1];
				this.CurEmployeeName = CObj.Name;
				/*
				EmpRelationshipList = [SELECT  relationship_notes__c,Relationship_Type__c, Relationship_Strength__c, Name,Id, Employee__c,Employee__r.First_Name__c,Employee__r.Last_Name__c,Contact__r.Account.Name, Contact__c,Contact__r.FirstName,Contact__r.LastName
            				FROM Employee_Relationships__c
            				WHERE Employee__c=:CurEmployeeId 
            				ORDER BY Relationship_Strength__c
            				LIMIT 200];
            				*/
            	for (Employee_Relationships__c temp :  [SELECT  relationship_notes__c,Relationship_Type__c, Relationship_Strength__c, Name,Id, Employee__c,Employee__r.First_Name__c,Employee__r.Last_Name__c,Contact__r.Account.Name, Contact__c,Contact__r.FirstName,Contact__r.LastName
            				FROM Employee_Relationships__c
            				WHERE Employee__c=:CurEmployeeId 
            				ORDER BY Relationship_Strength__c
            				LIMIT 200])
            	{
            		if (temp.relationship_notes__c !=null)
            		{
	            		temp.relationship_notes__c = temp.relationship_notes__c.replaceAll('\r\n','#r#n');
	            		temp.relationship_notes__c = temp.relationship_notes__c.replaceAll('"','&quot;');
            		}
            		EmpRelationshipList.add(temp);
            	}
            	if(EmpRelationshipList.size()>0)IsNoEmpty = true;
            }
        
        this.canDelete = true;
        Schema.DescribeFieldResult fieldResult = Employee_Relationships__c.Relationship_Type__c.getDescribe();
        List<Schema.PicklistEntry> PickilstValues = fieldResult.getPicklistValues();
        
        this.Type_values = new List<picklistItem>();
        Type_values.add(new picklistItem('','--None--'));
        for (Schema.PicklistEntry pVal : PickilstValues){Type_values.add(new picklistItem(pVal.value,pVal.label));}
        
        fieldResult = Employee_Relationships__c.Relationship_Strength__c.getDescribe();
        PickilstValues = fieldResult.getPicklistValues();
        this.Strength_values = new List<picklistItem>();
        for (Schema.PicklistEntry pVal : PickilstValues){Strength_values.add(new picklistItem(pVal.value,pVal.label));}
        Strength_values.add(new picklistItem('','--None--'));
        }
        
    }
    
    
}