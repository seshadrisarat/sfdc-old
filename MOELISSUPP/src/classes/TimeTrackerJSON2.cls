/**
* Test methods are in Test_Timetracker.cls
**/
/*
Class which generate JSON data for "Non-Deal Projects" for current WEEK and current EMPLOYEE

Modified: Privlad 02/23/2010 - task: 956
modified: Vika 03/19/2010 - Task #10065
modified: yuguziy 08/04/2010 - Task #10249
*/
public  without sharing class TimeTrackerJSON2 {
    public list<Time_Tracker__c> objList {get; set;}
    public List<TimeTrackerJSON.picklistItem> TT_Status_values {get; set;}
    public List<TimeTrackerJSON.picklistItem> TT_SeniorBanker_values {get; set;}
    public Integer fieldNoteMaxLength { get; set; }
    public list<String> listMDSCRNonDeals {get; set;}
    
    public TimeTrackerJSON2()
    {
        objList = new list<Time_Tracker__c>();
        listMDSCRNonDeals = TimeTracker_logic.getMDSC_Require_NonDealProjects();
        Id tssId = System.currentPageReference().getParameters().get('tssid');
        if (tssId != null) 
        {
        	objList = TimeTracker_logic.getTimeTrackerList_nonDeal(tssId);
        }

        Schema.DescribeFieldResult fieldResult = Time_Tracker__c.Non_Deal_Project__c.getDescribe();
        List<Schema.PicklistEntry> PickilstValues = fieldResult.getPicklistValues();
        TT_Status_values = new List<TimeTrackerJSON.picklistItem>();
        
        TT_Status_values.add(new TimeTrackerJSON.picklistItem('',''));
        for (Schema.PicklistEntry pVal : PickilstValues){TT_Status_values.add(new TimeTrackerJSON.picklistItem(pVal.value,pVal.label));}
        
		TT_SeniorBanker_values = TimeTrackerJSON.getSeniorBanker_values();
	
        this.fieldNoteMaxLength = Time_Tracker__c.Note__c.getDescribe().getLength();
    }
    
    
    
}