/**
* Test methods are in Tests_for_Multiedit.cls
**/
public with sharing class DealContacts_AddMultiple_pages 
{
	public string jsonContent { get; set; }
	public String ErrorMsg {get; set;}
	public String CurDealId {get; set;}
	public boolean canDelete { get; set; }
	public boolean isTest = false;
	
	public String page { get; set; }
    public String rows { get; set; }
    public PageReference go() { return null; }
    
	public DealContacts_AddMultiple_pages() 
	{
		if(System.currentPageReference().getParameters().get('did')!=null && System.currentPageReference().getParameters().get('did')!='')
            CurDealId = System.currentPageReference().getParameters().get('did'); 
        if(System.currentPageReference().getParameters().get('page')!=null && System.currentPageReference().getParameters().get('page')!='')
            page = System.currentPageReference().getParameters().get('page'); 
        if(System.currentPageReference().getParameters().get('rows')!=null && System.currentPageReference().getParameters().get('rows')!='')
            rows = System.currentPageReference().getParameters().get('rows');
        
        this.canDelete = true;
	}

     
	public Boolean saveJson()
	{
		PageReference pageRef;
		System.debug('!!!!!!!!!!!!!!!!!!!!!!'+jsonContent);
		if(jsonContent==null || jsonContent=='')  return false;
        JSONObject jsonObj = new JSONObject(jsonContent);        
		
		
	    Project_Client_Contact__c tmpTrack;
        if( jsonObj.getValue('delList') != null && jsonObj.getValue('delList').values.size()>0)
        {
           if(this.canDelete)
           {
                for (integer i = 0; i < jsonObj.getValue('delList').values.size() ; i++){
                    tmpTrack = new Project_Client_Contact__c(id = jsonObj.getValue('delList').values.get(i).str);
                    try {delete tmpTrack;} 
                    catch (Exception ex)
					{
			   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
						return false;
					}
                }
           }
           else 
           {
	   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient privileges. Please contact the Help Desk'));
				return false;
           }
        }
        

        boolean changed;
		integer len;
        if (jsonObj.getValue('table')!=null && jsonObj.getValue('table').values!=null && jsonObj.getValue('table').values.size()>0)len = jsonObj.getValue('table').values.size();
        else len = 0;
        string valueId;
        List<Project_Client_Contact__c> tbList = new List<Project_Client_Contact__c>();
        Project_Client_Contact__c tb = null;
         
        Set<Id> cl_con_ids = new Set<Id>();      
		for(integer i = 0; i < len; i++) 
		{
			valueId = jsonObj.getValue('rows').values.get(i).str;
			
			
			string newRole = jsonObj.getValue('table').values.get(i).values.get(3).obj.getString('value');
			string dateVal = jsonObj.getValue('table').values.get(i).values.get(4).obj.getString('value');
			if(valueId.compareTo('new_')>0)
			{
				try {
					String newContact = jsonObj.getValue('table').values.get(i).values.get(2).obj.getValue('value').obj.getString('lkid');
					tb = new Project_Client_Contact__c(Role__c=newRole, Moelis_Project__c=this.CurDealId, Comments__c=dateVal, Client_Contact__c=newContact);
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
			List<Project_Client_Contact__c> tb2List = 
					  [ Select Role__c, Moelis_Project__c, Comments__c, Client_Contact__c
                		From Project_Client_Contact__c 
                		where Moelis_Project__c=:this.CurDealId and Id=:valueId];
			if (tb2List.size() > 0) tb = tb2List[0];
			else tb = null;
			changed = false;
/*
			try {
                	if (newContact != tb.Client_Contact__c) {
                        if(newContact==null || newContact=='') tb.Client_Contact__c = null;
                        else tb.Client_Contact__c = newContact;
                        changed =  true;                    
                	}
			} catch (Exception e) { }
	*/	
			try {
				if (newRole != tb.Role__c) {
                        if(newRole==null || newRole=='') tb.Role__c = null;
                        else tb.Role__c = newRole;
                        changed =  true;                    
				}
			} catch (Exception e) { }
			
			if(tb != null)
			{
                    if(tb.Comments__c != dateVal) {
                        tb.Comments__c = dateVal;
                        changed = true; 
                    }
                    if (changed) tbList.add(tb);
             }
			}
			/*if (tb!=null){
				Id cid = tb.Client_Contact__c;
				if (cl_con_ids.contains(cid)){
					String cname = jsonObj.getValue('table').values.get(i).values.get(2).obj.getString('value'); 
					//throw new Exception('Duplicate contacts not allowed... Id=' + cid + ' Name=' + cname);
					String msg = 'Duplicate contacts not allowed... Id=' + cid + ' Name=' + cname;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
					return false;
				}
				cl_con_ids.add(cid);
			}*/
          }
		if(tbList.size()>0){ upsert tbList;}
        return true;
	}
	
     public PageReference save()
     {
     	this.saveJson();
        return null;
        //PageReference pageRef = new PageReference('/apex/DealContacts_AddMultyple?did='+CurDealId+'&page='+page+'&rows='+rows);
		//pageRef.setRedirect(true);
        //return pageRef;
     }
     
    public PageReference save_close()
    {
     	if (this.saveJson() == false) return null; 
     	PageReference pageRef = new PageReference('/'+CurDealId);
		pageRef.setRedirect(true);
        return pageRef;
    }
	
	public PageReference cancel()
    {
        PageReference pageRef = new PageReference('/'+CurDealId);
		pageRef.setRedirect(true);
        return pageRef;
    }
}