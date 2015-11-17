/**
* Test methods are in Test_Timetracker.cls
**/
/*
Main class for Timesheet 
The Main Objects: TimeSheet_Summary__c  and Time_Tracker__c



Modified: Privlad 02/23/2010 - task: 956
modified: Vika 03/04/2010 - Task #10017
modified: Vika 03/19/2010 - Task #10065
modified: Vika 03/22/2010 - Task #10067
modified: yuguziy 08/04/2010 - Task #10249
modified: Vika 05/21/2010 - Task #10378,10374   
*/
public without sharing class TimeTracker {
        public List<String> lProjects = new List<String>();
        
        /* Sring containing the current date of current TimeSheet_Summary Object (example 5/3/2010) */
        public String SelProjItem {get; set;}
        public String testData {get; set;}
        public Time_Tracker__c SelWeekDateTT {get; set;}
        public boolean isTest = false;
        public Employee_Profile__c epTestData = null;
        public Map<String,String> lProjectsMode = new Map<String,String>();
        
        /* The main TimeSheetSummary Object the current Week and current Employee */
        public  TimeSheet_Summary__c UserTimeSheet_SummaryObj;
        /* The "Additional Comments" text for main TimeSheet_Summary Object (UserTimeSheet_SummaryObj)*/
        public String UserMsg = '';
        /* The "Overall Capacity" text for main TimeSheet_Summary Object (UserTimeSheet_SummaryObj)*/
        public String OverallCapacity = '';
        
        /* The current employee ID */
        public String curEmployeeID {get; set;}
        public Time_Tracker__c SelWeekDateTTForEmpl = new Time_Tracker__c();

        public Time_Tracker__c newTimeTrackingObj = new Time_Tracker__c();
        public Time_Tracker__c getTTObj(){ return newTimeTrackingObj;}
        public void setTTObj(Time_Tracker__c inVal){ newTimeTrackingObj = inVal;}
        
        public double TotalHours = 0;
        
        public String ErrorMsg {get; set;}
        public String ErrorMsg2 {get; set;}
        public Time_Tracker__c getSelWeekDateTTForEmpl(){ return SelWeekDateTTForEmpl;}
        public void setSelWeekDateTTForEmpl(Time_Tracker__c inVal){ SelWeekDateTTForEmpl = inVal;}

        public boolean rightAllShare {get;set;}
        public boolean getShareRenderer() {
            if (curEmployeeID != null && curEmployeeID !='' && this.rightAllShare == false) return true;
            else return false;
        }
        
        /* ds
         * Return date of TimeSheet that select in pickList
         */
        public String selProjDate {
            get {
                String res = null;
                TimeSheet_Summary__c tmp;
                //system.debug('===============================>>>>>>>>>>>> '+SelProjItem);
                if (SelProjItem != 'NewWeek') {
                    tmp = TimeTracker_logic.getTimeSheetById(SelProjItem+''); //Return TimeSheet object
                    if (tmp.Week_Start_Date__c != null) { //Convert Week Stard Date to formatted string
                        res = tmp.Week_Start_Date__c.month()+'/';
                        res += tmp.Week_Start_Date__c.day()+'/';
                        res += tmp.Week_Start_Date__c.year()+'';
                    }
                }
                return res;
            }
        }
        
        /* method to get Employee object data for current User */
        public static Employee_Profile__c getCurEmployee()
        {
            id id1 = UserInfo.getUserId();
            for(Employee_Profile__c retObj : [Select e.User_ID__c, e.Name, e.Id From Employee_Profile__c e where e.User_ID__c = :id1 limit 1])
            {
                return retObj;
            }
            return null;
        }        
    
    /* methods to get and set OverallCapacity value */    
    public void setOverallCapacity (String value) {OverallCapacity = value;}
    public String getOverallCapacity()
    {
         if(this.UserTimeSheet_SummaryObj!=null && this.UserTimeSheet_SummaryObj.Overall_Capacity__c!=null)
         {
                return this.UserTimeSheet_SummaryObj.Overall_Capacity__c;
         }
         return '';
    }
    /* Options for Capacity Selection Bar */
    public List<SelectOption> getCapacity() 
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = TimeSheet_Summary__c.Overall_Capacity__c.getDescribe();
        List<Schema.PicklistEntry> PickilstValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pVal : PickilstValues){options.add(new SelectOption(pVal.value,pVal.label));}
        return options;
    }
        /* methods to get and set "Additional Comments" text value */ 
        public void setUserMsg(String inVal){ UserMsg = inVal;}
        public String getUserMsg()
        {
            if(this.UserTimeSheet_SummaryObj!=null && this.UserTimeSheet_SummaryObj.Text__c!=null)
            {
                return this.UserTimeSheet_SummaryObj.Text__c;
            }
            return '';
        }
        
        /* method indicates (is the current TimeSheet 'Submitted'?)*/
        public Boolean getIsSubmited()
        {
            if(this.UserTimeSheet_SummaryObj!=null && this.UserTimeSheet_SummaryObj.Stage__c == 'Submitted') return true;
            return false;
        }
        
        /*
        method to get The main TimeSheetSummary Object the current Week and current Employee 
        */
        public TimeSheet_Summary__c getUserTShSummaryObj()
        {
            TimeSheet_Summary__c ret = new TimeSheet_Summary__c();
            if(SelProjItem!=null && SelProjItem!='' && SelProjItem!='NewWeek')
            {
                ret = TimeTracker_logic.getTimeSheetById(SelProjItem+'');
            }
            return ret;
        }
        
        /* 
            Method (constructor) defines 
                - current Week
                - current employee 
                - main TimeSheetSummaryObject the current WEEK and current employee 
                - rights for current user to save current DATA
            Constructor getting all necessary data from Page Parameters array
        */
        public TimeTracker()
        {
            if(SelWeekDateTT==null) SelWeekDateTT = new Time_Tracker__c();
            
            //get TimeSheet_Summari ID from page parameters
            if(System.currentPageReference().getParameters().get('tssid')!=null && System.currentPageReference().getParameters().get('tssid')!='') {
                SelProjItem = System.currentPageReference().getParameters().get('tssid'); 
            }
            
            //get current employee ID from page parameters
            if(System.currentPageReference().getParameters().get('empid')!=null && System.currentPageReference().getParameters().get('empid')!='') 
                curEmployeeID = System.currentPageReference().getParameters().get('empid');
            
            // access to save/submit/delete/edit/view for Employee userId
            this.rightAllShare = false;
            
            Employee_Profile__c curEMP = [Select User_ID__c From Employee_Profile__c where Id = :curEmployeeID limit 1];
            if (curEMP != null && curEMP.User_ID__c == UserInfo.getUserId())this.rightAllShare = true;
            // access to save/submit/delete/edit/view for SystemAdmin 
            list<Profile> prof = null;
            prof = [    Select Id 
                        From Profile 
                        Where ( Name = 'SP Moelis Project Admin' OR
                                Name = 'System Administrator' OR 
                                Name = 'System Admin without Employee info' OR 
                                Name = 'System Admin w/o IR permissions' OR 
                                Name = 'System Admin without Employee info and IT' OR 
                                Name = 'System Admin w/o IR permissions and IT' OR 
                                Name = 'SP Moelis Business Manager' OR 
                                Name = 'SP Moelis FMP Admin' OR 
                                Name = 'SP Moelis Mgmt Team' 
                                ) AND Id=:UserInfo.getProfileId()
                        ];
            if(prof.size()>0)this.rightAllShare = true;
             
            UserTimeSheet_SummaryObj = getUserTShSummaryObj();
        }
        
        /*
            method calculates  TotalHours for all timetrackers for current WEEK and current employee
        */
        public double getTotalHours()
        {
            TotalHours = 0;
            if(SelProjItem!=null && SelProjItem!='' && SelProjItem!='NewWeek')
            {
                TotalHours = TimeTracker_logic.getTotalHours(SelProjItem+'');
            }
            
            return TotalHours;
        }
        
        
        public PageReference selectEmployee()
        {
            if(SelWeekDateTTForEmpl.Employee__c!=null)
            {
               //system.debug('--------------------------------------'+System.currentPageReference().getParameters().get('sfdc.tabName'));
                String param1 = System.currentPageReference().getParameters().get('sfdc.tabName');
                String newURL = '/apex/TimeTracker?empid='+SelWeekDateTTForEmpl.Employee__c;
                if(param1!=null) newURL = newURL + '&sfdc.tabName='+param1;
                    
                PageReference pageRef = new PageReference(newURL);
                pageRef.setRedirect(true);
                return pageRef;
            }
            return null;
        } 
        
        /*
         * Return current Employee object by his ID
        */
        public static Employee_Profile__c getCurEmployee(String EmplID)
        {
            if(EmplID == null && EmplID=='') return null;
            for(Employee_Profile__c retObj : [Select e.User_ID__c, e.Name, e.Id From Employee_Profile__c e where e.ID = :EmplID limit 1])
            {
                return retObj;
            }
            return null;
        }
        
        public Employee_Profile__c getCurEmployeeNew()
        {
            return TimeTracker.getCurEmployee(curEmployeeID);
        }
        
        public List<String> getTBListPanel()
        {
            
            List<String> aRetArr = new List<String>();
            if(SelProjItem!=null && SelProjItem!='' && SelProjItem!='NewWeek')
            {
                aRetArr.add('Selected Project Item.');
            }
            return aRetArr;
        } 
        
        public List<String> getTBWeekFormPanel()
        {
            List<String> aRetArr = new List<String>();
            if(curEmployeeID!=null && curEmployeeID!=''){ aRetArr.add('Show Week Sel Form.');}
            return aRetArr;
        }
        
        public List<String> getTBEmployeeFormPanel()
        {
            List<String> aRetArr = new List<String>();
            if(curEmployeeID==null || curEmployeeID==''){ aRetArr.add('Show Employee Sel Form.');}
            return aRetArr;
        }

        public List<String> getTBFormAddPanel()
        {
            List<String> aRetArr = new List<String>();
            if(SelProjItem!=null && SelProjItem=='NewWeek'){ aRetArr.add('Show Add Form.');}
            return aRetArr;
        }
        
        /* ds
         * Generate List of Options of available weeks
        */
        public List<selectOption> getWeekDatesOpts()
        {
            list<selectOption> retOpts = new list<selectOption>();
            retOpts.add(new SelectOption('','...select...'));
            String tempValue = '';
            for (TimeSheet_Summary__c tmp: TimeTracker_logic.getAvailableTimeSheets(curEmployeeId+'')) {
                tempValue = formatDate(tmp.Week_Start_Date__c)+' | ('+tmp.Stage__c+')';
                //system.debug('=============== Option ================>>>>>>> '+tmp.Id+' | '+tempValue);
                retOpts.add(new SelectOption(tmp.Id+'',tempValue));
            }
            if (this.rightAllShare == true) //If user have a permissions to add new week
                retOpts.add(new SelectOption('NewWeek','New Week'));                         
            return retOpts;
        }
        
        /* ds
         * Format date to String from system to {MM/DD/yyyy} format
         */
        private String formatDate(Date d) {
            String str = '';
            Integer day,month;
            if (d == null) d = Date.today();
            month = d.month();
            if (month < 10) {
                str += '0';
            }
            str += month+'/';
            day = d.day();
            if (day < 10) {
                str += '0';
            }
            str += day+'/'+d.year();
            return str;
        }
        
        /* JSON datas string for TimeTrackers (Deal section) */
        public string jsonContent { get; set; }
        /* JSON datas string for TimeTrackers (Non-Deal section) */
        public string jsonContent2 { get; set; }
        
        public static Date getFirstMondayInWeek(Date inVal)
        {
            datetime myDate = datetime.newInstance( inVal.year(), inVal.month(), inVal.day());
            //integer dayOfWeek =  integer.valueOf(''+myDate.format('F'));
            Map<String,integer> iConverToMon = new Map<String,integer>{'Sun'=>6,'Mon'=>0,'Tue'=>1,'Wed'=>2,'Thu'=>3,'Fri'=>4,'Sat'=>5};
            return inVal.addDays(-1*iConverToMon.get(''+myDate.format('E')));
        }
        
        /* method for generation new record in TimeSheetSummary Object for current WEEK and current Employee (visual: generating new line in WEEK selecting bar) 
            and generation all 'Deal Project' TimeTracker records (for the new TimeSheetSummaryObject record ) which Deal Team Member:
            - is 'Active'
            - Deal Name NOT 'Non-Deal Project'
            - Deal Stage NOT ('Closed - Completed' , 'Closed - Dead', 'Closed - Lost' )
            - Deal Status 'Active' or 'Hold'
        */
        public PageReference createNewWeek()
        {
            PageReference pageRef = null;
            if(SelWeekDateTT!=null && SelWeekDateTT.Week_Start_Date__c!=null)
            {
                date newDate = TimeTracker.getFirstMondayInWeek(SelWeekDateTT.Week_Start_Date__c);
                String newSelDataTTStr = newDate.month()+'/'+newDate.day()+'/'+newDate.year();
                /*
                if(newDate>date.today())
                {
                    ErrorMsg = 'You can\'t submitted timesheets for future weeks. Please select Start Date for another week.';
                    return null;                    
                }
                */
                lProjects = TimeTracker_logic.getWeekDates(curEmployeeId+'');
                if(lProjects.size()>0)
                {
                    for(String tmpStr:lProjects)
                    {
                        ErrorMsg = '';
                        if(tmpStr==newSelDataTTStr)
                        {
                            ErrorMsg = 'This week already exists. Please select Start Date for another week.';
                            return null;
                        }
                    }
                }
                /*
                create new record in TimeSheetSummary Object 
                */
                if (UserTimeSheet_SummaryObj != null) 
                {
                    TimeSheet_Summary__c UserTimeSheet_SummaryObjCopy = new TimeSheet_Summary__c(Employee__c = (ID)curEmployeeID);
                    UserTimeSheet_SummaryObjCopy.Week_Start_Date__c = newDate;
                    UserTimeSheet_SummaryObjCopy.Overall_Capacity__c = UserTimeSheet_SummaryObj.Overall_Capacity__c;
                    UserTimeSheet_SummaryObjCopy.Text__c =  UserTimeSheet_SummaryObj.Text__c;
                    UserTimeSheet_SummaryObjCopy.Stage__c = 'New';
                    UserTimeSheet_SummaryObj = UserTimeSheet_SummaryObjCopy;
                    
                    //system.debug('============= UserTimeSheet_SummaryObj ==== >>>>> '+UserTimeSheet_SummaryObj);
                    
                    insert UserTimeSheet_SummaryObj;
                }
                
                /* 
                    create TimeTrackerDetail records for deal section 
                    (list of 'Active' DealTeamMembers  for Current Employee where Deal Name NOT 'Non-Deal Project', Deal Status 'Active' or 'Hold') 
                */
                TimeTracker_logic.createTimeTrackersForDealSection(UserTimeSheet_SummaryObj);
            
                SelProjItem = UserTimeSheet_SummaryObj.Id;
                //prepare a page to refresh
                String newURL = '/apex/TimeTracker?tssid='+SelProjItem;
                newURL += '&empId='+curEmployeeID;
                pageRef = new PageReference(newURL);
                pageRef.setRedirect(true);
            }
            else ErrorMsg = 'Error. Date value is empty. Please select date for new week.';
            
            return pageRef;
        }
        
        /* method for generation borwser GET query string ( of WEEK selecting bar) */
        public PageReference selProject()
        {
            PageReference pageRef = null;
            //system.debug('============= SelProjItem ===========>>>> '+SelProjItem);
            if(SelProjItem!=null && SelProjItem!='')
            {
                String newURL = '/apex/TimeTracker?tssid='+SelProjItem;
                newURL += '&empId='+curEmployeeID;
                pageRef = new PageReference(newURL);
                pageRef.setRedirect(true);
            }   
            return pageRef;
        }

        public PageReference cancel()
        {
            return null;
        }        

        public Date parceDate(String dateVal)
        {
            Date contactDate = null;
            
                try 
                {
                    integer dayVal = integer.valueOf(dateVal.substring(3,5));
                    integer monthVal = integer.valueOf(dateVal.substring(0,2));
                    integer yearVal = integer.valueOf(dateVal.substring(6,10));
                    contactDate = date.newInstance(yearVal, monthVal, dayVal);
                    
                } catch (Exception e) {
                    
                }
            return contactDate;
        }

         /* method for add new "Non-Deal" Project for current TimeSheet
            and save "Deal" and "Non-Deal" Projects  received from JSON 
         
        public PageReference save_and_new()
        {
            Date curTTDateSQL;
            if(SelProjItem!=null && SelProjItem!='') {
                if(SelProjItem=='NewWeek') {
                    curTTDateSQL = TimeTracker.getFirstMondayInWeek(SelWeekDateTT.Week_Start_Date__c);
                } else {
                    curTTDateSQL = TimeTracker_logic.getTimeSheetById(SelProjItem+'').Week_Start_Date__c;
                }
            }
            
            if(newTimeTrackingObj.Hours__c<0)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You can\'t enter negative hours value');
                ApexPages.addMessage(myMsg);
                return null;
            }
            
            //system.debug('SelWeekDateTT.Week_Start_Date__c===' + SelWeekDateTT.Week_Start_Date__c);
            newTimeTrackingObj.Week_Start_Date__c = TimeTracker.getFirstMondayInWeek(curTTDateSQL);

            Ibanking_Project__c iDeal = null; 
            for(Ibanking_Project__c tmpIDeal : [Select Id From Ibanking_Project__c Where Name = 'Non-Deal Project' limit 1])
            { 
                iDeal = tmpIDeal;
            }
            // FIX bug with 'Non-Deal Project' record!
            if(iDeal == null) return null;
            
            newTimeTrackingObj.Deal__c = iDeal.id;
            
            newTimeTrackingObj.Employee__c = curEmployeeID;

            //system.debug('================newTimeTrackingObj===>>>>>>>>>>>>>>' + newTimeTrackingObj);
            if(newTimeTrackingObj.Deal__c!=null && newTimeTrackingObj.Employee__c!=null && newTimeTrackingObj.Non_Deal_Project__c!=null && newTimeTrackingObj.Non_Deal_Project__c!='' && newTimeTrackingObj!=null) 
            {
                newTimeTrackingObj.Time_Sheet_Summary__c = UserTimeSheet_SummaryObj.Id;
                insert newTimeTrackingObj;
            }
            newTimeTrackingObj = new Time_Tracker__c();
            saveJson();
            return selProject();
        }
        */
        /* 
            method for save "Deal" Projects received from JSON for current week and current employee:
            - parse JSON data
            - save the timetracker data if something was changed ( Hours Spent or Status or Note) 
         */
        private Boolean saveDataOne(String inMode) 
        {
            if(jsonContent==null || jsonContent=='')  return false;
            JSONObject jsonObj = new JSONObject(jsonContent);
            if (jsonObj == null || jsonObj.getValue('table') == null ) return false;
            integer len = jsonObj.getValue('table').values.size();
            string valueId;
            List<Time_Tracker__c> tbList = new List<Time_Tracker__c>();
            List<Time_Tracker__c> tb2List = new List<Time_Tracker__c>();
            Time_Tracker__c tb;
            string dateVal;
            string SeniorBanker;
            Date dDateVal;
            boolean changed;
            
            Employee_Profile__c curEmplObj = isTest?epTestData:TimeTracker.getCurEmployee(curEmployeeID);
            Date curTTDateSQL = null;
            if(SelProjItem!=null && SelProjItem!='') {
                if(SelProjItem=='NewWeek') {
                    curTTDateSQL = TimeTracker.getFirstMondayInWeek(SelWeekDateTT.Week_Start_Date__c);
                } else {
                    curTTDateSQL = TimeTracker_logic.getTimeSheetById(SelProjItem+'').Week_Start_Date__c;
                }
            }
            
            if (SelProjItem == null) return false;
            
            for (integer i = 0; i < len; i++) {
                valueId = jsonObj.getValue('rows').values.get(i).str;
                
                tb = TimeTracker_logic.getTimeTracker(SelProjItem+'', valueId);
                changed = false;
                //Senior Banker
                SeniorBanker = jsonObj.getValue('table').values.get(i).values.get(3).obj.getString('value');
                try {
                    if(SeniorBanker=='') SeniorBanker = null;
                    if (SeniorBanker != tb.Senior_Banker__c) {
                        if(SeniorBanker==null || SeniorBanker=='') tb.Senior_Banker__c = null;
                        else tb.Senior_Banker__c = SeniorBanker;
                        changed =  true;                    
                    }
                } catch (Exception e){ }
                //Hours Spent
                dateVal = jsonObj.getValue('table').values.get(i).values.get(4).obj.getString('value');
                try {
                    double tmpInt;
                    if (dateVal == null || dateVal == '') tmpInt = null;
                    else tmpInt = double.valueOf(dateVal); 
                    if(tb.Hours__c != tmpInt) {
                        if(tmpInt<0)
                        {
                            tmpInt = (-1)*tmpInt;
                        }
                        tb.Hours__c = tmpInt;
                        changed = true;
                    }
                } catch (Exception e){ }

                // Status
                try {
                    string newstatus = jsonObj.getValue('table').values.get(i).values.get(5).obj.getString('value');
                    if (newstatus != tb.Status__c) {
                        if(newstatus==null || newstatus=='') tb.Status__c = null;
                        else tb.Status__c = newstatus;
                        changed =  true;                    
                    }
                } catch (Exception e) { }
                
                //Note
                dateVal = jsonObj.getValue('table').values.get(i).values.get(6).obj.getString('value');
                if(tb != null)
                {
                    if(tb.Note__c != dateVal) {
                        tb.Note__c = dateVal;
                        changed = true; 
                    }
                    if(tb.Time_Sheet_Summary__r.Stage__c==null || tb.Time_Sheet_Summary__r.Stage__c != inMode)
                    {
                        tb.Time_Sheet_Summary__r.Stage__c = inMode;
                        changed = true; 
                    }
    
                    if (changed)
                    {
                        tbList.add(tb);
                    }
                }
                
            }
            system.debug('tbList ------------------------->'+tbList);
            if(tbList.size()>0){ try {upsert tbList;} catch(Exception ex) {}}
            return true;
        }

        

        /* method for save "Non-Deal" Projects  received from JSON for current week and current employee
            - parse JSON data
            - save the timetracker data if something was changed ( Hours Spent or Note) 
            - delete selected "Non-Deal Projects"
        */
        private Boolean saveDataTwo(String inMode) 
        {
            if(jsonContent2==null || jsonContent2=='')  return false;
            JSONObject jsonObj = new JSONObject(jsonContent2);
            List<Time_Tracker__c> tmpListTrack = new List<Time_Tracker__c>();
            if(jsonObj.getValue('delList') != null)
            {
                Time_Tracker__c tmpTrack;
                for (integer i = 0; i < jsonObj.getValue('delList').values.size() ; i++){
                    tmpTrack = new Time_Tracker__c(id = jsonObj.getValue('delList').values.get(i).str);
                    tmpListTrack.add(tmpTrack);
                }
                if(tmpListTrack.size() > 0)  try {delete tmpListTrack;} catch(Exception ex) {system.debug('DML Error: '+ex);}
            }
            
            if (jsonObj == null || jsonObj.getValue('table') == null ) return false;
            integer len = jsonObj.getValue('table').values.size();
            string valueId;
            List<Time_Tracker__c> tbList = new List<Time_Tracker__c>();
            Time_Tracker__c tb = null;
            Double hours;
            String seniorBankerId;
            String stringHours;
            String notes;
            String nonDealProject;
            Date dDateVal;
            Boolean changed;
            Ibanking_Project__c nonDealObj;
            List<Ibanking_Project__c> lstNonDeal = [Select Id From Ibanking_Project__c i where name ='Non-Deal Project' order by CreatedDate desc limit 1];
       		if(!lstNonDeal.isEmpty())
       			nonDealObj = lstNonDeal[0];
       		
            Employee_Profile__c curEmplObj = isTest?epTestData:TimeTracker.getCurEmployee(curEmployeeID);
            Date curTTDateSQL = null;
            if(SelProjItem!=null && SelProjItem!='') {
                if(SelProjItem=='NewWeek') {
                    curTTDateSQL = TimeTracker.getFirstMondayInWeek(SelWeekDateTT.Week_Start_Date__c);
                } else {
                    curTTDateSQL = TimeTracker_logic.getTimeSheetById(SelProjItem+'').Week_Start_Date__c;
                }
            }
            
            if (SelProjItem == null) return null;
            
            for (integer i = 0; i < len; i++) {
                
                // *************** ROWS ***************
                valueId = jsonObj.getValue('rows').values.get(i).str;
                nonDealProject = jsonObj.getValue('table').values.get(i).values.get(1).obj.getString('value'); // 2
                seniorBankerId = jsonObj.getValue('table').values.get(i).values.get(2).obj.getString('value'); // 3
                stringHours = jsonObj.getValue('table').values.get(i).values.get(3).obj.getString('value'); // 3
                try {   if (stringHours == null || stringHours == '') hours = null; else hours = double.valueOf(stringHours); } catch (Exception e) { }
                notes = jsonObj.getValue('table').values.get(i).values.get(4).obj.getString('value'); // 4
                if(valueId.compareTo('new_')>0)
                {
                    if(nonDealObj != null && nonDealObj.Id != null)
                    {
                        tb = new Time_Tracker__c(Non_Deal_Project__c = nonDealProject, 
                                                Note__c = notes, Hours__c = hours, 
                                                Deal__c = nonDealObj.Id, 
                                                Senior_Banker__c = (seniorBankerId != '' ? seniorBankerId : null),
                                                Employee__c = UserTimeSheet_SummaryObj.Employee__c,
                                                Week_Start_Date__c = UserTimeSheet_SummaryObj.Week_Start_Date__c,
                                                Time_Sheet_Summary__c = UserTimeSheet_SummaryObj.Id);
                        //if(tb != null)    tbList.add(tb); 
                        if(tb != null)try{insert tb;} catch(Exception ex) {}
                    }
                }
                else
                {
                    for (Time_Tracker__c tbTmp : [
                        Select ID, Non_Deal_Project__c,Senior_Banker__c, Status__c, Note__c, Time_Sheet_Summary__r.Stage__c, Hours__c, Employee__c, Week_Start_Date__c, Deal__c 
                        From Time_Tracker__c 
                        where id =: valueId 
                        limit 1])
                    {
                        
                        tb = tbTmp;
                        changed = false;
        
                        // *************** TABLE ***************
                      
                        //Senior Banker
                        try {
                            if(seniorBankerId == '') seniorBankerId = null;
                            if(tb.Senior_Banker__c != seniorBankerId) {
                                tb.Senior_Banker__c = seniorBankerId;
                                changed = true;
                            }
                            
                        } catch (Exception e){ }
                        //Hours Spent
                        try {
                            if(tb.Hours__c != hours) {
                                if(hours<0) hours = (-1)*hours;
                                tb.Hours__c = hours;
                                changed = true;
                            }
                            
                        } catch (Exception e){ }
                        //Note
                        if(tb.Note__c != notes) {
                            tb.Note__c = notes;
                            changed = true; 
                        }
                        if(tb.Time_Sheet_Summary__r.Stage__c==null || tb.Time_Sheet_Summary__r.Stage__c != inMode) {
                            tb.Time_Sheet_Summary__r.Stage__c = inMode;
                            changed = true; 
                        }
        
                        if (changed) {
                            //tbList.add(tb);
                            try{update tb;} catch(Exception ex) {}
                        }
                    }
                }
                
            }


            //if(tbList.size()>0){ try{upsert tbList;} catch(Exception ex) {}}
            return true;
        }
        
        
        /* 
            method for save "Deal" Projects and "Non-Deal" Projects  received from JSON 
            and change TimeSheetSummaryObject Stage to "New" or "Submitted"
        */
        private PageReference saveData(String inMode) {
            if (UserTimeSheet_SummaryObj != null )
            {
                if(UserMsg==null) UserMsg = '';
                UserTimeSheet_SummaryObj.Text__c = UserMsg;
                UserTimeSheet_SummaryObj.Overall_Capacity__c = OverallCapacity;
                UserTimeSheet_SummaryObj.Stage__c = inMode;
                update UserTimeSheet_SummaryObj;
            }
            if (!saveDataOne(inMode)) return null;
            if (!saveDataTwo(inMode)) return null;
            return selProject();
        }
        
        /* "Submit" button handler */
        public PageReference submitJson()
        {
            /*
            PageReference saveData = saveData('Submitted');
            PageReference res = new PageReference('/'+curEmployeeID);
            res.setRedirect(true);
            return res;
            */
            return saveData('Submitted');
        }
        
        /* "Save" button handler */
        public PageReference saveJson()
        {
            return saveData('New');
        } 
        
        
        /* ds
         * Temporary method for clean up 'NEW' records in TimeSheet_Summary__c 
        */
        public void clearNewTimesheets() {
            List<TimeSheet_Summary__c> temp = [SELECT id,Week_Start_Date__c,Stage__c FROM TimeSheet_Summary__c
                            WHERE Employee__c = :curEmployeeId and Stage__c = 'New'];
            for (TimeSheet_Summary__c item: temp) {
                system.debug('=========== ID ====>>> '+item.Id+' ==== Stage ===>>> '+item.Stage__c);
            }
            delete temp;
        }
        
        /* ds
         * Temporary method for clean up duplicates in TimeSheet_Summary__c 
         * and in Time_Tracker__c databases
        */
        public void clearDuplicates() {
            string query = '';
            
            query = 'SELECT id, Week_Start_Date__c FROM TimeSheet_Summary__c';
            if (isTest) query += ' LIMIT 1000'; 
            List<TimeSheet_Summary__c> temp = Database.query(query);
            List<TimeSheet_Summary__c> toDelete = new List<TimeSheet_Summary__c>();
            List<Date> inBase = new List<Date>();
            Boolean needDelete;
            for (TimeSheet_Summary__c item: temp) {
                needDelete = False;
                for (Date dItem: inBase) {
                    if (item.Week_Start_Date__c == dItem) {
                        needDelete = True;
                    }
                }
                if (needDelete) {
                    toDelete.add(item);
                    system.debug('============== TO DELETE ============== >>>> '+item.Id);
                } else {
                    inBase.add(item.Week_Start_Date__c);
                }
            }
            system.debug('+++++++++++++++++++ TO DELETE SUMM +++++++++++++++++++++ >>>> '+toDelete.size());
            delete toDelete;
            
            query = 'SELECT id,Deal__c,Time_Sheet_Summary__c FROM Time_Tracker__c';
            if (isTest) query += ' LIMIT 1000'; 
            List<Time_Tracker__c> ttemp = Database.query(query);
            
            //List<Time_Tracker__c> ttoDelete = new List<Time_Tracker__c>();
            Map<Id, Time_Tracker__c> ttoDelete = new Map<Id, Time_Tracker__c>();
            
            List<Time_Tracker__c> tinBase = new List<Time_Tracker__c>();
            Boolean tneedDelete;
            
            Map<Id, List<Time_Tracker__c>> ttMap = new Map<Id, List<Time_Tracker__c>>(); 
            
            if (ttemp.size()>0) {
                for (Time_Tracker__c item: ttemp) {
                 if(!ttMap.containsKey(item.Time_Sheet_Summary__c)) ttMap.put(item.Time_Sheet_Summary__c, new List<Time_Tracker__c>());
                 ttMap.get(item.Time_Sheet_Summary__c).add(item);
                }
            }
            
            if (ttemp.size()>0) {
                for (Time_Tracker__c item: ttemp)
                {
                    for(Time_Tracker__c item2:ttMap.get(item.Time_Sheet_Summary__c))
                    {
                        if (!ttoDelete.containsKey(item.id) && item2.Id != item.Id && item2.Deal__c == item.Deal__c) {
                            ttoDelete.put(item2.id, item2);
                        }
                    }
                    
                    /*
                    for (Time_Tracker__c item_2: ttemp) {
                        if (item_2.Id != item.Id && item_2.Time_Sheet_Summary__c == item.Time_Sheet_Summary__c && item_2.Deal__c == item.Deal__c) {
                            ttoDelete.add(item_2);
                        }
                    }
                    */
                    //ttoDelete = [SELECT id,Deal__c,Time_Sheet_Summary__c FROM Time_Tracker__c WHERE Id !=:item.id AND Deal__c =:item.Deal__c AND Time_Sheet_Summary__c=:item.Time_Sheet_Summary__c];
                    /*tneedDelete = False;
                    for (Time_Tracker__c dItem: tinBase) {
                        if (item.Deal__c == dItem.Deal__c && 
                            item.Time_Sheet_Summary__c == dItem.Time_Sheet_Summary__c) {
                            tneedDelete = True;
                        }
                    }
                    if (tneedDelete) {
                        ttoDelete.add(item);
                        system.debug('============== TO DELETE ============== >>>> '+item.Id);
                    } else {
                        tinBase.add(item);
                    }*/
                }
                if (ttoDelete.size()>0) delete ttoDelete.values();
            }
            /*system.debug('+++++++++++++++++++ TO DELETE SUMM +++++++++++++++++++++ >>>> '+ttoDelete.size());
            delete ttoDelete;*/
        }
}