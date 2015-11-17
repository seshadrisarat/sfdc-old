/**
* Test methods are in Test_StaffingTimesheet.cls as StaffingTimesheetReport tests
**/
public without sharing class StaffingTimesheetReport_logic {
	
	public static List<Employee_Profile__c> getEmpList(List<String> ids) {
		List<Employee_Profile__c> res = new List<Employee_Profile__c>();
		if (ids.size() > 0) {
			String str = '';
			for (String item :ids) {
				if (str == '') {
					str += '\''+item+'\'';
				} else {
					str += ',\''+item+'\'';
				}
			}
			String queryStr = 'SELECT Id,Name,Office_Location__c,Title__c FROM Employee_Profile__c WHERE ';
			queryStr += 'Id in ('+str+')';
			res = database.query(queryStr);
		}
		return res;
	}
	
	public static List<Employee_Profile__c> getCurrEmployee(String userId) {
		List<Employee_Profile__c> res = null;
		List<Employee_Profile__c> tmp = new List<Employee_Profile__c>();
		String queryStr = '';
		queryStr = 'SELECT Id,Name,Office_Location__c,Staffing_Office_Location__c,Staffing_Business_Type__c,Title__c,Staffing_Title__c FROM Employee_Profile__c WHERE User_ID__r.Id=\''+userId+'\' Limit 1';
		if (userId != '' && userId != null) {
			tmp = database.query(queryStr);
			if (tmp.size() > 0) {
				res = tmp;
			}
		}
		
		return res;
	}
	
	private static String timeTrackerFields = ' Deal__r.Sector__c,Time_Sheet_Summary__r.Employee__r.Rank__c,Time_Sheet_Summary__r.Employee__r.Office_Location__c,Time_Sheet_Summary__r.Employee__r.Last_Name__c,Time_Sheet_Summary__r.Employee__r.First_Name__c,Time_Sheet_Summary__r.Employee__r.Title__c,Time_Sheet_Summary__r.Employee__r.Group__c,Deal__r.Industry__c,Employee__r.Group__c,Deal__r.RecordType.Name,Deal__r.Type__c,Deal__r.Stage__c,Time_Sheet_Summary__r.Employee__r.id,Time_Sheet_Summary__r.Week_Start_Date__c,Time_Sheet_Summary__r.Id,Deal__r.Client__r.Name,Time_Sheet_Summary__r.Stage__c,Time_Sheet_Summary__r.Text__c,Time_Sheet_Summary__r.Overall_Capacity__c,Non_Deal_Project__c,Deal__r.Name,Hours__c,Note__c,Employee__r.First_Name__c,Employee__r.Last_Name__c,Employee__r.ID,Week_Start_Date__c,Employee__r.Title__c,Employee__r.Office_Location__c,Employee__r.Status__c,Status__c,Stage__c,Deal_Team_Members__c ';
	private static String timeSheetSummaryFields = ' Employee__r.Name,Employee__r.Rank__c,Employee__r.Group__c,Stage__c,Employee__r.First_Name__c,Employee__r.Last_Name__c,Text__c,Employee__r.ID,Overall_Capacity__c,Week_Start_Date__c,Employee__r.Title__c,Employee__r.Office_Location__c,Employee__r.Status__c ';
	//Returns a Detail Report records
	public static List<Time_Tracker__c> getGroupedEmployees(Date fromStartDate, Date endStartDate, String titles, String offices, String businessType, Boolean includeInactive, Boolean includeAll) {
		List<Time_Tracker__c> res;
		
		Integer sy = fromStartDate.year();
		Integer sm = fromStartDate.month();
		Integer sd = fromStartDate.day();
		String fromDate = StaffingTimesheetReport_logic.getDate(sy,sm,sd);
		Integer ey = endStartDate.year();
		Integer em = endStartDate.month();
		Integer ed = endStartDate.day();
		String endDate = StaffingTimesheetReport_logic.getDate(ey,em,ed);
		
		String whereTitleStr = StaffingTimesheetReport_logic.getWhereTitleStr(titles);
		String whereOfficeStr = StaffingTimesheetReport_logic.getWhereOfficeStr(offices);
		String whereBusinessTypeStr = StaffingTimesheetReport_logic.getWhereBusinessTypeStr(businessType);
		String whereIncludeInactiveDetailStr = StaffingTimesheetReport_logic.getWhereIncludeInactiveDetailStr(includeInactive);
		String employeeWhereTitleStr = StaffingTimesheetReport_logic.getEmployeeWhereTitleStr(titles);
		String employeeWhereOfficeStr = StaffingTimesheetReport_logic.getEmployeeWhereOfficeStr(offices);
		String employeeWhereBusinessTypeStr = StaffingTimesheetReport_logic.getEmployeeWhereBusinessTypeStr(businessType);
		String employeeWhereIncludeInactiveStr = StaffingTimesheetReport_logic.getEmployeeWhereIncludeInactiveStr(includeInactive);
		String queryStr = '';
		queryStr += 'SELECT '+StaffingTimesheetReport_logic.timeTrackerFields;
		queryStr += ' FROM Time_Tracker__c ';
		queryStr += ' WHERE ';
		queryStr += ' Time_Sheet_Summary__r.Week_Start_Date__c >= '+fromDate+' ';
		queryStr += ' AND Time_Sheet_Summary__r.Week_Start_Date__c <= '+endDate+' ';
		queryStr += whereTitleStr;
		queryStr += whereOfficeStr;
		queryStr += whereBusinessTypeStr;
		queryStr += whereIncludeInactiveDetailStr;
		//queryStr += 'Order by Time_Sheet_Summary__r.Employee__r.Name, Time_Sheet_Summary__r.Employee__r.Last_Name__c,Time_Sheet_Summary__r.Week_Start_Date__c,Time_Sheet_Summary__r.Employee__r.Title__c,Time_Sheet_Summary__r.Employee__r.Rank__c,Deal__r.Stage__c DESC,Deal__r.Client__r.Name,Deal__r.Name,CreatedDate Limit 10000';
		//queryStr += 'Order by Time_Sheet_Summary__r.Employee__r.Rank__c, Time_Sheet_Summary__r.Employee__r.Name, Time_Sheet_Summary__r.Employee__r.Last_Name__c, '
			//+ 'Time_Sheet_Summary__r.Week_Start_Date__c,Time_Sheet_Summary__r.Employee__r.Title__c,'+
			//' Deal__r.Stage__c DESC,Deal__r.Client__r.Name,Deal__r.Name,CreatedDate Limit 10000';
			//Commented by Sruti as per Moelissup -7 
		queryStr += ' Order by Time_Sheet_Summary__r.Week_Start_Date__c, Time_Sheet_Summary__r.Employee__r.Title__c, Time_Sheet_Summary__r.Employee__r.Rank__c, '+
			'Time_Sheet_Summary__r.Employee__r.Last_Name__c, Time_Sheet_Summary__r.Employee__r.First_Name__c, Deal__r.Stage__c DESC, Deal__r.Client__r.Name,Deal__r.Name,CreatedDate Limit 10000';

		
		res = database.query(queryStr);
		
		Set<Id> Set_dealIds = new Set<Id>();
		List<Project_Resource__c> dealTeamMembers = new List<Project_Resource__c>();
		//Map<Id,String> Map_DealId_DealTeam = new Map<Id,String>();
		Map<Id,List<String>> Map_DealId_ListDealTeam = new Map<Id,List<String>>();
		for (Time_Tracker__c item:res) 
		{
			Set_dealIds.add(item.Deal__c);
		}
		if(Set_dealIds.size() > 0)
		{
			for(Project_Resource__c PR_item : [SELECT Banker__r.Title__c,Banker__r.Name,Project__c FROM Project_Resource__c WHERE Project__c IN : Set_dealIds Order by Banker__r.Title__c])
			{
				if (Map_DealId_ListDealTeam.containsKey(PR_item.Project__c))	
				{
					Map_DealId_ListDealTeam.get(PR_item.Project__c).add(PR_item.Banker__r.Name);
				}
		        else 
		        {
		        	if(PR_item.Project__c != null)
		        	{
			       		List<String> tmp1 = new List<String>();
			       		tmp1.add(PR_item.Banker__r.Name);
			       		Map_DealId_ListDealTeam.put(PR_item.Project__c,tmp1);
		        	}
		        }
				
			}
		}
		
		for (Integer i=0;i<res.size();i++) 
		{
			if(res[i] != null)
			{
				Boolean flag;
				res[i].Deal_Team_Members__c = '';
				if(res[i].Deal__c != null && Map_DealId_ListDealTeam.containsKey(res[i].Deal__c))
				{
					List<String> tmp = new List<String>();
					for(String item_DealTeamName : Map_DealId_ListDealTeam.get(res[i].Deal__c)) {
						if (res[i].Deal_Team_Members__c == '' || res[i].Deal_Team_Members__c == null) res[i].Deal_Team_Members__c = item_DealTeamName;
						else	res[i].Deal_Team_Members__c += '; '+item_DealTeamName;
					}
				}
			}
		}
		
		if (includeAll) { //If 'Include all' is checked
			String inStr = ''; //Ids of already selected records
			for (Time_Tracker__c elem: res) {
				if (inStr == '') {
					inStr += '(\''+elem.Time_Sheet_Summary__r.Employee__r.ID+'\'';
				} else {
					inStr += ',\''+elem.Time_Sheet_Summary__r.Employee__r.ID+'\'';
				}
			}
			if (inStr != '') {
				inStr += ')';
				instr = 'ID NOT IN '+inStr;
			}
			
			List<Employee_Profile__c> emps; //Select all other records
			queryStr = ' SELECT Rank__c,Group__c,First_Name__c,Last_Name__c,Name,Title__c,Status__c,Office_Location__c FROM Employee_Profile__c WHERE '+inStr+' ';
			if (instr != '') queryStr += ' AND ';
			queryStr += employeeWhereTitleStr;
			queryStr += employeeWhereOfficeStr;
			queryStr += employeeWhereBusinessTypeStr;
			queryStr += employeeWhereIncludeInactiveStr;
			queryStr += ' Order by Title__c,Rank__c, Name, Last_Name__c,CreatedDate Limit 10000';
			emps = database.query(queryStr);
			if (emps != null) {
				for (Employee_Profile__c emp: emps) { //Adding selected records to result query
					Time_Tracker__c temp = new Time_Tracker__c();
					temp.Time_Sheet_Summary__r = new TimeSheet_Summary__c();
					temp.Time_Sheet_Summary__r.Employee__r = emp;
					temp.Employee__r = emp;
					//MOELIS-108
				//	temp.Note__c = 'No Timesheet for this period.';
					res.add(temp);
				}
			}
		}
		return res;
    }
	
	//Returns a Summary Report records
	public static List<TimeSheet_Summary__c> getSummaryReport(Date fromStartDate, Date endStartDate, String titles, String offices, String businessType, Boolean includeInactive, Boolean includeAll) {
		List<TimeSheet_Summary__c> res;
		
		Integer sy = fromStartDate.year();
		Integer sm = fromStartDate.month();
		Integer sd = fromStartDate.day();
		String fromDate = StaffingTimesheetReport_logic.getDate(sy,sm,sd);
		Integer ey = endStartDate.year();
		Integer em = endStartDate.month();
		Integer ed = endStartDate.day();
		String endDate = StaffingTimesheetReport_logic.getDate(ey,em,ed);
		
		String whereTitleStr_Summary = StaffingTimesheetReport_logic.getWhereTitleStr_Summary(titles);
		String whereOfficeStr_Summary = StaffingTimesheetReport_logic.getWhereOfficeStr_Summary(offices);
		String whereBusinessTypeStr_Summary = StaffingTimesheetReport_logic.getWhereBusinessTypeStr_Summary(businessType);
		String whereIncludeInactiveStr = StaffingTimesheetReport_logic.getWhereIncludeInactiveStr(includeInactive);
		String employeeWhereTitleStr = StaffingTimesheetReport_logic.getEmployeeWhereTitleStr(titles);
		String employeeWhereOfficeStr = StaffingTimesheetReport_logic.getEmployeeWhereOfficeStr(offices);
		String employeeWhereBusinessTypeStr = StaffingTimesheetReport_logic.getEmployeeWhereBusinessTypeStr(businessType);
		String employeeWhereIncludeInactiveStr = StaffingTimesheetReport_logic.getEmployeeWhereIncludeInactiveStr(includeInactive);
		String queryStr = '';
		queryStr += 'SELECT '+StaffingTimesheetReport_logic.timeSheetSummaryFields;
		queryStr += 'FROM TimeSheet_Summary__c ';
		queryStr += 'WHERE ';
		queryStr += 'Week_Start_Date__c >= '+fromDate+' ';
		queryStr += 'AND Week_Start_Date__c <= '+endDate+' ';
		queryStr += whereTitleStr_Summary;
		queryStr += whereOfficeStr_Summary;
		queryStr += whereBusinessTypeStr_Summary;
		queryStr += whereIncludeInactiveStr;
		queryStr += 'AND Employee__c != null ';
		queryStr += ' Order by Week_Start_Date__c, Employee__r.Title__c, Employee__r.Rank__c, Employee__r.Name, Employee__r.Last_Name__c Limit 10000';
		
		res = database.query(queryStr);
		if (includeAll) {
			String inStr = '';
			for (TimeSheet_Summary__c elem: res) {
				if (inStr == '') {
					inStr += '(\''+elem.Employee__r.ID+'\'';
				} else {
					inStr += ',\''+elem.Employee__r.ID+'\'';
				}
			}
			if (inStr != '') {
				inStr += ')';
				instr = 'ID NOT IN '+inStr+' AND ';
			}
			
			List<Employee_Profile__c> emps; 
			queryStr = 'SELECT Rank__c,Group__c, First_Name__c,Last_Name__c,Name,Title__c,Status__c,Office_Location__c FROM Employee_Profile__c WHERE '+inStr+' ';
			queryStr += employeeWhereTitleStr;
			queryStr += employeeWhereOfficeStr;
			queryStr += employeeWhereBusinessTypeStr;
			queryStr += employeeWhereIncludeInactiveStr;
			queryStr += ' Order by Title__c,Rank__c, Name, Last_Name__c Limit 10000';
			emps = database.query(queryStr);
			if (emps != null) {
				for (Employee_Profile__c emp: emps) {
					TimeSheet_Summary__c temp = new TimeSheet_Summary__c();
					temp.Employee__r = emp;
					temp.Text__c = 'No Timesheet for this period.';
					res.add(temp);
				}
			}
		}
		return res;
	}
	
	//Transforming string of Titles to part of query
	public static String getWhereTitleStr(String titles) {
		List<String> t = new List<String>();
		String res = '';
		if (titles != '' && titles != null) {
			t = titles.split(';');
			for (String title: t) {
				if (res == '') {
					res += ' AND (Time_Sheet_Summary__r.Employee__r.Title__c = \''+title+'\' ';
				} else {
					res += 'OR Time_Sheet_Summary__r.Employee__r.Title__c = \''+title+'\' ';
				}
			}
			res += ') ';
		}
		return res;
	}
	
	//Transforming string of Offices to part of query
	public static String getWhereOfficeStr(String offices) {
		List<String> o = new List<String>();
		String res = '';
		if (offices != '' && offices != null) {
			o = offices.split(';');
			for (String office: o) {
				if (res == '') {
					res += ' AND (Time_Sheet_Summary__r.Employee__r.Office_Location__c = \''+office+'\' ';
				} else {
					res += 'OR Time_Sheet_Summary__r.Employee__r.Office_Location__c = \''+office+'\' ';
				}
			}
			res += ') ';
		}
		
		return res;
	}

	//Transforming string of businessType to part of query
	public static String getWhereBusinessTypeStr(String businessType) {
		List<String> tmpRes = new List<String>();
		String res = '';
		if (businessType != '' && businessType != null) {
			tmpRes = businessType.split(';');
			for (String item: tmpRes) {
				if (res == '') {
					res += ' AND (Time_Sheet_Summary__r.Employee__r.Business_Type__c = \''+item+'\' ';
				} else {
					res += 'OR Time_Sheet_Summary__r.Employee__r.Business_Type__c = \''+item+'\' ';
				}
			}
			res += ') ';
		}
		return res;
	}
	
		//Transforming string of Titles to part of query
	public static String getWhereTitleStr_Summary(String titles) {
		List<String> t = new List<String>();
		String res = '';
		if (titles != '' && titles != null) {
			t = titles.split(';');
			for (String title: t) {
				if (res == '') {
					res += ' AND (Employee__r.Title__c = \''+title+'\' ';
				} else {
					res += 'OR Employee__r.Title__c = \''+title+'\' ';
				}
			}
			res += ') ';
		}
		return res;
	}
	
	//Transforming string of Offices to part of query
	public static String getWhereOfficeStr_Summary(String offices) {
		List<String> o = new List<String>();
		String res = '';
		if (offices != '' && offices != null) {
			o = offices.split(';');
			for (String office: o) {
				if (res == '') {
					res += ' AND (Employee__r.Office_Location__c = \''+office+'\' ';
				} else {
					res += 'OR Employee__r.Office_Location__c = \''+office+'\' ';
				}
			}
			res += ') ';
		}
		return res;
	}

	//Transforming string of businessType to part of query
	public static String getWhereBusinessTypeStr_Summary(String businessType) {
		List<String> tmpRes = new List<String>();
		String res = '';
		if (businessType != '' && businessType != null) {
			tmpRes = businessType.split(';');
			for (String item: tmpRes) {
				if (res == '') {
					res += ' AND (Employee__r.Business_Type__c = \''+item+'\' ';
				} else {
					res += 'OR Employee__r.Business_Type__c = \''+item+'\' ';
				}
			}
			res += ') ';
		}
		return res;
	}
	
	//If 'Include inactive?' not checked, then return part of query 
	public static String getWhereIncludeInactiveStr(Boolean includeInactive) {
		String res = '';
		if (!includeInactive) {
			res += ' AND Employee__r.Status__c = \'Active\' ';
		}
		return res;
	}
	public static String getWhereIncludeInactiveDetailStr(Boolean includeInactive) {
		String res = '';
		if (!includeInactive) {
			res += ' AND Time_Sheet_Summary__r.Employee__r.Status__c = \'Active\' ';
		}
		return res;
	}
	
	//Transforming string of Titles to part of Employee query
	public static String getEmployeeWhereTitleStr(String titles) {
		List<String> t = new List<String>();
		String res = '';
		if (titles != '' && titles != null) {
			t = titles.split(';');
			for (String title: t) {
				if (res == '') {
					res += ' (Title__c = \''+title+'\' ';
				} else {
					res += 'OR Title__c = \''+title+'\' ';
				}
			}
			res += ') AND ';
		}
		return res;
	}
	
	//Transforming string of Offices to part of Employee query
	public static String getEmployeeWhereOfficeStr(String offices) {
		List<String> o = new List<String>();
		String res = '';
		if (offices != '' && offices != null) {
			o = offices.split(';');
			for (String office: o) {
				if (res == '') {
					res += ' (Office_Location__c = \''+office+'\' ';
				} else {
					res += 'OR Office_Location__c = \''+office+'\' ';
				}
			}
			res += ') AND ';
		}
		return res;
	}
	
	//Transforming string of Business Types to part of Employee query
	public static String getEmployeeWhereBusinessTypeStr(String businessTypes) {
		List<String> bt = new List<String>();
		String res = '';
		if (businessTypes != '' && businessTypes != null) {
			bt = businessTypes.split(';');
			for (String item: bt) {
				if (res == '') {
					res += ' (Business_Type__c = \''+item+'\' ';
				} else {
					res += 'OR Business_Type__c = \''+item+'\' ';
				}
			}
			res += ') AND ';
		}
		return res;
	}
	
	//If 'Include inactive?' not checked, then return part of Employee query
	public static String getEmployeeWhereIncludeInactiveStr(Boolean includeInactive) {
		String res = '';
		if (!includeInactive) {
			res += ' (Status__c = \'Active\') ';
		} else {
			res += ' (Status__c != \'\') ';
		}
		return res;
	}
	
	//Returm the date in normal format
	public static String getDate(Integer yyyy,Integer mm, Integer dd) {
		String res = String.valueOf(yyyy)+'-';
		if (mm < 10) {
			res += '0';
		}
		res += String.valueOf(mm)+'-';
		if (dd <10) {
			res += '0';
		}
		res += String.valueOf(dd);
		return res;
	}
	
}