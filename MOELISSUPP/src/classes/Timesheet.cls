/*

Modified: Privlad 02/23/2010 - task: 956
modified: Vika 03/19/2010 - Task #10065
modified: yuguziy 04/08/2010 - Task #10249
modified: yuguziy 04/16/2010 - Task #10280 - can be deleted now
*/
public class Timesheet {

	public static Employee_Profile__c getCurEmployee()
    {
    	id id1 = UserInfo.getUserId();
        for(Employee_Profile__c retObj : [Select e.User_ID__c, e.Name, e.Id From Employee_Profile__c e where e.User_ID__c = :id1 limit 1])
        {
        	return retObj;
		}
		return null;
	}

	public static testMethod void testMyController()
	{
		Employee_Profile__c emplProfObj = Timesheet.getCurEmployee();
	}
    
/*    
        public list<Timesheet_Entry__c> objList {get; set;}
        public List<TimeTrackerJSON.picklistItem> TT_Status_values {get; set;}

        public List<String> lProjects = new List<String>();
        public List<String> lProjectsID = new List<String>();
        public String SelProjItem {get; set;}
        public String testData {get; set;}
        public Timesheet__c SelWeekDateTT {get; set;}
        public boolean isTest = false;
        public Employee_Profile__c epTestData = null;
        
        public double TotalHours = 0;
        
        public String ErrorMsg {get; set;}
        
        public Timesheet()
        {
            objList = new list<Timesheet_Entry__c>();
            if(SelWeekDateTT==null)
            {
                SelWeekDateTT = new Timesheet__c();
                if(System.currentPageReference().getParameters().get('pid')!=null && System.currentPageReference().getParameters().get('pid')!='')
                {
                    SelProjItem = System.currentPageReference().getParameters().get('pid');
                }
            }
            else
            {
                SelProjItem = SelWeekDateTT.ID;
            }
            if(SelProjItem!=null && SelProjItem!='NewWeek')
            {
                id id1 = UserInfo.getUserId();
                Employee_Profile__c curEmplObj = Timesheet.getCurEmployee();

                SelWeekDateTT = [Select t.Week_ending__c, t.TotalHours__c, t.Status__c, t.Notes__c, t.Name, t.Id, t.Employee__c, t.CreatedById From Timesheet__c t where ID=:SelProjItem limit 1];
                objList = [Select t.Timesheet__c, t.Status__c, t.Name, t.Id, t.Hours__c, t.Employee__c, t.Deal__c, t.Note__c, t.Deal__r.name From Timesheet_Entry__c t where t.Timesheet__c = :SelProjItem and Employee__c=:curEmplObj.ID and CreatedById=:id1 order by t.Deal__r.Name limit 200];
            }
            
            Schema.DescribeFieldResult fieldResult = Timesheet_Entry__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> PickilstValues = fieldResult.getPicklistValues();
            TT_Status_values = new List<TimeTrackerJSON.picklistItem>();
            
            TT_Status_values.add(new TimeTrackerJSON.picklistItem('',''));
            for (Schema.PicklistEntry pVal : PickilstValues){ TT_Status_values.add(new TimeTrackerJSON.picklistItem(pVal.value,pVal.label));}
            
        }
        
        public Timesheet__c getCurrTimesheet()
        {
            if(SelProjItem==null && System.currentPageReference().getParameters().get('pid')!=null && System.currentPageReference().getParameters().get('pid')!='')
            {
                SelProjItem = System.currentPageReference().getParameters().get('pid');
            }
            
            if(SelWeekDateTT==null && SelProjItem!=null)
            {
                SelWeekDateTT = [Select t.Week_ending__c, t.TotalHours__c, t.Status__c, t.Notes__c, t.Name, t.Id, t.Employee__c, t.CreatedById From Timesheet__c t where ID=:SelProjItem limit 1];
            }
            
            return SelWeekDateTT;
        }
        
        public static Employee_Profile__c getCurEmployee()
        {
            id id1 = UserInfo.getUserId();
            for(Employee_Profile__c retObj : [Select e.User_ID__c, e.Name, e.Id From Employee_Profile__c e where e.User_ID__c = :id1 limit 1])
            {
                return retObj;
            }
            return null;
        }
        public List<String> getTBListPanel()
        {
            
            List<String> aRetArr = new List<String>();
            if(SelProjItem!=null && SelProjItem!='' && SelProjItem!='NewWeek')
            {
                boolean isProjectExists = false;
                for(Project_Resource__c presObj:[Select p.Project__c, p.Id, p.Banker__r.User_ID__c, p.Banker__c From Project_Resource__c p where p.Banker__r.User_ID__c = :UserInfo.getUserId() limit 1])
                {
                    isProjectExists = true;
                }
                if(isProjectExists) aRetArr.add('Selected Project Item.');
                else ErrorMsg = 'Week was not created. You does not have assigned project.';
                
            }
            return aRetArr;
        } 
        
        public List<String> getTBFormAddPanel()
        {
            
            List<String> aRetArr = new List<String>();
            if(SelProjItem!=null && SelProjItem=='NewWeek'){ aRetArr.add('Show Add Form.');}
            return aRetArr;
        }
        
        public List<selectOption> getWeekDatesOpts()
        {
            list<selectOption> retOpts = new list<selectOption>();
            lProjects = getWeekDates();
            if(lProjectsID.size()>0)
            {
                for(Timesheet__c tmpTSObj : [Select t.Week_ending__c, t.Status__c, t.Name, t.Id, t.Employee__c, t.CreatedById From Timesheet__c t where t.ID in :lProjectsID order by t.Name])
                {
                    retOpts.add(new SelectOption(tmpTSObj.ID,tmpTSObj.Name+' ('+(tmpTSObj.Status__c==null?'New':tmpTSObj.Status__c)+')'));
                }
            }
            
            return retOpts;
        }
        
        public List<String> getWeekDates()
        {
            String tmpDataStr = '';
            if(lProjects.size()==0)
            {
                Employee_Profile__c curEmplObj = Timesheet.getCurEmployee();
                String tmpStr = '';
                
                if(curEmplObj!=null)
                {
                    lProjects = new List<String>();
                    lProjectsID = new List<String>();
                    id id1 = UserInfo.getUserId();
                    for (Timesheet__c ttObj : [Select t.Week_ending__c, t.Name, t.Id, t.CreatedById, t.Employee__c From Timesheet__c t where t.Employee__c = :curEmplObj.ID and CreatedById=:id1  order by t.Week_ending__c limit 20]) 
                    {
                        if(ttObj.Week_ending__c!=null)
                        {
                            tmpDataStr = ttObj.Week_ending__c.month()+'/'+ttObj.Week_ending__c.day()+'/'+ttObj.Week_ending__c.year();
                            lProjects.add(tmpDataStr);
                            lProjectsID.add(''+ttObj.ID);
                        }
                        //tmpStr = selDataTT.month()+'/'+selDataTT.day()+'/'+selDataTT.year();
                    }
                }
            }

            return lProjects;
        }
        
        
        public string jsonContent { get; set; }
        
        public static Date getFirstMondayInWeek(Date inVal)
        {
            datetime myDate = datetime.newInstance( inVal.year(), inVal.month(), inVal.day());
            //integer dayOfWeek =  integer.valueOf(''+myDate.format('F'));
            Map<String,integer> iConverToMon = new Map<String,integer>{'Sun'=>6,'Mon'=>0,'Tue'=>1,'Wed'=>2,'Thu'=>3,'Fri'=>4,'Sat'=>5};
            return inVal.addDays(-1*iConverToMon.get(''+myDate.format('E')));
        }
        
        public PageReference createNewWeek()
        {
            System.debug('Dbg createNewWeek: ' + (SelWeekDateTT!=null) + ' | ' +(SelWeekDateTT.Week_ending__c!=null)+' | '+(SelWeekDateTT.Name!=null));
            if(SelWeekDateTT!=null && SelWeekDateTT.Week_ending__c!=null && SelWeekDateTT.Name!=null)
            {
                
                date newDate = TimeTracker.getFirstMondayInWeek(SelWeekDateTT.Week_ending__c);

                if(newDate>date.today())
                {
                    ErrorMsg = 'You can\'t submitted timesheets for future weeks. Please select Start Date for another week.';
                    return null;    
                }
                String newSelDataTTStr = newDate.month()+'/'+newDate.day()+'/'+newDate.year();
                lProjects = getWeekDates();
                if(lProjects.size()>0)
                {
                    for(String tmpStr:lProjects)
                    {
                        if(tmpStr==newSelDataTTStr)
                        {
                            ErrorMsg = 'This week already exists. Please select Start Date for another week.';
                            return null;
                        }
                    }
                }
                
                Timesheet__c SelWeekDateTT_NEW = new Timesheet__c(Name=SelWeekDateTT.Name, Week_ending__c = SelWeekDateTT.Week_ending__c);
                
                Employee_Profile__c curEmplObj = Timesheet.getCurEmployee();
                SelWeekDateTT_NEW.Status__c = 'New';
                SelWeekDateTT_NEW.Employee__c = curEmplObj.ID;
                insert SelWeekDateTT_NEW;
                SelProjItem = ''+SelWeekDateTT_NEW.ID;

                //Select t.Timesheet__c, t.Employee__c, t.Deal__c From Timesheet_Entry__c t
                List<Timesheet_Entry__c> lTimesheetEntryForIns = new List<Timesheet_Entry__c>();
                for(Project_Resource__c presObj:[Select p.Project__c, p.Id, p.Banker__r.User_ID__c, p.Banker__c From Project_Resource__c p where p.Banker__r.User_ID__c = :UserInfo.getUserId() and p.Project__r.Stage__c != 'Closed - Completed' and p.Project__r.Stage__c != 'Closed - Dead' and p.Project__r.Stage__c != 'Closed - Lost' limit 100])
                {
                   if(presObj.Project__c != null)
                   {
                    Timesheet_Entry__c ttNewObj = new Timesheet_Entry__c(Employee__c=curEmplObj.ID,Deal__c=presObj.Project__c,Timesheet__c=SelWeekDateTT_NEW.ID);
                    lTimesheetEntryForIns.add(ttNewObj);
                    //insert ttNewObj;
                   }
                }
                if(lTimesheetEntryForIns.size()>0) insert lTimesheetEntryForIns;

                String newURL = '/apex/Timesheet?pid='+SelProjItem;
                PageReference pageRef = new PageReference(newURL);
                pageRef.setRedirect(true);
                return pageRef;
                

            }
            else ErrorMsg = 'Error. Date value is empty. Please select date for new week.';
            
            return null;
        }
        
        public PageReference selProject()
        {
            //System.currentPageReference().getParameters().put('pid',SelProjItem);
            if(SelProjItem!=null && SelProjItem!='')
            {
                String param1 = System.currentPageReference().getParameters().get('sfdc.tabName');
                String newURL = '/apex/Timesheet?pid='+SelProjItem;
                if(param1!=null) newURL = newURL + '&sfdc.tabName='+param1;
                
                PageReference pageRef = new PageReference(newURL);
                pageRef.setRedirect(true);
                return pageRef;
            }   
            
            return null;
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
        
        private PageReference saveData(String inMode)
        {
            //testData = ''+jsonContent;
            JSONObject jsonObj = new JSONObject(jsonContent);
            integer len = jsonObj.getValue('table').values.size();
            string valueId;
            List<Timesheet_Entry__c> tbList = new List<Timesheet_Entry__c>();
            system.debug('=== END ===');
            Timesheet_Entry__c tb = new Timesheet_Entry__c();
            string dateVal;
            Date dDateVal;
            boolean changed;
            Employee_Profile__c curEmplObj = isTest?epTestData:Timesheet.getCurEmployee();

            if(SelWeekDateTT.ID!=null) SelProjItem = ''+SelWeekDateTT.ID;
            
            if(SelProjItem==null || SelProjItem=='')
            {
                ErrorMsg = 'Error. Incorrect Timesheet Object.';
                return null;
            }
            
            for (integer i = 0; i < len; i++)
            {
                valueId = jsonObj.getValue('rows').values.get(i).str;
                //ErrorMsg = ''+valueId;
                
                system.debug('SelProjItem===' + SelProjItem);
                system.debug('curEmplObj.ID===' + curEmplObj.ID);
                system.debug('valueId===' + valueId);
                
                
                
                
                
                
                tb = [Select ID, Status__c, Note__c, Hours__c, Employee__c, Deal__c, Timesheet__c From Timesheet_Entry__c where Timesheet__c =:SelProjItem and Employee__c=:curEmplObj.ID and Deal__c=:valueId limit 1];
                changed = false;

                //Hours Spent
                dateVal = jsonObj.getValue('table').values.get(i).values.get(1).obj.getString('value');
                
                try
                {
                    double tmpInt = double.valueOf(dateVal);
                    //testData += '--'+tmpInt;
                    if(tb.Hours__c != tmpInt)
                    {
                        if(tmpInt<0) tmpInt = (-1)*tmpInt;
                        tb.Hours__c = tmpInt;
                        changed = true;
                    }
                    
                }
                catch (Exception e){ }

                // Status
                try 
                {
                    string newstatus = jsonObj.getValue('table').values.get(i).values.get(2).obj.getString('value');
                    if (newstatus != tb.Status__c) 
                    {
                        if(newstatus==null || newstatus=='') tb.Status__c = null;
                        else tb.Status__c = newstatus;
                        changed =  true;                    
                    }
                } catch (Exception e) {
                    
                }
                
                //Note
                dateVal = jsonObj.getValue('table').values.get(i).values.get(3).obj.getString('value');
                if(tb.Note__c != dateVal)
                {
                    tb.Note__c = dateVal;
                    changed = true; 
                }

                if (changed)
                {
                    tbList.add(tb);
                }
                
            }
            
            if(tbList.size()>0){ update tbList;}
            
           
            
            id id1 = UserInfo.getUserId();
            //curTTDateSQL
            SelWeekDateTT.Status__c = inMode;
            update SelWeekDateTT;
            
            return selProject();
        }
        
        
        public PageReference submitJson()
        {
            return saveData('Submitted');
        }
        
        public PageReference saveJson()
        {
            return saveData('New');
            //return null;
        } 
        
    public static testMethod void testMyController()
    {
        ID iCompanyRT = null;
        ID iDealRT = null;
        RecordType[] recTypeIDs  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Account' limit 1];
        for(RecordType rtItem: recTypeIDs)
        {
            iCompanyRT = rtItem.ID;
        }

        RecordType[] recTypeIDs2  = [Select id,Name,SobjectType from RecordType where SobjectType = 'Ibanking_Project__c' limit 1];
        for(RecordType rtItem: recTypeIDs2)
        {
            iDealRT = rtItem.ID;
        }
        
        Account accObj1 = new Account(Name='Company1',RecordTypeId=iCompanyRT,Type='Other',Industry='Other',Public_Private__c='Public',Client_Code__c='00001',EBITDA__c=2.0,Enterprise_Value__c=3.0,TickerSymbol='CSCO',Total_Revenue__c=10.0,Website='www.mail.ru');
        insert accObj1;
        
        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c emplObj = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        emplObj.User_ID__c = UserID;
        insert emplObj;


        id id1 = UserInfo.getUserId();
        Employee_Profile__c emplProfObj = null;
        for(Employee_Profile__c retObj : [Select e.User_ID__c, e.Name, e.Id From Employee_Profile__c e where e.User_ID__c = :id1 limit 1])
        {
            emplProfObj = retObj;
        }




        Ibanking_Project__c IbankProjObj = [Select i.website__c,i.Type__c, i.Transaction_Type__c, i.Transaction_Sub_Type__c, i.Transaction_Feature__c, i.Transaction_Completion_Date__c, i.Transaction_Announcement_Date__c, i.Ticker__c, i.TaxID__c, i.Target__c, i.Target_Revenues__c, i.Target_Ent_Value_Deal_Amount__c, i.Target_EBITDA__c, i.SystemModstamp, i.Status__c, i.Stage__c, i.Source_of_Funds__c, i.Sector__c, i.Revenue_Probability__c, i.Restrict__c, i.Relationship_History__c, i.Region__c,  i.RecordTypeId, i.Reason__c, i.PublicPrivate__c, i.Proposed_Fee_Structure__c, i.Product_Type__c, i.Probability_Adjusted_Revenue__c, i.Phone__c, i.OwnerId, i.Official_Committee_Financial_Advisor__c, i.Notes__c, i.Notes_4__c, i.Notes_3__c, i.Notes_2__c, i.Name, i.NBRC_Committee_Done_By__c, i.NBRC_Approval_Done_By__c, i.Moelis_Role__c, i.Milestone_NBRC_Committee_Date__c, i.Milestone_NBRC_Approved_Date__c, i.Milestone_KYC_Cleared_Date__c, i.Milestone_FINCEN_Cleared_Date__c, i.Milestone_Expense_Code_Date__c, i.Milestone_DealTeamConflictCheckCleared__c, i.Milestone_Agreements_Received_Date__c, i.Milestone_AML_OFAC_Cleared_Date__c, i.List_of_Owners__c, i.Lenders_Financial_Advisor_Firm__c, i.Lenders_Counsel_Firm__c, i.Legal_Done_By__c, i.Legal_Approved_Date__c, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.KYC_Cleared_Done_By__c, i.Jurisdiction__c, i.Judge__c, i.IsDeleted, i.Internal_Group__c, i.Industry__c, i.Include_in_Pipeline__c, i.Id, i.Headquarters_City__c, i.Google_Internet_Check_Results__c, i.Google_Internet_Check_Date__c, i.Full_Description_of_Transaction__c, i.Financial_Sponsor__c, i.Filing_Date__c,  i.Fax__c, i.Fairness_Opinion__c, i.FINCEN_Cleared_Done_By__c, i.Expense_Code__c, i.Expense_Code_Done_By__c, i.Expected_Engagement_Date__c, i.Expected_Close_Date__c, i.Estimated_Fee_Revenue__c, i.Est_Transaction_Size__c, i.Engagement_Date__c, i.Email__c, i.Description__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Competitive_Landscape__c, i.Company_Financial_Advisor_Firm__c, i.Company_Counsel_Firm__c, i.Co_Advisors__c, i.Client__c, i.Client_Revenues__c, i.Client_Enterprise_Value__c, i.Client_EBITDA__c, i.Client_Alias__c, i.Case_Number__c, i.Business_Type__c, i.Amount_of_Assets__c, i.Agreement_Received_Done_By__c, i.Acquiror__c, i.AML_OFAC_Cleared_Done_By__c From Ibanking_Project__c i order by i.CreatedDate desc limit 1];
        IbankProjObj.Client__c = accObj1.ID;
        //IbankProjObj.Staffer__c = emplObj.ID;
        IbankProjObj.Co_Advisors__c = 'Test textttt';
        IbankProjObj.Competitive_Landscape__c = 'Test textttt';
        IbankProjObj.Stage__c = 'TTTEST!';


        update IbankProjObj;


        system.debug('IbankProjObj.ID===' + IbankProjObj.ID);
        Project_Resource__c ProgResObj = new Project_Resource__c(Role__c='Other', Project__c=IbankProjObj.ID, Banker__c=emplObj.ID);

        insert ProgResObj;
        IbankProjObj.Name = 'Test Name-2';
        update IbankProjObj;
        
        Date myDate = date.today();
        myDate = TimeTracker.getFirstMondayInWeek(myDate);
        String curPidIDTest = myDate.month()+'/'+myDate.day()+'/'+myDate.year();
        Time_Tracker__c ttTrack1 = new Time_Tracker__c(Week_Start_Date__c=myDate,Employee__c=emplObj.ID,Deal__c=IbankProjObj.ID);
        insert ttTrack1;
        
        myDate.addDays(-7);
        Time_Tracker__c ttTrack2 = new Time_Tracker__c(Week_Start_Date__c=myDate,Employee__c=emplObj.ID,Deal__c=IbankProjObj.ID);
        insert ttTrack2;    

        delete ttTrack2;

        
        
        
        
        
        Test.startTest();
        
        Timesheet__c testTimesheet = new Timesheet__c();
        testTimesheet.Week_ending__c = date.newInstance(2009,1,1);
        testTimesheet.Employee__c = emplProfObj.ID;
        testTimesheet.Name = 'Test Timesheet';
        
        insert testTimesheet;

        Timesheet_Entry__c testEntry = new Timesheet_Entry__c();
        testEntry.Status__c = 'Other';
        testEntry.Note__c = 'qwe';
        testEntry.Hours__c = 6.0;
        testEntry.Employee__c = emplProfObj.Id;
        testEntry.Deal__c = IbankProjObj.Id; //IbankProjObj
        testEntry.Timesheet__c = testTimesheet.Id;
        insert testEntry;
        
        system.debug('testEntry.Timesheet__c===' + testEntry.Timesheet__c);
        system.debug('testEntry.Employee__c===' + testEntry.Employee__c);
        system.debug('testEntry.Deal__c===' + testEntry.Deal__c);
//                tb = [Select ID, Status__c, Note__c, Hours__c, Employee__c, Deal__c, Timesheet__c From Timesheet_Entry__c where Timesheet__c =:SelProjItem and Employee__c=:curEmplObj.ID and Deal__c=:valueId limit 1];


      
        
        
        Timesheet cc = new Timesheet();
        cc.epTestData = emplProfObj;
        System.currentPageReference().getParameters().put('pid', IbankProjObj.Id);
        cc.jsonContent = '{ "rows" : ["' + IbankProjObj.Id + '"],"table" : [[{"value" : "Test Proj99","type" : "sflink"},{"value" : "10.1","type" : "rtext"},{"value" : "Heavy Workload","type" : "smplselect"},{"value" : "note-1","type" : "text"}]]}';
        
        Timesheet__c ts = cc.getCurrTimesheet();
        Employee_Profile__c currentEmployee = Timesheet.getCurEmployee();
        cc.SelWeekDateTT = testTimesheet;
        PageReference pr1 = cc.createNewWeek();
        
        List<String> stringList = cc.getTBListPanel();
        List<String> stringList2 = cc.getTBFormAddPanel();
        List<selectOption> soList = cc.getWeekDatesOpts();
        List<String> stringList3 = cc.getWeekDates();
        Date aDate = date.newInstance(2009,1,1);
        Date firstMonday = Timesheet.getFirstMondayInWeek(aDate);
        PageReference pr2 = cc.selProject();
        PageReference pr3 = cc.cancel();
        Date aDate2 = cc.parceDate('01/01/2009');

        
//      '{    "head" : [        "Deal Name",        "Hours Spent",        "Status",        "Notes"    ],    "fields" : [{        },{        },{            "values" :[                    { "value" : "", "label" : ""}                    ,{ "value" : "Heavy Workload", "label" : "Heavy Workload"}                    ,{ "value" : "Medium Workload", "label" : "Medium Workload"}                    ,{ "value" : "Light Workload", "label" : "Light Workload"}                    ,{ "value" : "Dormant", "label" : "Dormant"}                    ,{ "value" : "Other", "label" : "Other"}            ]        },{        }    ],    "rows" : [        "' + testTimesheet.Id + '"    ],    "table" : [        [            {                "value" : "Test Proj99",                "type" : "sflink"            },{                "value" : "10.1",                "type" : "rtext"            },{                "value" : "Heavy Workload",                "type" : "smplselect"            },{                "value" : "note-1",                "type" : "text"                     }        ]    ]}';
        
        //PageReference pr4 = cc.saveData('Approved');
        PageReference pr5 = cc.submitJson();
        





        Test.stopTest();
    }        
        
*/

}