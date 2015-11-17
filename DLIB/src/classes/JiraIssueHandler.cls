public class JiraIssueHandler extends TriggerHandler {

	public JiraIssueHandler() {
		//this.clearMaxLoopCount();
	 // this.setMaxLoopCount(5);
	}

	/****************************************
	* context method overrides
	****************************************/

	protected override void afterUpdate() {
		updateWorklogsWithMilestone();
	}

	/****************************************
  * private processing methods
  ****************************************/

  private void updateWorklogsWithMilestone() {
  	Map<Id,SF_Issue__c> newMap = (Map<Id,SF_Issue__c>)Trigger.newMap;
  	Map<Id,SF_Issue__c> oldMap = (Map<Id,SF_Issue__c>)Trigger.oldMap;

  	Set<Id> issueIds = new Set<Id>();
  	List<Worklog__c> worklogsToUpd = new List<Worklog__c>();

  	for(Id key : Trigger.newMap.keySet()) {
  		if(newMap.get(key).Milestone__c != oldMap.get(key).Milestone__c || 
         newMap.get(key).Project__c != oldMap.get(key).Project__c) {
  			issueIds.add(key);
  		}
  	}

  	List<Worklog__c> worklogs = [select Id, SF_Issue__c, PSA_Project__c, PSA_Milestone__c, PSA_Timecard__c, PSA_Timecard__r.pse__milestone__c, PSA_Timecard__r.pse__submitted__c from Worklog__c where SF_Issue__c in :issueIds AND (PSA_Timecard__c = null or (PSA_Timecard__r.pse__submitted__c = false AND PSA_Timecard__r.pse__approved__c = false))  limit 10000];

  	for(Worklog__c w : worklogs) {

  		//if(w.PSA_Milestone__c != newMap.get(w.SF_Issue__c).Milestone__c && 
  		//	w.PSA_Timecard__r.pse__submitted__c == false && 
  		//	w.PSA_Timecard__r.pse__approved__c == false) {

	  			w.PSA_Milestone__c = newMap.get(w.SF_Issue__c).Milestone__c;
          w.PSA_Project__c = newMap.get(w.SF_Issue__c).Project__c;
	  			worklogsToUpd.add(w);
  		//}
  	}

  	update worklogsToUpd;
  }
}