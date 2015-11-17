trigger UpdateProjectCompanies on Company_Project__c (after delete, after insert, after update) 
{
	List<Company_Project__c> lChanges=(trigger.isDelete?trigger.old:trigger.new);
	Map<Id,Project__c> mProjects=new Map<Id,Project__c>();
	
	for(Company_Project__c cp : lChanges)
	{
		mProjects.put(cp.Project__c, new Project__c(id=cp.Project__c,Related_Companies__c=''));
	}
	
	List<Company_Project__c> lProjectsToUpdate=[SELECT Project__c, Company__r.Name FROM Company_Project__c WHERE Project__c IN :mProjects.keySet() ORDER BY Project__c, Company__r.Name];
	
	
	for(Company_Project__c cp : lProjectsToUpdate)
	{
		Project__c p=mProjects.get(cp.Project__c);
		p.Related_Companies__c=p.Related_Companies__c+', '+cp.Company__r.Name;
	}
	
	for(Project__c p : mProjects.values())
	{
		if(p.Related_Companies__c.startsWith(', '))
			p.Related_Companies__c=p.Related_Companies__c.substring(2);
	}

	update mProjects.values();
}