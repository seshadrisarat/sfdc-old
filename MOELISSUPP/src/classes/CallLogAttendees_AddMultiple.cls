/**
* Test methods are in Test_CallLog.cls
**/
public with sharing class CallLogAttendees_AddMultiple 
{
	public class MyException extends Exception{}
	
	public string jsonContent { get; set; }
	public String ErrorMsg {get; set;}
	public String CurCallLogId {get; set;}
	public boolean canDelete { get; set; }
	public boolean isTest = false;
	
	public CallLogAttendees_AddMultiple() 
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
		
        Call_Log_Moelis_Attendee__c tmpTrack;
        List<Call_Log_Moelis_Attendee__c> CallLogDelete = new List<Call_Log_Moelis_Attendee__c>();
        if( jsonObj.getValue('delList') != null && jsonObj.getValue('delList').values.size()>0)
        {
			if(this.canDelete)
	        {
	                for (integer i = 0; i < jsonObj.getValue('delList').values.size() ; i++){
	                    tmpTrack = new Call_Log_Moelis_Attendee__c(id = jsonObj.getValue('delList').values.get(i).str);
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
        String newContact;
        String newNote;
        List<Call_Log_Moelis_Attendee__c> tbList = new List<Call_Log_Moelis_Attendee__c>();
        Call_Log_Moelis_Attendee__c tb = null;
        
        
        Map<Id,Call_Log_Moelis_Attendee__c> tbMapUPD = new Map<Id,Call_Log_Moelis_Attendee__c>();
        Map<Id,String> tbMapJSONContact = new Map<Id,String>();
        Map<Id,String> tbMapJSONNote = new Map<Id,String>();
        List<Id> tbListIdUPD = new List<Id>();
        for(integer i = 0; i < len; i++) 
		{
			valueId = jsonObj.getValue('rows').values.get(i).str;
			newContact = jsonObj.getValue('table').values.get(i).values.get(1).obj.getValue('value').obj.getString('lkid');
			newNote = jsonObj.getValue('table').values.get(i).values.get(3).obj.getString('value');
			if(valueId.compareTo('new_')>0)
			{
				tb = new Call_Log_Moelis_Attendee__c(Employee__c = newContact, Notes__c = newNote, Call_Log__c = this.CurCallLogId);
				if(tb != null)	tbList.add(tb);
			}
			else 
			{
				tbListIdUPD.add(valueId);
				tbMapJSONContact.put(valueId,newContact);
				tbMapJSONNote.put(valueId,newNote);
			}
		}
		if (tbListIdUPD.size() > 0)
		{
			for( Call_Log_Moelis_Attendee__c tmpO : 
					  [ Select Id, Notes__c, Employee__c
					  	From Call_Log_Moelis_Attendee__c 
                		where Call_Log__c =:this.CurCallLogId and Id IN :tbListIdUPD limit 1000])
            {
            	tbMapUPD.put(tmpO.Id,tmpO);
            	
            }
		}
		if (tbMapUPD.size() > 0)
		{
			List<Call_Log_Moelis_Attendee__c> tb2List;
			for(Id tmpId : tbMapUPD.keySet())
            {
            	tb = tbMapUPD.get(tmpId);
				changed = false;
				newContact = tbMapJSONContact.get(tmpId);
				newNote = tbMapJSONNote.get(tmpId);
				try {
					if (newContact != tb.Employee__c) {
	                        if(newContact==null || newContact=='') tb.Employee__c = null;
	                        else tb.Employee__c = newContact;
	                        changed =  true;                    
					}
				}catch (Exception ex){
			   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
						return false;
				}
				
				if(tb != null || isTest)
				{
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