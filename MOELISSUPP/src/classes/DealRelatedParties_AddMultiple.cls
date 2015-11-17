public with sharing class DealRelatedParties_AddMultiple 
{
	/*
	public class MyException extends Exception{}
	
	public string jsonContent { get; set; }
	public String ErrorMsg {get; set;}
	public String CurDealId {get; set;}
	public boolean canDelete { get; set; }
	public boolean isTest = false;
	
	public DealRelatedParties_AddMultiple() 
	{
		if(System.currentPageReference().getParameters().get('did')!=null && System.currentPageReference().getParameters().get('did')!='')
        {
            CurDealId = System.currentPageReference().getParameters().get('did'); 
        }

        this.canDelete = true;
	}

	public Boolean saveJson()
	{
		PageReference pageRef;
		System.debug('!!!!!!!!!!!!!!!!!!!!!!'+jsonContent);
		if(jsonContent==null || jsonContent=='')  return false;
        JSONObject jsonObj = new JSONObject(jsonContent);        
		
        Deal_Related_Parties__c tmpTrack;
        List<Deal_Related_Parties__c> ToDelete = new List<Deal_Related_Parties__c>();
        if( jsonObj.getValue('delList') != null && jsonObj.getValue('delList').values.size()>0)
        {
			if(this.canDelete)
	        {
	                for (integer i = 0; i < jsonObj.getValue('delList').values.size() ; i++){
	                    tmpTrack = new Deal_Related_Parties__c(id = jsonObj.getValue('delList').values.get(i).str);
	                    toDelete.add(tmpTrack);
	                }
	        }
	        else 
	        {
		   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient privileges. Please contact the Help Desk'));
					return false;
	        }
	    	if(toDelete.size() > 0) delete toDelete;
        }
        

        boolean changed;
        integer len;
        if (jsonObj.getValue('table')!=null && jsonObj.getValue('table').values!=null && jsonObj.getValue('table').values.size()>0)len = jsonObj.getValue('table').values.size();
        else len = 0;
        
        String valueId;
        String newCompany;
        String newRole;
        String newParty;
        String newNote;
        List<Deal_Related_Parties__c> tbList = new List<Deal_Related_Parties__c>();
        Deal_Related_Parties__c tb = null;
        
        
        Map<Id,Deal_Related_Parties__c> tbMapUPD = new Map<Id,Deal_Related_Parties__c>();
        Map<Id,String> tbMapJSONCompany = new Map<Id,String>();
        Map<Id,String> tbMapJSONRole = new Map<Id,String>();
        Map<Id,String> tbMapJSONParty = new Map<Id,String>();
        Map<Id,String> tbMapJSONNote = new Map<Id,String>();
        List<Id> tbListIdUPD = new List<Id>();
        for(integer i = 0; i < len; i++) 
		{
			valueId = jsonObj.getValue('rows').values.get(i).str;
			newCompany = jsonObj.getValue('table').values.get(i).values.get(2).obj.getValue('value').obj.getString('lkid');
			newRole = jsonObj.getValue('table').values.get(i).values.get(3).obj.getString('value');
			newParty = jsonObj.getValue('table').values.get(i).values.get(4).obj.getString('value');
			newNote = jsonObj.getValue('table').values.get(i).values.get(5).obj.getString('value');
			if(valueId.compareTo('new_')>0)
			{
				tb = new Deal_Related_Parties__c(Role__c = newRole, Party__c = newParty, Company__c = newCompany, Notes__c = newNote, Deal__c=this.CurDealId);
				if(tb != null)	tbList.add(tb);
			}
			else 
			{
				tbListIdUPD.add(valueId);
				tbMapJSONCompany.put(valueId,newCompany);
				tbMapJSONRole.put(valueId,newRole);
				tbMapJSONParty.put(valueId,newParty);
				tbMapJSONNote.put(valueId,newNote);
			}
		}
		if (tbListIdUPD.size() > 0)
		{
			for( Deal_Related_Parties__c tmpO : 
					  [ Select Id, Role__c, Party__c, Notes__c, Company__c
					  	From Deal_Related_Parties__c 
                		where Deal__c =:this.CurDealId and Id IN :tbListIdUPD limit 1000])
            {
            	tbMapUPD.put(tmpO.Id,tmpO);
            }
		}
		if (tbMapUPD.size() > 0)
		{
			List<Deal_Related_Parties__c> tb2List;
			for(Id tmpId : tbMapUPD.keySet())
            {
            	tb = tbMapUPD.get(tmpId);
				changed = false;
				try 
				{
					newCompany = tbMapJSONCompany.get(tmpId);
					if (newCompany != tb.Company__c) {
	                        if(newCompany==null || newCompany=='') tb.Company__c = null;
	                        else tb.Company__c = newCompany;
	                        changed =  true;                    
					}
				}catch (Exception ex){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));return false;}
				try 
				{
					newRole = tbMapJSONRole.get(tmpId);
					if (newRole != tb.Role__c) {
	                        if(newRole==null || newRole=='') tb.Role__c = null;
	                        else tb.Role__c = newRole;
	                        changed =  true;                    
					}
				}catch (Exception ex){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));return false;}
				try 
				{
					newParty = tbMapJSONParty.get(tmpId);
					if (newParty != tb.Party__c) {
	                        if(newParty==null || newParty=='') tb.Party__c = null;
	                        else tb.Party__c = newParty;
	                        changed =  true;                    
					}
				}catch (Exception ex){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));return false;}
				
				if(tb != null || isTest)
				{
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
     	PageReference pageRef = new PageReference('/'+CurDealId);
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
     	PageReference pageRef = new PageReference('/'+CurDealId);
		pageRef.setRedirect(true);
        return pageRef;
     }
*/

}