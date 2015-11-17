public with sharing class SL_ProjectResource_Trigger_Handler 
{
private boolean boolIsExecuting = false;
    private integer numBatchSize = 0;
    public static boolean isFillRollUppFields = false;
      
    public SL_ProjectResource_Trigger_Handler(boolean isExecuting, integer size)
    {
        boolIsExecuting = isExecuting;
        numBatchSize = size;
    }
    
    
    public void OnAfterInsert(list<Project_Resource__c> newProjectResources)
    {   
        //if(!isFillRollUppFields)
       // {
            isFillRollUppFields = true;
            String err = FillRollUppFields(newProjectResources);
            String ch_err = changeError(err);
            if(ch_err != null && ch_err != '')
            {
            	for (Project_Resource__c a : newProjectResources)  a.Banker__c.addError(ch_err);
            }
       // }
    }
    
    public void OnAfterDelete(list<Project_Resource__c> oldProjectResources)
    { 
       // if(!isFillRollUppFields)
       // {
            isFillRollUppFields = true;
           	String err = FillRollUppFields(oldProjectResources);
           	String ch_err = changeError(err);
            if(ch_err != null && ch_err != '')
            {
            	for (Project_Resource__c a : oldProjectResources)  a.addError(ch_err);
            }
       // }
    }

    
    public void OnAfterUpdate(map<Id,Project_Resource__c> oldProjectResources, map<Id,Project_Resource__c> newProjectResources,list<Project_Resource__c> triggernew)
    {   
    	//if(!isFillRollUppFields)
        //{
            isFillRollUppFields = true;
            list<Project_Resource__c> newProjectResourcesEdit = new list<Project_Resource__c>();
            for(Id itemId : newProjectResources.keySet())
            {
            	if(	newProjectResources.get(itemId).Title__c != oldProjectResources.get(itemId).Title__c ||
            		newProjectResources.get(itemId).Status__c != oldProjectResources.get(itemId).Status__c ||
            		newProjectResources.get(itemId).Banker__c != oldProjectResources.get(itemId).Banker__c)
            	{
            		newProjectResourcesEdit.add(newProjectResources.get(itemId));
            	}
            }
            String err = FillRollUppFields(newProjectResourcesEdit);
            String ch_err = changeError(err);
            if(ch_err != null && ch_err != '')
            {
            	for (Project_Resource__c a : triggernew)  a.Banker__c.addError(ch_err);
            }
        //}
    }
    
    public static String changeError(String err)
    {
    	String changeError = '';
    	if(err != null && err.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,'))
        {
            	String[] aerr = err.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,', 2);
            	if(aerr != null && aerr[1] != null)  changeError = aerr[1];
        }
    	return changeError;
    }
    
    private static String FillRollUppFields(list<Project_Resource__c> projectResources)
    {
    	map<Id,Double> map_ProjectId_countProjectResources = new map<Id,Double>();
    	set<Id> listProjectIds = new set<Id>();
    	list<MDSC_Titles__c> MDSCTitles = MDSC_Titles__c.getall().values();
		Set<String> listMDSCTitles = new Set<String>();
		if(MDSCTitles != null) 
		{
			for(MDSC_Titles__c item : MDSCTitles) listMDSCTitles.add(item.Name);
		}
    	
    	for(Project_Resource__c item : projectResources)
    	{
    		if(	item.Project__c != null)	
    		{
    			listProjectIds.add(item.Project__c);
    			map_ProjectId_countProjectResources.put(item.Project__c, 0);
    		}
    	}
    	system.debug('listProjectIds = '+listProjectIds);
    	if(listProjectIds.size() > 0)
    	{
    		
    		
    		for(Project_Resource__c item : [	SELECT ID, Project__c
    											FROM Project_Resource__c 
    											WHERE 	Project__c IN : listProjectIds AND 
    													Status__c = 'Active' AND 
    													Banker__r.Title__c IN : listMDSCTitles ])
    		{
    			map_ProjectId_countProjectResources.put(item.Project__c, map_ProjectId_countProjectResources.get(item.Project__c) + 1);
    		}
    		
    		system.debug('map_ProjectId_countProjectResources = '+map_ProjectId_countProjectResources);
    		list<Ibanking_Project__c> listIbankingProjectToUpdate = new list<Ibanking_Project__c>();
    		for(Id projectId : listProjectIds)
    		{
    			Ibanking_Project__c newIbankingProject = new Ibanking_Project__c(Id = projectId);
    			if(map_ProjectId_countProjectResources.get(projectId) != null)
	    			newIbankingProject.count_DealTeamMD__c = map_ProjectId_countProjectResources.get(projectId);
    			listIbankingProjectToUpdate.add(newIbankingProject);
    		}
    		system.debug('listIbankingProjectToUpdate = '+listIbankingProjectToUpdate);
    		if(listIbankingProjectToUpdate.size() > 0)  
    		{
    			//update listIbankingProjectToUpdate;
    			
    			try 
    			{
		            update listIbankingProjectToUpdate;
		            
		        } 
		        catch (Exception e) 
		       	{
		        	return e.getMessage();
		    	}
        	
    		}
    	}
    	return null;
    }
    
   	public boolean IsTriggerContext
   	{
        get{ return this.boolIsExecuting;}
    }
     
    public boolean IsVisualforcePageContext
    {
        get{ return !this.IsTriggerContext;}
    }
     
    public boolean IsWebServiceContext
    {
        get{ return !this.IsTriggerContext;}
    }
     
    public boolean IsExecuteAnonymousContext
    {
        get{ return !this.IsTriggerContext;}
    }
}