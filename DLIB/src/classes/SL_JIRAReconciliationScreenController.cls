/****************************************************************************************
Name            : SL_JIRAReconciliationScreenController
Author          : Julia Kolesnik
Created Date    : January 28, 2014
Description     : SLFF-22
******************************************************************************************/
global class SL_JIRAReconciliationScreenController {
	
	public pse__Timecard_Header__c tc						{get;set;}
	public list<Item> lstMatches								{get;set;}
	public list<Item> lstNoMatches								{get;set;}
	public list<Item> lstResult								{get;set;}
	private set<Id> setExistingApprovedTimecards			{get;set;}
	public list<WorklogItem> lstJira						{get;set;}
	public list<WorklogItem> lstMissing						{get;set;}
	public Map<String,Decimal> mapWorklogTime;	
	public Map<String,Integer> mapWorklogCount;

	
	public SL_JIRAReconciliationScreenController() {
		tc = new pse__Timecard_Header__c();
		lstMatches = new list<Item>();
		lstNoMatches = new list<Item>();
		mapWorklogTime = new Map<String,Decimal>();
		mapWorklogCount = new Map<String,Integer>();
		setExistingApprovedTimecards = new set<Id>();
	}
	
	public PageReference approve() {
		if (ApexPages.hasMessages()) ApexPages.getMessages().clear();
		
		set<Id> setApprovedTimecards = new set<Id>();
		for (Item item:lstMatches) {
			if (item.IsSubmitted && !setExistingApprovedTimecards.contains(item.worklog.Id)) {
				setApprovedTimecards.add(item.worklog.Id);
			}
		}
		
		list<pse__Timecard_Header__c> lstTimecards = new list<pse__Timecard_Header__c>();
		for (pse__Timecard_Header__c item:[Select Id, Name, pse__Status__c, pse__submitted__c FROM pse__Timecard_Header__c WHERE Id IN :setApprovedTimecards]) {
			item.pse__submitted__c = true;
			item.pse__Status__c = 'Submitted';
			lstTimecards.add(item);
		}
		
		//try {
			if (lstTimecards.size()>0) update lstTimecards;
			
			for (Item item:lstMatches) {
				if (setApprovedTimecards.contains(item.worklog.Id) || setExistingApprovedTimecards.contains(item.worklog.Id) ) {
					item.worklog.pse__submitted__c = true;
					item.worklog.pse__Status__c = 'Submitted';
				}
			}
			return null;
		//} catch (exception ex) {
			//ApexPages.addMessages(ex);
		//}
	}
	
	public void refresh() {
		lstMatches = new list<Item>();
		lstNoMatches = new list<Item>();
		Map<String, Item> mapResult = new Map<String, Item>();
		lstJira = new List<WorklogItem>();

		Item curItem;
		map<string,pse__Timecard_Header__c> mapKeyWorklogs = new map<string,pse__Timecard_Header__c>();
		//for (Worklog__c item:[Select Id, JIRA_Start_Date__c, Week_Start_Date__c, PSA_Project__c, PSA_Timecard__c,  
		//						PSA_Timecard__r.pse__Total_Hours__c, PSA_Timecard__r.pse__Status__c, 
		//						PSA_Timecard__r.pse__submitted__c,JIRA_Issue__c, SF_Issue__c, SF_Issue__r.Milestone__c,
		//						PSA_Milestone__c, JIRA_Contact__c, hours__c, Timecard_Key__c, JIRA_User_Name__c
		//						FROM Worklog__c
		//						WHERE Week_Start_Date__c=:tc.pse__Start_Date__c limit 2000]) {
		for(pse__Timecard_Header__c item : [select Id, pse__resource__c, pse__resource__r.Department__c, pse__project__c, pse__milestone__c, pse__total_hours__c, 
												pse__Approved__c, pse__Status__c,pse__Submitted__c, Timecard_Key__c, pse__resource__r.JIRA_User_Name__c
											from pse__Timecard_Header__c 
											where (pse__resource__r.Department__c = 'Kiev Development' or pse__resource__r.Department__c = 'India Development')
											and pse__Start_Date__c = :tc.pse__Start_Date__c]) {
			if (!mapKeyWorklogs.containskey(item.Timecard_Key__c)) mapKeyWorklogs.put(item.Timecard_Key__c, item);
			if (item.pse__Submitted__c) setExistingApprovedTimecards.add(item.Id);
		}

		for (string key:mapKeyWorklogs.keySet()) {
			curItem = new Item(mapKeyWorklogs.get(key));
			curItem.JiraWLinSF += mapKeyWorklogs.get(key).pse__total_hours__c;
			
			//if(mapWL.containsKey(curItem.milestonecontact)) {
			//	curItem.JiraWL = mapWL.get(curItem.milestonecontact).timeSpentHours;
			//}

			mapResult.put(curItem.milestonecontact, curItem);
		}


		Map<String, WorklogItem> mapWL = new Map<String, WorklogItem>();
		for(WorklogItem wl : getWorklogInfo(tc.pse__Start_Date__c, tc.pse__Start_Date__c.addDays(7), 'Dynamo')) {
 
			if(mapResult.containsKey(wl.milestonecontact)) {
				mapResult.get(wl.milestonecontact).JiraWL += wl.timeSpentHours;
				mapResult.get(wl.milestonecontact).SFWorklogsTotal = mapWorklogTime.get(wl.milestonecontact);
				mapResult.get(wl.milestonecontact).countWorklogsInSF = mapWorklogCount.get(wl.milestonecontact);
				mapResult.get(wl.milestonecontact).countWorklogsInJIRA = mapResult.get(wl.milestonecontact).countWorklogsInJIRA == null ? wl.countWorklogsInJIRA : mapResult.get(wl.milestonecontact).countWorklogsInJIRA + wl.countWorklogsInJIRA;
			} else {
				lstJira.add(wl);
			}
		}	

		for(WorklogItem wl : getWorklogInfo(tc.pse__Start_Date__c, tc.pse__Start_Date__c.addDays(7), 'Trekbin')) {
 
			if(mapResult.containsKey(wl.milestonecontact)) {
				mapResult.get(wl.milestonecontact).JiraWL += wl.timeSpentHours;
				mapResult.get(wl.milestonecontact).SFWorklogsTotal = mapWorklogTime.get(wl.milestonecontact);
				mapResult.get(wl.milestonecontact).countWorklogsInSF = mapWorklogCount.get(wl.milestonecontact);
				mapResult.get(wl.milestonecontact).countWorklogsInJIRA = mapResult.get(wl.milestonecontact).countWorklogsInJIRA == null ? wl.countWorklogsInJIRA : mapResult.get(wl.milestonecontact).countWorklogsInJIRA + wl.countWorklogsInJIRA;
			} else {
				lstJira.add(wl);
			}
		}	

		for(String key : mapResult.keySet()) {
			if(mapResult.get(key).JiraWL == mapResult.get(key).JiraWLinSF) {
				lstMatches.add(mapResult.get(key));
			}
			else {
				lstNoMatches.add(mapResult.get(key));
			}
		}

		Map<String, Contact> mapC = new Map<String,Contact>();


		for(Contact c : [select Id, JIRA_User_Name__c from Contact where pse__is_Resource__c = true and pse__is_Resource_Active__c = true and Recordtype.Name = 'Employee']) {
			mapC.put(c.JIRA_User_Name__c, c);
		}

		for(WorklogItem w : lstJira) {
			if(mapC.containsKey(w.author)) w.Contact = mapC.get(w.author);

		}
 
	}

	@RemoteAction
    global static list<Issue> getIssuesFromJqlSearch(String jqlSearchString) {
        HttpResponse res;
		JIRARequest jr = new JIRARequest('key,id',jqlSearchString);
		jr.TEST_FLAG = 1;
		jr.sendrequest();
		try {
			res = jr.res;
        	JIRAIssue obj = (JIRAIssue) System.JSON.deserialize(res.getBody(), JIRAIssue.class);
        	//system.debug('-------obj.worklog='+obj.worklog);
        	return obj.worklog;
        } catch (System.CalloutException e) {
            System.debug(res.toString());
            return null;
    	}
    }
    
    //@RemoteAction
    public list<WorklogItem> getWorklogInfo(Date strStartDate, Date strEndDate, String targetGroup) {
    	string milestonekey = 'null';
    	date startDate, endDate;
    	Set<String> setIssues = new Set<String>();
    	
    	map<String, SF_Issue__c> mapIssueName_Issue = new map<String, SF_Issue__c>();

 
        HttpResponse res;
        list<WorklogItem> lstWL = new list<WorklogItem>();
		//string endpoint = '/issue/'+issue.key+'/worklog/';
		string endpoint = '/timesheet-gadget/1.0/raw-timesheet.json?targetGroup=' + targetGroup + '&startDate=' + strStartDate + '&endDate=' + strEndDate;
		JIRARequest jr = new JIRARequest(endpoint);
		jr.JIRA_PREFIX = '/rest';
		jr.TEST_FLAG = 2;
		jr.sendrequest();
		try {
			res = jr.res;
	    	JIRAIssue obj = (JIRAIssue) System.JSON.deserialize(res.getBody(), JIRAIssue.class);
 
	    	date wlDate;
	    	map<string,map<String,WorklogItem>> mapContactWorklogs = new map<string,map<String,WorklogItem>>();
	    	system.debug(obj);
	    	if(obj != null && obj.worklog != null) { 
	    		for (Issue item:obj.worklog) {
	    			system.debug(item);
	    			if(item != null && item.key != null) setIssues.add(item.key);
	    		}
	    	}

	        for (SF_Issue__c item:[Select Milestone__c, Id, Name FROM SF_Issue__c WHERE Name in :setIssues ]) {
	        	mapIssueName_Issue.put(item.Name, item);
	        }
	        for (AggregateResult item:[SELECT psa_milestone__c milestone, jira_contact__r.jira_user_name__c cont, sum(hours__c) hrs, count(Id) cnt FROM worklog__c  
	        							WHERE SF_Issue__r.Name in :setIssues 
	        							AND Week_Start_Date__c = :strStartDate
	        							AND jira_contact__r.jira_user_name__c != null
	        							AND psa_milestone__c != null
	        							GROUP BY psa_milestone__c, jira_contact__r.jira_user_name__c]) {
	        	mapWorklogTime.put(item.get('milestone') + '-' + item.get('cont'), (Decimal)item.get('hrs'));
	        	mapWorklogCount.put(item.get('milestone') + '-' + item.get('cont'), (Integer)item.get('cnt'));
	        }
    		//startDate = Datetime.valueOf(strStartDate.replace('T',' ')).date();
    		//endDate = Datetime.valueOf(strEndDate.replace('T',' ')).date();
    		startDate = strStartDate;
    		endDate = strEndDate;

    		if(obj == null || obj.worklog == null) return lstWL;

	    	for (Issue issue:obj.worklog) {
	    		for(Worklog item : issue.entries) {

		    		wlDate = convertFromUnix(Integer.valueOf(item.startDate.left(10)));
		    		if (wlDate>=startDate && wlDate<endDate) {
			    		if (!mapContactWorklogs.containsKey(issue.key)) mapContactWorklogs.put(issue.key,new map<String, WorklogItem>());
			    		if(!mapContactWorklogs.get(issue.key).containsKey(item.author)) {
			    			mapContactWorklogs.get(issue.key).put(item.author, new WorklogItem());
			    			lstWL.add(mapContactWorklogs.get(issue.key).get(item.author));
			    		}
			    		
			    		WorklogItem wl = mapContactWorklogs.get(issue.key).get(item.author);
			    		if(wl.timeSpentHours == null) wl.timeSpentHours = 0.0;
			    		wl.timeSpentHours += item.timeSpent / 3600.0;
			    		wl.key = issue.key;
			    		wl.author = item.author;
			    		wl.countWorklogsInJIRA = wl.countWorklogsInJIRA == null ? 1 : wl.countWorklogsInJIRA + 1;

			    		if(mapIssueName_Issue.containsKey(wl.key)) {
			    			wl.milestonecontact = mapIssueName_Issue.get(wl.key).Milestone__c + '-' + item.author;
			    			system.debug('Milestone Contact: ' + wl.milestonecontact);
			    		}


		    		}
		    	}
	    	}

	    	return lstWL;
    	} catch (System.CalloutException e) {
            System.debug(res.toString());
            return null;
    	}
    }
    
    public static Date convertFromUnix(Integer dt) {
    	return datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0).addSeconds(dt).date();
    }

    global class JIRAIssue {
		global list<Issue> worklog;
    }
    
	global class Issue {
	    global String id;
	    global String key;
	    global List<Worklog> entries;
  	}
  	
  	global class JIRAWorklog {
		global list<Worklog> worklogs;
	}
	
	global class Worklog {
	    global String id;
	    global Integer timeSpent;
	    public String startDate;
	    global String author;
  	}
  	
  	public class Author {
	    public String name;
	    public String emailAddress;
  	}
  	
  	public class WorklogItem {
	    public String key {get;set;}
	    public String milestonecontact {get;set;}
	    public String author {get;set;}
	    public decimal timeSpentHours {get;set;}
	    public integer countWorklogsInJIRA {get;set;}
	    public Contact contact {get;set;}
	    public pse__milestone__c milestone {get;set;}
	    //public Id getMilestone {
	    //	if(this.milestonecontact == null) return null;
	    //	if(this.milestonecontact.split('-').size() > 0)
	    //		return this.milestonecontact.split('-')[0];
	    //}
	    //public Id getContact {
	    //	if(this.milestonecontact == null) return null;
	    //	if(this.milestonecontact.split('-').size() > 1)
	    //		return this.milestonecontact.split('-')[1];
	    //}	    
  	}
  	
  	public class MissingItem {
  		public Contact contact {get;set;}
  		public pse__Milestone__c milestone {get;set;}
  		public WorklogItem item {get;set;}
  	}

  	public class Item {
  		public string TimecardKey			{get;set;}
  		public pse__Timecard_Header__c worklog			{get;set;}
  		public decimal JiraWL				{get;set;}
  		public decimal JiraWLinSF			{get;set;}
  		public integer countWorklogsInSF	{get;set;}
		public integer countWorklogsInJIRA	{get;set;}
  		public decimal SFWorklogsTotal		{get;set;}
  		public boolean IsSubmitted			{get;set;}
  		public string milestonecontact		{get;set;}
  		public Item (pse__Timecard_Header__c p_worklog) {
  			worklog = p_worklog;
  			IsSubmitted = p_worklog.pse__Submitted__c;
  			JiraWL = 0;
  			JiraWLinSF = 0;
  			milestonecontact = p_worklog.pse__milestone__c;
  			if (p_worklog.pse__resource__r.Jira_User_Name__c!=null) milestonecontact = milestonecontact + '-' + p_worklog.pse__resource__r.Jira_User_Name__c;
  		}
  	}
}