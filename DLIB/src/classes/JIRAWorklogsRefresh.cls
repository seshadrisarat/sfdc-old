public with sharing class JIRAWorklogsRefresh {
	public Integer numberOfHours = -2;
	public List<SF_Issue__c> issues;
	public boolean shouldDelete = false;

	public JIRAWorklogsRefresh() {
		this.issues = [Select Id, Name, Worklogs_Needed__c, Milestone__c, OA_Task_Id__c, Project__c, Project__r.Legacy_Project__c FROM SF_Issue__c WHERE Worklogs_Needed__c=true order by Name limit 10];
	}

	public JIRAWorklogsRefresh(String issueName) {
		this.issues = [Select Id, Name, Worklogs_Needed__c, Milestone__c, OA_Task_Id__c, Project__c, Project__r.Legacy_Project__c FROM SF_Issue__c WHERE Name = :issueName];
	}

	public JIRAWorklogsRefresh(List<SF_Issue__c> lstIssues) {
		this.issues = lstIssues;
	}

	public void run(){
		HttpResponse res;
		string endpoint;
		JIRARequest jr;
		
		List<Worklog__c> lsWorklogs = new List<Worklog__c>();
        Worklog__c curWorklog;
        map<string,Id> mapIssueName2Ids = new map<string,Id>();
        for (SF_Issue__c item:issues){
        	mapIssueName2Ids.put(item.Name,item.Id);
        }
        
		set<string> setUpdatedWorklogs = new set<string>();
		set<string> setContactJIRANames = new set<string>();
		for (SF_Issue__c item:issues){
			endpoint = '/issue/'+item.Name+'/worklog/';
			jr = new JIRARequest(endpoint);
			jr.TEST_FLAG = 2;
			jr.sendrequest();
			res = jr.res;
        	JIRAWorklogs obj = (JIRAWorklogs) System.JSON.deserialize(res.getBody(), JIRAWorklogs.class);
        	if (obj!=null) {
        		for (Worklog wl:obj.worklogs) {
        			Datetime updated = (datetime)json.deserialize('"' + wl.started + '"', datetime.class);
        			if (!setUpdatedWorklogs.contains(wl.id) && datetime.now().addHours(numberOfHours) <= updated) {
	        			curWorklog = new Worklog__c();
	                    curWorklog.JIRA_ID__c = wl.id;
	                    curWorklog.JIRA_Notes__c = wl.comment;
	                    curWorklog.JIRA_Issue__c = item.Name;
	                    curWorklog.Jira_Created__c = (datetime)json.deserialize('"' + wl.created + '"', datetime.class);
	                    curWorklog.Jira_Updated__c = (datetime)json.deserialize('"' + wl.updated + '"', datetime.class);
	                    curWorklog.SF_Issue__c = mapIssueName2Ids.get(item.Name);
	                    curWorklog.hours__c = wl.timeSpentSeconds/(60*60);
	                    curWorklog.PSA_Milestone__c = item.Milestone__c;
	                    curWorklog.PSA_Project__c = item.Project__c;
	                    curWorklog.Project__c = item.Project__r.Legacy_Project__c;
	                    curWorklog.OA_ProjectTask_ID__c = item.OA_Task_Id__c;
	                    curWorklog.JIRA_User_Name__c = wl.author.name;
	                    //curWorklog.Project_Task__r = new Project_Task__c(OA_Project_Task_Id__c = item.OA_Task_Id__c);
	                    curWorklog.JIRA_Start_Date__c = (datetime)json.deserialize('"' + wl.started + '"', datetime.class);
	                    curWorklog.Seconds__c = wl.timeSpentSeconds;
	                    curWorklog.Send_to_OA__c = true;

	                    lsWorklogs.add(curWorklog);
	                    setUpdatedWorklogs.add(wl.id);
	                    setContactJIRANames.add(curWorklog.JIRA_User_Name__c);
        			}
        		}
        	}
        	
			item.Worklogs_Needed__c = false;
		}
		
    	map<string,id> mapJIRANameToContactIds = new map<string,id>();
    	for (Contact item:[Select Id, JIRA_User_Name__c FROM Contact WHERE JIRA_User_Name__c IN :setContactJIRANames]) {
    		mapJIRANameToContactIds.put(item.JIRA_User_Name__c, item.Id);
    	}
    	
      	for (Worklog__c item:lsWorklogs)
      	{
      		if (mapJIRANameToContactIds.containsKey(item.JIRA_User_Name__c)) {
      			item.JIRA_Contact__c = mapJIRANameToContactIds.get(item.JIRA_User_Name__c);
      		}
      	}
      	
		try {
			Database.upsert(lsWorklogs,Worklog__c.Fields.JIRA_ID__c,false);
    	} catch(Exception e) {
    		for (SF_Issue__c item:issues){
    			item.Worklog_Error__c = e.getMessage() + '\r\n' + e.getStackTraceString();
    			item.Worklogs_Needed__c = false;
    		}
    	}
    	update issues;
    	
    	if(shouldDelete && !setUpdatedWorklogs.isEmpty()) {
	    	list<Worklog__c> lstWorklogsToDel = new list<Worklog__c>();
	    	for (Worklog__c item:[Select Id, JIRA_ID__c, SF_Issue__c FROM Worklog__c WHERE SF_Issue__c IN :mapIssueName2Ids.values() AND PSA_Timecard__r.pse__submitted__c = false AND PSA_Timecard__r.pse__approved__c = false]) {
	    		if (!setUpdatedWorklogs.contains(item.JIRA_ID__c)) lstWorklogsToDel.add(item);
	    	}
	    	
	    	delete lstWorklogsToDel;
	    }
	}
	
	public class JIRAWorklogs {
		public integer total;
		public list<Worklog> worklogs;
	}
	
	public class Worklog {
	    public String id;
	    public String comment;
	    public String timeSpent;
	    public Decimal timeSpentSeconds;
	    public String started;
	    public String updated;
	    public String created;
	    public Author author;
  	}
  	
  	public class Author {
	    public String name;
	    public String emailAddress;
  	}
}