public with sharing class DealRelatedParties_AddMultipleJSON 
{
	/*
	public String CurDealId {get; set;}
	public Boolean IsNoEmpty {get; set;}
    public list<Deal_Related_Parties__c> DealPartiesList {get; set;}
    
    public String DealProjectName {get; set;}
    public String CurDealAccountPrefix {get; set;}
    
	public List<picklistItem> Role_values {get; set;}
	public List<picklistItem> Party_values {get; set;}
	public class picklistItem 
	{
        public string value {get; set;}
        public string label {get; set;}
        
        public picklistItem (string val, string lbl)
        {
            value = val;
            label = lbl;            
        }
    }
    
    public DealRelatedParties_AddMultipleJSON()
    {
        DealPartiesList = new list<Deal_Related_Parties__c>();
        
        if(System.currentPageReference().getParameters().get('did')!=null && System.currentPageReference().getParameters().get('did')!='')
        {
          
            CurDealId = System.currentPageReference().getParameters().get('did');
             
            Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
			this.CurDealAccountPrefix = R.getKeyPrefix();
			
            if(CurDealId!=null && CurDealId!='')
            {
				Ibanking_Project__c DealObj = [Select Name From Ibanking_Project__c WHERE Id=:CurDealId limit 1];
				this.DealProjectName = DealObj.Name;
					
            	for (Deal_Related_Parties__c temp :  [Select Role__c, Party__c, Notes__c, Deal__c, Company__c,Company__r.Name,Deal__r.Name
            				From Deal_Related_Parties__c d
            				WHERE Deal__c=:CurDealId 
            				ORDER BY Party__c
            				LIMIT 200])
            	{
            		if (temp.Notes__c !=null)
            		{
	            		temp.Notes__c = temp.Notes__c.replaceAll('\r\n','#r#n');
	            		temp.Notes__c = temp.Notes__c.replaceAll('"','&quot;');
            		}
            		DealPartiesList.add(temp);
            	}		
            	if(DealPartiesList.size()>0)IsNoEmpty = true;		
            }
            
        }
     
        Schema.DescribeFieldResult fieldResult = Deal_Related_Parties__c.Role__c.getDescribe();
        List<Schema.PicklistEntry> PickilstValues = fieldResult.getPicklistValues();
        this.Role_values = new List<picklistItem>();
        Role_values.add(new picklistItem('','--None--'));
        for (Schema.PicklistEntry pVal : PickilstValues){Role_values.add(new picklistItem(pVal.value,pVal.label));}
        
        fieldResult = Deal_Related_Parties__c.Party__c.getDescribe();
        PickilstValues = fieldResult.getPicklistValues();
        this.Party_values = new List<picklistItem>();
        Party_values.add(new picklistItem('','--None--'));
        for (Schema.PicklistEntry pVal : PickilstValues){Party_values.add(new picklistItem(pVal.value,pVal.label));}
        
    }
    */
}