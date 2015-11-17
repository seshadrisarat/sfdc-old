public class ByBankerInterestReport {

	public String minDateStr     {get;set;}
	public String maxDateStr     {get;set;}

	public Date minDatetime      {get;set;}
	public Date maxDatetime      {get;set;} 


	public List<String> selectedUserList;
	public List<MySection> sectionList {get;set;}
	
	public ByBankerInterestReport() {
		String selUsers = ApexPages.currentPage().getParameters().get('selUsers');
		this.minDateStr  = System.currentPageReference().getParameters().get('mint');
		this.maxDateStr  = System.currentPageReference().getParameters().get('maxt');
		this.minDatetime = getDateMin(minDateStr);
		this.maxDatetime = getDateMax(maxDateStr);

		if (selUsers!= null && selUsers!='') {
			selectedUserList = selUsers.split(':');
			
			List<RECA_Fund_Interests__c> fundInterestList = [
				SELECT Id, RECA_Fund__r.Name, Investor__r.Name, Interest_Level__c, Investor__r.Primary_Coverage__r.Initials__c, 
						Commitment_Size_Low_USD__c, Commitment_Size_High_USD__c 
				FROM RECA_Fund_Interests__c 
				WHERE Investor__r.Primary_Coverage__c in :selectedUserList AND RECA_Fund__r.Status__c = 'Active' ORDER BY Interest_Level__c, Investor__r.Primary_Coverage__r.Initials__c, Investor__r.Name];
			
			initSections(fundInterestList);
		}
		
	}

	public Date getDateMin(String str) {
		if(str==null || str.length()<10) return null;
		String month = str.substring(0,2);		system.debug('month=' + month);
		String day   = str.substring(3,5);		system.debug('day  =' + day);
		String year  = str.substring(6);		system.debug('year =' + year);
		return date.valueOf(year + '-' + month + '-' + day);// + ' 00:00:00');
	}
	public Date getDateMax(String str) {
		if(str==null || str.length()<10) return null;
		String month = str.substring(0,2);		system.debug('month=' + month);
		String day   = str.substring(3,5);		system.debug('day  =' + day);
		String year  = str.substring(6);		system.debug('year =' + year);
		return date.valueOf(year + '-' + month + '-' + day);// + ' 23:59:59');
	}

	public String getFontSize() {
		return '70%';
	}

	public String getBorderColors() {
		return 'padding:2px; border-top: 0px #c0c0c0 solid;border-right: 1px #c0c0c0 solid; border-bottom: 1px #c0c0c0 solid; ';
	}

	public String getDateNow() {
		return DateTime.now().format('MMMM dd, yyyy');
	}
	
	public void initSections(List<RECA_Fund_Interests__c> fundInterestList) {
		sectionList = new List<MySection>();
		
		System.Debug('fundInterestList_________'+fundInterestList);
		
		Set<Id> fundInterestsIds = new Set<Id>();
		for(RECA_Fund_Interests__c item : fundInterestList) { fundInterestsIds.add(item.Id); }

		Map<Id, List<Event>> map_InvMtg   = get_InvMtgMap(fundInterestsIds);
		Map<Id, List<Event>> map_DDMtg    = get_DDMtgMap(fundInterestsIds);
		Map<Id, List<Event>> map_Comments = get_CommentsMap(fundInterestsIds);
		
		Map<String, List<RECA_Fund_Interests__c>> map_initials_fiList = new Map<String, List<RECA_Fund_Interests__c>>();
		for(RECA_Fund_Interests__c item : fundInterestList) {
			if(!map_initials_fiList.containsKey(item.Investor__r.Primary_Coverage__r.Initials__c))
				map_initials_fiList.put(item.Investor__r.Primary_Coverage__r.Initials__c, new List<RECA_Fund_Interests__c>());
			map_initials_fiList.get(item.Investor__r.Primary_Coverage__r.Initials__c).add(item);
		}
		
		
		// Sorting by InterestLevel
		for(String sectionItem : map_initials_fiList.keySet()) {
			List<RECA_Fund_Interests__c> curList = map_initials_fiList.get(sectionItem);
			
			Map<String, List<RECA_Fund_Interests__c>> map_interest_fiList = new Map<String, List<RECA_Fund_Interests__c>>();
			for(String interestItem : new String[] {'Closed', 'Circled', 'Strong Interest', 'Interest', 'Potential Interest', 'Unlikely', 'Declined'}) {
				map_interest_fiList.put(interestItem, new List<RECA_Fund_Interests__c>()); 
				for(integer i = 0; i < curList.size(); i++) {
					if(curList[i].Interest_Level__c == interestItem) {
						map_interest_fiList.get(interestItem).add(curList[i]);
					}
				}
				
			}

			List<RECA_Fund_Interests__c> newList = new List<RECA_Fund_Interests__c>();
			newList.addAll(map_interest_fiList.get('Closed'));
			newList.addAll(map_interest_fiList.get('Circled'));
			newList.addAll(map_interest_fiList.get('Strong Interest'));
			newList.addAll(map_interest_fiList.get('Interest'));
			newList.addAll(map_interest_fiList.get('Potential Interest'));
			newList.addAll(map_interest_fiList.get('Unlikely'));
			newList.addAll(map_interest_fiList.get('Declined'));

			map_initials_fiList.put(sectionItem, newList);
		}
		
		
		
		Map<String, MySection> map_initials_section = new Map<String, MySection>();
		for(String sectionItem : map_initials_fiList.keySet()) {
			MySection newSection = new MySection();
			newSection.sectionName = sectionItem;
			for(RECA_Fund_Interests__c item : map_initials_fiList.get(sectionItem)) {
				MyRow newRow = new MyRow();
				newRow.investorName = item.Investor__r.Name;
				newRow.status = item.Interest_Level__c;
				newRow.fundName = item.RECA_Fund__r.Name;
				newRow.low = item.Commitment_Size_Low_USD__c;
				newRow.high = item.Commitment_Size_High_USD__c;


				if (map_InvMtg.containsKey(item.Id))
					for(Event aItem : map_InvMtg.get(item.Id)) { 
						newRow.invMtgDate.add(aItem.ActivityDate.format());
						if(newRow.invMtgDate.size() >= 3) break;
					}
				if (map_DDMtg.containsKey(item.Id))
					for(Event aItem : map_DDMtg.get(item.Id)) { 
						newRow.DDMeetingDate.add(aItem.ActivityDate.format());
						if(newRow.DDMeetingDate.size() >= 3) break;
					}
				if (map_Comments.containsKey(item.Id))
					for(Event aItem : map_Comments.get(item.Id)) {
						if (aItem.Description != null && aItem.Description != '') 
							newRow.comments.add(aItem.ActivityDate.format() + ': ' + aItem.Description);
						if(newRow.comments.size() >= 3) break;
					}
				
				
				newSection.rows.add(newRow);
				
			}
			map_initials_section.put(sectionItem, newSection);
		}
		
		
		
		List<String> alphSectionList = new List<String>();
		for(String sectionItem : map_initials_section.keySet())
			alphSectionList.add(sectionItem);
		alphSectionList.sort();
		for(String sectionItem : alphSectionList)
			sectionList.add(map_initials_section.get(sectionItem));
			
			
		System.Debug('sectionList_________'+sectionList);
	}

	public Map<Id, List<Event>> get_InvMtgMap(Set<Id> fundInterestsIds) { // BY EVENTS
		Map<Id, List<Event>> resultMap = new Map<Id, List<Event>>();
		List<Event> eventList = [SELECT ActivityDate, Type, LastModifiedDate, Subject, Description, WhatId 
									FROM Event 
									WHERE Type='Investor Meeting' and WhatId in :fundInterestsIds AND ActivityDate >= :minDatetime and ActivityDate <= :maxDatetime
									ORDER BY ActivityDate desc]; 
		for (Event item: eventList) {
			if(!resultMap.containsKey(item.WhatId)) resultMap.put(item.WhatId, new List<Event>());
			resultMap.get(item.WhatId).add(item);
		}
		return resultMap;
	}
	public Map<Id, List<Event>> get_DDMtgMap(Set<Id> fundInterestsIds) { // BY EVENTS
		Map<Id, List<Event>> resultMap = new Map<Id, List<Event>>();
		List<Event> eventList = [SELECT ActivityDate, Type, LastModifiedDate, Subject, Description, WhatId 
									FROM Event 
									WHERE Type='Due Diligence Meeting' and WhatId in :fundInterestsIds AND ActivityDate >= :minDatetime and ActivityDate <= :maxDatetime
									ORDER BY ActivityDate desc]; 
		for (Event item: eventList) {
			if(!resultMap.containsKey(item.WhatId)) resultMap.put(item.WhatId, new List<Event>());
			resultMap.get(item.WhatId).add(item);
		}
		return resultMap;
	}
	public Map<Id, List<Event>> get_CommentsMap(Set<Id> fundInterestsIds) { // BY EVENTS
		Map<Id, List<Event>> resultMap = new Map<Id, List<Event>>();
		List<Event> eventList = [SELECT ActivityDate, Type, LastModifiedDate, Subject, Description, WhatId 
									FROM Event 
									WHERE WhatId in :fundInterestsIds AND ActivityDate >= :minDatetime and ActivityDate <= :maxDatetime
									ORDER BY ActivityDate desc]; 
		for (Event item: eventList) {
			if(!resultMap.containsKey(item.WhatId)) resultMap.put(item.WhatId, new List<Event>());
			resultMap.get(item.WhatId).add(item);
		}
		return resultMap;
	}


	public List<MyRow> getRows(String interestLevel) {
		List<MyRow> rowsList = new List<MyRow>();
		
		return rowsList;
	}

	public class MySection {
		public String sectionName {get;set;}
		public List<MyRow> rows   {get;set;}
		
		public MySection() {
			sectionName = '';
			rows        = new List<MyRow>();
		}
		public Double getTotalLow() {
			double result = 0;
			for(MyRow item : rows) { 
				if (item != null && item.Low != null)
					result += item.Low; 
			}
			return result;
		}
		public Double getTotalHigh() {
			double result = 0;
			for(MyRow item : rows) {
				if (item != null && item.High != null) 
					result += item.High; 
			}
			return result;
		}
		
	}


	public class MyRow {
		public String investorName           {get;set;}
		public String status                 {get;set;}
		public String fundName               {get;set;}
		public Double low                    {get;set;}
		public Double high                   {get;set;}
		public List<String> invMtgDate       {get;set;}
		public List<String> DDMeetingDate    {get;set;}
		public List<String> comments         {get;set;}

		public MyRow() {
			investorName      = '';
			status            = '';
			fundName          = '';
			low               = 0;
			high              = 0;
			invMtgDate        = new List<String>();
			DDMeetingDate     = new List<String>();
			comments          = new List<String>();
		}
	}
	
	
	public static String PreparingDate(Date dateParam) {
		String month = '' + dateParam.month();
		if (month.length() == 1) month = '0' + month;
		String day   = '' + dateParam.day();
		if (day.length()   == 1) day   = '0' + day;
		return month + '/' + day + '/' + dateParam.year();
	}
	
	
	public static testMethod void testThis() {
		Profile newProfile = [select Id,Name from Profile where Name like '%RECA%' limit 1]; 

		// for User record you maybe need to change username and email
		User testUser = new User(Username='test54325@test.com', LastName='testLast', Email='test54325@test.com', Alias='EuKr', CommunityNickname='EuKr', TimeZoneSidKey='Pacific/Fiji', LocaleSidKey='ar', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=newProfile.Id); 
		insert testUser;
		
		RECA_Fund__c testFund = new RECA_Fund__c(name='testFund');
		insert testFund;
		
		Account testAccount = new Account(name='testAccount');
		testAccount.Primary_Coverage__c = testUser.Id;
		insert testAccount;
		
		RECA_Fund_Interests__c testFI = new RECA_Fund_Interests__c(RECA_Fund__c=testFund.Id, Interest_Level__c='CLOSED', Investor__c=testAccount.Id);
		insert testFI;
		
		Date minDateOpp = date.today().addDays(-14);
		Date maxDateOpp = date.today();

		List<RECA_Fund_Interests__c> fundInterestList = new List<RECA_Fund_Interests__c>();
		fundInterestList.add(testFI);
		
		ApexPages.currentPage().getParameters().put('selUsers', testUser.Id);
		ApexPages.currentPage().getParameters().put('mint', PreparingDate(minDateOpp));
		ApexPages.currentPage().getParameters().put('maxt', PreparingDate(maxDateOpp));
		
		ByBankerInterestReport con = new ByBankerInterestReport();
		
		Date dTest = con.getDateMin(null);
		dTest = con.getDateMax(null);
		
		String strTest = con.getFontSize();
		strTest = con.getBorderColors();
		strTest = con.getDateNow();
		con.initSections(fundInterestList);
		con.getRows(null);
		ByBankerInterestReport.MyRow MyRowObj1 = new ByBankerInterestReport.MyRow();
		ByBankerInterestReport.MyRow MyRowObj2 = new ByBankerInterestReport.MyRow();
		List<ByBankerInterestReport.MyRow> testList = new List<ByBankerInterestReport.MyRow>();
		testList.add(MyRowObj1);
		testList.add(MyRowObj2);
		
		ByBankerInterestReport.MySection SubCon = new ByBankerInterestReport.MySection();
		SubCon.rows = testList;
		SubCon.getTotalLow();
		SubCon.getTotalHigh();
	}
}