public class ByBankerInterestReport_Selection {

	public Boolean selectionMode {get;set;} 
	public Opportunity minDateOpp {get;set;}
	public Opportunity maxDateOpp {get;set;}
	public String labelStr {get;set;}



	private List<String> selectedUserList;
//	public List<MySection> sectionList {get;set;}
	
	public ByBankerInterestReport_Selection() {
		selectedUserStr = new String[]{};
		minDateOpp = new Opportunity(CloseDate=date.today().addDays(-14));
		maxDateOpp = new Opportunity(CloseDate=date.today());
	}



	public String[] selectedUserStr {get;set;}
	 
	public List<SelectOption> getUserList() {
		List<SelectOption> resultList = new List<SelectOption>();
		List<User> userList = [SELECT Id, Name, Initials__c FROM User WHERE Initials__c != NULL ORDER BY Initials__c];
		for(User item : userList)
			resultList.add(new SelectOption(item.Id, item.Initials__c + '  ( ' + item.Name + ' )'));
		return resultList;
	}

	private String PreparingDate(Date dateParam) {
		String month = '' + dateParam.month();
		if (month.length() == 1) month = '0' + month;
		String day   = '' + dateParam.day();
		if (day.length()   == 1) day   = '0' + day;
		return month + '/' + day + '/' + dateParam.year();
	}
	
	public Pagereference actionSave() {
		String resStr = '';
		for(String item : selectedUserStr) { resStr += ':' + item; }
		if (resStr.length() > 0) { resStr = resStr.substring(1); } 

		system.debug('resStr===' + resStr);
		return new Pagereference('/apex/ByBankerInterestReport?selUsers=' + resStr + '&mint=' + PreparingDate(minDateOpp.CloseDate) + '&maxt=' + PreparingDate(maxDateOpp.CloseDate));
	}
	
	public static testMethod void testThis() {
		ByBankerInterestReport_Selection con = new ByBankerInterestReport_Selection();
		con.getUserList();
		con.actionSave();
	}

}