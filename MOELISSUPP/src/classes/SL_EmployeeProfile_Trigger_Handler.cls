public with sharing class SL_EmployeeProfile_Trigger_Handler  
{
	private boolean boolIsExecuting = false;
    private integer numBatchSize = 0;
    public static boolean isFillRollUppFields = false;
      
    private Set<String> listMDSCTitles = null;
    
    public SL_EmployeeProfile_Trigger_Handler(boolean isExecuting, integer size)
    {
        boolIsExecuting = isExecuting;
        numBatchSize = size;
        this.listMDSCTitles = new Set<String>();
        this.listMDSCTitles = getListMDSCTitles();
    } 
    
    public void OnBeforeUpdate(map<Id,Employee_Profile__c> oldEmployeeProfiles, map<Id,Employee_Profile__c> newEmployeeProfiles,list<Employee_Profile__c> triggernew)
    {   
    	//if(!isFillRollUppFields)
        //{
            isFillRollUppFields = true;
            list<Employee_Profile__c> newEmployeeProfilesEdit = new list<Employee_Profile__c>();
            for(Id itemId : newEmployeeProfiles.keySet())
            {
            	if(	newEmployeeProfiles.get(itemId).Title__c != oldEmployeeProfiles.get(itemId).Title__c &&
            		!this.listMDSCTitles.contains(newEmployeeProfiles.get(itemId).Title__c) &&
            		this.listMDSCTitles.contains(oldEmployeeProfiles.get(itemId).Title__c)
            	
            	/*||
            		newEmployeeProfiles.get(itemId).Status__c != oldEmployeeProfiles.get(itemId).Status__c*/)
            	{
            		newEmployeeProfilesEdit.add(newEmployeeProfiles.get(itemId));
            	}
            }
            String err = FillRollUppFields(newEmployeeProfilesEdit);
            String ch_err = SL_ProjectResource_Trigger_Handler.changeError(err);
            if(ch_err != null && ch_err != '')
            {
            	for (Employee_Profile__c a : triggernew)  a.Title__c.addError(ch_err);
            }
        //}
    }
    
    public static set<String> getListMDSCTitles()
    {
    	List<MDSC_Titles__c> MDSCTitles = MDSC_Titles__c.getall().values();
    	Set<String> tmp_listMDSCTitles = new Set<String>();
		if(MDSCTitles != null) 
		{
			for(MDSC_Titles__c item : MDSCTitles) tmp_listMDSCTitles.add(item.Name);
		} 
		return tmp_listMDSCTitles;
    }
    
    private String FillRollUppFields(list<Employee_Profile__c> EmployeeProfiles)
    {
    	map<Id,Double> map_ProjectId_countProjectResources = new map<Id,Double>();
    	set<Id> listEmployeeIds = new set<Id>();
    	for(Employee_Profile__c item : EmployeeProfiles)
    	{
    		listEmployeeIds.add(item.id);
    	}
    	if(listEmployeeIds.size() > 0)
    	{
    		set<Id> listProjectIds = new set<Id>();
    		for(Project_Resource__c item : [	SELECT ID, Project__c,Banker__c
    											FROM Project_Resource__c 
    											WHERE 	Banker__c IN : listEmployeeIds])
    		{
    			listProjectIds.add(item.Project__c);
    			map_ProjectId_countProjectResources.put(item.Project__c, 0);
    		}
    		if(listProjectIds.size() > 0)
    		{
    			for(Project_Resource__c item : [	
    											SELECT ID, Project__c,Banker__c,Banker__r.Title__c
    											FROM Project_Resource__c 
    											WHERE 	Project__c IN : listProjectIds AND 
    													Banker__c NOT IN : listEmployeeIds AND
    													Status__c = 'Active' AND 
    													Banker__r.Title__c IN : listMDSCTitles ])
	    		{
		    		if(!map_ProjectId_countProjectResources.keySet().contains(item.Project__c))map_ProjectId_countProjectResources.put(item.Project__c, 0);
		    		map_ProjectId_countProjectResources.put(item.Project__c, map_ProjectId_countProjectResources.get(item.Project__c) + 1);
	    		}
    		}
    		list<Ibanking_Project__c> listIbankingProjectToUpdate = new list<Ibanking_Project__c>();
    		if(listProjectIds.size() > 0)
    		{
	    		for(Id projectId : listProjectIds)
	    		{
	    			Ibanking_Project__c newIbankingProject = new Ibanking_Project__c(Id = projectId);
	    			if(map_ProjectId_countProjectResources.get(projectId) != null)
		    			newIbankingProject.count_DealTeamMD__c = map_ProjectId_countProjectResources.get(projectId);
	    			listIbankingProjectToUpdate.add(newIbankingProject);
	    		}
	    		if(listIbankingProjectToUpdate.size() > 0)  
	    		{
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