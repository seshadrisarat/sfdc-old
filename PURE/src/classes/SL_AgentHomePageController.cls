/*  
*  ClassName  	  : SL_AgentHomePageController
*  CreatedOn      : 12/5/2014
*  ModifiedBy     : Kyle Lawson
*/

global without sharing class SL_AgentHomePageController {   
	
	public List<RecentlyViewedAccountWrapper> lstRecentMembers {get;set;}
	public List<MemberWrapper> lstMembersSearched			   {get;set;}
	public List<ClaimsWrapper> lstMemberClaims				   {get;set;}
	public List<PastDueWrapper> lstMembersWithPastDueBalances  {get;set;}

	public String lastNameLogic  {get;set;}
	public String stateLogic 	 {get;set;}
	public String zipCodeLogic 	 {get;set;}
	public String policyLogic	 {get;set;}

	public String firstNameSearch {get;set;}  
	public String lastNameSearch  {get;set;}
	public String citySearch  	  {get;set;}
	public String stateSearch  	  {get;set;}
	public String zipCodeSearch   {get;set;}
	public String memberIdSearch  {get;set;}
	public String policySearch    {get;set;}
	
	// Added as per PURE-65
	public String strSortColumn    {get;set;}   // Used for storing the column name on which header is clicked for sorting
	public String strSortTable    {get;set;}    // Used to know the table name on which column header is clicked for sorting
  
	// Added as per PURE-65 for sorting functionality for all the sections in BrokerHomePage
	public String strSearchResTable {get;set;}
	public String strSearchSortColumn {get;set;}
	public String strSearchSortDir {get;set;}
	
	public String strRecentlyViewedTable {get;set;}
	public String strRecentlyViewedSortColumn {get;set;}
	public String strRecentlyViewedSortDir {get;set;}
	
	public String strMemPastDueTable {get;set;}
	public String strMemPastDueSortColumn {get;set;}
	public String strMemPastDueSortDir {get;set;}
	
	public String strMemClaimActTable {get;set;}
	public String strMemClaimActSortColumn {get;set;}
	public String strMemClaimActSortDir {get;set;}

	public Integer numMembersReturned {get;set;}

	// Footer variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	public String pureInsurancelink			{get;set;}
	public String privacyPolicyLink			{get;set;}
	public String fAQlink					{get;set;}
	public String shareYourStorylink		{get;set;}
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	@TestVisible  private String strUserId  	  {get;set;}
	@TestVisible  private String strContactId   {get;set;}

	public String moreParamName {get;set;}
	@TestVisible private Boolean moreMembers {get;set;}
	@TestVisible private Boolean moreMemBalances {get;set;}
	@TestVisible private Boolean moreClaims {get;set;}

	@TestVisible private Set<Id> accessibleMemberIds {get;set;}

	public Boolean isError 					{get;set;}
	
	// Added as per PURE-65 for sorting column headers
	
	public SL_AgentHomePageController()
	{
		/** TAKEN FROM FOOTER COMPONENT - SHOULD REFACTOR INTO EXTENSION OR GLOBAL CLASS **/
		pureInsurancelink = privacyPolicyLink = fAQlink = shareYourStorylink = '';
		
		PortalURLMap__c oFAQ = new PortalURLMap__c();
		PortalURLMap__c oPureinsurance = new PortalURLMap__c();
		PortalURLMap__c oPrivacyPolicy = new PortalURLMap__c();
		PortalURLMap__c oShareYourStory = new PortalURLMap__c();
		
		oFAQ = PortalURLMap__c.getInstance('FAQ');
		oPureinsurance = PortalURLMap__c.getInstance('pureInsurance.com');
		oPrivacyPolicy = PortalURLMap__c.getInstance('PrivacyPolicy');
		oShareYourStory = PortalURLMap__c.getInstance('ShareYourStory');

		fAQlink = (oFAQ != null) ? oFAQ.URL__c : '#';
		pureInsurancelink = (oPureinsurance != null) ? oPureinsurance.URL__c : '#';
		privacyPolicyLink = (oPrivacyPolicy != null) ? oPrivacyPolicy.URL__c : '#';
		shareYourStorylink = (oShareYourStory != null) ? oShareYourStory.URL__c : '#';
		/** ******************************************************************** **/

		// Current user's ID
		strUserId = Userinfo.getUserId();

		lstRecentMembers = new List<RecentlyViewedAccountWrapper>();
		lstMembersSearched = new List<MemberWrapper>();
		lstMemberClaims = new List<ClaimsWrapper>();
		lstMembersWithPastDueBalances = new List<PastDueWrapper>();
		accessibleMemberIds = new Set<Id>();
		
		// Client wants logic options defaulted to AND
		lastNameLogic = 'AND';
		stateLogic = 'AND';
		zipCodeLogic = 'AND';
		policyLogic = 'AND';

		// Search box variables
		firstNameSearch = '';
		lastNameSearch = '';
		citySearch = '';
		stateSearch = '--Select--';
		zipCodeSearch = '';
		memberIdSearch = '';
		policySearch = '';
		strSortTable = '';

		moreParamName = '';

		moreMembers = false;
		moreClaims = false;
		moreMemBalances = false;
		
		getUrlParametersForSorting();// Method called to get Url Parameters for sorting functionality of all the sections
		
		numMembersReturned = -1; // If a search is performed, this will be >= 0
		
		// Created for forming dynamic query
		String strAccountQuery = '';

		// Arrive at page from the Broker Portal View - Home link on a broker contact record
		if(ApexPages.currentPage().getParameters().containsKey('bid')){
			strContactId = ApexPages.currentPage().getParameters().get('bid');
		} else {
			//Get the current User's Contact ID
			List<User> curUser = [SELECT ContactID FROM User WHERE Id = :strUserId];

			if(!curUser.isEmpty())
				strContactId = curUser[0].ContactID;
			else
				System.debug('Error: No current user found');
		}

		// The only members that this user should have access to
		List<Account> accessibleMembers = [SELECT ID 
		 								   FROM Account 
		 								   WHERE Broker__c IN (SELECT Agency__c 
		 					 								  FROM Agency_Contact__c 
										 					  WHERE Contact__c = :strContactId
										 					  AND User_Status__c = 'Active'
										 					  AND (Agency__r.Broker_Status__c = 'Active' 
										 					   OR Agency__r.Broker_Status__c = 'Suspended with Access')) 
										   AND RecordType.Name = 'Member'];

		if(!accessibleMembers.isEmpty())
		{
			// Remove duplicates
			for(Account a : accessibleMembers)
			{
				accessibleMemberIds.add(a.Id);
			}
			
			// Remove duplicates
			Set<Id> recentlyViewedIds = new Set<Id>();	
			Map<Id, RecentlyViewed> mapRecentlyViewed = new Map<Id, RecentlyViewed>();
			
		    // Recently viewed query
			List<RecentlyViewed> lstRecentlyViewed = [SELECT Id, LastViewedDate
												  	 FROM RecentlyViewed
											  		 WHERE Type = 'Account' 
											  		   AND ID IN :accessibleMemberIds
											  		 ORDER BY LastViewedDate DESC 
											  		 LIMIT 5];
			if(!lstRecentlyViewed.isEmpty())
			{
				for(RecentlyViewed rv : lstRecentlyViewed){
					recentlyViewedIds.add(rv.Id);
					mapRecentlyViewed.put(rv.Id, rv);
				}
			}	
			// Added as per PURE-65 to make query dynamic for sorting functionality based on selected column header if there is no column in URL for this table then ordering based on LastViewedDate
			if(String.isEmpty(strRecentlyViewedTable))
			{
				Map<Id, Account> mapUnorderedRecentMembers = new Map<Id, Account>([SELECT Id, Name, Member_Key_EDW__c, 
																							  ShippingCity, ShippingState, 
																							  Broker__r.Broker_Id__c
																					   FROM Account 
																					   WHERE Id IN :recentlyViewedIds 
																						 AND Id IN :accessibleMemberIds
																						 Order by Name DESC ]);
	
				// Wrap each Recently Viewed Account in order to sort them by Last Viewed Date
				for(RecentlyViewed rv : mapRecentlyViewed.values())
				{
					RecentlyViewedAccountWrapper accWrapper = new RecentlyViewedAccountWrapper(mapUnorderedRecentMembers.get(rv.Id), rv.LastViewedDate);
					lstRecentMembers.add(accWrapper);
				}
				// Order each of the recent members based on the recently viewed order
				lstRecentMembers.sort();
			 }	
			// Added as per PURE-65 to make query dynamic for sorting functionality based on selected column header
			else
			{
				strAccountQuery = 'SELECT Id, Name, Member_Key_EDW__c,ShippingCity, ShippingState, Broker__r.Broker_Id__c FROM Account WHERE Id IN :accessibleMemberIds AND ID IN:recentlyViewedIds ';
				
				if( strRecentlyViewedTable == 'RecentlyViewedMembers' && !String.isEmpty(strRecentlyViewedSortColumn))
				{
					strAccountQuery += ' ORDER BY ' + strRecentlyViewedSortColumn + ' ' + strRecentlyViewedSortDir;
				}	
				else
					strAccountQuery += ' ORDER BY Name DESC' ;	
				
				for(Account objAccount : Database.Query(strAccountQuery))
				{
					RecentlyViewedAccountWrapper accWrapper = new RecentlyViewedAccountWrapper(objAccount);
					lstRecentMembers.add(accWrapper);
				}
			}	
		}		
		
		// Updated as per PURE-65 to make query dynamic for Members with Past Due Balances section based on selected column header
	    strAccountQuery = 'SELECT Id, Name, IsOverdue__c, Min_Due__c, Oldest_Past_Due_Date__c FROM Account WHERE Id IN :accessibleMemberIds AND IsOverdue__c > 0';
			
		if( strMemPastDueTable == 'MembersWithPastDueBalances' && !String.isEmpty(strMemPastDueSortColumn))
			strAccountQuery += ' ORDER BY ' + strMemPastDueSortColumn + ' ' + strMemPastDueSortDir;  
		else
			strAccountQuery += ' ORDER BY Min_Due__c DESC' ;
					 
		List<Account> lstMembersWithPastDue = new List<Account>();
		
		// Members with past due balances
		lstMembersWithPastDue = Database.query(strAccountQuery);

		// Put members with past due balances into a wrapper in order to 
		// associate a number with each claim, allowing us to hide and show them
		Integer numMemPastDue = 1;
		for(Account a : lstMembersWithPastDue){
			PastDueWrapper pdw = new PastDueWrapper(a.Id, a.Name, a.Min_Due__c, a.IsOverdue__c, 
				  							a.Oldest_Past_Due_Date__c, numMemPastDue++);
			lstMembersWithPastDueBalances.add(pdw);
		}
			
		List<Claim__c> lstMembersWithClaimActivity = new List<Claim__c>();
		//Date threeMonthsAgo = Date.today() - ((365/12) * 3); // Approximation of 3 months ago
		Date sixtyDaysAgo = Date.today() - 60;
		
		// Updated as per PURE-65 to make query dynamic for sorting functionality based on selected column header
		strAccountQuery = 'SELECT Member__r.Name, RecordType.Name, Claim_Number__c,Total_Paid__c, Loss_Location__c, Date_of_Loss__c,CanShowDetails__c, Member__r.Id FROM Claim__c WHERE Member__r.Id IN :accessibleMemberIds AND ((Claim_Status__c !=' + '\'' + 'Closed' + '\'' + ' AND Claim_Status__c !=' + '\'' + 'In Subrogation' + '\'' + ') OR Portal_Closed_Date__c >= :sixtyDaysAgo)';

		if( strMemClaimActTable == 'MembersWithClaimActivity' && !String.isEmpty(strMemClaimActSortColumn))
			strAccountQuery += ' ORDER BY ' + strMemClaimActSortColumn + ' ' + strMemClaimActSortDir;
		else
			strAccountQuery += ' ORDER BY Date_of_Loss__c DESC';	

		// Members with claim Activity, don't show closed claims that were closed more than 3 months ago
		lstMembersWithClaimActivity =  Database.query(strAccountQuery);
		
		// Put claims into a wrapper in order to associate a number with each claim, 
		// allowing us to hide and show them
		Integer numClaim = 1;
		for(Claim__c c : lstMembersWithClaimActivity){
			ClaimsWrapper cw = new ClaimsWrapper(c.RecordType.Name, c.Claim_Number__c, c.Total_Paid__c, 
												 c.Loss_Location__c, c.Date_of_Loss__c, c.CanShowDetails__c, 
												 c.Member__r.Name, c.Member__r.Id, numClaim++);
			lstMemberClaims.add(cw);
		}	
	}

	/*
        * MethodName        : pageAction
        * param             : None
        * Description       : This function will be called on load of member landing page to query 
        					  all active policies and open claims related to loggedIn user.
    */
	public pageReference pageAction()
	{
		// make guests login first.
		if(Userinfo.getUserType() == 'Guest') return new PageReference('/BrokerLogin');
		system.debug('!!!!!user type/id: '+ Userinfo.getUserType()+'/'+Userinfo.getUserId());
		
		String userAccountId;
		Map<String, String> parameters = ApexPages.currentPage().getParameters();

		System.debug('~~~~~ Parameters: '+parameters);

		if(!parameters.isEmpty() && !parameters.containsKey('all') && !parameters.containsKey('isRegistered')){
			String fn = parameters.get('fn'); // First name
			String lnl = parameters.get('lnl'); // Last name logic
			String ln = parameters.get('ln'); // Last name
			String c = parameters.get('c'); // City
			String zcl = parameters.get('zcl'); // Zip code logic
			String zc = parameters.get('zc'); // Zip code
			String sl = parameters.get('sl'); // State logic
			String s = parameters.get('s'); // State
			String mids = parameters.get('mids'); // Member key edw
			String pl = parameters.get('pl'); // Policy logic
			String p = parameters.get('p'); // Member ID derived from Policy #
			String pnum = parameters.get('pnum'); // Policy #. Used instead of 'p' to fill in search box

			setSearchBoxes(fn, lnl, ln, c, zcl, zc, sl, s, mids, pl, pnum);

			// Condition added for not to display 'Member Search Results' section when column header is clicked for sorting 
			if(!String.isEmpty(fn) || !String.isEmpty(lnl) || !String.isEmpty(ln) || !String.isEmpty(c) || !String.isEmpty(zcl) || !String.isEmpty(zc) || !String.isEmpty(sl) || !String.isEmpty(s) || !String.isEmpty(mids) || !String.isEmpty(pl) || !String.isEmpty(p) || !String.isEmpty(pnum))
			{
				lstMembersSearched = searchFromParameters(accessibleMemberIds, fn, lnl, ln, c, 
															  zcl, zc, sl, s, mids, pl, p);
				numMembersReturned = lstMembersSearched.size();
			}
			
		} else if(parameters.containsKey('all')){
			lstMembersSearched = getMembersFromIds(accessibleMemberIds);
			numMembersReturned = lstMembersSearched.size();
		}

		return null;
	}
	
	// Method used to get Url Parameters for sorting functionality of all the sections
	public void getUrlParametersForSorting()
	{
		// Added as per PURE-65 for handling sorting functionality for all tables
		if(ApexPages.currentPage().getParameters().containsKey('sortSearchResTable'))
			strSearchResTable = ApexPages.currentPage().getParameters().get('sortSearchResTable');
			
		if(ApexPages.currentPage().getParameters().containsKey('sortSearchResColumn'))
			strSearchSortColumn = ApexPages.currentPage().getParameters().get('sortSearchResColumn');
			
		if(ApexPages.currentPage().getParameters().containsKey('searchResColsortorder'))
			strSearchSortDir =  ApexPages.currentPage().getParameters().get('searchResColsortorder');	
			
		if(ApexPages.currentPage().getParameters().containsKey('sortRecViewTable'))
			strRecentlyViewedTable = ApexPages.currentPage().getParameters().get('sortRecviewTable');
			
		if(ApexPages.currentPage().getParameters().containsKey('sortRecViewColumn'))
			strRecentlyViewedSortColumn = ApexPages.currentPage().getParameters().get('sortRecViewColumn');
			
		if(ApexPages.currentPage().getParameters().containsKey('sortRecViewColDir'))
			strRecentlyViewedSortDir =  ApexPages.currentPage().getParameters().get('sortRecViewColDir');	
			
		if(ApexPages.currentPage().getParameters().containsKey('sortPastDueTable'))
			strMemPastDueTable = ApexPages.currentPage().getParameters().get('sortPastDueTable');
			
		if(ApexPages.currentPage().getParameters().containsKey('sortPastDueColumn'))
			strMemPastDueSortColumn = ApexPages.currentPage().getParameters().get('sortPastDueColumn');
			
		if(ApexPages.currentPage().getParameters().containsKey('sortPastDueDir'))
			strMemPastDueSortDir =  ApexPages.currentPage().getParameters().get('sortPastDueDir');	
			
		if(ApexPages.currentPage().getParameters().containsKey('sortClaimActTable'))
			strMemClaimActTable = ApexPages.currentPage().getParameters().get('sortClaimActTable');
			
		if(ApexPages.currentPage().getParameters().containsKey('sortClaimActColumn'))
			strMemClaimActSortColumn = ApexPages.currentPage().getParameters().get('sortClaimActColumn');
			
		if(ApexPages.currentPage().getParameters().containsKey('sortClaimActColumnDir'))
			strMemClaimActSortDir =  ApexPages.currentPage().getParameters().get('sortClaimActColumnDir');		
	}		

	/*
        * MethodName        : searchMembers
        * param             : None
        * Description       : This function will be called when a user clicks the search
        					  button for the Member Search. It constructs a URL to the 
        					  broker home page with parameters set to each of the filled 
        					  in search values or sorting parameters. 
        					  Finally it returns a page reference to that URL.
    */
	public PageReference searchMembers()
	{
		String searchURL = formURlParametersForSearchOrSorting('Search'); // Method called to construct URL parameters     
		PageReference searchPage = new PageReference(searchURL);
		searchPage.setAnchor('MemberSearchResults');
		searchPage.setRedirect(true);
		return searchPage;   
	}
	
	/*
        * MethodName        : sortPageSections
        * param             : None
        * Description       : This function will be called on click of column header to perform sorting for that section;
        					  It constructs a URL to the 
        					  broker home page with parameters set to each of the filled 
        					  in search values or sorting parameters. Finally it returns a page reference to that URL.
    */
	public PageReference sortPageSections()
	{
		String searchURL = formURlParametersForSearchOrSorting('Sort'); // Method called to construct URL parameters
		PageReference searchPage = new PageReference(searchURL);
		searchPage.setAnchor(strSortTable);
		searchPage.setRedirect(true);
		return searchPage;   
	}
	
	/*
        * MethodName        : formURlParametersForSearchOrSorting
        * param             : None
        * Description       : This function is used to construct the UrL Parameters to perform search or sorting.
    */
    
	public String formURlParametersForSearchOrSorting(String strSearchOrSort)
	{
		
		String searchURL = Url.getCurrentRequestUrl().getPath();
		
		if(searchURL.indexOf('?') > -1)
			searchURL += '&';
		else
			searchURL += '?';

		Boolean atLeastOneSearchParam = false;

		// No logic to choose before first name
		if(firstNameSearch != ''){
			atLeastOneSearchParam = true;
			searchURL += 'fn=' + String.escapeSingleQuotes(firstNameSearch);
		}

		if(lastNameSearch != '' && (!atLeastOneSearchParam || lastNameLogic != '---')){
			if(atLeastOneSearchParam)
				searchURL += '&lnl=' + lastNameLogic;
			else
				atLeastOneSearchParam = true;

			searchURL += '&ln=' + String.escapeSingleQuotes(lastNameSearch);
		}

		// No logic to choose before City
		if(citySearch != ''){
			atLeastOneSearchParam = true;

			searchURL += '&c=' + String.escapeSingleQuotes(citySearch);
		}

		if((stateSearch != '' && stateSearch != '--Select--') && (!atLeastOneSearchParam || stateLogic != '---')){
			if(atLeastOneSearchParam)
				searchURL += '&sl=' + stateLogic;
			else
				atLeastOneSearchParam = true;

			searchURL += '&s=' + String.escapeSingleQuotes(stateSearch);
		}

		if(zipCodeSearch != '' && (!atLeastOneSearchParam || zipCodeLogic != '---')){
			if(atLeastOneSearchParam)
				searchURL += '&zcl=' + zipCodeLogic;
			else
				atLeastOneSearchParam = true;

			searchURL += '&zc=' + String.escapeSingleQuotes(zipCodeSearch);
		}

		// No logic to choose before member ID
		if(memberIdSearch != ''){
			
			atLeastOneSearchParam = true;
			searchURL += '&mids=' + String.escapeSingleQuotes(memberIdSearch);
		}

		if(policySearch != '' && (!atLeastOneSearchParam || policyLogic != '---')){

			// If policySearch isn't at least 9 digits long, it is invalid 
			if(policySearch.length() >= 9){

				String policySearch9Digits = policySearch.substring(0, 9);

				List<Policy__c> membersWithPolicy = [SELECT Member__r.Id 
													 FROM Policy__c 
													 WHERE Policy_Number_9_Digits__c = :policySearch9Digits];
				
				if(!membersWithPolicy.isEmpty()){

					if(atLeastOneSearchParam)
						searchURL += '&pl=' + policyLogic;

					searchURL += '&p=';

					for(Policy__c p : membersWithPolicy){
						searchURL += p.Member__r.Id + ',';
					}

					searchURL = searchURL.removeEnd(',');

				// If no members were found, we should include that no members were found
				} else{
					searchURL += '&p=none';
				}

			} else {
				searchURL += '&p=none';  
			}

			searchURL += '&pnum=' + policySearch;
			atLeastOneSearchParam = true; // Set this to be true if we are inside this if block
		}
		
		//If nothing was entered in the search box, show all accessible members
		if(!atLeastOneSearchParam && strSearchOrSort == 'Search')
			searchURL += 'all=true';                                       
		
		if(strSearchOrSort == 'Sort' && ApexPages.currentPage().getParameters().containsKey('all'))
			searchURL += 'all=true';
		
		// Added as per PURE-65 to pass column,tablename,Sortdirection in URL to perform sorting based on selected column header in 'Member Search Results' section
		if(!String.isEmpty(strSearchResTable) && !String.isEmpty(strSearchSortColumn) || (String.isEmpty(strSearchResTable) && strSortTable== 'MemberSearchResults'))
		{
			String strSortOrder;
			
			// Checking if the same column is clicked then swapping sort direction
			if(strSearchSortColumn == strSortColumn && strSortTable == 'MemberSearchResults')
			   strSortOrder = strSearchSortDir == 'DESC' ? 'ASC' : 'DESC';
			else if(!String.isEmpty(strSearchSortDir) && strSortTable != 'MemberSearchResults')
			 	strSortOrder = strSearchSortDir;   
			// Sorting new column by ascending on default
			else
				 strSortOrder = 'ASC';	
			 	
			 if(!String.isEmpty(strSortColumn) && strSortTable == 'MemberSearchResults')	
			 	strSearchSortColumn = strSortColumn;
			 	  
			searchURL += '&sortSearchResTable=MemberSearchResults&sortSearchResColumn=' + String.escapeSingleQuotes(strSearchSortColumn) + '&searchResColsortorder=' + strSortOrder;
		}		
		
		// Added as per PURE-65 to pass column,tablename,Sortdirection in URL to perform sorting based on selected column header in 'Recently Viewed Members' section
		if(!String.isEmpty(strRecentlyViewedTable) && !String.isEmpty(strRecentlyViewedSortColumn) || (String.isEmpty(strRecentlyViewedTable) && strSortTable == 'RecentlyViewedMembers'))
		{
			String strSortOrder;
			
			// Checking if the same column is clicked then swapping sort direction
			if(strRecentlyViewedSortColumn == strSortColumn && strSortTable == 'RecentlyViewedMembers')
			   strSortOrder = strRecentlyViewedSortDir == 'DESC' ? 'ASC' : 'DESC';
			   
			else if(!String.isEmpty(strRecentlyViewedSortDir) && strSortTable != 'RecentlyViewedMembers')
			 	strSortOrder = strRecentlyViewedSortDir;
			// Sorting new column by ascending on default
			else
				 strSortOrder = 'ASC';
			 	
			 if(!String.isEmpty(strSortColumn) && strSortTable == 'RecentlyViewedMembers')	
			 	strRecentlyViewedSortColumn = strSortColumn;	
			 	  
			searchURL += '&sortRecViewTable=RecentlyViewedMembers&sortRecViewColumn=' + String.escapeSingleQuotes(strRecentlyViewedSortColumn) + '&sortRecViewColDir=' + strSortOrder;
		}		
		
		// Added as per PURE-65 to pass column,tablename,Sortdirection in URL to perform sorting based on selected column header in 'Members with Past Due Balances' section
		if(!String.isEmpty(strMemPastDueTable) && !String.isEmpty(strMemPastDueSortColumn) || (String.isEmpty(strMemPastDueTable) && strSortTable == 'MembersWithPastDueBalances'))
		{
			String strSortOrder;

			// Checking if the same column is clicked then swapping sort direction
			if(strMemPastDueSortColumn == strSortColumn && strSortTable == 'MembersWithPastDueBalances')
			   strSortOrder = strMemPastDueSortDir == 'DESC' ? 'ASC' : 'DESC';
			   
			else if(!String.isEmpty(strMemPastDueSortDir) && strSortTable != 'MembersWithPastDueBalances' )
			 	strSortOrder = strMemPastDueSortDir;
			// Sorting new column by ascending on default
			else
				 strSortOrder = 'ASC';
			
			 if(!String.isEmpty(strSortColumn) && strSortTable == 'MembersWithPastDueBalances')	
			 	strMemPastDueSortColumn = strSortColumn;		
			 	  
			searchURL += '&sortPastDueTable=MembersWithPastDueBalances&sortPastDueColumn=' + String.escapeSingleQuotes(strMemPastDueSortColumn) + '&sortPastDueDir=' + strSortOrder;
		}		
		
		// Added as per PURE-65 to pass column,tablename,Sortdirection in URL to perform sorting based on selected column header in 'Members with Claim Activity' section
		if(!String.isEmpty(strMemClaimActTable) && !String.isEmpty(strMemClaimActSortColumn) || (String.isEmpty(strMemClaimActTable) && strSortTable == 'MembersWithClaimActivity'))
		{
			String strSortOrder;
			
			// Checking if the same column is clicked then swapping sort direction
			if(strMemClaimActSortColumn == strSortColumn && strSortTable == 'MembersWithClaimActivity')
			   strSortOrder = strMemClaimActSortDir == 'DESC' ? 'ASC' : 'DESC';
			// Sorting by ascending on default
			else if(!String.isEmpty(strMemClaimActSortDir) && strSortTable != 'MembersWithClaimActivity')
			 	strSortOrder = strMemClaimActSortDir;
			else
				 strSortOrder = 'ASC';
			 	
			 if(!String.isEmpty(strSortColumn) && strSortTable == 'MembersWithClaimActivity')	
			 	strMemClaimActSortColumn = strSortColumn;		
			 	  
			searchURL += '&sortClaimActTable=MembersWithClaimActivity&sortClaimActColumn=' + String.escapeSingleQuotes(strMemClaimActSortColumn) + '&sortClaimActColumnDir=' + strSortOrder;
		}

		// If someone opened a list and searched, the list should remain open
		if(moreMembers){
			searchURL += '&moremembers=true';
		}
		if(moreMemBalances){
			searchURL += '&morememBalances=true';
		}
		if(moreClaims){
			searchURL += '&moreclaim=true';
		}
		
		return searchURL;
	}

	// Populates search boxes and selects logic dropdowns based on url values.
	// Defaults all logic dropdown selections to AND if nothing was picked
	private void setSearchBoxes(String fn, String lnl, String ln, String c, String zcl, String zc, String sl, 
								String s, String mids, String pl, String pnum){
 
		firstNameSearch = fn;
		lastNameLogic = (lnl == null ? 'AND' : lnl);
		lastNameSearch = ln;
		citySearch = c;
		zipCodeLogic = (zcl == null ? 'AND' : zcl);
		zipCodeSearch = zc;
		stateLogic = (sl == null ? 'AND' : sl);
		stateSearch = s;
		memberIdSearch = mids;
		policyLogic = (pl == null ? 'AND' : pl);
		policySearch = pnum;
	}

	// We want to retrieve all accessible members when someone searches without
	// any parameters
	private List<MemberWrapper> getMembersFromIds(Set<Id> accessibleMemberIds)
	{
		// Updated as per PURE-65 to make query dynamic for sorting functionality based on selected column header
		String strAccountQuery = 'SELECT Id, Name, Member_Key_EDW__c,ShippingCity, ShippingState,Broker__r.Broker_Id__c FROM Account WHERE RecordType.Name =' + '\'Member' +'\'' + ' AND Status__c =' + '\'Active' + '\'' + ' AND ID IN :accessibleMemberIds ORDER BY ';
		
		if( strSearchResTable == 'MemberSearchResults' && !String.isEmpty(strSearchSortColumn))
			strAccountQuery += strSearchSortColumn + ' ' + strSearchSortDir;
		else
			strAccountQuery += ' Name ASC';	
		
		List<Account> accessibleMembers = Database.query(strAccountQuery);

		List<MemberWrapper> wrappedAccessibleMembers = new List<MemberWrapper>();

		Integer memCount = 1;
		for(Account mem : accessibleMembers){
			MemberWrapper mw = new MemberWrapper(mem.Id, mem.Name, mem.Member_Key_EDW__c, 
												 mem.ShippingCity, mem.ShippingState, 
												 mem.Broker__r.Broker_Id__c, memCount++, null);
			wrappedAccessibleMembers.add(mw);
		}
		return wrappedAccessibleMembers;
	}

	/*
	 Will search for a member based on search parameters in the URL. Complicated logic dictates how the 
	 query is constructed. Assumes that there is at least one search parameter passed to it.

	 A user can enter:

	 	  First Name - Logic - Last Name 
	 OR - City - Logic - State - Logic - ZipCode 
	 OR - Member Id - Logic - PolicyNumber

	 Where logic equals an AND or an OR. 

	 Before City, State, or Zipcode there should always be an OR if none of the preceding search boxes
	 were populated.

	 This is also true for Member Id and Policy Number. For example, if the only search boxes were 
	 First Name, State, and Policy Number the resulting query should be ((First Name) OR (State) OR 
	 (Policy Number)).

	 I am assuming that ORS are separating different chunks of logic, and ANDs are joining pieces, 
	 for example: 
	 	(First Name AND Last Name) OR (City AND State)
	 or
	 	(First Name) OR (Last Name) OR (Zip Code) OR (Member ID AND PolicyNumber)

	 More complicated logic can't be constructed without allowing the user to insert parenthesis and 
	 order the fields.

	 Return: List of members returned
	*/
	private List<MemberWrapper> searchFromParameters(Set<Id> accessibleMemberIds, String firstName, 
										String lastNameLogic, String lastName, String city, 
										String zipCodeLogic, String zipCode, String stateLogic, 
										String state, String memberId, String policyLogic, String policyMemIds){

		List<MemberWrapper> memberSearchResults = new List<MemberWrapper>();

		if(accessibleMemberIds == null){
			return memberSearchResults;
		}

		// The main query that will retrieve all of the Members
		String accountQuery = 'SELECT Id, Name, Member_Key_EDW__c, ShippingCity, ' + 
									 'ShippingState, Broker__r.Broker_Id__c ' + 
								  'FROM Account ' + 
								  'WHERE RecordType.Name = \'Member\' '+ 
								      'AND Status__c = \'Active\' AND ID';

		// Create a queryable string with all of the accessible member ids
		String accessibleIds = ' IN ('; 
		for(Id i : accessibleMemberIds){
			accessibleIds += '\'' + i + '\',';
		}

		accessibleIds = accessibleIds.removeEnd(',');
		accessibleIds += ') ';

		accountQuery += accessibleIds;

		// The query that finds Members indirectly through their Contacts
		String contactQuery = 'SELECT AccountId '+
				      		  'FROM Contact '+
				      		  'WHERE AccountId' + accessibleIds + ' AND ((';

		String searchString = ''; // String to hold additional account filter values

		Boolean contactQueried = false; // First and Last name are only applicable to Contacts
		Boolean accountQueried = false; // so these are tracked separately

		// Only a contact has a first and last name
		if(firstName != null){

			// Escape single quotes to prevent SOQL injection attacks
			String escapedFirstName = String.escapeSingleQuotes(firstName);
			contactQuery +='FirstName LIKE \'' + escapedFirstName + '%\'';
			contactQueried = true;
		}

		if(lastName != null && (!contactQueried || lastNameLogic != null)){

			// If the user entered a filter value before this (in this case, first name), 
			// then add the selected logic
			if(contactQueried){
				String logic = constructLogic(lastNameLogic);
				contactQuery += logic;
			}

			String escapedLastName = String.escapeSingleQuotes(lastName);
			contactQuery += 'LastName LIKE \'' + escapedLastName + '%\'';
			contactQueried = true;
		}

		// Both Accounts and Contacts have mailing addresses
		Boolean addressQueried = false;
		if(city != null){

			String escapedCity = String.escapeSingleQuotes(city);

			searchString += 'ShippingCity = \'' + escapedCity + '\'';

			if(contactQueried){
				contactQuery += ') OR (';
			}

			contactQuery += 'MailingCity = \'' + escapedCity + '\'';

			contactQueried = true;
			accountQueried = true;
			addressQueried = true;
		}

		if(state != null && (!contactQueried || stateLogic != null)){
			if(contactQueried || accountQueried){

				if(contactQueried){
					if(!addressQueried){
						contactQuery += ') OR (';
					} else {
						contactQuery += constructLogic(stateLogic);
					}
				}
				
				// It's possible that we haven't encountered an Account field yet, 
				// so handle this as a special case
				if(addressQueried){
					searchString += constructLogic(stateLogic);
				} else {
					if(accountQueried){
						searchString += ') OR (';
					}
				}
			}

			String escapedState = String.escapeSingleQuotes(state);

			searchString += 'ShippingState = \'' + escapedState + '\'';
			contactQuery += 'MailingState = \'' + escapedState + '\'';

			contactQueried = true;
			accountQueried = true;
			addressQueried = true;
		}

		if(zipCode != null && (!contactQueried || zipCodeLogic != null)){
			if(contactQueried || accountQueried){

				String chosenLogic = constructLogic(zipCodeLogic);

				if(contactQueried){
					if(!addressQueried){
						contactQuery += ') OR (';
					} else {
						contactQuery += chosenLogic;
					}
				}

				// It's possible that we haven't encountered an Account field yet, 
				// so handle this as a special case
				if(addressQueried){
					searchString += chosenLogic;
				} else {
					if(accountQueried){
						searchString += ') OR (';
					}
				}
			}

			String escapedZip = String.escapeSingleQuotes(zipCode);

			searchString += 'ShippingPostalCode = \'' + escapedZip + '\'';
			contactQuery += 'MailingPostalCode = \'' + escapedZip + '\'';

			contactQueried = true;
			accountQueried = true;
			addressQueried = true;
		}

		Boolean idsQueried = false;
		if(memberId != null){

			String queryString = 'Member_Key_EDW__c = \'' + String.escapeSingleQuotes(memberId) + '\'';

			if(accountQueried){
				searchString += ') OR (';
			}

			searchString += queryString;

			if(contactQueried){
				contactQuery += ') OR (';
			}

			contactQuery += 'Account.'+ queryString;
			accountQueried = true;
			contactQueried = true;
			idsQueried = true;
		}

		// The policy portion of the search requires member account ids that we previously 
		// queried from policies directly, when the URL was constructed
		if(policyMemIds != null && (!accountQueried || policyLogic != null)){

			List<String> memIds = policyMemIds.split(',');

			System.debug('~~~~~ MemIds: ' + memIds);

			// There can only be one, so we will only use the first.
			// Policy Member Id can be none if nothing was found in query
			if(memIds[0] != 'none'){

				String logic = constructLogic(policyLogic); // Used if an OR isn't required

				if(contactQueried){
					if(!idsQueried){
						contactQuery += ') OR (';
					} else {
						contactQuery += logic;
					}
				}

				if(!idsQueried){
					if(accountQueried){ // If this is the only query, use an OR joiner
						searchString += ') OR (';
					}
				} else{ // Member ID was queried, so use selected logic
					searchString += logic;
				}

				searchString += 'ID = \'' + String.escapeSingleQuotes(memIds[0]) + '\'';
				contactQuery += 'Account.ID = \'' + + String.escapeSingleQuotes(memIds[0]) + '\'';
				accountQueried = true;
				contactQueried = true;
				idsQueried = true;
			}
		}

		// Query contacts, then add those IDs to the account query
		String contactAccountIds = null;
		if(contactQueried){
			contactQuery += '))';
			System.debug('~~~~~ contactQuery: ' + contactQuery);
			List<Contact> contactsSearched = Database.query(contactQuery);

			if(!contactsSearched.isEmpty()){
				contactAccountIds = 'Id IN (';

				for(Contact c : contactsSearched){
					contactAccountIds += '\'' + c.AccountId + '\',';
				}

				contactAccountIds = contactAccountIds.removeEnd(',');
				contactAccountIds += ') ';

				System.debug('~~~~~ contactAccountIds: ' + contactAccountIds);
			}
		}

		if(accountQueried || contactQueried){

			searchString += ')';

			System.debug('~~~~~ Account Query: ' + accountQuery);
			System.debug('~~~~~ Contact Query Results: ' + contactAccountIds);
			System.debug('~~~~~ Search String: ' + searchString);

			if(contactQueried && contactAccountIds != null){
				if(accountQueried){
					// If accounts were queried we need to surround with an OR to account
					// for the OR before the address or Id section
					accountQuery += ' AND (' + contactAccountIds + ' OR (' + searchString;
				}
				else
					accountQuery += ' AND (' + contactAccountIds;
			} else if(accountQueried){
				accountQuery += ' AND ((' + searchString;
			} else {
				return memberSearchResults; // Nothing was queried
			}

			accountQuery += ') ORDER By ';

			Boolean customOrder = false;
			
			// Updated as per PURE-65 to make query dynamic for sorting functionality based on selected column header
			if(strSearchResTable == 'MemberSearchResults' && !String.isEmpty(strSearchSortColumn)){
				accountQuery += ' ' + strSearchSortColumn + ' ' + strSearchSortDir;
			} else{
				accountQuery += ' Name ASC';	
			}
			
			List<Account> unwrappedMembers = Database.query(accountQuery);

			// Wrap members so we can hide / show them as necessary
			Integer memCount = 1;
			String searchedName = '';

			if(firstName != null){
				searchedName += firstName;
			}

			if(lastName != null){
				if(firstName != null){
					searchedName += ' ';
				}
				searchedName += lastName;
			}

			for(Account mem : unwrappedMembers){
				MemberWrapper mw = new MemberWrapper(mem.Id, mem.Name, mem.Member_Key_EDW__c, 
													 mem.ShippingCity, mem.ShippingState, 
													 mem.Broker__r.Broker_Id__c, 0, searchedName);
				memberSearchResults.add(mw);
			}

			// Sort results based on closeness to searched term
			if(!String.isBlank(searchedName) && strSearchResTable != 'MemberSearchResults'){
				memberSearchResults.sort();
			}

			// Make sure that the members are displayed in sorted order
			// so add index corresponding to new position
			for(MemberWrapper mw : memberSearchResults){
				mw.memberIndex = memCount++;
			}
		}

		return memberSearchResults;
	}

	// ORs should mark the end and beginning of sections 
	// in the logic of the query, ANDs should join fields
	private String constructLogic(String queryLogic){
		String logic;

		if(queryLogic == 'OR')
			logic = ') ' + queryLogic + ' (';
		else
			logic = ' ' + queryLogic + ' ';

		return logic;
	}

	// Query the account with 'For View' so that the account shows up in Recently Viewed
	public PageReference navigateToMember(){
		String memberId = ApexPages.currentPage().getParameters().get('mId');

		List<Account> viewedAccount = [SELECT Id
									   FROM Account
									   WHERE Id = :memberId
									   LIMIT 1 FOR VIEW];

		PageReference memberPage = new PageReference('/MemberHomePage?mid=' + memberId);
		memberPage.setRedirect(true);

		return memberPage;
	}

	// Query the claim's account with 'For View' so that the account shows up in Recently Viewed
	public PageReference navigateToClaim(){
		String claimNumber = ApexPages.currentPage().getParameters().get('claimNum');
		String memberId = ApexPages.currentPage().getParameters().get('mId');

		List<Account> viewedAccount = [SELECT Id
									   FROM Account
									   WHERE Id = :memberId
									   LIMIT 1 FOR VIEW];

		PageReference claimPage = new PageReference('/claimDetails?url='+claimNumber+'&mId='+memberId);
		claimPage.setRedirect(true);

		return claimPage;
	}

	public List<SelectOption> getStateList(){
		List<SelectOption> states = new List<SelectOption>();
		states.add(new SelectOption('--Select--', '--Select--'));
		states.add(new SelectOption('AK', 'AK'));
		states.add(new SelectOption('AL', 'AL'));
		states.add(new SelectOption('AR', 'AR'));
		states.add(new SelectOption('AZ', 'AZ'));
		states.add(new SelectOption('CA', 'CA'));
		states.add(new SelectOption('CO', 'CO'));
		states.add(new SelectOption('CT', 'CT'));
		states.add(new SelectOption('DE', 'DE'));
		states.add(new SelectOption('FL', 'FL'));
		states.add(new SelectOption('GA', 'GA'));
		states.add(new SelectOption('HI', 'HI'));
		states.add(new SelectOption('IA', 'IA'));
		states.add(new SelectOption('ID', 'ID'));
		states.add(new SelectOption('IL', 'IL'));
		states.add(new SelectOption('IN', 'IN'));
		states.add(new SelectOption('IT', 'IT'));
		states.add(new SelectOption('KS', 'KS'));
		states.add(new SelectOption('KY', 'KY'));
		states.add(new SelectOption('LA', 'LA'));
		states.add(new SelectOption('ME', 'ME'));
		states.add(new SelectOption('MD', 'MD'));
		states.add(new SelectOption('MA', 'MA'));
		states.add(new SelectOption('MI', 'MI'));
		states.add(new SelectOption('MN', 'MN'));
		states.add(new SelectOption('MO', 'MO'));
		states.add(new SelectOption('MS', 'MS'));
		states.add(new SelectOption('MT', 'MT'));
		states.add(new SelectOption('NC', 'NC'));
		states.add(new SelectOption('ND', 'ND'));
		states.add(new SelectOption('NE', 'NE'));
		states.add(new SelectOption('NH', 'NH'));
		states.add(new SelectOption('NJ', 'NJ'));
		states.add(new SelectOption('NM', 'NM'));
		states.add(new SelectOption('NV', 'NV'));
		states.add(new SelectOption('NY', 'NY'));
		states.add(new SelectOption('OH', 'OH'));
		states.add(new SelectOption('OK', 'OK'));
		states.add(new SelectOption('OR', 'OR'));
		states.add(new SelectOption('PA', 'PA'));
		states.add(new SelectOption('RI', 'RI'));
		states.add(new SelectOption('SC', 'SC'));
		states.add(new SelectOption('SD', 'SD'));
		states.add(new SelectOption('TN', 'TN'));
		states.add(new SelectOption('TX', 'TX'));
		states.add(new SelectOption('UT', 'UT'));
		states.add(new SelectOption('VA', 'VA'));
		states.add(new SelectOption('VT', 'VT'));
		states.add(new SelectOption('DC', 'DC'));
		states.add(new SelectOption('WA', 'WA'));
		states.add(new SelectOption('WI', 'WI'));
		states.add(new SelectOption('WV', 'WV'));
		states.add(new SelectOption('WY', 'WY'));
		return states;
	}

	public void addMoreParam(){
		if(moreParamName == 'moremembers'){
			moreMembers = true;
		} else if(moreParamName == 'morememBalances'){
			moreMemBalances = true;
		} else if(moreParamName == 'moreclaim'){
			moreClaims = true;
		}

		System.debug('~~~moreParamName = ' + moreParamName + ' Adding parameter: moreMembers=' + moreMembers + ' moreMemBalances=' + moreMemBalances + ' moreClaims=' +moreClaims);
	}

	public void removeMoreParam(){
		if(moreParamName == 'moremembers'){
			moreMembers = false;
		} else if(moreParamName == 'morememBalances'){
			moreMemBalances = false;
		} else if(moreParamName == 'moreclaim'){
			moreClaims = false;
		}
	}

/***** Object Wrappers ******/

	// Wrapper to allow hiding and showing members in search list
	private class MemberWrapper implements comparable{
		public Id memId            	{get;set;}
		public String name          {get;set;}
		public String memberKeyEDW  {get;set;}
		public String shippingCity  {get;set;}
		public String shippingState {get;set;}
		public String brokerId      {get;set;}
		public Integer memberIndex  {get;set;}
		public String searchedName  {get;set;} // Name that was searched when member was populated

		public MemberWrapper(Id memId, String name, String memberKeyEDW, String shippingCity, 
							 String shippingState, String brokerId, Integer memberIndex, 
							 String searchedName){
			this.memId = memId;
			this.name = name;
			this.memberKeyEDW = memberKeyEDW;
			this.shippingCity = shippingCity;
			this.shippingState = shippingState;
			this.brokerId = brokerId;
			this.memberIndex = memberIndex;
			this.searchedName = searchedName;
		}

		// Prioritize members whose name starts with the searched name, otherwise
		// order by members whose name is closest to the searched name
		public Integer compareTo(Object compareTo){
			Integer returnValue = 0;

			if(String.isBlank(this.searchedName)){
				return returnValue;
			}

			MemberWrapper comparedMember = (MemberWrapper)compareTo;

			Integer searchedNameLength = this.searchedName.length();

			// To get rid of discrepancies based on length of the string, only compare strings up to the same length
			Integer nameDistance = 
				this.searchedName.getLevenshteinDistance(this.name.substring(0, searchedNameLength), 30);

			Integer comparedNameDistance = 
				comparedMember.searchedName.getLevenshteinDistance(comparedMember.name.substring(0, searchedNameLength), 30);

			if(this.name.startsWith(this.searchedName) && 
				 !comparedMember.name.startsWith(comparedMember.searchedName)){
				returnValue = -2;
			} else if(!this.name.startsWith(this.searchedName) && 
				 comparedMember.name.startsWith(comparedMember.searchedName)){
				returnValue = 2;
			} else {
				// If the name distance is -1 then it is more than 30 changes away from the string
				if(nameDistance == -1 && comparedNameDistance != -1){
					returnValue = 2;
				} else if(comparedNameDistance == -1 && comparedNameDistance != -1){
					returnValue = -2;
				} else if(nameDistance < comparedNameDistance){
					returnValue = -1;
				} else if(nameDistance > comparedNameDistance){
					returnValue = 1;
				}
			}

			return returnValue;
		}
	}

	// Wrapper to allow us to sort recently viewed accounts
	private class RecentlyViewedAccountWrapper implements comparable{

		public Account acc {get;set;}
		public Datetime lastViewed {get;set;}

		public RecentlyViewedAccountWrapper(Account account)
		{
			this.acc = account;
		}
		public RecentlyViewedAccountWrapper(Account account, Datetime lastViewedDate){
			this.acc = account;
			this.lastViewed = lastViewedDate;
		}  
		
		// We want to show most recently viewed accounts first in the list, but we
		// are iterating through the objects and adding them to a list, so we need
		// to score it backwards 
		public Integer compareTo(Object compareTo){
			recentlyViewedAccountWrapper compareDates = (recentlyViewedAccountWrapper)compareTo;
				
			Integer returnValue = 0;
			if(this.lastViewed > compareDates.lastViewed) {
				returnValue = -1;
			} else if(this.lastViewed < compareDates.lastViewed) {
				returnValue = 1;
			}

			return returnValue;
		}
	}
	
	/*Inner Class to store all claims related to loggedin member . */
	public class claimsWrapper
	{
		public String 	policyType 		{get;set;}
		public String 	claimNumber   	{get;set;}
		public Decimal 	totalPaid		{get;set;}
		public String 	lossLocation	{get;set;}
		public Date   	dateOfLoss 		{get;set;}
		public Boolean  canShowDetails	{get;set;}
		public String   memberName		{get;set;}
		public Id 		memberId 		{get;set;}
		public Integer 	claimCount 		{get;set;}
		
		/* Inner class  parametric constructor */
		public claimsWrapper(String policyType, String claimNumber, Decimal totalPaid, String lossLocation, 
							 Date dateOfLoss, Boolean canShowDetails, String memberName, Id memberId, 
							 Integer claimCount)
		{
			this.policyType = policyType;
			this.claimNumber = claimNumber;
			this.totalPaid = totalPaid;
			this.lossLocation = lossLocation;
			this.dateOfLoss = dateOfLoss;
			this.canShowDetails = canShowDetails;
			this.memberName = memberName;
			this.memberId = memberId;
			this.claimCount = claimCount;
		}
	}

	public class PastDueWrapper
	{
		public Id memberId 			{get;set;}
		public String memberName	{get;set;}
		public Decimal totalPastDue	{get;set;}
		public Decimal numPastDue	{get;set;}
		public Datetime oldestPastDueDate {get;set;}
		public Integer pastDueCount {get;set;}

		public PastDueWrapper(Id memberId, String memberName, Decimal totalPastDue, Decimal numPastDue, 
							  Datetime oldestPastDueDate, Integer pastDueCount){
			this.memberId = memberId;
			this.memberName = memberName;
			this.totalPastDue = totalPastDue;
			this.numPastDue = numPastDue;
			this.oldestPastDueDate = oldestPastDueDate;
			this.pastDueCount = pastDueCount;
		}
	}
}