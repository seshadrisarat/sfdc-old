public with sharing class ViewTaskExtensionController {
	private Id taskId;
	
	public ViewTaskExtensionController(ApexPages.StandardController stdController) {
		taskId = stdController.getId();
	}
	
	public PageReference initPage() {
		try {
			Task t = [SELECT Id, Call_Sync_Id__c FROM Task WHERE Id = :taskId];
			if(t.Call_Sync_Id__c != null) {
				Event e = [SELECT Id FROM Event WHERE Id = :t.Call_Sync_Id__c];
				
				PageReference pr = new PageReference('/' + e.Id);
				pr.setRedirect(true);
				return pr;
			}
		} catch(Exception e) {}
		
		return null;
	}
}