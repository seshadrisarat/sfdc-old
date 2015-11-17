public class psaSelfAssignmentController {
	public pse__Assignment__c assignment 	{get;set;}
	public pse__Schedule__c schedule 		{get;set;}
	public string projects 					{get;set;}
	public Contact resource 				{get;set;}

	public psaSelfAssignmentController() {
		init();
	}

	private void init() {
		resource = null;
		for (Contact item:[Select Id, Name FROM Contact WHERE pse__Salesforce_User__c = :UserInfo.getUserId() AND pse__Is_Resource__c = true AND pse__Is_Resource_Active__c = true limit 1]) {
			resource = item;
		}
		if (resource == null) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'A Resource record was not found linked to your force.com user. A Resource record is required for this operation.'));
			return;
		}
		
		assignment = new pse__Assignment__c();
		schedule = new pse__Schedule__c(pse__Sunday_Hours__c = 0.00,pse__Monday_Hours__c = 8.00,pse__Tuesday_Hours__c = 8.00,pse__Wednesday_Hours__c = 8.00,pse__Thursday_Hours__c = 8.00,pse__Friday_Hours__c = 8.00,pse__Saturday_Hours__c = 0.00);
		
		list<string> lstprojects = new list<string>();
		projects = '';
		for (pse__Proj__c item:[Select Id, Name FROM pse__Proj__c WHERE pse__Is_Active__c=true order by Name]) {
			lstprojects.add(item.Name);
		}
		if (!lstprojects.isEmpty()) projects = '"'+String.join(lstprojects, '","' )+'"';
	}


	public pagereference save() {
		string accountName;
		for (pse__Proj__c item:[Select Id, pse__Account__r.Name FROM pse__Proj__c WHERE Id=:assignment.pse__Project__c]) {
			accountName = item.pse__Account__r.Name;
		}

		Savepoint sp = Database.setSavepoint();
		try {
			upsert schedule;
			assignment.Name = accountName + ' - ' + resource.Name;
			assignment.pse__Schedule__c = schedule.Id;
			assignment.pse__Resource__c = resource.Id;
			upsert assignment;

			pagereference p = new pagereference('/'+assignment.Id);
			p.setRedirect(true);
			return p;

		} catch (DmlException e) {
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
			return null;
		}
		
	}
	
	public void checkAssignment() {
		String project = ApexPages.currentPage().getParameters().get('project');
		String role = ApexPages.currentPage().getParameters().get('role');
		Id projectId = null;
		for (pse__Proj__c item:[Select Id FROM pse__Proj__c WHERE Name=:project]) {
			projectId = item.Id;
		}
		
		for (pse__Assignment__c item:[Select Id, pse__Schedule__c, pse__Project__c, pse__Role__c, pse__Resource__c, pse__Nick_Name__c 
									FROM pse__Assignment__c WHERE pse__Project__c=:projectId 
									AND pse__Resource__c=:resource.Id AND pse__Role__c=:role limit 1]) {
			assignment = item;	
			for (pse__Schedule__c sc:[Select pse__Start_Date__c, pse__End_Date__c, pse__Sunday_Hours__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, 
									pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c FROM pse__Schedule__c WHERE Id=:item.pse__Schedule__c limit 1]) {
				schedule = sc;				
			}
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Assignment already exists.'));
			return;
		}
		
		assignment = new pse__Assignment__c(pse__Project__c = projectId, pse__Role__c = role);
		schedule = new pse__Schedule__c(pse__Sunday_Hours__c = 0.00,pse__Monday_Hours__c = 8.00,pse__Tuesday_Hours__c = 8.00,pse__Wednesday_Hours__c = 8.00,pse__Thursday_Hours__c = 8.00,pse__Friday_Hours__c = 8.00,pse__Saturday_Hours__c = 0.00);
		//ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Assignment doesn\'t exist for these Project and Role. New Assignment will be created.'));
		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Assignment doesn\'t exist for these Project and Role. New Assignment will be created.'));
	}
}