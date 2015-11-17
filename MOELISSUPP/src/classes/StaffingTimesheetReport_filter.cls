/**
* Test methods are in Test_StaffingTimesheet.cls
**/
public without sharing class StaffingTimesheetReport_filter {
	
	private String outputTo_p = null;
	public String outputTo{
		get {
			if (outputTo_p == null) {
				outputTo_p = 'pdf';
			}
			return outputTo_p;
		}
		set {
			outputTo_p = value;
		}
	}
	
	public StaffingTimesheetReport_filter() {
		errMsg = '';
		
		List<Employee_Profile__c> emps = StaffingTimesheetReport_logic.getEmpList(selectedIds);
		
		//If in Emloyee record fields Staffing_Office_Location__c or Staffing_Title__c is empty
		//then display message "Insufficient privileges"
		if (currEmployee == null) {
			errMsg = 'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.';
		}else
		if (StTitle == '' || StOfficeLocation == '') {
			errMsg = 'Insufficient privileges to view the content of the page.';
		}
		if (currEmployee[0].Staffing_Title__c == null || currEmployee[0].Staffing_Office_Location__c == null ||
					currEmployee[0].Staffing_Title__c == '' || currEmployee[0].Staffing_Office_Location__c == '') {
			errMsg = 'Insufficient privileges to view the content of the page.';
			system.debug('======== currEmployee[0] ======== >>>> '+currEmployee[0]);
		}
	}
	
	private List<Employee_Profile__c> currEmployee_p = null;
	public List<Employee_Profile__c> currEmployee { //Get record of first Employee of current user (SELECT ... Limit 1)
		get {
			if (currEmployee_p == null) {
				Id userId = UserInfo.getUserId();
				currEmployee_p = StaffingTimesheetReport_logic.getCurrEmployee(userId);
			}
			if (currEmployee_p == null) { // Eliminate a null-value in record
				currEmployee_p = new List<Employee_Profile__c>();
				currEmployee_p.add(new Employee_Profile__c());
			}
			return currEmployee_p;
		}
	}
	
	public String StOfficeLocation { 	// Formatted string contains list of current emploee Staffing Office
		get {							// ...Location value
			String res = '';
			for (Employee_Profile__c item: currEmployee) {
				if (res == '') { 
					res = item.Staffing_Office_Location__c;
				} else {
					res += ';'+item.Staffing_Office_Location__c;
				}
			}
			return res;
		}
	}

	public String StTitle { //      =//= Staffing Title value
		get {
			String res = '';
			for (Employee_Profile__c item: currEmployee) {
				if (res == '') { 
					res = item.Staffing_Title__c;
				} else {
					res += ';'+item.Staffing_Title__c;
				}
			}
			return res;
		}
	}
	
	public String StBusinessType { //      =//= Staffing Title value
		get {
			String res = '';
			for (Employee_Profile__c item: currEmployee) {
				if (res == '') { 
					res = item.Staffing_Business_Type__c;
				} else {
					res += ';'+item.Staffing_Business_Type__c;
				}
			}
			return res;
		}
	}
	
	private List<String> selectedIds_p = null;
	public List<String> selectedIds { // Employees, that selected on previous page in multiselect list
		get {
			String ids = ApexPages.currentPage().getParameters().get('empId');
			List<String> res;
			if (ids != null && ids != '') {
				res = ids.split(';',0);
				selectedIds_p = res;
			}
			if (selectedIds_p == null) selectedIds_p = new List<String>();
			return selectedIds_p;
		}
	}
	
	private Employee_Profile__c filter = new Employee_Profile__c();
	public Employee_Profile__c getFilter() { return filter; }
	public void setFilter(Employee_Profile__c value) { filter = value; }
	
	private Contact fromStartDate = new Contact(); //using field Birthdate
	public Contact getFromStartDate() {return fromStartDate;}
	public void setFromStartDate(Contact value) {fromStartDate = value;} 
	
	private Contact endStartDate = new Contact(); //using field Birthdate
	public Contact getEndStartDate() {return endStartDate;}
	public void setEndStartDate(Contact value) {endStartDate = value;}
	public String errMsg {get;set;}
	
	private Boolean includeInactive_p = null;
	public Boolean includeInactive {
		get {
			if (includeInactive_p == null) {
				includeInactive_p = false;
			}
			return includeInactive_p;
		}
		set {
			includeInactive_p = value;
		}
	}
	
	private Boolean includeAll_p = null;
	public Boolean includeAll {
		get {
			if (includeAll_p == null) {
				includeAll_p = false;
			}
			return includeAll_p;
		}
		set {
			includeAll_p = value;
		}
	}
	
	public String displayBlock {get;set;}
	
	public List<SelectOption> titles { //Get pickList from Employee object
		get {
			Schema.DescribeFieldResult obj = Employee_Profile__c.Title__c.getDescribe(); //Get object describe
			List<Schema.PicklistEntry> vals = obj.getPicklistValues(); //Get PickList values
			List<SelectOption> res = new List<SelectOption>();
			Boolean toAdd;
			if (StTitle != null && StTitle != '') {
				for (Schema.PicklistEntry val: vals) { //Add values to result array
					toAdd = False;
					for (String title: StTitle.split(';',0)) {
						if (title == val.getLabel()) {
							toAdd = True;
						}
					}
					if (toAdd) {
						res.add(new SelectOption(val.getLabel(),val.getValue()));
					}
				}
			} else {
				errMsg = 'Insufficient privileges to view the content of the page.';
			}
			return res;
		}
	}
	private List<String> titlesList_p = null; //Array of selected values in picklist
	public List<String> titlesList {
		get {
			if (titlesList_p == null) {
				titlesList_p = new List<String>(); 
			}
			return titlesList_p;
		}
		set {
			titlesList_p = value;
		}
	}
	private String titlesString { //Transform selected picklist values to String
		get {
			String res = '';
			if (titlesList.size() > 0) {
				for (String val: titlesList) {
					if (res == '') {
						res += val;
					} else {
						res += ';'+val;
					}
				}
			}
			if (res == '') {
				res = StTitle;
			}
			return res;
		}
	}

	public List<SelectOption> offices { //Similarly to titles
		get {
			Schema.DescribeFieldResult obj = Employee_Profile__c.Office_Location__c.getDescribe();
			List<Schema.PicklistEntry> vals = obj.getPicklistValues();
			List<SelectOption> res = new List<SelectOption>();
			Boolean toAdd;
			if (StOfficeLocation != null && StOfficeLocation != '') {
				for (Schema.PicklistEntry val: vals) { //Add values to result array
					toAdd = False;
					for (String office: StOfficeLocation.split(';',0)) {
						if (office == val.getLabel()) {
							toAdd = True;
						}
					}
					if (toAdd) {
						res.add(new SelectOption(val.getLabel(),val.getValue()));
					}
				}
			} else {
				errMsg = 'Insufficient privileges to view the content of the page.';
			}
			return res;
		}
	}
	private List<String> officesList_p = null; //Similarly to titles
	public List<String> officesList {
		get {
			if (officesList_p == null) {
				officesList_p = new List<String>(); 
			}
			return officesList_p;
		}
		set {
			officesList_p = value;
		}
	}
	public String officesString { //Similarly to titles
		get {
			String res = '';
			if (officesList.size() > 0) {
				for (String val: officesList) {
					if (res == '') {
						res += val;
					} else {
						res += ';'+val;
					}
				}
			}
			if (res == '') {
				res = StOfficeLocation;
			}
			return res;
		}
	}

	public List<SelectOption> businessTypes { //Similarly to titles
		get {
			Schema.DescribeFieldResult obj = Employee_Profile__c.Staffing_Business_Type__c.getDescribe();
			List<Schema.PicklistEntry> vals = obj.getPicklistValues();
			List<SelectOption> res = new List<SelectOption>();
			Boolean toAdd;
			if (StBusinessType != null && StBusinessType != '') {
				for (Schema.PicklistEntry val: vals) { //Add values to result array
					toAdd = False;
					for (String bType: StBusinessType.split(';',0)) {
						if (bType == val.getLabel()) {
							toAdd = True;
						}
					}
					if (toAdd) {
						res.add(new SelectOption(val.getLabel(),val.getValue()));
					}
				}
			} else {
				errMsg = 'Insufficient privileges to view the content of the page.';
			}
			return res;
		}
	}
	private List<String> businessTypeList_p = null; //Similarly to titles
	public List<String> businessTypeList {
		get {
			if (businessTypeList_p == null) {
				businessTypeList_p = new List<String>(); 
			}
			return businessTypeList_p;
		}
		set {
			businessTypeList_p = value;
		}
	}
	public String businessTypeString { //Similarly to titles
		get {
			String res = '';
			if (businessTypeList.size() > 0) {
				for (String val: businessTypeList) {
					if (res == '') {
						res += val;
					} else {
						res += ';'+val;
					}
				}
			}
			if (res == '') {
				for (SelectOption val: businessTypes) {
					if (res == '') {
						res += val.getValue();
					} else {
						res += ';'+val.getValue();
					}
				}
			}
			return res;
		}
	}
	
	public String reportLink {
		get {
			String res = '/apex/StaffingTimesheetReport?';
			res += '&fromStartDate='+fromStartDate.Birthdate;
			res += '&endStartDate='+endStartDate.Birthdate;
			res += '&titles='+this.titlesString;
			res += '&offices='+this.officesString;
			res += '&businessType='+this.businessTypeString;
			res += '&outputTo='+this.outputTo;
			String includeInact = '0';
			if (this.includeInactive) { //Convert Boolean expression to String and put to parameters
				includeInact = '1';
			}
			res += '&includeInactive='+includeInact;
			String inclAll = '0';
			if (this.includeAll) { //Convert Boolean expression to String and put to parameters
				inclAll = '1';
			}
			res += '&includeAll='+inclAll;
			
			return res;
		}
	}
	
	private PageReference showReport(String reportType) { //Going to report page & transfer parameters
		PageReference pg = new PageReference('/apex/StaffingTimesheetReport');
		pg.getParameters().put('reportType',reportType);
		pg.getParameters().put('fromStartDate',fromStartDate.Birthdate+'');
		
		pg.getParameters().put('endStartDate',endStartDate.Birthdate+'');
		pg.getParameters().put('titles',this.titlesString);
		pg.getParameters().put('offices',this.officesString);
		pg.getParameters().put('businessType',this.businessTypeString);

		pg.getParameters().put('outputTo',this.outputTo);

		String includeInact = '0';
		if (this.includeInactive) { //Convert Boolean expression to String and put to parameters
			includeInact = '1';
		}
		pg.getParameters().put('includeInactive',includeInact);

		String inclAll = '0';
		if (this.includeAll) { //Convert Boolean expression to String and put to parameters
			inclAll = '1';
		}
		pg.getParameters().put('includeAll',inclAll);

		pg.setRedirect(true);
		return pg;
	}
	public PageReference showSummaryReport() {
		PageReference pg = showReport('summary');
		return pg;
	} 
	public PageReference showDetailReport() {
		PageReference pg = showReport('detail');
		return pg;
	} 
}