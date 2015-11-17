/**
* Test methods are in Test_StaffingTimesheet.cls
**/
public with sharing class StaffingTimesheetReport {
	
	public String excelHeaderDuplicate {
		get {
			String res = '<x:ExcelName><x:Name>Print_Titles</x:Name><x:SheetIndex>1</x:SheetIndex><x:Formula>=$5:$5</x:Formula></x:ExcelName>';
			return res;
		}
	}
	
	public String errMsg{ //Message, shows into Error block
		get {
			String str = errMsg;
			if (isSummary == '' || isSummary == null) {str = 'You don\'t have a permissions to view this page.';}
			return str;
		}
		set;
	}
	
	public String generatedBy {
		get {
			String str = ''; 
			str += UserInfo.getFirstName();
			str += ' '+UserInfo.getLastName();
			return str;
		}
	}
	/*public DateTime generatedTime {
		get {
			DateTime curr = DateTime.now();
			return curr;
		}
	}*/
	public String generatedTime {
		get {
			String res = '';
			DateTime nowTime = datetime.now();
			res = nowTime.month()+'\\'+nowTime.day()+'\\'+nowTime.year()+' '+nowTime.hour()+':'+nowTime.minute()+' ';
			return res;
		}
	}
	
	private Contact fromStartDate = new Contact(); //using field Birthdate
	public Contact getFromStartDate(){ //Getting fromStartDate from PageParams
		String param = ApexPages.currentPage().getParameters().get('fromStartDate');
		if (param != null) {
			fromStartDate.Birthdate = date.valueOf(param); //Transforming from string to Date
		}
		return fromStartDate;
	}

	private Contact endStartDate = new Contact(); //using field Birthdate
	public Contact getEndStartDate(){
		String param = ApexPages.currentPage().getParameters().get('endStartDate');
		if (param != null) {
			endStartDate.Birthdate = date.valueOf(param);
		}
		return endStartDate;
		
	}
	private String titles_p {get;set;} //Getting Titles List value from Page params once
	public String titles {
		get {
			if (titles_p == null) {
				titles_p = ApexPages.currentPage().getParameters().get('titles');
			}
			return titles_p;
		}
	}

	private String offices_p {get;set;} //Getting Office_Location value from Page params once
	public String offices {
		get {
			if (offices_p == null) {
				offices_p = ApexPages.currentPage().getParameters().get('offices');
			}
			return offices_p;
		}
	}
	
	private String businessType_p {get;set;} //Getting Business_Type__c value from Page params once
	public String businessType {
		get {
			if (businessType_p == null) {
				businessType_p = ApexPages.currentPage().getParameters().get('businessType');
			}
			return businessType_p;
			
		}
	}
	
	private String outputTo_p {get;set;} //Getting outputTo option from Page params once
	public String outputTo {
		get {
			if (outputTo_p == null) {
				outputTo_p = ApexPages.currentPage().getParameters().get('outputTo');
			}
			return outputTo_p;
		}
	}
	
	public String chooseRender {
		get {
			String res = '';
			if (outputTo == 'pdf') {
				res = 'pdf';
			}
			return res;
		}
	}
	
	public String contentType {
		get {
			String res = '';
			if (outputTo == 'xls') {
				 res = 'application/vnd.ms-excel#'+generatedTime.replaceAll(' ','_')+'_StaffingTimesheetReport.xls';
			}
			return res;
		}
	}
	
	private Boolean includeInactive_p {get;set;} //Get and transform includeInactive value from String to Boolean
	public Boolean includeInactive {
		get {
			if (includeInactive_p == null) {
				includeInactive_p = false;
				String val = ApexPages.currentPage().getParameters().get('includeInactive');
				if (val == '1') {
					includeInactive_p = true;
				}
			}
			return includeInactive_p;
		}
	}
	
	private Boolean includeAll_p {get;set;} //Get and transform includeAll value from String to Boolean
	public Boolean includeAll {
		get {
			if (includeAll_p == null) {
				includeAll_p = false;
				String val = ApexPages.currentPage().getParameters().get('includeAll');
				if (val == '1') {
					includeAll_p = true;
				}
			}
			return includeAll_p;
		}
	}
	
	public String isSummary { //Display the desired panel, depending on the report
		get {
			String val = '';
			String reportType = ApexPages.currentPage().getParameters().get('reportType');
			if (reportType != null) {
				val = '1';
				if (reportType == 'detail') {
					val = '0';
				}
			}
			return val;
		}
	}
	
	public List<TimeSheet_Summary__c> summaryTable { //Table of Summary report
		get {
			List<TimeSheet_Summary__c> res = new List<TimeSheet_Summary__c>();
			if (isSummary == '1') {
				res = StaffingTimesheetReport_logic.getSummaryReport(getFromStartDate().Birthdate, getEndStartDate().Birthdate, titles, offices, businessType, includeInactive, includeAll);
			}
			return res;
		}
	} 
	
	public List<EmployeeRecord> getReport() { //Get Summary Report table
		List<EmployeeRecord> res = new List<EmployeeRecord>();
		if (isSummary == '1') {
			if (summaryTable.size() > 0) {
				EmployeeRecord toAdd = new EmployeeRecord();
				Date currDate = summaryTable[0].Week_Start_Date__c; //Date of current Week
				for (TimeSheet_Summary__c rec:summaryTable) {
					if (rec.Week_Start_Date__c != currDate) { //If this is Next Week
						if (toAdd.TimeSheet.size() > 0) {
							res.add(sortByRankSummary(toAdd));
						}
						toAdd = new EmployeeRecord();
						currDate = rec.Week_Start_Date__c;
					}
					//Filling EmployeeRecord object fields
					toAdd.WeekStartDate = rec.Week_Start_Date__c;
					toAdd.Id = rec.Id;
					if (!isExcludeEmployee(rec.Employee__r.Group__c,rec.Employee__r.Title__c)) {
						toAdd.TimeSheet.add(rec);
						toAdd.NumEmployees++;
					}
				}
				if (toAdd.TimeSheet.size() > 0) {
					res.add(sortByRankSummary(toAdd)); //Add last EmployeeRecord to result array
				}
			}
		}
        return res;
    }
    
    public List<DetailRecord> getDetailReport() { //Get Detail Report table
		List<DetailRecord> res = new List<DetailRecord>();
		map<string,string> mapEmployeeNameToProject = new map<string,string>();
		if (isSummary == '0') {
			List<Time_Tracker__c> summaryTable1 = StaffingTimesheetReport_logic.getGroupedEmployees(getFromStartDate().Birthdate, getEndStartDate().Birthdate, titles, offices, businessType, includeInactive, includeAll);
			DetailRecord toAdd = new DetailRecord(); //DetailRecord of Employee
			WeekRecord empAdd = new WeekRecord(); //Detail Record of Week (analog TimeSheet_Summary)
			if (summaryTable1.size() > 0) {
				//Initiating variables of start values
				Date currDate = summaryTable1[0].Time_Sheet_Summary__r.Week_Start_Date__c;
				ID currId = summaryTable1[0].Time_Sheet_Summary__r.Employee__r.Id;
				Integer size = summaryTable1.size();
				for (Integer i=0; i<size; i++) 
				{
					Time_Tracker__c rec = summaryTable1[i];
					if (rec.Time_Sheet_Summary__r.Week_Start_Date__c != currDate) 
					{ //If this is next Week
						//Then this is new Employee
						
						if (empAdd.Records.size() > 0) 
						{
							if (!isExcludeEmployee(empAdd.empGroup,empAdd.Title)) 
							{
								toAdd.TimeRecords.add(sortByNoDeal(empAdd));
								toAdd.NumEmployees++;
							}
						}
						if (toAdd.TimeRecords.size() > 0) 
						{
							res.add(toAdd);
						}
						toAdd = new DetailRecord();
						empAdd = new WeekRecord();
						currId = rec.Time_Sheet_Summary__r.Employee__r.Id;
						currDate = rec.Time_Sheet_Summary__r.Week_Start_Date__c;
					} 
					else if (rec.Time_Sheet_Summary__r.Employee__r.id != currId) 
					{ //If this is new Employee
						if (empAdd.Records.size() > 0) {
							if (!isExcludeEmployee(empAdd.empGroup,empAdd.Title)) {
								toAdd.TimeRecords.add(sortByNoDeal(empAdd));
								toAdd.NumEmployees++;
							}
						}
						empAdd = new WeekRecord();
						currId = rec.Time_Sheet_Summary__r.Employee__r.Id;
					}
					//Filling Week & Employee objects fields
					empAdd.FirstName = rec.Time_Sheet_Summary__r.Employee__r.First_Name__c;
					empAdd.LastName = rec.Time_Sheet_Summary__r.Employee__r.Last_Name__c;
					empAdd.Office = rec.Time_Sheet_Summary__r.Employee__r.Office_Location__c;
					empAdd.Title = rec.Time_Sheet_Summary__r.Employee__r.Title__c;
					empAdd.empGroup = rec.Time_Sheet_Summary__r.Employee__r.Group__c;
					empAdd.Rank = rec.Time_Sheet_Summary__r.Employee__r.Rank__c;
					empAdd.Stage = rec.Time_Sheet_Summary__r.Stage__c;
					if (rec.Hours__c != null)
						empAdd.TotalHours += rec.Hours__c;
					empAdd.TotalCapacity = rec.Time_Sheet_Summary__r.Overall_Capacity__c;
					empAdd.WeekComment = rec.Time_Sheet_Summary__r.Text__c;
					empAdd.Records.add(rec);
					if (i == 0) {
						toAdd.isFirst = true;
					}
					toAdd.WeekStartDate = rec.Time_Sheet_Summary__r.Week_Start_Date__c;
					toAdd.Id = rec.Id;
				}
				//Add last records to result array
				if (empAdd.Records.size() > 0) {
					if (!isExcludeEmployee(empAdd.empGroup,empAdd.Title)) {
						toAdd.TimeRecords.add(sortByNoDeal(empAdd));
						toAdd.NumEmployees++;
						
					}
				}
				if (toAdd.TimeRecords.size() > 0) {
					res.add(toAdd);
				}
			}
		}
        return res;
    }
    
    private EmployeeRecord sortByRankSummary(EmployeeRecord record) {
    	/*Integer i,j;
    	TimeSheet_Summary__c buf = new TimeSheet_Summary__c();
    	for(i=0;i<record.TimeSheet.size();i++) {
    		for(j=0;j<record.TimeSheet.size()-i-1;j++) {
    			if(
    				record.TimeSheet[j].Employee__r.Rank__c != 'AN3' &&
    				record.TimeSheet[j].Employee__r.Rank__c != 'AN2' &&
    				record.TimeSheet[j].Employee__r.Rank__c != 'AN1' &&
    				record.TimeSheet[j].Employee__r.Rank__c != 'VP3' &&
    				record.TimeSheet[j].Employee__r.Rank__c != 'VP2' &&
    				record.TimeSheet[j].Employee__r.Rank__c != 'VP1' &&
    				record.TimeSheet[j].Employee__r.Rank__c < record.TimeSheet[j+1].Employee__r.Rank__c
    			) {
    				buf = record.TimeSheet[j];
    				record.TimeSheet[j] = record.TimeSheet[j+1];
    				record.TimeSheet[j+1] = buf;
    			}
    		}
    	}*/
    	
    	return record;
    }
    
    private Boolean isExcludeEmployee(String empGroup, String empTitle) {
    	Boolean res = false;
    	if (empGroup == 'Management & Operations' &&
    		 (empTitle == 'Analyst' ||
    		  empTitle == 'Associate' ||
    		  empTitle == 'Vice President')
    		) {
    		res = True;
    	}
    	return res;
    }
    
    /*
     * Deal/non-deal sorting (deals at the top and non-deals at the bottom with order
     * of projects as it was added in timesheet (per Issue 628))
    */
    private WeekRecord sortByNoDeal(WeekRecord rec){
    	Integer i,j;
    	Time_Tracker__c buf = new Time_Tracker__c();
    	Integer size = rec.Records.size();
    	for (i=0; i<size; i++) {
    		for (j=0;j<size-1;j++) {
	    		if (rec.Records[j].Deal__r.Name == 'Non-Deal Project') {
	    			buf = rec.Records[j];
	    			rec.Records[j] = rec.Records[j+1];
	    			rec.Records[j+1] = buf;
	    		}
    		}
    	}
    	return rec;
    }
    
    public class WeekRecord {
    	public String FirstName{get;set;}
    	public String LastName{get;set;}
    	public String Office{get;set;}
    	public String Title{get;set;}
    	public String empGroup{get;set;}
    	public String Stage{get;set;}
    	public Decimal TotalHours{get;set;}
    	public String TotalCapacity{get;set;}
    	public String WeekComment{get;set;}
    	public String Rank{get;set;}
    	public List<Time_Tracker__c> Records{get;set;}
    	public WeekRecord() {
    		FirstName = '';
    		LastName = '';
    		Office = '';
    		Title = '';
    		TotalHours = 0;
    		TotalCapacity = '';
    		WeekComment = '';
    		Rank = '';
    		Records = new List<Time_Tracker__c>();
    	}
    }
    
    public class DetailRecord {
    	public ID Id{get;set;}
    	public Date WeekStartDate{get;set;}
    	public Integer NumEmployees{get;set;}
    	public List<WeekRecord> TimeRecords{get;set;}
    	public Boolean isFirst {get;set;}
    	public DetailRecord() {
    		NumEmployees = 0;
    		this.TimeRecords = new List<WeekRecord>();
    	}
    }
    
    public class EmployeeRecord {
    	public ID Id{get;set;}
    	public Date WeekStartDate{get;set;}
    	public Integer NumEmployees{get;set;}
    	public List<TimeSheet_Summary__c> TimeSheet{get;set;}
    	public EmployeeRecord() {
    		NumEmployees = 0;
    		this.TimeSheet = new List<TimeSheet_Summary__c>();
    	}
    }
    
    
    /* ============================================================= *
     * Temporary script to Clean Up Time_Tracker__c DB to duplicates *
     * ============================================================= */
    /*
    public void deleteDuplicates() { //Clear Time_Tracker__c from duplicates
    	Map<Id,Time_Tracker__c> TTid_TTobj_Map = new Map<Id,Time_Tracker__c>();
    	List<Time_Tracker__c> TT_toDelete = new List<Time_Tracker__c>();
        String queryString = 'SELECT Id,Deal__c FROM Time_Tracker__c';
        List<Time_Tracker__c> res = database.query(queryString);
        for (Time_Tracker__c tt_tmp: res) {
			if(TTid_TTobj_Map.containsKey(tt_tmp.Deal__c)) {
				TT_toDelete.add(tt_tmp);
			} else {
		 		TTid_TTobj_Map.put(tt_tmp.Deal__c,tt_tmp);
		 	}	
		}
		system.debug('>>>>>>>>>>>> IN DB >>>>>>>>>>>> '+res.size());
		system.debug('>>>>>>>>>>>> TO DELETE >>>>>>>>>>>> '+TT_toDelete.size());
		for (Time_Tracker__c toDel: TT_toDelete)
		  system.debug('============>>>>>>> '+toDel);
		delete TT_toDelete;
    }*/
    
    /* ================================================================== *
     * Temporary script to Clean Up TimeSheet_Summary__c DB to duplicates *
     * ================================================================== */
     /*
    public void cleanDuplicates_TSS() {
    	List<TimeSheet_Summary__c> lst = new List<TimeSheet_Summary__c>();
    	List<TimeSheet_Summary__c> toDelete = new List<TimeSheet_Summary__c>();
    	List<Time_Tracker__c> temp = null;
    	lst = [SELECT id FROM TimeSheet_Summary__c ORDER BY id];
    	Integer i;
    	for (i=90;i<lst.size();i++) {
    		i++;
    		if (i > 98) break;
    		temp = [SELECT id,Time_Sheet_Summary__c FROM Time_Tracker__c WHERE Time_Sheet_Summary__c = :lst[i].id];
    		if (temp.size() == 0) {
    			toDelete.add(lst[i]);
    		}
    	}
    	system.debug('============== IN DB ===============>>>> '+lst.size());
    	system.debug('============== TO DELETE ===============>>>> '+toDelete.size());
    	delete toDelete;
    }*/
}