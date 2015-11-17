/**
* Test methods are in Tests_for_Multiedit.cls
**/
public class ContactMoelisRelationship_AddMultiple 
{
	public string jsonContent { get; set; }
	public String ErrorMsg {get; set;}
	public String CurContactId {get; set;}
	public boolean canDelete { get; set; }
	
	public ContactMoelisRelationship_AddMultiple() 
	{
		if(System.currentPageReference().getParameters().get('did')!=null && System.currentPageReference().getParameters().get('did')!='')
        {
            this.CurContactId = System.currentPageReference().getParameters().get('did'); 
        }
        
        this.canDelete = true;
	}

	public Boolean saveJson()
	{
		PageReference pageRef;
		if(jsonContent==null || jsonContent=='') return false;
        JSONObject jsonObj = new JSONObject(jsonContent);        
		
        Employee_Relationships__c tmpTrack;
        if( jsonObj.getValue('delList') != null && jsonObj.getValue('delList').values.size()>0)
        {
           if(this.canDelete)
	       {
	                for (integer i = 0; i < jsonObj.getValue('delList').values.size() ; i++)
	                {
	                    tmpTrack = new Employee_Relationships__c(id = jsonObj.getValue('delList').values.get(i).str);
	                    delete tmpTrack;
	                }
	        } else {
		   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient privileges. Please contact the Help Desk'));
					return false;
	        }
        }

        boolean changed;
        integer len;
        if (jsonObj.getValue('table')!=null && jsonObj.getValue('table').values!=null && jsonObj.getValue('table').values.size()>0)len = jsonObj.getValue('table').values.size();
        else len = 0;
        string valueId;
        List<Employee_Relationships__c> tbList = new List<Employee_Relationships__c>();
        Employee_Relationships__c tb = null;
		for(integer i = 0; i < len; i++) 
		{
			valueId = jsonObj.getValue('rows').values.get(i).str;
			string newType = jsonObj.getValue('table').values.get(i).values.get(4).obj.getString('value');
			string newStrength = jsonObj.getValue('table').values.get(i).values.get(5).obj.getString('value');
			string dateVal = jsonObj.getValue('table').values.get(i).values.get(6).obj.getString('value');
			if(valueId.compareTo('new_')>0)
			{
				try 
				{
					String newEmployee = jsonObj.getValue('table').values.get(i).values.get(3).obj.getValue('value').obj.getString('lkid');
					String newEmployeeName = jsonObj.getValue('table').values.get(i).values.get(3).obj.getValue('value').obj.getString('lkold');
					if ((newEmployee == null || newEmployee == '') && newEmployeeName != null && newEmployeeName != '')
                    {
                    	Employee_Profile__c EmPrObj = [SELECT Id FROM Employee_Profile__c WHERE Name=:newEmployeeName limit 1];
                    	if (EmPrObj != null) newEmployee = EmPrObj.Id;
                    }
					tb = new Employee_Relationships__c(Employee__c=newEmployee,Contact__c=this.CurContactId,relationship_notes__c=dateVal,Relationship_Type__c=newType, Relationship_Strength__c=newStrength);
				} 
				catch (Exception ex)
				{
		   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
					return false;
				}
				if(tb != null)	tbList.add(tb);
			}
			else
			{
			List<Employee_Relationships__c> tb2List = 
					  [ Select relationship_notes__c,Relationship_Type__c, Relationship_Strength__c, Id, Employee__c,Contact__c
                		From Employee_Relationships__c 
                		where Contact__c=:this.CurContactId and Id=:valueId];
			if (tb2List.size() > 0) tb = tb2List[0];
			else tb = null;
			changed = false;
			try {
				if (newType != tb.Relationship_Type__c) {
                        if(newType==null || newType=='') 
                        {
                        	tb.Relationship_Type__c = null;
                        	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select Type'));
							//return false;
                        }	
                        else tb.Relationship_Type__c= newType;
                        changed =  true;                    
				}
			}catch (Exception ex){
		   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
					return false;
			}
			try {
				if (newStrength != tb.Relationship_Strength__c) {
                        if(newStrength==null || newStrength=='') 
                        {
                        	tb.Relationship_Strength__c = null;
                        	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select Strength'));
							//return false;
                        }	
                        else tb.Relationship_Strength__c= newStrength;
                        changed =  true;                    
				}
			}catch (Exception ex){
		   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
					return false;
			}
			

			if(tb != null)
			{
               if(tb.relationship_notes__c != dateVal) 
               {
               		tb.relationship_notes__c = dateVal;
                	changed = true; 
               }
               if (changed) tbList.add(tb);
             }
			}
          }
		if(tbList.size()>0){ upsert tbList;}
        return true;
	}
	
	public PageReference save()
    {
     	this.saveJson();
        return null;
    }
     
    public PageReference save_close()
    {
     	if (this.saveJson() == false) return null; 
     	PageReference pageRef = new PageReference('/'+CurContactId);
		pageRef.setRedirect(true);
        return pageRef;
    }
     
	public PageReference cancel()
    {
        return null;
    }
}