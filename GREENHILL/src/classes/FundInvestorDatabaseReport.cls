public with sharing class FundInvestorDatabaseReport {

	public RECA_Fund__c curFundObj     {get;set;}
	public List<MySection> sectionList {get;set;}
	public String renderMode           {get;set;}
	
	public FundInvestorDatabaseReport() {
		String curFundId = ApexPages.currentPage().getParameters().get('fundId');
		renderMode = ApexPages.currentPage().getParameters().get('renderMode');
		if (curFundId != null && curFundId != '') {
			for(RECA_Fund__c item : [SELECT Id, Name, Native_Currency__c FROM RECA_Fund__c WHERE Id = :curFundId limit 1]) { curFundObj = item; }
			
			initSections();
		}
	}

	public String getChooserender()
	{
		if(renderMode=='pdf') return 'pdf';
		else return null;
	}
	

    public String getChooserender2()
	{
		if(renderMode=='pdf') return 'application/pdf#FundInvestorDatabaseReport.pdf';
		else if(renderMode=='excel') return 'application/vnd.ms-excel#FundInvestorDatabaseReport.xls';
		else return null;
	}

	
	public String getFontSize() {
		return '70%';
	}
	
	public String getBorderColors() {
		return 'padding:2px; border-top: 0px #c0c0c0 solid; border-right: 1px #c0c0c0 solid; border-bottom: 1px #c0c0c0 solid; ';
	}
	
	public String getDateNow() {
		return DateTime.now().format('MMMM dd, yyyy');
	}
	
	
	public void initSections() {
		sectionList = new List<MySection>();
		
		// CLOSED
		MySection sectionClosed = new MySection();
		sectionClosed.sectionName = 'CLOSED';
		sectionClosed.sectionNameSmall = 'Closed';
		sectionClosed.rows = getRows('Closed');
		countSubtotal(sectionClosed);
		sectionClosed.totalLow  = sectionClosed.subtotalLow;
		sectionClosed.totalHigh = sectionClosed.subtotalHigh;

		// CIRCLED
		MySection sectionCircled = new MySection();
		sectionCircled.sectionName = 'CIRCLED';
		sectionCircled.sectionNameSmall = 'Circled';
		sectionCircled.rows = getRows('Circled');
		countSubtotal(sectionCircled);
		sectionCircled.totalLow  = sectionClosed.totalLow + sectionCircled.subtotalLow;
		sectionCircled.totalHigh = sectionClosed.totalHigh + sectionCircled.subtotalHigh;

		// STRONG INTEREST
		MySection sectionStrongInterest = new MySection();
		sectionStrongInterest.sectionName = 'STRONG INTEREST';
		sectionStrongInterest.sectionNameSmall = 'Strong Interest';
		sectionStrongInterest.rows = getRows('Strong Interest');
		countSubtotal(sectionStrongInterest);
		sectionStrongInterest.totalLow  = sectionCircled.totalLow + sectionStrongInterest.subtotalLow;
		sectionStrongInterest.totalHigh = sectionCircled.totalHigh + sectionStrongInterest.subtotalHigh;

		// INTEREST
		MySection sectionInterest = new MySection();
		sectionInterest.sectionName = 'INTEREST';
		sectionInterest.sectionNameSmall = 'Interest';
		sectionInterest.rows = getRows('Interest');
		countSubtotal(sectionInterest);
		sectionInterest.totalLow  = sectionStrongInterest.totalLow + sectionInterest.subtotalLow;
		sectionInterest.totalHigh = sectionStrongInterest.totalHigh + sectionInterest.subtotalHigh;

		// POTENTIAL INTEREST
		MySection sectionPotentialInterest = new MySection();
		sectionPotentialInterest.sectionName = 'POTENTIAL INTEREST';
		sectionPotentialInterest.sectionNameSmall = 'Potential Interest';
		sectionPotentialInterest.rows = getRows('Potential Interest');
		countSubtotal(sectionPotentialInterest);
		sectionPotentialInterest.totalLow  = sectionInterest.totalLow + sectionPotentialInterest.subtotalLow;
		sectionPotentialInterest.totalHigh = sectionInterest.totalHigh + sectionPotentialInterest.subtotalHigh;

		// UNLIKELY
		MySection sectionUnlikely = new MySection();
		sectionUnlikely.sectionName = 'UNLIKELY';
		sectionUnlikely.sectionNameSmall = 'Unlikely';
		sectionUnlikely.rows = getRows('Unlikely');
		countSubtotal(sectionUnlikely);
		sectionUnlikely.totalLow  = sectionPotentialInterest.totalLow + sectionUnlikely.subtotalLow;
		sectionUnlikely.totalHigh = sectionPotentialInterest.totalHigh + sectionUnlikely.subtotalHigh;

		// DECLINED
		MySection sectionDeclined = new MySection();
		sectionDeclined.sectionName = 'DECLINED';
		sectionDeclined.sectionNameSmall = 'Declined';
		sectionDeclined.rows = getRows('Declined');
		countSubtotal(sectionDeclined);
		sectionDeclined.totalLow  = sectionUnlikely.totalLow + sectionDeclined.subtotalLow;
		sectionDeclined.totalHigh = sectionUnlikely.totalHigh + sectionDeclined.subtotalHigh;
		
		
		sectionList.add(sectionClosed);
		sectionList.add(sectionCircled);
		sectionList.add(sectionStrongInterest);
		sectionList.add(sectionInterest);
		sectionList.add(sectionPotentialInterest);
		sectionList.add(sectionUnlikely);
		sectionList.add(sectionDeclined);
	}
	
	private void countSubtotal(MySection sect) {
		for(MyRow item : sect.rows) {
			if (item.low != null)  sect.subtotalLow  += item.low;
			if (item.high != null) sect.subtotalHigh += item.high;
		}
	}
	
	
	
	
	
	public List<MyRow> getRows(String interestLevel) {
		List<MyRow> rowsList = new List<MyRow>();
		List<RECA_Fund_Interests__c> fundInterestList = [
			SELECT Id, Investor__r.Name, Interest_Level__c, Investor__r.Primary_Coverage__r.Initials__c, Investor__r.Secondary_Coverage__r.Initials__c, Commitment_Size_Low_USD__c, Commitment_Size_High_USD__c, Comments__c
			FROM RECA_Fund_Interests__c 
			WHERE RECA_Fund__c = :curFundObj.Id AND Interest_Level__c = :interestLevel
			ORDER BY Investor__r.Name];
			
		Set<Id> fundInterestsIds = new Set<Id>();
		for (RECA_Fund_Interests__c item : fundInterestList) { fundInterestsIds.add(item.Id); }
		List<Document_History__c> documentHistoryList = [SELECT Id, RECA_Fund_Interest__c, Date_Sent__c, Type__c FROM Document_History__c WHERE RECA_Fund_Interest__c in :fundInterestsIds ORDER BY Date_Sent__c desc];
		
		Map<String, List<Document_History__c>> Map_type_docHist = new Map<String, List<Document_History__c>>();
		for(Document_History__c item : documentHistoryList) {
			if(!Map_type_docHist.containsKey(item.Type__c)) { Map_type_docHist.put(item.Type__c, new List<Document_History__c>()); }
			Map_type_docHist.get(item.Type__c).add(item);
		}
		
		
		Map<Id, List<Event>> map_InvMtg   = get_InvMtgMap(fundInterestsIds);
		Map<Id, List<Event>> map_DDMtg    = get_DDMtgMap(fundInterestsIds);
		Map<Id, List<Event>> map_ICMtg    = get_ICMtgMap(fundInterestsIds);
		Map<Id, List<Event>> map_Comments = get_CommentsMap(fundInterestsIds);
		
		for (RECA_Fund_Interests__c item : fundInterestList) {
			MyRow newRow = new MyRow();
			newRow.investorName      = item.Investor__r.Name;
			newRow.interestLevel     = item.Interest_Level__c;
			newRow.primaryCoverage   = item.Investor__r.Primary_Coverage__r.Initials__c;
			newRow.secondaryCoverage = item.Investor__r.Secondary_Coverage__r.Initials__c;
			newRow.low               = item.Commitment_Size_Low_USD__c;
			newRow.high              = item.Commitment_Size_High_USD__c;
			
			if (Map_type_docHist.containsKey('Flash Report'))
				for(Document_History__c dhItem : Map_type_docHist.get('Flash Report')) 
					if (dhItem.Date_Sent__c != null && dhItem.RECA_Fund_Interest__c == item.Id) /***/ newRow.flashSent.add(dhItem.Date_Sent__c.format()); 
			if (Map_type_docHist.containsKey('Presentation'))
				for(Document_History__c dhItem : Map_type_docHist.get('Presentation')) 
					if (dhItem.Date_Sent__c != null && dhItem.RECA_Fund_Interest__c == item.Id) /***/ newRow.presentationSent.add(dhItem.Date_Sent__c.format()); 
			if (Map_type_docHist.containsKey('PPM'))
				for(Document_History__c dhItem : Map_type_docHist.get('PPM')) 
					if (dhItem.Date_Sent__c != null && dhItem.RECA_Fund_Interest__c == item.Id) /***/ newRow.PPMsent.add(dhItem.Date_Sent__c.format()); 
			if (Map_type_docHist.containsKey('DDQ'))
				for(Document_History__c dhItem : Map_type_docHist.get('DDQ')) 
					if (dhItem.Date_Sent__c != null && dhItem.RECA_Fund_Interest__c == item.Id) /***/ newRow.DDQsent.add(dhItem.Date_Sent__c.format()); 
			if (Map_type_docHist.containsKey('LPA'))
				for(Document_History__c dhItem : Map_type_docHist.get('LPA')) 
					if (dhItem.Date_Sent__c != null && dhItem.RECA_Fund_Interest__c == item.Id) /***/ newRow.LPAsent.add(dhItem.Date_Sent__c.format());
					
			if (map_InvMtg.containsKey(item.Id))
				for(Event aItem : map_InvMtg.get(item.Id)) 
					newRow.invMtgDate.add(aItem.ActivityDate.format());

			if (map_DDMtg.containsKey(item.Id))
				for(Event aItem : map_DDMtg.get(item.Id)) 
					newRow.DDMeetingDate.add(aItem.ActivityDate.format());
			
			/*
			if (map_Comments.containsKey(item.Id)) {
				Integer count = 0;
				for(Event aItem : map_Comments.get(item.Id)) {
					if (aItem.Description != null && aItem.Description != '') 
						newRow.comments.add(aItem.ActivityDate.format() + ': ' + aItem.Description);
					count++;
					if (count >= 3) break;
				}
			}
			*/
			newRow.comments = item.Comments__c;
			
			rowsList.add(newRow);
		}
		return rowsList;
	}
	
	private Map<Id, List<Event>> get_InvMtgMap(Set<Id> fundInterestsIds) { // BY EVENTS
		Map<Id, List<Event>> resultMap = new Map<Id, List<Event>>();
		List<RECA_Fund_Interests__c> eventList = [Select ID, (SELECT ActivityDate, Type, LastModifiedDate, Subject, Description, WhatId 
																FROM Events where Type='Investor Meeting' ORDER BY ActivityDate desc limit 3)
				From RECA_Fund_Interests__c Where ID in :fundInterestsIds ALL ROWS]; 
		
		for (RECA_Fund_Interests__c itemPre: eventList) {
			for (Event item: itemPre.Events) {
				if(!resultMap.containsKey(item.WhatId)) resultMap.put(item.WhatId, new List<Event>());
				resultMap.get(item.WhatId).add(item);
			}
		}
		return resultMap;
	}

	private Map<Id, List<Event>> get_DDMtgMap(Set<Id> fundInterestsIds) { // BY EVENTS
		
		Map<Id, List<Event>> resultMap = new Map<Id, List<Event>>();
		List<RECA_Fund_Interests__c> eventList = [Select ID, (SELECT ActivityDate, Type, LastModifiedDate, Subject, Description, WhatId 
																FROM Events where Type='Due Diligence Meeting' ORDER BY ActivityDate desc limit 3)
				From RECA_Fund_Interests__c Where ID in :fundInterestsIds ALL ROWS]; 
		
		for (RECA_Fund_Interests__c itemPre: eventList) {
			for (Event item: itemPre.Events) {
				if(!resultMap.containsKey(item.WhatId)) resultMap.put(item.WhatId, new List<Event>());
				resultMap.get(item.WhatId).add(item);
			}
		}		
		return resultMap;
	}

	private Map<Id, List<Event>> get_ICMtgMap(Set<Id> fundInterestsIds) { // BY EVENTS

		Map<Id, List<Event>> resultMap = new Map<Id, List<Event>>();
		List<RECA_Fund_Interests__c> eventList = [Select ID, (SELECT ActivityDate, Type, LastModifiedDate, Subject, Description, WhatId 
																FROM Events where Type='IC Meeting' ORDER BY ActivityDate desc limit 3)
				From RECA_Fund_Interests__c Where ID in :fundInterestsIds ALL ROWS]; 
		
		for (RECA_Fund_Interests__c itemPre: eventList) {
			for (Event item: itemPre.Events) {
				if(!resultMap.containsKey(item.WhatId)) resultMap.put(item.WhatId, new List<Event>());
				resultMap.get(item.WhatId).add(item);
			}
		}	
		return resultMap;
	}

	private Map<Id, List<Event>> get_CommentsMap(Set<Id> fundInterestsIds) { // BY EVENTS

		Map<Id, List<Event>> resultMap = new Map<Id, List<Event>>();
		List<RECA_Fund_Interests__c> eventList = [Select ID, (SELECT ActivityDate, Type, LastModifiedDate, Subject, Description, WhatId 
																FROM Events ORDER BY ActivityDate desc limit 3)
				From RECA_Fund_Interests__c Where ID in :fundInterestsIds ALL ROWS]; 
		
		for (RECA_Fund_Interests__c itemPre: eventList) {
			for (Event item: itemPre.Events) {
				if(!resultMap.containsKey(item.WhatId)) resultMap.put(item.WhatId, new List<Event>());
				resultMap.get(item.WhatId).add(item);
			}
		}	
		return resultMap;
	}


	
	public class MySection {
		public String sectionName      {get;set;}
		public String sectionNameSmall {get;set;}
		public List<MyRow> rows        {get;set;}
		
		public Double subtotalLow      {get;set;}
		public Double subtotalHigh     {get;set;}
		public Double totalLow         {get;set;}
		public Double totalHigh        {get;set;}
		
		public MySection() {
			rows = new List<MyRow>();
			subtotalLow  = 0;
			subtotalHigh = 0;
			totalLow     = 0;
			totalHigh    = 0;
		}
	}
	
	public class MyRow {
		public String investorName           {get;set;}
		public String interestLevel          {get;set;}
		public String primaryCoverage        {get;set;}
		public String secondaryCoverage      {get;set;}
		public Double low                    {get;set;}
		public Double high                   {get;set;}
		public List<String> flashSent        {get;set;}
		public List<String> PPMsent          {get;set;}
		public List<String> presentationSent {get;set;} 
		public List<String> DDQsent          {get;set;}
		public List<String> LPAsent          {get;set;}
		public List<String> invMtgDate       {get;set;}
		public List<String> DDMeetingDate    {get;set;}
		public List<String> ICMeetingDate    {get;set;}
		//public List<String> comments         {get;set;}
		public String comments               {get;set;}

		public MyRow() {
			investorName      = '';
			interestLevel     = '';
			primaryCoverage   = '';
			secondaryCoverage = '';
			low               = 0;
			high              = 0;
			flashSent         = new List<String>();
			PPMsent           = new List<String>();
			presentationSent  = new List<String>();
			DDQsent           = new List<String>();
			LPAsent           = new List<String>();
			invMtgDate        = new List<String>();
			DDMeetingDate     = new List<String>();
			ICMeetingDate     = new List<String>();
			comments          = ''; // new List<String>();
		}
	}
	
	public static testMethod void testThis() {
		RECA_Fund__c testFund = new RECA_Fund__c(name='testFund');
		insert testFund;
		
		Account testAccount = new Account(name='testAccount');
		insert testAccount;
		
		RECA_Fund_Interests__c testFI = new RECA_Fund_Interests__c(RECA_Fund__c=testFund.Id, Interest_Level__c='CLOSED', Investor__c=testAccount.Id);
		insert testFI;
		
		ApexPages.currentPage().getParameters().put('renderMode', 'pdf');
		ApexPages.currentPage().getParameters().put('fundId', testFund.Id);
		
		FundInvestorDatabaseReport con = new FundInvestorDatabaseReport();
		con.getChooserender();
		con.getChooserender2();
		con.getFontSize();
		con.getBorderColors();
		con.getDateNow();
		//con.getRows();
	}
}