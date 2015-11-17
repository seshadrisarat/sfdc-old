/**
*		MyCompaniesDashboardController contains controller method and actions to the MyCompaniesCytdWpDashboardPage and MyCompaniesAppointmentsDashbpardPage VF pages.
*	
*		Author  :   Wilson Ng
*		Date	:	Mar 05, 2013
*  
*		Revision History:
*			Date	Author			Comments
*
*/
public with sharing class MyCompaniesDashboardController {
	
	// private variables
	Id currUserId = UserInfo.getUserId();
	string yearLiteralFilter = 'THIS_YEAR';
	decimal yearEndWpGoal = 0;
	decimal yearlyApptsGoal = 0;
	
	// constructor
	public MyCompaniesDashboardController() {
		
		// check for override url parameters: uid and yearLiteral
		if(ApexPages.currentPage().getParameters().get('uid') != null)
			currUserId = (Id)ApexPages.currentPage().getParameters().get('uid');
		if(ApexPages.currentPage().getParameters().get('yearLiteral') != null)
			yearLiteralFilter = (string)ApexPages.currentPage().getParameters().get('yearLiteral');
			
		//query user record fields: WP_Year_End_Target__c and New_Appointments_Yearly_Goal__c
		User[] users = [select WP_Year_End_Target__c, New_Appointments_Yearly_Goal__c from User where Id=:currUserId];
		if(users.size() > 0) {
			yearEndWpGoal = DashboardUtility.getValue(users[0], 'WP_Year_End_Target__c');
			yearlyApptsGoal = DashboardUtility.getValue(users[0], 'New_Appointments_Yearly_Goal__c');
		}
	}

	//
	// CYTD WP methods
	public string currencyLabel { get { return DashboardUtility.getCurrencyScaleLabel(true); } }
	public list<DashboardUtility.Data> getCytdwpData() {
		decimal cytdWpTotal = 0;
		
		//query all Broker accounts where owner = current owner, sum field is Written_Premium_CYTD_EDW__c
		for(Account[] accounts : [select Written_Premium_CYTD_EDW__c from Account where OwnerId=:currUserId and RecordType.DeveloperName=:DashboardUtility.BROKER_REC_TYPE])
			for(Account acct : accounts)
				cytdWpTotal += DashboardUtility.getValue(acct, 'Written_Premium_CYTD_EDW__c');

		list<DashboardUtility.Data> cytdwpData = new list<DashboardUtility.Data>();
		// show in M's
		cytdwpData.add(new DashboardUtility.Data('CYTD vs YE Goal', DashboardUtility.getDisplayValue(cytdWpTotal, 1000000, 1), DashboardUtility.getDisplayValue(yearEndWpGoal, 1000000, 1)));
		system.debug('CytdWp Data: ' + cytdwpData);
		return cytdwpData;
	}
	
	
	//
	// # of Appointments method
	private list<DashboardUtility.Data> apptData = null;
	public integer apptMax { 
		get {
			integer max = 0;
			for(DashboardUtility.Data d : getApptData())
				if(d.data1 > max)
					max = Integer.valueOf(d.data1); 
			return Math.max(5, 5 * Math.floor((max+4) / 5)).intValue();		// calculate the left axis top value
		}
	}
	public list<DashboardUtility.Data> getApptData() {
		if(apptData == null) {
			map<integer, decimal> ytdMap = DashboardUtility.constructEmptyYTDMap();
			
			//query accounts where owner = current user and Appt Date = THIS_YEAR, roll-up field is Date_of_Appointment__c
			string query = 'select Date_of_Appointment__c from Account where OwnerId=:currUserId and Date_of_Appointment__c=' + yearLiteralFilter;
			for(Account[] accounts : database.query(query))
				for(Account acct : accounts) {
					decimal cnt = ytdMap.get(acct.Date_of_Appointment__c.month());
					ytdMap.put(acct.Date_of_Appointment__c.month(), ++cnt);
				}
				
			apptData = DashboardUtility.convertToDataList(ytdMap);
			
			// calculate monthly cummulative total and populate the yearly appts goal value
			decimal cummTotal = 0;
			for(DashboardUtility.Data d : apptData) {
				decimal tmp = d.data1;
				d.data1 += cummTotal;
				cummTotal += tmp;
				d.data2 = yearlyApptsGoal;
			}
		}
		system.debug('Appt Data: ' + apptData);
		return apptData;
	}
	
	
	// test methods
	@isTest
	static void testThisController_cytdwp() {
		// create dummy accounts
		list<Account> acctList = new list<Account>();
		for(integer i=0; i<10; i++)
			acctList.add(new Account(Name='test account'+i, Written_Premium_CYTD_EDW__c=i, RecordType=new Recordtype(Name=DashboardUtility.BROKER_REC_TYPE.replaceAll('_', ' '))));
		insert acctList;
		
		Test.startTest();
		
		PageReference pageRef = Page.MyCompaniesCytdWpDashboardPage;
		Test.setCurrentPageReference(pageRef);		
		MyCompaniesDashboardController controller = new MyCompaniesDashboardController();

		string teststr = controller.currencyLabel;
		
		list<DashboardUtility.Data> testdata = controller.getCytdwpData();
		
		Test.stopTest();
	}
	
	
	@isTest
	static void testThisController_appointments() {
		// create dummy accounts
		list<Account> acctList = new list<Account>();
		for(integer i=0; i<60; i++) {
			Date newdate = system.today() + Math.round(Math.random() * 365);		// create random dates
			acctList.add(new Account(Name='test account'+i, Date_of_Appointment__c=newdate, RecordType=new Recordtype(Name=DashboardUtility.BROKER_REC_TYPE.replaceAll('_', ' '))));
		}
		insert acctList;
		
		Test.startTest();
		
		PageReference pageRef = Page.MyCompaniesAppointmentsDashboardPage;
		Test.setCurrentPageReference(pageRef);		
		MyCompaniesDashboardController controller = new MyCompaniesDashboardController();

		list<DashboardUtility.Data> testdata = controller.getApptData();
		integer testint = controller.apptMax;
		
		Test.stopTest();
	}
}