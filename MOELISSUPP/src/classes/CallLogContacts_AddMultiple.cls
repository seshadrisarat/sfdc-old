/**
* Test methods are in Test_CallLog.cls
**/
public class CallLogContacts_AddMultiple 
{
	public class MyException extends Exception{}
	public string jsonContent { get; set; }
	public String ErrorMsg {get; set;}
	public String CurCallLogId {get; set;}
	public boolean canDelete { get; set; }
	public boolean isTest = false;
	
	public CallLogContacts_AddMultiple() 
	{
		if(System.currentPageReference().getParameters().get('clid')!=null && System.currentPageReference().getParameters().get('clid')!='')
        {
            CurCallLogId = System.currentPageReference().getParameters().get('clid'); 
        }
        this.canDelete = true;
	}

	public Boolean saveJson()
	{
		PageReference pageRef;
		System.debug('!!!!!!!!!!!!!!!!!!!!!!'+jsonContent);
		if(jsonContent==null || jsonContent=='')  return false;
        JSONObject jsonObj = new JSONObject(jsonContent);        
		
        Call_Log_Contact__c tmpTrack;
        List<Call_Log_Contact__c> CallLogDelete = new List<Call_Log_Contact__c>();
        if( jsonObj.getValue('delList') != null && jsonObj.getValue('delList').values.size()>0)
        {
			if(this.canDelete)
	        {
	                for (integer i = 0; i < jsonObj.getValue('delList').values.size() ; i++){
	                    tmpTrack = new Call_Log_Contact__c(id = jsonObj.getValue('delList').values.get(i).str);
	                    CallLogDelete.add(tmpTrack);
	                }
	        }
	        else 
	        {
		   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient privileges. Please contact the Help Desk'));
					return false;
	        }
	    	if(CallLogDelete.size() > 0) delete CallLogDelete;
        }
        

        boolean changed;
        integer len;
        if (jsonObj.getValue('table')!=null && jsonObj.getValue('table').values!=null && jsonObj.getValue('table').values.size()>0)len = jsonObj.getValue('table').values.size();
        else len = 0;
        
        String valueId;
        String newCompany;
        String newContact;
        String newNote;
        String newPhone;
        String newEmail;
        String newCity;
        String newState;
        String newTitle;
        
        List<Call_Log_Contact__c> tbList = new List<Call_Log_Contact__c>();
        Call_Log_Contact__c tb = null;
        
        
        Map<Id,Call_Log_Contact__c> tbMapUPD = new Map<Id,Call_Log_Contact__c>();
        //Map<Id,String> tbMapJSONCompany = new Map<Id,String>();
        //Map<Id,String> tbMapJSONContact = new Map<Id,String>();
        Map<Id,String> tbMapJSONTitle = new Map<Id,String>();
        Map<Id,String> tbMapJSONPhone = new Map<Id,String>();
        Map<Id,String> tbMapJSONEmail = new Map<Id,String>();
        Map<Id,String> tbMapJSONCity = new Map<Id,String>();
        Map<Id,String> tbMapJSONNote = new Map<Id,String>();
        Map<Id,String> tbMapJSONState = new Map<Id,String>();
        List<Id> tbListIdUPD = new List<Id>();
        for(integer i = 0; i < len; i++) 
		{
			valueId = jsonObj.getValue('rows').values.get(i).str;
			
			newCompany = jsonObj.getValue('table').values.get(i).values.get(2).obj.getString('value');
			newTitle = jsonObj.getValue('table').values.get(i).values.get(3).obj.getString('value');
			newPhone = jsonObj.getValue('table').values.get(i).values.get(4).obj.getString('value');
			
			newEmail = jsonObj.getValue('table').values.get(i).values.get(5).obj.getString('value');
	        newCity = jsonObj.getValue('table').values.get(i).values.get(6).obj.getString('value');
	        newState = jsonObj.getValue('table').values.get(i).values.get(7).obj.getString('value');
			newNote = jsonObj.getValue('table').values.get(i).values.get(8).obj.getString('value');
			if(valueId.compareTo('new_')>0)
			{
				newContact = jsonObj.getValue('table').values.get(i).values.get(1).obj.getValue('value').obj.getString('lkid');
				tb = new Call_Log_Contact__c(Contact__c = newContact, Notes__c = newNote, Call_Log__c = this.CurCallLogId);
				if(tb != null)	tbList.add(tb);
			}
			else 
			{
				tbListIdUPD.add(valueId);
				//tbMapJSONContact.put(valueId,newContact);
				//tbMapJSONCompany.put(valueId,newCompany);
				tbMapJSONNote.put(valueId,newNote);
				tbMapJSONTitle.put(valueId,newTitle);
				tbMapJSONPhone.put(valueId,newPhone);
				tbMapJSONEmail.put(valueId,newEmail);
				tbMapJSONCity.put(valueId,newCity);
				tbMapJSONState.put(valueId,newState);
			}
		}
		if (tbListIdUPD.size() > 0)
		{
			for( Call_Log_Contact__c tmpO : 
					  [ Select Id, Notes__c, Contact__c,Title__c,Phone__c,Email__c,Business_City__c,Business_State_Province__c
					  	From Call_Log_Contact__c 
                		where Call_Log__c =:this.CurCallLogId and Id IN :tbListIdUPD limit 1000])
            {
            	tbMapUPD.put(tmpO.Id,tmpO);
            }
		}
		if (tbMapUPD.size() > 0)
		{
			List<Call_Log_Contact__c> tb2List;
			for(Id tmpId : tbMapUPD.keySet())
            {
            	tb = tbMapUPD.get(tmpId);
				changed = false;
				/*			
				try 
				{
					newContact = tbMapJSONContact.get(tmpId);
					if (newContact != tb.Contact__c) {
	                        if(newContact==null || newContact=='') tb.Contact__c = null;
	                        else tb.Contact__c = newContact;
	                        changed =  true;                    
					}
				}catch (Exception ex){
			   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
						return false;
				}
				*/
				if(tb != null || isTest)
				{
					/*
					newCompany = tbMapJSONCompany.get(tmpId);
					system.debug('tb.Company_Name__c = '+tb.Company_Name__c+' newCompany='+newCompany);
					if(tb.Company_Name__c != newCompany || isTest) 
					{
						system.debug('tb.Company_Name__c = '+tb.Company_Name__c+' newCompany='+newCompany);
	                        tb.Company_Name__c = newCompany;
	                        changed = true; 
					}
					*/
					newTitle = tbMapJSONTitle.get(tmpId);
					if(tb.Title__c != newTitle || isTest) 
					{
	                        tb.Title__c = newTitle;
	                        changed = true; 
					}
					newPhone = tbMapJSONPhone.get(tmpId);
					if(tb.Phone__c != newPhone || isTest) 
					{
	                        tb.Phone__c = newPhone;
	                        changed = true; 
					}
					
					try 
					{
					newEmail = tbMapJSONEmail.get(tmpId);
					if(tb.Email__c != newEmail || isTest) 
					{
	                        tb.Email__c = newEmail;
	                        changed = true; 
					}
					}catch (Exception ex){
			   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
						return false;
					}
					
					newCity = tbMapJSONCity.get(tmpId);
					if(tb.Business_City__c != newCity || isTest) 
					{
	                        tb.Business_City__c = newCity;
	                        changed = true; 
					}
					newState = tbMapJSONState.get(tmpId);
					if(tb.Business_State_Province__c != newState || isTest) 
					{
	                        tb.Business_State_Province__c = newState;
	                        changed = true; 
					}
					
					
					
					newNote = tbMapJSONNote.get(tmpId);
	                    if(tb.Notes__c != newNote || isTest) 
	                    {
	                        tb.Notes__c = newNote;
	                        changed = true; 
	                    }
	                    if (changed || isTest)	tbList.add(tb);
	                    
	             }
            }   
		}
		if(tbList.size()>0 || isTest)
		{ 
			try 
			{
				upsert tbList;
				if(isTest) throw new MyException();
			}catch (Exception ex){
		   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
					return false;
			}
		}
		return true;
	}
	
	public PageReference cancel()
    {
     	PageReference pageRef = new PageReference('/'+CurCallLogId);
		pageRef.setRedirect(true);
        return pageRef;
     }
     
     public PageReference save()
     {
     	this.saveJson();
        return null;
     }
     
     public PageReference save_close()
     {
     	if (this.saveJson() == false && !isTest) return null; 
     	PageReference pageRef = new PageReference('/'+CurCallLogId);
		pageRef.setRedirect(true);
        return pageRef;
     }


}