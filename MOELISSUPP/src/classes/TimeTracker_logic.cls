public without sharing class TimeTracker_logic {
    
    public static String tssFields = 'Text__c,Employee__c,Employee__r.Id,Overall_Capacity__c,Stage__c,Week_Start_Date__c'; 
    public static String ttFields = 'Id,DealTeamMember_Inactive_Date__c,Senior_Banker__c,Non_Deal_Project__c,Week_Start_Date__c,Status__c,Note__c,Hours__c,Employee__c,Deal__r.Name,Deal__c,Deal__r.Client__c,Deal__r.Client__r.Name,Time_Sheet_Summary__r.Stage__c,Deal__r.Stage__c';
    
    public static List<String> getWeekDates(String currEmployeeId) {
        String queryStr = '';
        String toInsert = '';
        List<TimeSheet_Summary__c> tmp = new List<TimeSheet_Summary__c>();
        List<String> res = new List<String>();
        
        if (currEmployeeId != null) {
            queryStr += 'SELECT Week_Start_Date__c,Id,Stage__c FROM TimeSheet_Summary__c ';
            queryStr += 'WHERE Employee__r.Id = \''+currEmployeeId+'\' ORDER BY Week_Start_Date__c';
            
            try {
                tmp = database.query(queryStr);
                
                for (TimeSheet_Summary__c item: tmp) {
                    toInsert = item.Week_Start_Date__c.month()+'/';
                    toInsert += item.Week_Start_Date__c.day()+'/';
                    toInsert += item.Week_Start_Date__c.year()+'';
                    res.add(toInsert);
                }
            } catch(Exception ex) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'DB Error[getWeekDates]: '+ex);
                ApexPages.addMessage(msg);
            }
        }
        
        return res;
    }
    
    public static List<TimeSheet_Summary__c> getAvailableTimeSheets(String currEmployeeId) {
        String queryStr = '';
        List<TimeSheet_Summary__c> res = new List<TimeSheet_Summary__c>();
        
        if (currEmployeeId != null) {
            queryStr += 'SELECT Week_Start_Date__c,Id,Stage__c FROM TimeSheet_Summary__c ';
            queryStr += 'WHERE Employee__r.Id = \''+currEmployeeId+'\' ORDER BY Week_Start_Date__c';
            
            try {
                res = database.query(queryStr);
            } catch(Exception ex) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'DB Error[getAvailableTimeSheets]: '+ex);
                ApexPages.addMessage(msg);
            }
            //system.debug('================= database.query(queryStr).size() ===========>>>> '+res.size());
        }
        return res;
    }
    
    public static TimeSheet_Summary__c getTimeSheetById(String id) {
        List<TimeSheet_Summary__c> tmp;
        TimeSheet_Summary__c res = new TimeSheet_Summary__c();
        String queryStr = '';
        
        if (id != null) {
            queryStr += 'SELECT '+TimeTracker_logic.tssFields+' ';
            queryStr += 'FROM TimeSheet_Summary__c ';
            queryStr += 'WHERE id = \''+id+'\'';
            
            try {
                tmp = database.query(queryStr);
                if (tmp.size() > 0) {
                    res = tmp[0];
                }
            } catch (Exception ex) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'DB Error[getTimeSheetById]: '+ex);
                ApexPages.addMessage(msg);
            }
        }
        return res;
    }
    
    public static Time_Tracker__c getTimeTracker(String selProjItem, String dealId) {
        String queryStr = '';
        List<Time_Tracker__c> tmp;
        Time_Tracker__c res = null;
        
        if (selProjItem != null && dealId != null) {
            queryStr += 'SELECT '+TimeTracker_logic.ttFields+' FROM Time_Tracker__c ';
            queryStr += 'WHERE Time_Sheet_Summary__r.Id = \''+selProjItem+'\' ';
            queryStr += 'AND Deal__c = \''+dealId+'\'';
            
            try {
                tmp = database.query(queryStr);
                if (tmp.size() > 0) {
                    res = tmp[0];
                } 
            }catch(Exception ex) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'DB Error[getTimeTracker]:'+ex);
                ApexPages.addMessage(msg);
            }
        }
        return res;
    }
    
    public static List<Time_Tracker__c> getTimeTrackerList(String id) {
        List<Time_Tracker__c> res = new List<Time_Tracker__c>();
        String queryStr = '';
        if (id != null) {
            queryStr += 'SELECT '+TimeTracker_logic.ttFields+' FROM Time_Tracker__c ';
            queryStr += 'WHERE Time_Sheet_Summary__r.Id = \''+id+'\' ';
            queryStr += 'AND (Non_Deal_Project__c = null or Non_Deal_Project__c = \'\') ';
            //queryStr += 'ORDER BY Deal__r.Name LIMIT 200';
            queryStr += 'ORDER BY Deal__r.Stage__c,Deal__r.Client__c,Deal__r.Name ';
            queryStr += 'LIMIT 200';
            
            
            //system.debug('===========queryStr===========>>>> '+queryStr);
            
            try {
                List<Time_Tracker__c> res_pre = database.query(queryStr);
                List<Time_Tracker__c> toDelete = new List<Time_Tracker__c>();
                Boolean isDel;
                
                Map<Id,Time_Tracker__c> TTid_TTobj_Map = new Map<Id,Time_Tracker__c>();
                for(Time_Tracker__c temp: res_pre)
                {
                    
                    if(TTid_TTobj_Map.containsKey(temp.Deal__c)) toDelete.add(temp);
                    else {
                        if (temp.Note__c !=null){
                            temp.Note__c = temp.Note__c.replaceAll('\r\n',' ');
                            temp.Note__c = temp.Note__c.replaceAll('"','&quot;');
                        }
                        res.add(temp);
                        TTid_TTobj_Map.put(temp.Deal__c,temp);
                    }
                    
                    /*if (temp.Note__c !=null)
                    {
                        temp.Note__c = temp.Note__c.replaceAll('\r\n',' ');
                        temp.Note__c = temp.Note__c.replaceAll('"','&quot;');
                    }
                    isDel = false;
                    for (Time_Tracker__c item: res) {
                        if (item.Deal__c == temp.Deal__c) {
                            isDel = true;
                        }
                    }
                    if (isDel) {
                        toDelete.add(temp);
                    }else{
                        res.add(temp);
                    }*/
                }
                system.debug('======== toDelete ======== >>>> '+toDelete);
                system.debug('======== res ======== >>>> '+res);
                if (toDelete.size() > 0) {
                    //delete toDelete;
                }
                
                
                
            } catch(Exception ex) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'DB Error[getTimeTrackerList]: '+ex);
                ApexPages.addMessage(msg);
            }
        }
        return res;
    }
    
    public static List<Time_Tracker__c> getTimeTrackerList_nonDeal(String id) {
        List<Time_Tracker__c> res = new List<Time_Tracker__c>();
        String queryStr = '';
        if (id != null) {
            queryStr += 'SELECT '+TimeTracker_logic.ttFields+' FROM Time_Tracker__c ';
            queryStr += 'WHERE Time_Sheet_Summary__r.Id = \''+id+'\' ';
            queryStr += 'AND (Non_Deal_Project__c != null or Non_Deal_Project__c != \'\') ';
            queryStr += 'ORDER BY Deal__r.Name LIMIT 200';
            
            //system.debug('===========queryStr===========>>>> '+queryStr);
            
            try {
                List<Time_Tracker__c> res_pre = database.query(queryStr);
                for(Time_Tracker__c temp: res_pre)
                {
                    if (temp.Note__c !=null)    
                    {
                        temp.Note__c = temp.Note__c.replaceAll('\r\n',' ');
                        temp.Note__c = temp.Note__c.replaceAll('"','&quot;');
                    }
                    res.add(temp);
                }
            } catch(Exception ex) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'DB Error[getTimeTrackerList_nonDeal]: '+ex);
                ApexPages.addMessage(msg);
            }
        }
        return res;
    }
    
    public static void createTimeTrackersForDealSection(TimeSheet_Summary__c timeSheetSummaryObj) {
        List<Time_Tracker__c> lTimeTrackersForUpd = new List<Time_Tracker__c>();
        /* list of 'Active' DealTeamMembers  for Current Employee where Deal Name NOT 'Non-Deal Project', Deal Status 'Active' or 'Hold'*/
        if(timeSheetSummaryObj!=null && timeSheetSummaryObj.Employee__c != null && timeSheetSummaryObj.Week_Start_Date__c != null)
        {
            for(Project_Resource__c presObj:[
                            Select p.Project__c,p.Status__c, p.Id, p.Banker__r.User_ID__c, p.Banker__c 
                            From Project_Resource__c p 
                            where p.Project__r.Name!='Non-Deal Project' and 
                                  p.Banker__c = :timeSheetSummaryObj.Employee__c and 
                                  /* old logic
                                  p.Project__r.Stage__c != 'Closed - Completed' and 
                                  p.Project__r.Stage__c != 'Closed - Dead' and 
                                  p.Project__r.Stage__c != 'Closed - Lost' and 
                                  */
                                  p.Status__c = 'Active' and
                                  (p.Project__r.Status__c  = 'Active' or p.Project__r.Status__c  = 'Hold')
                            limit 100])
            {
                if(  presObj.Project__c!=null)
                {
                        /*
                            create list of TimeTrackers (for 'Deal' section) for all Deals where: DealTeamMember is 'Active',   Deal Name NOT 'Non-Deal Project', Deal Stage NOT ('Closed - Completed', 'Closed - Dead','Closed - Lost'), Deal Status 'Active' or 'Hold' 
                        */
                      Time_Tracker__c ttNewObj = new Time_Tracker__c(
                                                                    Employee__c=timeSheetSummaryObj.Employee__c,
                                                                    Deal__c=presObj.Project__c,
                                                                    Week_Start_Date__c=timeSheetSummaryObj.Week_Start_Date__c,
                                                                    Time_Sheet_Summary__c = timeSheetSummaryObj.Id);
                        lTimeTrackersForUpd.add(ttNewObj);
                }
            }
        }
        if(lTimeTrackersForUpd.size()>0) 
        {
                    system.debug('lTimeTrackersForUpd--------------------->'+lTimeTrackersForUpd);
                    //insert list of TimeTrackers 
                    insert lTimeTrackersForUpd;
        }
    }   
    
    public static Double getTotalHours(String id) {
        Double res = 0;
        List<Time_Tracker__c> tmp;
        String queryStr = '';
        
        if (id != null) {
            queryStr += 'SELECT Hours__c FROM Time_Tracker__c ';
            queryStr += 'WHERE Time_Sheet_Summary__r.Id = \''+id+'\' ';
            try {
                tmp = database.query(queryStr);
                
                for (Time_Tracker__c item: tmp) {
                    if (item.Hours__c != null)
                            res += item.Hours__c;
                }
            } catch(Exception ex) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'DB Error[getTotalHours]: '+ex);
                ApexPages.addMessage(msg);
            }
        }
        return res; 
    }   
    
    public static list<String> getMDSC_Require_NonDealProjects()
    {
        list<MDSC_Require_NonDealProjects__c> MDSCRequireNonDeals = MDSC_Require_NonDealProjects__c.getall().values();
        list<String> listMDSCR = new list<String>();
        if(MDSCRequireNonDeals != null)
        {
            for(MDSC_Require_NonDealProjects__c item : MDSCRequireNonDeals) listMDSCR.add(item.Name);
        }
        return listMDSCR;
    }
}