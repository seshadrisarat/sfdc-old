/**
* Test methods are in Test_Timetracker.cls
**/
/*
Class which generate JSON data for "Deal Projects" section for current WEEK and current EMPLOYEE and delete duplicated timetrackers


Modified: Privlad 02/23/2010 - task: 956
modified: Vika 03/19/2010 - Task #10065
modified: yuguziy 08/04/2010 - Task #10249
modified: Sruti 15/07/2013 - MOELISSUPP - 5
*/
public without sharing class TimeTrackerJSON {
    //public List<Time_Tracker__c> objList {get; set;}
    public List<timeTracker> objList {get; set;}
    public List<Time_Tracker__c> toDeleteObjList = new List<Time_Tracker__c>();
    public List<Time_Tracker__c> newTimeTrackerRecordsList {get; set;}
    public List<picklistItem> TT_Status_values {get; set;}
    //public List<picklistItem> TT_SeniorBanker_values {get; set;}
    public Id tssId;
    public Integer fieldNoteMaxLength { get; set; }
    Set<Id> listDealId;
    public TimeTrackerJSON()
    {
        objList = new list<timeTracker>();
        listDealId = new Set<Id>();
        newTimeTrackerRecordsList = new list<Time_Tracker__c>();
        tssId = System.currentPageReference().getParameters().get('tssid');
        if (tssId != null) {
        	//objList = TimeTracker_logic.getTimeTrackerList(tssId);
			try {
				listDealId = getTimeTrackerDealIds();
        		/*
                	create TimeTrackerDetail records for deal section 
                */
                TimeSheet_Summary__c curTimeSheetSummaryObj = TimeTracker_logic.getTimeSheetById(tssId);
                if(curTimeSheetSummaryObj != null && curTimeSheetSummaryObj.Employee__c != null && curTimeSheetSummaryObj.Stage__c != 'Submitted') 
                {
					// list of 'Active' DealTeamMembers  for Current Employee where Deal Name NOT 'Non-Deal Project', Deal Status 'Active' or 'Hold'
					for(Project_Resource__c presObj:[
			                			Select Project__c,Project__r.Name,Status__c, Id, Banker__r.User_ID__c, Banker__c 
			                			From Project_Resource__c 
			                			where Project__r.Name!='Non-Deal Project' and 
			                				  Banker__c = :curTimeSheetSummaryObj.Employee__c and 
			                				  Status__c = 'Active' and
			                				  (Project__r.Status__c  = 'Active' or Project__r.Status__c  = 'Hold') AND
			                				  Project__c Not IN : listDealId
			                			limit 100])
					{
						if(	 presObj.Project__c!=null && tssId!=null)
						{
							Time_Tracker__c ttNewObj = new Time_Tracker__c(Deal__c=presObj.Project__c,Time_Sheet_Summary__c = tssId,Employee__c = curTimeSheetSummaryObj.Employee__c,Week_Start_Date__c =curTimeSheetSummaryObj.Week_Start_Date__c);
							newTimeTrackerRecordsList.add(ttNewObj);
						}
					}
				}
				
			} catch(Exception ex) {
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'DB Error[getTimeTrackerList]: '+ex);
				ApexPages.addMessage(msg);
			}
        }

        Schema.DescribeFieldResult fieldResult = Time_Tracker__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> PickilstValues = fieldResult.getPicklistValues();
        TT_Status_values = new List<picklistItem>();
        
        TT_Status_values.add(new picklistItem('',''));
        for (Schema.PicklistEntry pVal : PickilstValues){TT_Status_values.add(new picklistItem(pVal.value,pVal.label));}
        
        //TT_SeniorBanker_values = getTT_SeniorBanker_values();
		
        this.fieldNoteMaxLength = Time_Tracker__c.Note__c.getDescribe().getLength();
    }
    
	private void getTimeTrackerRecords(String queryStrAdditional) 
	{ 
		List<Time_Tracker__c> timeTrackersList = new List<Time_Tracker__c>();
        String queryStr = '';
        if (tssId != null) 
        {
        	queryStr += 'SELECT '+TimeTracker_logic.ttFields+' FROM Time_Tracker__c ';
			queryStr += 'WHERE Time_Sheet_Summary__r.Id = \''+tssId+'\' ';
			queryStr += 'AND Deal__r.Name != \'Non-Deal Project\' ';
			queryStr += 'AND (Non_Deal_Project__c = null or Non_Deal_Project__c = \'\') ';
			if(queryStrAdditional != null && queryStrAdditional != '') queryStr += 'AND Deal__r.Stage__c ' +queryStrAdditional+ ' ';
			queryStr += 'ORDER BY Deal__r.Stage__c Desc,Deal__r.Client__r.Name,Deal__r.Name ';
			queryStr += 'LIMIT 200';

			timeTrackersList = database.query(queryStr);
        }
        
        map<Id,list<picklistItem>> mapDealId_SBankers = new map<Id,list<picklistItem>>();
        list<String> listMDSCTitles = getSeniorBankerTitles();
        for(Project_Resource__c item:[
			 SELECT Project__c,Project__r.Name,Status__c, Id, Banker__r.User_ID__c, Banker__c,Banker__r.Name 
			 FROM Project_Resource__c 
			 WHERE Project__r.Name!='Non-Deal Project' AND 
			       Banker__r.Title__c IN : listMDSCTitles AND 
			       Status__c = 'Active' AND
			       Banker__r.Status__c = 'Active' AND
			       (Project__r.Status__c  = 'Active' or Project__r.Status__c  = 'Hold') AND
			       Project__c IN : listDealId
			 ORDER BY Project__c,Banker__r.Name])
		{
			if(item.Project__c!=null)
			{
				if(!mapDealId_SBankers.keySet().contains(item.Project__c)) 	mapDealId_SBankers.put(item.Project__c, new list<picklistItem>());
				mapDealId_SBankers.get(item.Project__c).add(new picklistItem(item.Banker__c, item.Banker__r.Name));
			}
		}
		Map<Id,Time_Tracker__c> TTid_TTobj_Map = new Map<Id,Time_Tracker__c>();
		for(Time_Tracker__c temp: timeTrackersList)
		{
			if(TTid_TTobj_Map.containsKey(temp.Deal__c)) this.toDeleteObjList.add(temp);
			else 
			{
			        if (temp.Note__c !=null)
			        {
			              	temp.Note__c = temp.Note__c.replaceAll('\r\n',' ');
			              	temp.Note__c = temp.Note__c.replaceAll('"','&quot;');
			        }
			        this.objList.add(new timeTracker(
			        					temp.Deal__c, 
			        					temp.Deal__r.Name, 
			        					temp.Deal__r.Client__r.Name, 
			        					temp.Deal__r.Stage__c,
			        					temp.Hours__c,
			        					temp.Status__c,
			        					temp.Note__c, 
			        					temp.Senior_Banker__c, 
			        					(mapDealId_SBankers.get(temp.Deal__c) != null ? mapDealId_SBankers.get(temp.Deal__c) : null )));
					{
						
			        TTid_TTobj_Map.put(temp.Deal__c,temp);
					}
			}
				
		}
    }
    
    private Set<Id> getTimeTrackerDealIds() 
	{
		Set<Id> listTimeTrackerDealIds = new Set<Id>();
		if (tssId != null) 
		{
        	for(Time_Tracker__c tmpTT: [SELECT Deal__c FROM Time_Tracker__c 
        								WHERE Time_Sheet_Summary__r.Id =: tssId
        								AND (Non_Deal_Project__c = null or Non_Deal_Project__c = '') 
        								LIMIT 200])
        	{
        		listTimeTrackerDealIds.add(tmpTT.Deal__c);
        	}
        }
		return listTimeTrackerDealIds;
    }
    
    public static list<String> getSeniorBankerTitles()
    {
    	list<MDSC_Titles__c> MDSCTitles = MDSC_Titles__c.getall().values();
		list<String> listMDSCTitles = new list<String>();
		if(MDSCTitles != null)
		{
			for(MDSC_Titles__c item : MDSCTitles) listMDSCTitles.add(item.Name);
		}
		return listMDSCTitles;
    }

    public static List<picklistItem> getSeniorBanker_values()
    {
		list<String> listMDSCTitles = getSeniorBankerTitles();
		List<picklistItem>  SeniorBanker_values = new List<picklistItem>();
		SeniorBanker_values.add(new picklistItem('',''));
		if(listMDSCTitles.size() > 0)
		{
			for(Employee_Profile__c item: [SELECT Id,
												  Last_Name__c, 
												  First_Name__c 
											 FROM Employee_Profile__c 
										    WHERE Title__c IN : listMDSCTitles AND Status__c = 'Active'
										    ORDER BY Last_Name__c, First_Name__c LIMIT 1000])
			{
				SeniorBanker_values.add(new picklistItem(item.Id,item.Last_Name__c +', '+item.First_Name__c));
			}
			System.debug('==========SeniorBanker_values==============='+SeniorBanker_values);
			System.debug('==========listMDSCTitles==============='+listMDSCTitles);
		}
		return SeniorBanker_values;
    }
    
    public void getTimeTrackers()
	{
		if(this.newTimeTrackerRecordsList.size() > 0) 
		{
			insert this.newTimeTrackerRecordsList; //insert new added Deals to old TimeSheet
		}
		listDealId = getTimeTrackerDealIds();
		this.getTimeTrackerRecords(' NOT IN (\'Closed - Dead\',\'Closed - Lost\') ');		
		this.getTimeTrackerRecords(' IN (\'Closed - Dead\',\'Closed - Lost\') ');		
		
		//if(this.toDelete.size() > 0) delete toDelete; //delete duplicates
	}
	
	
	public class timeTracker 
    {
        public string dealId {get; set;}
        public string dealName {get; set;}
        public string client {get; set;}
        public list<picklistItem> listSeniorBanker {get; set;}
        public string stage {get; set;}
        public Double hours {get; set;}
        public string status {get; set;}
        public string note {get; set;}
         public string sBanker {get; set;}
        //Id,DealTeamMember_Inactive_Date__c,Senior_Banker__c,Non_Deal_Project__c,Week_Start_Date__c,Status__c,Note__c,Hours__c,Employee__c,Deal__r.Name,Deal__c,Deal__r.Client__c,Deal__r.Client__r.Name,Time_Sheet_Summary__r.Stage__c,Deal__r.Stage__c';
	
        public timeTracker(string p_dealId,string p_dealName, string p_client, string p_stage, Double p_hours,string p_status, string p_note, string p_sBanker, list<picklistItem> p_listSeniorBanker)
        {
            dealId = p_dealId;
            dealName = p_dealName;
        	client = p_client;
        	stage = p_stage;
        	hours = p_hours;
        	status = p_status;
        	note = p_note; 
        	sBanker = p_sBanker; 
        	listSeniorBanker = new list<picklistItem>();
        	if(p_listSeniorBanker != null)listSeniorBanker = p_listSeniorBanker;   
        }
        public list<picklistItem> getlistSeniorBanker()
        {
        	return listSeniorBanker;
        }
    }
    
   	public class picklistItem 
    {
        public string value {get; set;}
        public string label {get; set;}
        
        public picklistItem (string val, string lbl)
        {
            value = val;
            label = lbl;            
        }
    }
}