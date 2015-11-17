/*
Modified: Privlad 02/23/2010 - task: 956
Modified: Ekrivobok 02/24/2010 - task: 916
modified: yuguziy 04/07/2010 - Task #10220 #10249 #10252
modified: vika 04/29/2010 - Task #10307
modified: Vika 05/14/2010 - Task #10350
modified: Vika 06/26/2010 - silverline.jira.com/browse/MOELIS-17
modified: DMalenko 07/30/2010 - 08/06/2010 - silverline.jira.com/browse/MOELIS-17
backup & clean up: DMalenko 08/30/2010
*/

public class SSearch {
	
    // true=ascendent/false=descendent for GROUP BY
    public Boolean isTest {get;set;}
    
	public String asc_des {
		get {
			String str = '';
			if (asc_des != null)
				str = asc_des;
			return str;
		}
		set;
	}
    
	public String searchObject {get; set;} 
	public String searchStr {get; set;}
    
	public String renderMode = '';
    
	public String ErrorMsg {get; set;} 
    
	public String query {get; set;}
	public String results {get; set;}
        
	public integer ElemPerPage = 10;
	private String SearchTxt = '';
    
	public String getElemInBlock(){ return ''+ElemPerPage;}
	public void setElemInBlock(String inVal){ ElemPerPage = integer.valueOf(inVal);}
    
    public SSearch() {
    	isTest = false;
    	
    	String criteriaStr = null;
    	
    	for(ConflictSearchCriteria__c item : [
    		SELECT Name, Criteria__c FROM ConflictSearchCriteria__c WHERE Name = :UserInfo.getUserId() limit 1])
    	criteriaStr = item.Criteria__c;
    	
    	if (criteriaStr != null && criteriaStr != '') /***/ searchStr = criteriaStr;
    }
    
    public Pagereference preToSearch() {
    	if (searchStr != null && searchStr != '') /***/ toSearch();
    	return null;
    }
    
	public String getChooserender()
	{
		if(renderMode=='pdf') return 'pdf';
		else return null;
	}
    
    public String getChooserender2()
	{
		if(renderMode=='pdf') return 'application/x-download#ComplexConflictSearchResult.pdf';
		else if(renderMode=='excel') return 'application/vnd.ms-excel#ComplexConflictSearchResult.xls';
		else return null;
	}

	public List<String> getLinkPanel()
	{
	   	List<String> aRetArr = new List<String>();
	   	if(
	   		isTest ||
	   		getAccountListSize()!='0' || 
	   		getContactListSize()!='0' || 
	   		getDealListSize()!='0' || 
	   		getEmployeeListSize()!='0' || 
	   		getTargetBuyersListSize()!='0'
	   	){ aRetArr.add('Link List.');}
	   	return aRetArr;
	}
	
	public List<SelectOption> getElemInBlockItems()
	{
        List<SelectOption> options = new List<SelectOption>();
   		options.add(new SelectOption('10', '10'));
   		options.add(new SelectOption('25', '25'));
   		options.add(new SelectOption('50', '50'));
  		options.add(new SelectOption('100', '100'));
		return options;
    }
    
	public Pagereference printPDF()
	{
		 renderMode = 'pdf';
		 System.currentPageReference().setRedirect(true);  
		 return null;
	}

	public Pagereference printExcel()
	{
		PageReference pageRef = new PageReference('/apex/SSearch_Excel');
        return pageRef;
	}

	public Pagereference toClearCriteria() {
		searchStr = null;
		
		this.dealTeamList = null;
		accountListSize = 0;
		contactListSize = 0;
		dealListSize = 0;
		employeeListSize = 0;
		targetBuyersListSize = 0;
		
		Parent_Financial_Sponsor_ListSize = 0;
		Deal_Client_Contact_ListSize = 0;
		Deal_Team_ListSize = 0;
		Deal_Related_Party_ListSize = 0;
		Target_Buyer_Contacts_ListSize = 0;
		Deal_Idea_Client_ListSize = 0;
		Moelis_Employee_Relationship_ListSize = 0;
		
    	List<ConflictSearchCriteria__c> criteriaList = [
    		SELECT Name, Criteria__c FROM ConflictSearchCriteria__c WHERE Name = :UserInfo.getUserId()];
    	delete criteriaList;
    	return null;
	}

    // action for "Search" button
    public Pagereference toSearch()
    {
    	List<ConflictSearchCriteria__c> criteriaList = [
    		SELECT Name, Criteria__c FROM ConflictSearchCriteria__c WHERE Name = :UserInfo.getUserId()];
    	delete criteriaList;
    	
    	isNeedInitList = true;
    	searchQuery = '';
    	if(searchList!=null)
    	{
    		searchList.clear();
    		iElemPos = new CommDetailObj();
    		searchList = null;
    	}
    	SearchTxt = '';
    	
       	//Error. You have either entered a single character in your search criteria...
        Pattern MyPattern = Pattern.compile('(.*[a-zA-Z0-9]+.*)');
        Matcher MyMatcher = MyPattern.matcher(searchStr);
        if (searchStr==null || searchStr.trim().length() < 2 || verifyForEscapingSymbols(searchStr) || !MyMatcher.matches()) {
            ErrorMsg = '<div style="color:red;padding:10px" align="center"><b>Error. You have either entered a single character in your search criteria or <br/>you have entered an invalid character of ( ) \\ by which to search.</b></div>';
        } else {
            ErrorMsg = '';
            
            SearchTxt = prepareSearchList(this.searchStr);
            SearchTxt = SearchTxt.replaceAll('\'', '\\\\\'');
        }
    	if (searchStr != null && searchStr != '') {
    		ConflictSearchCriteria__c criteria = new ConflictSearchCriteria__c(Name=UserInfo.getUserId(), Criteria__c=searchStr);
    		insert criteria;
    	}
    	this.dealTeamCur = 1;
        return null;
    }
    
    public boolean verifyForEscapingSymbols(String str) {
        boolean error = false;
        //if      (str.indexOf('&') > -1) error = true;
        // else 
        if (
        //str.contains('|') 
        //|| str.contains('!') 
        //|| str.contains('{') || str.contains('}') 
        //|| str.contains('[') || str.contains(']') 
        //|| str.contains('^') 
        //|| str.contains('"') 
        //|| str.contains('~') 
        //|| str.contains('*') 
        //|| str.contains('?') 
        //|| str.contains(':') 
        //|| str.contains('\'') 
        str.contains('(') || str.contains(')') || str.contains('\\')
        // || str.contains('%') 
        ) error = true;
        return error;
    }
    
    // transform a string with commas to a string with stars "*"    
    private String prepareSearchList(String searchString) {
        String resultStr = '';
        searchString.replace('', '\n');
        List<String> arrStr = searchString.split(',');
        
        for(Integer i = 0; i < arrStr.size() - 1; i++) {
            if (arrStr.get(i).trim() != '') resultStr += arrStr.get(i).trim() + '* or ';
        }
        resultStr += arrStr.get(arrStr.size() - 1);
        resultStr += '*';
        return resultStr;
    }

	public String sTraceInfo = '';
	public List<List<SObject>> searchList = null;

	private integer accountListSize = null;
	private integer contactListSize = null;
	private integer contactByAccountListSize = null;
	private integer dealListSize = null;
	private integer employeeListSize = null;
	private integer targetBuyersListSize = null;
	
	private integer Parent_Financial_Sponsor_ListSize = null;
	private integer Deal_Client_Contact_ListSize = null;
	private integer Deal_Team_ListSize = null;
	private integer Deal_Related_Party_ListSize = null;
	private integer Target_Buyer_Contacts_ListSize = null;
	private integer Deal_Idea_Client_ListSize = null;
	private integer Moelis_Employee_Relationship_ListSize = null;

	public Boolean getIsResults() {
		Boolean flag = false;
		
		if (searchStr == null || searchStr=='')			flag = true;
		
		if (accountListSize > 0) 						flag = true;
		if (contactListSize > 0) 						flag = true;
		if (contactByAccountListSize > 0) 						flag = true;
		if (dealListSize > 0) 							flag = true;
		if (employeeListSize > 0) 						flag = true;
		if (targetBuyersListSize > 0) 					flag = true;
		
		if (Parent_Financial_Sponsor_ListSize > 0) 		flag = true;
		if (Deal_Client_Contact_ListSize > 0) 			flag = true;
		if (Deal_Team_ListSize > 0) 					flag = true;
		if (Deal_Related_Party_ListSize > 0) 			flag = true;
		if (Target_Buyer_Contacts_ListSize > 0) 		flag = true;
		if (Deal_Idea_Client_ListSize > 0) 				flag = true;
		if (Moelis_Employee_Relationship_ListSize > 0) 	flag = true;
		
		return flag;	
	}
	
	//ASC|DESC for all objects
	public CommDetailObj sSortDirectionComm = new CommDetailObj();
	public CommDetailObj getSortDirectionComm(){ return sSortDirectionComm;}
	public void setSortDirectionComm(CommDetailObj inVal){ sSortDirectionComm = inVal;}
	/*{
		sSortDirectionComm.AccountObj = 'ASC';
	}*/
	public boolean isNeedInitList = true;
	
	public CommDetailObj isPageNext = new CommDetailObj();
	public CommDetailObj getIsPageNext(){ return isPageNext;}

	public CommDetailObj isPageBack = new CommDetailObj();
	public CommDetailObj getIsPageBack(){ return isPageBack;}

	public CommDetailObj isPaging = new CommDetailObj();
	public CommDetailObj getIsPaging(){ return isPaging;}

	public CommDetailObj iElemPos = new CommDetailObj();
	public CommDetailObj getiElemPos(){ return iElemPos;}
	public void setiElemPos(CommDetailObj inVal){ iElemPos = inVal;}	

	public CommDetailObj sPagePos = new CommDetailObj();
	public CommDetailObj getSPagePos(){ return sPagePos;}

	public CommDetailObj sFirstElemID = new CommDetailObj();
	public CommDetailObj getSFirstElemID(){ return sFirstElemID;}
	public void setSFirstElemID(CommDetailObj inVal){ sFirstElemID = inVal;}

	public CommDetailObj sLastElemID = new CommDetailObj();
	public CommDetailObj getSLastElemID(){ return sLastElemID;}
	public void setSLastElemID(CommDetailObj inVal){ sLastElemID = inVal;}
	
	//private String SearchTxt = 'co* OR mo* OR sa* OR ke* OR da* OR mi* OR ol* OR la* OR bi*';
	
	private String sortDirection = 'ASC';
    public String sortExp = 'name';
    public String searchQuery = '';
    
    //Object fields in global query: 
    private String AccountFldList      = 'ID,Name,Phone,OwnerId,Owner.Alias,ParentId,Parent.Name';
    private String ContactFldList      = 'ID,Name,Phone,Owner.Alias,OwnerId,Email,Account.Name,Account.ID,AccountId,ReportsToId,ReportsTo.Name';
    private String DealFldList         = 'ID,Name,Status__c,Client__r.Name,Client__c,Company_Counsel_Firm__c,Company_Counsel_Firm__r.Name,Company_Financial_Advisor_Firm__c,Company_Financial_Advisor_Firm__r.Name,Financial_Sponsor__c,Financial_Sponsor__r.Name,Lenders_Counsel_Firm__c,Lenders_Counsel_Firm__r.Name,Lenders_Financial_Advisor_Firm__c,Lenders_Financial_Advisor_Firm__r.Name,Official_Committee_Financial_Advisor__c,Official_Committee_Financial_Advisor__r.Name,Judge__c,Judge__r.Name';
    private String DealIdeaFldList     = 'ID,Name,RecordType.Name,RecordTypeId,Client__r.Name,Client__c,Category__c';
    private String EmployeeFldList     = 'ID,Name,Title__c,Speciality_Sectors__c,Office_Location__c,Last_Name__c,First_Name__c,Group__c';
    private String TargetBuyersFldList = 'ID,Name,TargetBuyer__c,TargetBuyer__r.Name';
    
    private String Parent_Financial_Sponsor_FldList     = 'Id,Name,Company_Name__c,Company_Name__r.Name,Financial_Sponsor_Name__c,Financial_Sponsor_Name__r.Name';	// Financial_Sponsors__c
    private String Deal_Client_Contact_FldList          = 'Id,Name,Client_Contact__c,Client_Contact__r.Name'; 							// Project_Client_Contact__c
    private String Deal_Team_FldList                    = 'Id,Name,Banker__c,Banker__r.Name';											// Project_Resource__c
    private String Deal_Related_Party_FldList           = 'Id,Name,Company__c,Company__r.Name';											// Deal_Related_Parties__c
    private String Key_Constituents_FldList             = 'Id,Name,KC_Contact__c,KC_Contact__r.Name';									// Key_Constituents__c
    private String Target_Buyer_Contacts_FldList        = 'Id,Name,Contact__c,Contact__r.Name';											// Potential_Buyer_Investor_Contact__c
    private String Deal_Idea_Client_FldList             = 'Id,Name,Client_Contact__c,Client_Contact__r.Name';							// Research_Client_Contact__c
    private String Moelis_Employee_Relationship_FldList = 'Id,Name,Company__c,Contact__c,Contact__r.Name,Employee__c,Employee__r.Name';	// Employee_Relationships__c
	
	public String AccountSearchQuery {get;set;}
	public String SQForDeletedObj {get;set;}
	public String ContactSearchQuery {get;set;}
	public String DealSearchQuery {get;set;}
	public String DealIdeaSearchQuery {get;set;}
	public String EmployeeProfileSearchQuery {get;set;}
	public String TargetBuyersSearchQuery {get;set;}
	
	public String Parent_Financial_Sponsor_SearchQuery {get;set;}
	public String Deal_Client_Contact_SearchQuery {get;set;}
	public String Deal_Team_SearchQuery {get;set;}
	public String Deal_Related_Party_SearchQuery {get;set;}
	public String Key_Constituents_SearchQuery {get;set;}
	public String Target_Buyer_Contacts_SearchQuery {get;set;}
	public String Deal_Idea_Client_SearchQuery {get;set;}
	public String Moelis_Employee_Relationship_SearchQuery {get;set;}
	
/*
	Parent_Financial_Sponsor_SearchQuery
	Deal_Client_Contact_SearchQuery
	Deal_Team_SearchQuery
	Deal_Related_Party_SearchQuery
	Key_Constituents_SearchQuery
	Target_Buyer_Contacts_SearchQuery
	Deal_Idea_Client_SearchQuery
	Moelis_Employee_Relationship_SearchQuery
*/
	
	public void initList()
	{
		//SearchTxt = 'co* OR mo* OR sa* OR ke* OR da* OR mi* OR ol* OR la* OR bi*';
		isNeedInitList = false;
		SearchTxt = SearchTxt.trim();
		
		if(SearchTxt==null || SearchTxt=='' || SearchTxt=='*' || SearchTxt.length() <= 2) return;

			if (isTest==false) {
				if(searchQuery=='') searchQuery = 
				/*
				 * Problem has occured in FIND query. If we returning only Account records array,
				 * then ewerything worked normally. But if we returning any of the other records
				 * with Accounts array, several records is lost.
				*/
					'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' + 
					'Account            ('+AccountFldList+'      order by Name '+sSortDirectionComm.AccountObj+' Limit '+(ElemPerPage+1)+')&split; ' + 
					'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' + 
					'Contact            ('+ContactFldList+'      order by Name '+sSortDirectionComm.ContactObj+' Limit '+(ElemPerPage+1)+')&split; ' + 
					'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' + 
					'Ibanking_Project__c('+DealFldList+'         order by Name '+sSortDirectionComm.DealObj+' Limit '+(ElemPerPage+1)+')&split; ' +
					'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' + 
					'Employee_Profile__c('+EmployeeFldList+'     order by Name '+sSortDirectionComm.EmployeeObj+' Limit '+(ElemPerPage+1)+')&split; ' +
					'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' + 
					'Potential_Buyer_Investor__c   ('+TargetBuyersFldList+' order by Name '+sSortDirectionComm.TargetBuyersObj+' Limit '+(ElemPerPage+1)+')&split; ' +

					'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' + 
					'Financial_Sponsors__c     ('+Parent_Financial_Sponsor_FldList+' where Financial_Sponsor_Name__r.Name LIKE \'%a%\' order by Name '+sSortDirectionComm.Parent_Financial_Sponsor_Obj+' Limit '+(ElemPerPage+1)+')&split; ' +
					'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' + 
					'Project_Client_Contact__c ('+Deal_Client_Contact_FldList+'          order by Name '+sSortDirectionComm.Deal_Client_Contact_Obj+' Limit '+(ElemPerPage+1)+')&split; ' +
					'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' + 
					'Project_Resource__c       ('+Deal_Team_FldList+'                    order by Name '+sSortDirectionComm.Deal_Team_Obj+' Limit '+(ElemPerPage+1)+')&split; ' +
					'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' + 
					'Deal_Related_Parties__c   ('+Deal_Related_Party_FldList+'           order by Name '+sSortDirectionComm.Deal_Related_Party_Obj+' Limit '+(ElemPerPage+1)+')&split; ' +
					'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' + 
					'Potential_Buyer_Investor_Contact__c  ('+Target_Buyer_Contacts_FldList+'        order by Name '+sSortDirectionComm.Target_Buyer_Contacts_Obj+' Limit '+(ElemPerPage+1)+')&split; ' +
					'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING ' + 
					'Employee_Relationships__c ('+Moelis_Employee_Relationship_FldList+' order by Name '+sSortDirectionComm.Moelis_Employee_Relationship_Obj+' Limit '+(ElemPerPage+1)+')';
				
				List<String> searchQueryList = new List<String>();
				searchList = new List<List<sObject>>();
				List<List<sObject>> temp;
				searchQueryList = searchQuery.split('&split;',0);
				
				for (String elem: searchQueryList) {
					temp = search.query(elem);
					if (temp != null) {
						searchList.add(temp[0]);
					} else {
						searchList.add(new List<Contact>());
					}
				}
				
				//Insert empty rows for compatibility with earlier code
				searchList.add(3,new List<Contact>());
				searchList.add(10,new List<Contact>());
				searchList.add(12,new List<Contact>());
			} else { //If class running as a test class

	/*
	Parent_Financial_Sponsor_FldList 		// Financial_Sponsors__c
    Deal_Client_Contact_FldList 			// Project_Client_Contact__c
    Deal_Team_FldList 						// Project_Resource__c
    Deal_Related_Party_FldList				// Deal_Related_Parties__c
    Key_Constituents_FldList				// Key_Constituents__c
    Target_Buyer_Contacts_FldList			// Potential_Buyer_Investor_Contact__c
    Deal_Idea_Client_FldList				// Research_Client_Contact__c
    Moelis_Employee_Relationship_FldList	// Employee_Relationships__c
	*/
	
				SQForDeletedObj 			= 'select Name from Account             where Name=\'erkltjqweriltj\' order by Name Limit 1';
				AccountSearchQuery 			= 'select Name from Account             where Name=\''+searchStr+'\' order by Name Limit 5';
	        	ContactSearchQuery 			= 'select FirstName from Contact        where FirstName=\''+searchStr+'\' order by Name Limit 5';
				DealSearchQuery 			= 'select Name from Ibanking_Project__c where Name=\''+searchStr+'\' order by Name Limit 5';
				EmployeeProfileSearchQuery 	= 'select Name from Employee_Profile__c where Name=\''+searchStr+'\' order by Name Limit 5';
				TargetBuyersSearchQuery 	= 'select Name from Potential_Buyer_Investor__c    where Name=\''+searchStr+'\' order by Name Limit 5';

				Parent_Financial_Sponsor_SearchQuery		= 'select Name from Financial_Sponsors__c      where Name=\''+searchStr+'\' order by Name Limit 5';
				Deal_Client_Contact_SearchQuery				= 'select Name from Project_Client_Contact__c  where Name=\''+searchStr+'\' order by Name Limit 5';
				Deal_Team_SearchQuery						= 'select Name from Project_Resource__c        where Email__c=\''+searchStr+'\' order by Name Limit 5';
				Deal_Related_Party_SearchQuery				= 'select Name from Deal_Related_Parties__c    where Name=\''+searchStr+'\' order by Name Limit 5';
				Target_Buyer_Contacts_SearchQuery			= 'select Name from Potential_Buyer_Investor_Contact__c   where Name=\''+searchStr+'\' order by Name Limit 5';
				Deal_Idea_Client_SearchQuery				= 'select Name from Research_Client_Contact__c where Name=\''+searchStr+'\' order by Name Limit 5';
				Moelis_Employee_Relationship_SearchQuery	= 'select Name from Employee_Relationships__c  where Name=\''+searchStr+'\' order by Name Limit 5';

	        	searchList = new List<List<SObject>>();
	        	searchList.add(database.query(AccountSearchQuery));
	        	searchList.add(database.query(ContactSearchQuery));
	        	searchList.add(database.query(DealSearchQuery));
	        	searchList.add(database.query(SQForDeletedObj));// just to have something in list
	        	searchList.add(database.query(EmployeeProfileSearchQuery));
	        	searchList.add(database.query(TargetBuyersSearchQuery));
	        	
	        	searchList.add(database.query(Parent_Financial_Sponsor_SearchQuery));
	        	searchList.add(database.query(Deal_Client_Contact_SearchQuery));
	        	searchList.add(database.query(Deal_Team_SearchQuery));
	        	searchList.add(database.query(Deal_Related_Party_SearchQuery));
	        	searchList.add(database.query(SQForDeletedObj));// just to have something in list
	        	searchList.add(database.query(Target_Buyer_Contacts_SearchQuery));
	        	searchList.add(database.query(SQForDeletedObj));// just to have something in list
	        	searchList.add(database.query(Moelis_Employee_Relationship_SearchQuery));
			}
		/*
		 * Set initial values for all paging objects
		 * (sPagePos, isPaging, isPageNext, isPageBack)
		*/
		//Block for Account List Paging START
		integer AccountObjPos = iElemPos.AccountObj!=''?integer.valueOf(iElemPos.AccountObj):0;
		accountListSize = searchList[0].size();
		sPagePos.AccountObj = accountListSize>ElemPerPage?'('+(AccountObjPos+1)+'-'+(AccountObjPos+ElemPerPage)+')':'('+(AccountObjPos+1)+'-'+(AccountObjPos+accountListSize)+')';
		isPaging.AccountObj = (accountListSize>ElemPerPage || AccountObjPos>0)?'1':'0';
		isPageNext.AccountObj = accountListSize>ElemPerPage?'1':'0';
		isPageBack.AccountObj = AccountObjPos>0?'1':'0';
		if(accountListSize>0)
		{
			sFirstElemID.AccountObj = ''+((searchList[0])[0].ID);
			sLastElemID.AccountObj = accountListSize>ElemPerPage?''+((searchList[0])[ElemPerPage-1].ID):''+((searchList[0])[accountListSize-1].ID);
		}
		//Block for Account List Paging END
		
		//Block for Contact List Paging START
		integer ContactObjPos = iElemPos.ContactObj!=''?integer.valueOf(iElemPos.ContactObj):0;
		contactListSize = searchList[1].size();
		sPagePos.ContactObj = contactListSize>ElemPerPage?'('+(ContactObjPos+1)+'-'+(ContactObjPos+ElemPerPage)+')':'('+(ContactObjPos+1)+'-'+(ContactObjPos+contactListSize)+')';
		isPaging.ContactObj = (contactListSize>ElemPerPage || ContactObjPos>0)?'1':'0';
		isPageNext.ContactObj = contactListSize>ElemPerPage?'1':'0';
		isPageBack.ContactObj = ContactObjPos>0?'1':'0';
		if(contactListSize>0)
		{
			sFirstElemID.ContactObj = ''+((searchList[1])[0].ID);
			sLastElemID.ContactObj = contactListSize>ElemPerPage?''+((searchList[1])[ElemPerPage-1].ID):''+((searchList[1])[contactListSize-1].ID);
		}
		//Block for Contact List Paging END

		//Block for ContactByAccount List Paging START
		integer ContactByAccountObjPos = iElemPos.ContactByAccountObj!=''?integer.valueOf(iElemPos.ContactByAccountObj):0;
		contactByAccountListSize = searchList[13].size();
		sPagePos.ContactByAccountObj = contactByAccountListSize>ElemPerPage?'('+(ContactByAccountObjPos+1)+'-'+(ContactByAccountObjPos+ElemPerPage)+')':'('+(ContactByAccountObjPos+1)+'-'+(ContactByAccountObjPos+contactListSize)+')';
		isPaging.ContactByAccountObj = (contactByAccountListSize>ElemPerPage || ContactByAccountObjPos>0)?'1':'0';
		isPageNext.ContactByAccountObj = contactByAccountListSize>ElemPerPage?'1':'0';
		isPageBack.ContactByAccountObj = ContactByAccountObjPos>0?'1':'0';
		if(contactByAccountListSize>0)
		{
			sFirstElemID.ContactByAccountObj = ''+((searchList[13])[0].ID);
			sLastElemID.ContactByAccountObj = contactByAccountListSize>ElemPerPage?''+((searchList[13])[ElemPerPage-1].ID):''+((searchList[13])[contactByAccountListSize-1].ID);
		}
		//Block for ContactByAccount List Paging END

		//Block for deal List Paging START
		integer dealObjPos = iElemPos.DealObj!=''?integer.valueOf(iElemPos.DealObj):0;
		dealListSize = searchList[2].size();
		sPagePos.DealObj = dealListSize>ElemPerPage?'('+(dealObjPos+1)+'-'+(dealObjPos+ElemPerPage)+')':'('+(dealObjPos+1)+'-'+(dealObjPos+dealListSize)+')';
		isPaging.DealObj = (dealListSize>ElemPerPage || dealObjPos>0)?'1':'0';
		isPageNext.DealObj = dealListSize>ElemPerPage?'1':'0';
		isPageBack.DealObj = dealObjPos>0?'1':'0';
		if(dealListSize>0)
		{
			sFirstElemID.DealObj = ''+((searchList[2])[0].ID);
			sLastElemID.DealObj = dealListSize>ElemPerPage?''+((searchList[2])[ElemPerPage-1].ID):''+((searchList[2])[dealListSize-1].ID);
		}
		//Block for deal List Paging End	

		//Block for Employee List Paging START
		integer EmployeeObjPos = iElemPos.EmployeeObj!=''?integer.valueOf(iElemPos.EmployeeObj):0;
		EmployeeListSize = searchList[4].size();
		sPagePos.EmployeeObj = EmployeeListSize>ElemPerPage?'('+(EmployeeObjPos+1)+'-'+(EmployeeObjPos+ElemPerPage)+')':'('+(EmployeeObjPos+1)+'-'+(EmployeeObjPos+EmployeeListSize)+')';
		isPaging.EmployeeObj = (EmployeeListSize>ElemPerPage || EmployeeObjPos>0)?'1':'0';
		isPageNext.EmployeeObj = EmployeeListSize>ElemPerPage?'1':'0';
		isPageBack.EmployeeObj = EmployeeObjPos>0?'1':'0';
		if(EmployeeListSize>0)
		{
			sFirstElemID.EmployeeObj = ''+((searchList[4])[0].ID);
			sLastElemID.EmployeeObj = EmployeeListSize>ElemPerPage?''+((searchList[4])[ElemPerPage-1].ID):''+((searchList[4])[EmployeeListSize-1].ID);
		}
		//Block for Employee List Paging End
	
		//Block for TargetBuyers List Paging START
		integer TargetBuyersObjPos = iElemPos.TargetBuyersObj!=''?integer.valueOf(iElemPos.TargetBuyersObj):0;
		TargetBuyersListSize = searchList[5].size();
		sPagePos.TargetBuyersObj = TargetBuyersListSize>ElemPerPage?'('+(TargetBuyersObjPos+1)+'-'+(TargetBuyersObjPos+ElemPerPage)+')':'('+(TargetBuyersObjPos+1)+'-'+(TargetBuyersObjPos+TargetBuyersListSize)+')';
		isPaging.TargetBuyersObj = (TargetBuyersListSize>ElemPerPage || TargetBuyersObjPos>0)?'1':'0';
		isPageNext.TargetBuyersObj = TargetBuyersListSize>ElemPerPage?'1':'0';
		isPageBack.TargetBuyersObj = TargetBuyersObjPos>0?'1':'0';
		if(TargetBuyersListSize>0) {
			sFirstElemID.TargetBuyersObj = ''+((searchList[5])[0].ID);
			sLastElemID.TargetBuyersObj = TargetBuyersListSize>ElemPerPage?''+((searchList[5])[ElemPerPage-1].ID):''+((searchList[5])[TargetBuyersListSize-1].ID);
		}
		//Block for TargetBuyers List Paging End

		// fetching 
		String searchString = this.searchStr;
		List<String> searchArray = new List<String>();
		if (this.searchStr != null) {
			searchString.replace('', '\n');
			searchString = searchString.replaceAll('\'', '\\\\\'');
			searchArray = searchString.split(',');
		}

		//Block for Parent_Financial_Sponsor List Paging START
		String whereStr = '';
		String localQuery = 'SELECT ' + Parent_Financial_Sponsor_FldList + ' FROM Financial_Sponsors__c WHERE ';
		whereStr = SSearch_Additional.getWhereForSearchArray(searchArray, 'Company_Name__r.Name');
		if (whereStr != '') {
			whereStr += ' or ';
		}
		whereStr += SSearch_Additional.getWhereForSearchArray(searchArray, 'Financial_Sponsor_Name__r.Name');
		localQuery += whereStr;
		localQuery += ' Limit 1000';
		system.debug(localQuery);
		if (whereStr != '') {
			searchList[6] = database.query(localQuery);
		}
 		
		integer Parent_Financial_Sponsor_ObjPos = iElemPos.Parent_Financial_Sponsor_Obj!=''?integer.valueOf(iElemPos.Parent_Financial_Sponsor_Obj):0;
		Parent_Financial_Sponsor_ListSize = searchList[6].size();
		sPagePos.Parent_Financial_Sponsor_Obj = Parent_Financial_Sponsor_ListSize>ElemPerPage?'('+(Parent_Financial_Sponsor_ObjPos+1)+'-'+(Parent_Financial_Sponsor_ObjPos+ElemPerPage)+')':'('+(Parent_Financial_Sponsor_ObjPos+1)+'-'+(Parent_Financial_Sponsor_ObjPos+Parent_Financial_Sponsor_ListSize)+')';
		isPaging.Parent_Financial_Sponsor_Obj = (Parent_Financial_Sponsor_ListSize>ElemPerPage || Parent_Financial_Sponsor_ObjPos>0)?'1':'0';
		isPageNext.Parent_Financial_Sponsor_Obj = Parent_Financial_Sponsor_ListSize>ElemPerPage?'1':'0';
		isPageBack.Parent_Financial_Sponsor_Obj = Parent_Financial_Sponsor_ObjPos>0?'1':'0';
		if(Parent_Financial_Sponsor_ListSize>0) {
			sFirstElemID.Parent_Financial_Sponsor_Obj = ''+((searchList[6])[0].ID);
			sLastElemID.Parent_Financial_Sponsor_Obj = Parent_Financial_Sponsor_ListSize>ElemPerPage?''+((searchList[6])[ElemPerPage-1].ID):''+((searchList[6])[Parent_Financial_Sponsor_ListSize-1].ID);
		}
		//Block for Parent_Financial_Sponsor List Paging End

		//Block for Deal_Client_Contact List Paging START
		String whereDCCStr = '';
		localQuery = 'SELECT ' + Deal_Client_Contact_FldList + ' FROM Project_Client_Contact__c WHERE ';
		whereDCCStr = SSearch_Additional.getWhereForSearchArray(searchArray, 'Client_Contact__r.Name');
		localQuery += whereDCCStr;
		localQuery += ' Limit 1000';
		system.debug('Deal_Client_Contact => localQuery===' + localQuery);
		if (whereDCCStr != '') {
			searchList[7] = database.query(localQuery);
		}

		integer Deal_Client_Contact_ObjPos = iElemPos.Deal_Client_Contact_Obj!=''?integer.valueOf(iElemPos.Deal_Client_Contact_Obj):0;
		Deal_Client_Contact_ListSize = searchList[7].size();
		sPagePos.Deal_Client_Contact_Obj = Deal_Client_Contact_ListSize>ElemPerPage?'('+(Deal_Client_Contact_ObjPos+1)+'-'+(Deal_Client_Contact_ObjPos+ElemPerPage)+')':'('+(Deal_Client_Contact_ObjPos+1)+'-'+(Deal_Client_Contact_ObjPos+Deal_Client_Contact_ListSize)+')';
		isPaging.Deal_Client_Contact_Obj = (Deal_Client_Contact_ListSize>ElemPerPage || Deal_Client_Contact_ObjPos>0)?'1':'0';
		isPageNext.Deal_Client_Contact_Obj = Deal_Client_Contact_ListSize>ElemPerPage?'1':'0';
		isPageBack.Deal_Client_Contact_Obj = Deal_Client_Contact_ObjPos>0?'1':'0';
		if(Deal_Client_Contact_ListSize>0) {
			sFirstElemID.Deal_Client_Contact_Obj = ''+((searchList[7])[0].ID);
			sLastElemID.Deal_Client_Contact_Obj = Deal_Client_Contact_ListSize>ElemPerPage?''+((searchList[7])[ElemPerPage-1].ID):''+((searchList[7])[Deal_Client_Contact_ListSize-1].ID);
		}
		//Block for Deal_Client_Contact List Paging End

		//Block for Deal_Team List Paging START
		localQuery = 'SELECT ' + Deal_Team_FldList + ' FROM Project_Resource__c WHERE ' +
			SSearch_Additional.getWhereForSearchArray(searchArray, 'Banker__r.Name');
		localQuery += ' Limit 1000';

		integer Deal_Team_ObjPos = iElemPos.Deal_Team_Obj!=''?integer.valueOf(iElemPos.Deal_Team_Obj):0;
		Deal_Team_ListSize = searchList[8].size();
		sPagePos.Deal_Team_Obj = Deal_Team_ListSize>ElemPerPage?'('+(Deal_Team_ObjPos+1)+'-'+(Deal_Team_ObjPos+ElemPerPage)+')':'('+(Deal_Team_ObjPos+1)+'-'+(Deal_Team_ObjPos+Deal_Team_ListSize)+')';
		isPaging.Deal_Team_Obj = (Deal_Team_ListSize>ElemPerPage || Deal_Team_ObjPos>0)?'1':'0';
		isPageNext.Deal_Team_Obj = Deal_Team_ListSize>ElemPerPage?'1':'0';
		isPageBack.Deal_Team_Obj = Deal_Team_ObjPos>0?'1':'0';
		if(Deal_Team_ListSize>0) {
			sFirstElemID.Deal_Team_Obj = ''+((searchList[8])[0].ID);
			sLastElemID.Deal_Team_Obj = Deal_Team_ListSize>ElemPerPage?''+((searchList[8])[ElemPerPage-1].ID):''+((searchList[8])[Deal_Team_ListSize-1].ID);
		}
		//Block for Deal_Team List Paging End

		//Block for Deal_Related_Party List Paging START
		String whereDRPStr = '';
		localQuery = 'SELECT ' + Deal_Related_Party_FldList + ' FROM Deal_Related_Parties__c WHERE ';
		whereDRPStr = SSearch_Additional.getWhereForSearchArray(searchArray, 'Company__r.Name');
		localQuery += whereDRPStr;
		localQuery += ' Limit 1000';
		system.debug('Deal_Related_Party => localQuery===' + localQuery);
		if (whereDRPStr != '') {
			searchList[9] = database.query(localQuery);
		}

		integer Deal_Related_Party_ObjPos = iElemPos.Deal_Related_Party_Obj!=''?integer.valueOf(iElemPos.Deal_Related_Party_Obj):0;
		Deal_Related_Party_ListSize = searchList[9].size();
		sPagePos.Deal_Related_Party_Obj = Deal_Related_Party_ListSize>ElemPerPage?'('+(Deal_Related_Party_ObjPos+1)+'-'+(Deal_Related_Party_ObjPos+ElemPerPage)+')':'('+(Deal_Related_Party_ObjPos+1)+'-'+(Deal_Related_Party_ObjPos+Deal_Related_Party_ListSize)+')';
		isPaging.Deal_Related_Party_Obj = (Deal_Related_Party_ListSize>ElemPerPage || Deal_Related_Party_ObjPos>0)?'1':'0';
		isPageNext.Deal_Related_Party_Obj = Deal_Related_Party_ListSize>ElemPerPage?'1':'0';
		isPageBack.Deal_Related_Party_Obj = Deal_Related_Party_ObjPos>0?'1':'0';
		if(Deal_Related_Party_ListSize>0) {
			sFirstElemID.Deal_Related_Party_Obj = ''+((searchList[9])[0].ID);
			sLastElemID.Deal_Related_Party_Obj = Deal_Related_Party_ListSize>ElemPerPage?''+((searchList[9])[ElemPerPage-1].ID):''+((searchList[9])[Deal_Related_Party_ListSize-1].ID);
		}
		//Block for Deal_Related_Party List Paging End

		//Block for Target_Buyer_Contacts List Paging START
		String whereTBCStr = '';
		localQuery = 'SELECT ' + Target_Buyer_Contacts_FldList + ' FROM Potential_Buyer_Investor_Contact__c WHERE ';
		whereTBCStr = SSearch_Additional.getWhereForSearchArray(searchArray, 'Contact__r.Name');
		localQuery += whereTBCStr;
		localQuery += ' Limit 1000';
		system.debug('Target_Buyer_Contacts => localQuery===' + localQuery);
		if (whereTBCStr != '') {
			searchList[11] = database.query(localQuery);
		}

		integer Target_Buyer_Contacts_ObjPos = iElemPos.Target_Buyer_Contacts_Obj!=''?integer.valueOf(iElemPos.Target_Buyer_Contacts_Obj):0;
		Target_Buyer_Contacts_ListSize = searchList[11].size();
		sPagePos.Target_Buyer_Contacts_Obj = Target_Buyer_Contacts_ListSize>ElemPerPage?'('+(Target_Buyer_Contacts_ObjPos+1)+'-'+(Target_Buyer_Contacts_ObjPos+ElemPerPage)+')':'('+(Target_Buyer_Contacts_ObjPos+1)+'-'+(Target_Buyer_Contacts_ObjPos+Target_Buyer_Contacts_ListSize)+')';
		isPaging.Target_Buyer_Contacts_Obj = (Target_Buyer_Contacts_ListSize>ElemPerPage || Target_Buyer_Contacts_ObjPos>0)?'1':'0';
		isPageNext.Target_Buyer_Contacts_Obj = Target_Buyer_Contacts_ListSize>ElemPerPage?'1':'0';
		isPageBack.Target_Buyer_Contacts_Obj = Target_Buyer_Contacts_ObjPos>0?'1':'0';
		if(Target_Buyer_Contacts_ListSize>0) {
			sFirstElemID.Target_Buyer_Contacts_Obj = ''+((searchList[11])[0].ID);
			sLastElemID.Target_Buyer_Contacts_Obj = Target_Buyer_Contacts_ListSize>ElemPerPage?''+((searchList[11])[ElemPerPage-1].ID):''+((searchList[11])[Target_Buyer_Contacts_ListSize-1].ID);
		}
		//Block for Target_Buyer_Contacts List Paging End

		//Block for Moelis_Employee_Relationship List Paging START
		String whereMERStr = '';
		localQuery = 'SELECT ' + Moelis_Employee_Relationship_FldList + ' FROM Employee_Relationships__c WHERE ';
		whereMERStr = SSearch_Additional.getWhereForSearchArray(searchArray, 'Contact__r.Name');
		if (whereMERStr != '') {
			whereMERStr += ' or ';
		}
		whereMERStr += SSearch_Additional.getWhereForSearchArray(searchArray, 'Employee__r.Name');
		localQuery += whereMERStr;
		localQuery += ' Limit 1000';
		system.debug('Moelis_Employee_Relationship => localQuery===' + localQuery);
		if (whereMERStr != '') {
			searchList[13] = database.query(localQuery);
		}

		integer Moelis_Employee_Relationship_ObjPos = iElemPos.Moelis_Employee_Relationship_Obj!=''?integer.valueOf(iElemPos.Moelis_Employee_Relationship_Obj):0;
		Moelis_Employee_Relationship_ListSize = searchList[13].size();
		sPagePos.Moelis_Employee_Relationship_Obj = Moelis_Employee_Relationship_ListSize>ElemPerPage?'('+(Moelis_Employee_Relationship_ObjPos+1)+'-'+(Moelis_Employee_Relationship_ObjPos+ElemPerPage)+')':'('+(Moelis_Employee_Relationship_ObjPos+1)+'-'+(Moelis_Employee_Relationship_ObjPos+Moelis_Employee_Relationship_ListSize)+')';
		isPaging.Moelis_Employee_Relationship_Obj = (Moelis_Employee_Relationship_ListSize>ElemPerPage || Moelis_Employee_Relationship_ObjPos>0)?'1':'0';
		isPageNext.Moelis_Employee_Relationship_Obj = Moelis_Employee_Relationship_ListSize>ElemPerPage?'1':'0';
		isPageBack.Moelis_Employee_Relationship_Obj = Moelis_Employee_Relationship_ObjPos>0?'1':'0';
		if(Moelis_Employee_Relationship_ListSize>0) {
			sFirstElemID.Moelis_Employee_Relationship_Obj = ''+((searchList[13])[0].ID);
			sLastElemID.Moelis_Employee_Relationship_Obj = Moelis_Employee_Relationship_ListSize>ElemPerPage?''+((searchList[13])[ElemPerPage-1].ID):''+((searchList[13])[Moelis_Employee_Relationship_ListSize-1].ID);
		}
		//Block for Moelis_Employee_Relationship List Paging End
	} /* End of initList() function*/
	
	public PageReference selSortFld() { return null; }
	public String getTraceInfo() { return sTraceInfo; }
	
	/* Init size of list for all objects in search list */
	// Account	
	public String getAccountListSize() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return '0';
		if(accountListSize>ElemPerPage) return ''+ElemPerPage+'+';
		else return ''+accountListSize;
	}
	public List<Account> getAccountList() {
		if(isNeedInitList)	initList();
		if(searchList==null || searchList.size()==0) return null;
		if(searchList[0].size()>ElemPerPage) searchList[0].remove(searchList[0].size()-1);
		List<Account> ccc = (List<Account>)searchList[0];
		return ccc;
	}

	// Contact
	public String getContactListSize() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return '0';
		if(contactListSize>ElemPerPage) return ''+ElemPerPage+'+';
		else return ''+contactListSize;
	}
	public List<Contact> getContactList() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return null;
		if(searchList[1].size()>ElemPerPage) searchList[1].remove(searchList[1].size()-1);
		return (List<Contact>)searchList[1];
	}

	// Deal
	public String getDealListSize() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return '0';
		if(dealListSize>ElemPerPage) return ''+ElemPerPage+'+';
		else return ''+dealListSize;
	}
	public List<Ibanking_Project__c> getDealList() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return null;
		if(searchList[2].size()>ElemPerPage) searchList[2].remove(searchList[2].size()-1);
		return (List<Ibanking_Project__c>)searchList[2];
	}

	// Employee_Profile
	public String getEmployeeListSize() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return '0';
		if(employeeListSize>ElemPerPage) return ''+ElemPerPage+'+';
		else return ''+employeeListSize;
	}
	public List<Employee_Profile__c> getEmployeeList() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return null;
		if(searchList[4].size()>ElemPerPage) searchList[4].remove(searchList[4].size()-1);
		return (List<Employee_Profile__c>)searchList[4];
	}

	// Target_Buyers
	public String getTargetBuyersListSize() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return '0';
		if(targetBuyersListSize>ElemPerPage) return ''+ElemPerPage+'+';
		else return ''+targetBuyersListSize;
	}
	public List<Potential_Buyer_Investor__c> getTargetBuyersList() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return null;
		if(searchList[5].size()>ElemPerPage) searchList[5].remove(searchList[5].size()-1);
		return (List<Potential_Buyer_Investor__c>)searchList[5];
	}

	// Parent_Financial_Sponsor
	public String getParent_Financial_Sponsor_ListSize() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return '0';
		if(Parent_Financial_Sponsor_ListSize>ElemPerPage) return ''+ElemPerPage+'+';
		else return ''+Parent_Financial_Sponsor_ListSize;
	}
	public List<Financial_Sponsors__c> getParent_Financial_Sponsor_List() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return null;
		if(searchList[6].size()>ElemPerPage) searchList[6].remove(searchList[6].size()-1);
		return (List<Financial_Sponsors__c>)searchList[6];
	}

	// Deal_Client_Contact
	public String getDeal_Client_Contact_ListSize() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return '0';
		if(Deal_Client_Contact_ListSize>ElemPerPage) return ''+ElemPerPage+'+';
		else return ''+Deal_Client_Contact_ListSize;
	}
	public List<Project_Client_Contact__c> getDeal_Client_Contact_List() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return null;
		if(searchList[7].size()>ElemPerPage) searchList[7].remove(searchList[7].size()-1);
		return (List<Project_Client_Contact__c>)searchList[7];
	}

	// Deal_Team
	public List<Project_Resource__c> getDeal_Team_List() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return null;
		if(searchList[8].size()>ElemPerPage) searchList[8].remove(searchList[8].size()-1);
		return (List<Project_Resource__c>)searchList[8];
	}

	// Deal_Related_Party
	public String getDeal_Related_Party_ListSize() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return '0';
		if(Deal_Related_Party_ListSize>ElemPerPage) return ''+ElemPerPage+'+';
		else return ''+Deal_Related_Party_ListSize;
	}
	public List<Deal_Related_Parties__c> getDeal_Related_Party_List() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return null;
		if(searchList[9].size()>ElemPerPage) searchList[9].remove(searchList[9].size()-1);
		return (List<Deal_Related_Parties__c>)searchList[9];
	}

	// Target_Buyer_Contacts
	public String getTarget_Buyer_Contacts_ListSize() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return '0';
		if(Target_Buyer_Contacts_ListSize>ElemPerPage) return ''+ElemPerPage+'+';
		else return ''+Target_Buyer_Contacts_ListSize;
	}
	public List<Potential_Buyer_Investor_Contact__c> getTarget_Buyer_Contacts_List() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return null;
		if(searchList[11].size()>ElemPerPage) searchList[11].remove(searchList[11].size()-1);
		return (List<Potential_Buyer_Investor_Contact__c>)searchList[11];
	}

	// Moelis_Employee_Relationship
	public String getMoelis_Employee_Relationship_ListSize() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return '0';
		if(Moelis_Employee_Relationship_ListSize>ElemPerPage) return ''+ElemPerPage+'+';
		else return ''+Moelis_Employee_Relationship_ListSize;
	}
	public List<Employee_Relationships__c> getMoelis_Employee_Relationship_List() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return null;
		if(searchList[13].size()>ElemPerPage) searchList[13].remove(searchList[13].size()-1);
		return (List<Employee_Relationships__c>)searchList[13];
	}

	public String getSortExpression(){ return sortExp;}
	public void setSortExpression(String inVal){ sortExp = inVal;}

	public String getSortDirection(){
    	if(sortExp == null || sortExp == ''){ return 'ASC';}
    	else{ return sortDirection;}
 	}

	public void setSortDirection(String value){  
 	  sortDirection = (value == 'ASC')? 'DESC' : 'ASC';
 	}
 
   	public PageReference ViewData() {
       if(sortExp=='Account') { 
       		sSortDirectionComm.AccountObj =(sSortDirectionComm.AccountObj == 'ASC')? 'DESC' : 'ASC';
       		if (isTest==false) searchQuery = SSearch_Additional.getSearchQuery(SearchTxt, ElemPerPage, 'Account', sSortDirectionComm.AccountObj);
       		else searchQuery = 'select Name from Account where Name=\''+searchStr+'\' order by Name Limit 5';
       		iElemPos.AccountObj = '';
       }
       if(sortExp=='Contact') {
       		sSortDirectionComm.ContactObj =(sSortDirectionComm.ContactObj == 'ASC')? 'DESC' : 'ASC';
       		if (isTest==false) searchQuery = SSearch_Additional.getSearchQuery(SearchTxt, ElemPerPage, 'Contact', sSortDirectionComm.ContactObj);
       		else searchQuery = 'select FirstName from Contact where FirstName=\''+searchStr+'\' order by Name Limit 5';
       		iElemPos.ContactObj = '';
       }
       if(sortExp=='Deal') {
       		sSortDirectionComm.DealObj =(sSortDirectionComm.DealObj == 'ASC')? 'DESC' : 'ASC';
       		if (isTest==false) searchQuery = SSearch_Additional.getSearchQuery(SearchTxt, ElemPerPage, 'Ibanking_Project__c', sSortDirectionComm.DealObj);
       		else searchQuery = 'select Name from Ibanking_Project__c where Name=\''+searchStr+'\' order by Name Limit 5';
       		iElemPos.DealObj = '';
       }
       if(sortExp=='Employee') {
       		sSortDirectionComm.EmployeeObj =(sSortDirectionComm.EmployeeObj == 'ASC')? 'DESC' : 'ASC';
       		if (isTest==false) searchQuery = SSearch_Additional.getSearchQuery(SearchTxt, ElemPerPage, 'Employee_Profile__c', sSortDirectionComm.EmployeeObj);
       		else searchQuery = 'select Name from Employee_Profile__c where Name=\''+searchStr+'\' order by Name Limit 5';
       		iElemPos.EmployeeObj = '';
       }
       if(sortExp=='TargetBuyers') {
       		sSortDirectionComm.TargetBuyersObj =(sSortDirectionComm.TargetBuyersObj == 'ASC')? 'DESC' : 'ASC';
       		if (isTest==false) searchQuery = SSearch_Additional.getSearchQuery(SearchTxt, ElemPerPage, 'Potential_Buyer_Investor__c', sSortDirectionComm.TargetBuyersObj);
       		else searchQuery = 'select Name from Potential_Buyer_Investor__c where Name=\''+searchStr+'\' order by Name Limit 5';
       		iElemPos.TargetBuyersObj = '';
       }
       if(sortExp=='Parent_Financial_Sponsor') {
       		sSortDirectionComm.Parent_Financial_Sponsor_Obj =(sSortDirectionComm.Parent_Financial_Sponsor_Obj == 'ASC')? 'DESC' : 'ASC';
       		if (isTest==false) searchQuery = SSearch_Additional.getSearchQuery(SearchTxt, ElemPerPage, 'Financial_Sponsors__c', sSortDirectionComm.Parent_Financial_Sponsor_Obj);
       		else searchQuery = 'select Name from Financial_Sponsors__c where Name=\''+searchStr+'\' order by Name Limit 5';
       		iElemPos.Parent_Financial_Sponsor_Obj = '';
       }
       if(sortExp=='Deal_Client_Contact') {
       		sSortDirectionComm.Deal_Client_Contact_Obj =(sSortDirectionComm.Deal_Client_Contact_Obj == 'ASC')? 'DESC' : 'ASC';
       		if (isTest==false) searchQuery = SSearch_Additional.getSearchQuery(SearchTxt, ElemPerPage, 'Project_Client_Contact__c', sSortDirectionComm.Deal_Client_Contact_Obj);
       		else searchQuery = 'select Name from Project_Client_Contact__c where Name=\''+searchStr+'\' order by Name Limit 5';
       		iElemPos.Deal_Client_Contact_Obj = '';
       }
       if(sortExp=='Deal_Team') {
       		sSortDirectionComm.Deal_Team_Obj =(sSortDirectionComm.Deal_Team_Obj == 'ASC')? 'DESC' : 'ASC';
       		if (isTest==false) searchQuery = SSearch_Additional.getSearchQuery(SearchTxt, ElemPerPage, 'Project_Resource__c', sSortDirectionComm.Deal_Team_Obj);
       		else searchQuery = 'select Name from Project_Resource__c where Name=\''+searchStr+'\' order by Name Limit 5';
       		iElemPos.Deal_Team_Obj = '';
       }
       if(sortExp=='Deal_Related_Party') {
       		sSortDirectionComm.Deal_Related_Party_Obj =(sSortDirectionComm.Deal_Related_Party_Obj == 'ASC')? 'DESC' : 'ASC';
       		if (isTest==false) searchQuery = SSearch_Additional.getSearchQuery(SearchTxt, ElemPerPage, 'Deal_Related_Parties__c', sSortDirectionComm.Deal_Related_Party_Obj);
       		else searchQuery = 'select Name from Deal_Related_Parties__c where Name=\''+searchStr+'\' order by Name Limit 5';
       		iElemPos.Deal_Related_Party_Obj = '';
       }
       if(sortExp=='Target_Buyer_Contacts') {
       		sSortDirectionComm.Target_Buyer_Contacts_Obj =(sSortDirectionComm.Target_Buyer_Contacts_Obj == 'ASC')? 'DESC' : 'ASC';
       		if (isTest==false) searchQuery = SSearch_Additional.getSearchQuery(SearchTxt, ElemPerPage, 'Target_Buyer_Contacts__c', sSortDirectionComm.Target_Buyer_Contacts_Obj);
       		else searchQuery = 'select Name from Potential_Buyer_Investor_Contact__c where Name=\''+searchStr+'\' order by Name Limit 5';
       		iElemPos.Target_Buyer_Contacts_Obj = '';
       }
       if(sortExp=='Moelis_Employee_Relationship') {
       		sSortDirectionComm.Moelis_Employee_Relationship_Obj =(sSortDirectionComm.Moelis_Employee_Relationship_Obj == 'ASC')? 'DESC' : 'ASC';
       		if (isTest==false) searchQuery = SSearch_Additional.getSearchQuery(SearchTxt, ElemPerPage, 'Employee_Relationships__c', sSortDirectionComm.Moelis_Employee_Relationship_Obj);
       		else searchQuery = 'select Name from Employee_Relationships__c where Name=\''+searchStr+'\' order by Name Limit 5';
       		iElemPos.Moelis_Employee_Relationship_Obj = '';
       }
       
       if (isTest == false) initList();
       return null;
   }
   
	public String PagindDirection{ set; get;}  

	// ************** View Paging Data function (wery long) ****************** //
	// Function start when press next or previous button                       //
	// fter performing the function called initList() function                 //
	
	public PageReference ViewPagingData() { /* START ViewPagingData() FUNCTION*/
		///////////////////////////////////////// TargetBuyers /////////////////////////////////////////
		if(sortExp=='TargetBuyers') {
			if(PagindDirection=='Next') {
				List<Potential_Buyer_Investor__c> tmp = [select ID,Name from Potential_Buyer_Investor__c where id=:sLastElemID.TargetBuyersObj limit 1];
				Potential_Buyer_Investor__c CurObj = new Potential_Buyer_Investor__c();
				if (tmp.size() > 0) {
					CurObj = tmp[0];
				}
				searchQuery = SSearch_Additional.getSearchQueryWhere(SearchTxt, ElemPerPage, 'Potential_Buyer_Investor__c', sSortDirectionComm.TargetBuyersObj, CurObj.Name, CurObj.ID);
			}
			if(PagindDirection=='Prev') {
				String sddSQL = '';
				String sQuery = '';
				List<List<SObject>> searchListTmp1;
				List<Potential_Buyer_Investor__c> tmp = [select ID,Name from Potential_Buyer_Investor__c where id=:sFirstElemID.TargetBuyersObj limit 1];
				Potential_Buyer_Investor__c CurObj = new Potential_Buyer_Investor__c();
				if (tmp.size() > 0) {
					CurObj = tmp[0];
				} 
				if (isTest==false) {
					sQuery = 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING Potential_Buyer_Investor__c('+TargetBuyersFldList+' where Name'+(sSortDirectionComm.TargetBuyersObj=='DESC'?'>':'<')+'=\''+CurObj.Name+'\' and ID not in (\''+CurObj.ID+'\') order by Name '+(sSortDirectionComm.TargetBuyersObj=='DESC'?'ASC':'DESC')+' Limit '+ElemPerPage+')';
					searchListTmp1 = search.query(sQuery);
				} else { 
					sQuery = 'select Name from Potential_Buyer_Investor__c where Name=\''+searchStr+'\' order by Name Limit 5';
					searchListTmp1 = new List<List<Sobject>>();
					searchListTmp1.add(database.query(sQuery));
				}
				
				List<Potential_Buyer_Investor__c> lObjsTmp1 = (List<Potential_Buyer_Investor__c>)searchListTmp1[0];
				
				for(Potential_Buyer_Investor__c tmpObj : lObjsTmp1){ sddSQL += ',\''+tmpObj.ID+'\'';}
				sddSQL = '\''+CurObj.ID + '\'' + sddSQL;
				if (isTest==false) {
					searchQuery = SSearch_Additional.getSearchQueryWhereIn(SearchTxt, ElemPerPage, 'Potential_Buyer_Investor__c', sSortDirectionComm.TargetBuyersObj, sddSQL);
				} else {
					searchQuery = 'select Name from Potential_Buyer_Investor__c where Name=\''+searchStr+'\' order by Name Limit 5';
				}
			}
			
			integer CurTmpObjPos = iElemPos.TargetBuyersObj!=''?integer.valueOf(iElemPos.TargetBuyersObj):0;
			iElemPos.TargetBuyersObj = PagindDirection=='Next'?''+(CurTmpObjPos + ElemPerPage):(CurTmpObjPos>ElemPerPage?''+(CurTmpObjPos - ElemPerPage):'0');
		}

		///////////////////////////////////////// Employee /////////////////////////////////////////
		if(sortExp=='Employee') {
			if(PagindDirection=='Next') {
				Employee_Profile__c CurObj = [select ID,Name from Employee_Profile__c where id=:sLastElemID.EmployeeObj limit 1];
				searchQuery = SSearch_Additional.getSearchQueryWhere(SearchTxt, ElemPerPage, 'Employee_Profile__c', sSortDirectionComm.EmployeeObj, CurObj.Name, CurObj.ID);
			}
			if(PagindDirection=='Prev') {
				String sddSQL = '';
				String sQuery = '';
				List<List<SObject>> searchListTmp1;
				Employee_Profile__c CurObj = [select ID,Name from Employee_Profile__c where id=:sFirstElemID.EmployeeObj limit 1];
				if (isTest==false) {
					sQuery = 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING Employee_Profile__c('+EmployeeFldList+' where Name'+(sSortDirectionComm.EmployeeObj=='DESC'?'>':'<')+'=\''+CurObj.Name+'\' and ID not in (\''+CurObj.ID+'\') order by Name '+(sSortDirectionComm.EmployeeObj=='DESC'?'ASC':'DESC')+' Limit '+ElemPerPage+')';
					searchListTmp1 = search.query(sQuery);
				} else {
					sQuery = 'select Name from Employee_Profile__c where Name=\''+searchStr+'\' order by Name Limit 5';
					searchListTmp1 = new List<List<Sobject>>();
					searchListTmp1.add(database.query(sQuery));
				}
				
				List<Employee_Profile__c> lObjsTmp1 = (List<Employee_Profile__c>)searchListTmp1[0];
				
				for(Employee_Profile__c tmpObj : lObjsTmp1){ sddSQL += ',\''+tmpObj.ID+'\'';}
				sddSQL = '\''+CurObj.ID + '\'' + sddSQL;
				if (isTest==false) {
					searchQuery = SSearch_Additional.getSearchQueryWhereIn(SearchTxt, ElemPerPage, 'Employee_Profile__c', sSortDirectionComm.EmployeeObj, sddSQL);
				} else {
					searchQuery = 'select Name from Employee_Profile__c where Name=\''+searchStr+'\' order by Name Limit 5';
				}
			}
			
			integer CurTmpObjPos = iElemPos.EmployeeObj!=''?integer.valueOf(iElemPos.EmployeeObj):0;
			iElemPos.EmployeeObj = PagindDirection=='Next'?''+(CurTmpObjPos + ElemPerPage):(CurTmpObjPos>ElemPerPage?''+(CurTmpObjPos - ElemPerPage):'0');
		}

		///////////////////////////////////////// Deal /////////////////////////////////////////
		if(sortExp=='Deal') {
			if(PagindDirection=='Next') {
				Ibanking_Project__c CurObj = null;
				for(Ibanking_Project__c tmpCurObj : [select ID,Name from Ibanking_Project__c where id=:sLastElemID.DealObj limit 1]){ CurObj = tmpCurObj;}
				if(CurObj==null) return null;
				searchQuery = SSearch_Additional.getSearchQueryWhere(SearchTxt, ElemPerPage, 'Ibanking_Project__c', sSortDirectionComm.DealObj, CurObj.Name, CurObj.ID);
			}
			if(PagindDirection=='Prev') {
				String sddSQL = '';
				String sQuery = '';
				List<List<SObject>> searchListTmp1;
				
				if(sFirstElemID==null || sFirstElemID.DealObj==null) return null;
				Ibanking_Project__c CurObj = null;
				for(Ibanking_Project__c tmpCurObj : [select ID,Name from Ibanking_Project__c where id=:sFirstElemID.DealObj limit 1]){ CurObj = tmpCurObj;}
				if(CurObj==null) return null;
				
				if (isTest==false) {
					sQuery = 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING Ibanking_Project__c('+DealFldList+' where Name'+(sSortDirectionComm.DealObj=='DESC'?'>':'<')+'=\''+CurObj.Name+'\' and ID not in (\''+CurObj.ID+'\') order by Name '+(sSortDirectionComm.DealObj=='DESC'?'ASC':'DESC')+' Limit '+ElemPerPage+')';
					searchListTmp1 = search.query(sQuery);
				} else {
					sQuery = 'select Name from Ibanking_Project__c where Name=\''+searchStr+'\' order by Name Limit 5';
					searchListTmp1 = new List<List<Sobject>>();
					searchListTmp1.add(database.query(sQuery));
				}
				
				List<Ibanking_Project__c> lObjsTmp1 = (List<Ibanking_Project__c>)searchListTmp1[0];
				
				for(Ibanking_Project__c tmpObj : lObjsTmp1){ sddSQL += ',\''+tmpObj.ID+'\'';}
				sddSQL = '\''+CurObj.ID + '\'' + sddSQL;
				if (isTest==false) {
					searchQuery = SSearch_Additional.getSearchQueryWhereIn(SearchTxt, ElemPerPage, 'Ibanking_Project__c', sSortDirectionComm.DealObj, sddSQL);
				} else {
					searchQuery = 'select Name from Ibanking_Project__c where Name=\''+searchStr+'\' order by Name Limit 5';
				}
			}
			integer CurTmpObjPos = iElemPos.DealObj!=''?integer.valueOf(iElemPos.DealObj):0;
			iElemPos.DealObj = PagindDirection=='Next'?''+(CurTmpObjPos + ElemPerPage):(CurTmpObjPos>ElemPerPage?''+(CurTmpObjPos - ElemPerPage):'0');
		}

		///////////////////////////////////////// Contact /////////////////////////////////////////
		if(sortExp=='Contact') {
			if(PagindDirection=='Next') {
				Contact CurObj = null;
				for(Contact tmpCurObj : [select ID,Name from Contact where id=:sLastElemID.ContactObj limit 1]){ CurObj = tmpCurObj;}
				if(CurObj==null) return null;
				searchQuery = SSearch_Additional.getSearchQueryWhere(SearchTxt, ElemPerPage, 'Contact', sSortDirectionComm.ContactObj, CurObj.Name, CurObj.ID);
			
			}
			if(PagindDirection=='Prev') {
				String sddSQL = '';
				String sQuery = '';
				List<List<SObject>> searchListTmp1;

				if(sFirstElemID==null || sFirstElemID.ContactObj==null) return null;
				Contact CurObj = null;
				for(Contact tmpCurObj : [select ID,Name from Contact where id=:sFirstElemID.ContactObj limit 1]){ CurObj = tmpCurObj;}
				if(CurObj==null) return null;

				if (isTest==false) {
					sQuery = 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING Contact('+ContactFldList+' where Name'+(sSortDirectionComm.ContactObj=='DESC'?'>':'<')+'=\''+CurObj.Name+'\' and ID not in (\''+CurObj.ID+'\') order by Name '+(sSortDirectionComm.ContactObj=='DESC'?'ASC':'DESC')+' Limit '+ElemPerPage+')';
					searchListTmp1 = search.query(sQuery);
				} else {
					sQuery = 'select FirstName from Contact where FirstName=\''+searchStr+'\' order by Name Limit 5';
					searchListTmp1 = new List<List<Sobject>>();
					searchListTmp1.add(database.query(sQuery));
				}
				
				List<Contact> lObjsTmp1 = (List<Contact>)searchListTmp1[0];
				
				for(Contact tmpObj : lObjsTmp1){ sddSQL += ',\''+tmpObj.ID+'\'';}
				sddSQL = '\''+CurObj.ID + '\'' + sddSQL;
				if (isTest==false) {
					searchQuery = SSearch_Additional.getSearchQueryWhereIn(SearchTxt, ElemPerPage, 'Contact', sSortDirectionComm.ContactObj, sddSQL);
				} else {
					searchQuery = 'select FirstName from Contact where FirstName=\''+searchStr+'\' order by Name Limit 5';
				}
			}
			integer CurTmpObjPos = iElemPos.ContactObj!=''?integer.valueOf(iElemPos.ContactObj):0;
			iElemPos.ContactObj = PagindDirection=='Next'?''+(CurTmpObjPos + ElemPerPage):(CurTmpObjPos>ElemPerPage?''+(CurTmpObjPos - ElemPerPage):'0');
		}

		///////////////////////////////////////// Account /////////////////////////////////////////
		if(sortExp=='Account') {
			if(PagindDirection=='Next') {
				Account CurObj = null;
				for(Account tmpCurObj : [select ID,Name from Account where id=:sLastElemID.AccountObj limit 1]){
					CurObj = tmpCurObj;
				}
				if(CurObj==null) return null;
				searchQuery = SSearch_Additional.getSearchQueryWhere(SearchTxt, ElemPerPage, 'Account', sSortDirectionComm.AccountObj, CurObj.Name, CurObj.ID);
			}
			if(PagindDirection=='Prev') {
				String sddSQL = '';
				String sQuery = '';
				List<List<SObject>> searchListTmp1;

				if(sFirstElemID==null || sFirstElemID.AccountObj==null) return null;
				Account CurObj = null;
				for(Account tmpCurObj : [select ID,Name from Account where id=:sFirstElemID.AccountObj limit 1]){ CurObj = tmpCurObj;}
				if(CurObj==null) return null;

				if (isTest==false) {
					sQuery = 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING Account('+AccountFldList+' where Name'+(sSortDirectionComm.AccountObj=='DESC'?'>':'<')+'=\''+CurObj.Name+'\' and ID not in (\''+CurObj.ID+'\') order by Name '+(sSortDirectionComm.AccountObj=='DESC'?'ASC':'DESC')+' Limit '+ElemPerPage+')';
					searchListTmp1 = search.query(sQuery);
				} else {
					sQuery = 'select Name from Account where Name=\''+searchStr+'\' order by Name Limit 5';
					searchListTmp1 = new List<List<Sobject>>();
					searchListTmp1.add(database.query(sQuery));
				}

				List<Account> lObjsTmp1 = (List<Account>)searchListTmp1[0];
				
				for(Account tmpObj : lObjsTmp1){ 
					sddSQL += ',\''+tmpObj.ID+'\'';
				}
				sddSQL = '\''+CurObj.ID + '\'' + sddSQL;
				if (isTest==false) {
					searchQuery = SSearch_Additional.getSearchQueryWhereIn(SearchTxt, ElemPerPage, 'Account', sSortDirectionComm.AccountObj, sddSQL);
				} else {
					searchQuery = 'select Name from Account where Name=\''+searchStr+'\' order by Name Limit 5';
				}
			}
			integer CurTmpObjPos = iElemPos.AccountObj!=''?integer.valueOf(iElemPos.AccountObj):0;
			iElemPos.AccountObj = PagindDirection=='Next'?''+(CurTmpObjPos + ElemPerPage):(CurTmpObjPos>ElemPerPage?''+(CurTmpObjPos - ElemPerPage):'0');
		}

		///////////////////////////////////////// Parent_Financial_Sponsor ///////////////////////////////////////// Financial_Sponsors__c
		if(sortExp=='Parent_Financial_Sponsor') {
			if(PagindDirection=='Next') {
				List<Financial_Sponsors__c> tmp = [select ID,Name from Financial_Sponsors__c where id=:sLastElemID.Parent_Financial_Sponsor_Obj limit 1];
				Financial_Sponsors__c CurObj = new Financial_Sponsors__c();
				if (tmp.size() > 0) {
					CurObj = tmp[0];
				}
				searchQuery = SSearch_Additional.getSearchQueryWhere(SearchTxt, ElemPerPage, 'Financial_Sponsors__c', sSortDirectionComm.Parent_Financial_Sponsor_Obj, CurObj.Name, CurObj.ID);
			}
			if(PagindDirection=='Prev') {
				String sddSQL = '';
				String sQuery = '';
				List<List<SObject>> searchListTmp1;
				List<Financial_Sponsors__c> tmp = [select ID,Name from Financial_Sponsors__c where id=:sFirstElemID.Parent_Financial_Sponsor_Obj limit 1];
				Financial_Sponsors__c CurObj = new Financial_Sponsors__c();
				if (tmp.size() > 0) {
					CurObj = tmp[0];
				}
				if (isTest==false) {
					sQuery = 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING Financial_Sponsors__c('+Parent_Financial_Sponsor_FldList+' where Name'+(sSortDirectionComm.Parent_Financial_Sponsor_Obj=='DESC'?'>':'<')+'=\''+CurObj.Name+'\' and ID not in (\''+CurObj.ID+'\') order by Name '+(sSortDirectionComm.Parent_Financial_Sponsor_Obj=='DESC'?'ASC':'DESC')+' Limit '+ElemPerPage+')';
					searchListTmp1 = search.query(sQuery);
				} else {
					sQuery = 'select Name from Financial_Sponsors__c where Name=\''+searchStr+'\' order by Name Limit 5';
					searchListTmp1 = new List<List<Sobject>>();
					searchListTmp1.add(database.query(sQuery));
				}
				
				List<Financial_Sponsors__c> lObjsTmp1 = (List<Financial_Sponsors__c>)searchListTmp1[0];
				
				for(Financial_Sponsors__c tmpObj : lObjsTmp1){ sddSQL += ',\''+tmpObj.ID+'\'';}
				sddSQL = '\''+CurObj.ID + '\'' + sddSQL;
				if (isTest==false) {
					searchQuery = SSearch_Additional.getSearchQueryWhereIn(SearchTxt, ElemPerPage, 'Financial_Sponsors__c', sSortDirectionComm.Parent_Financial_Sponsor_Obj, sddSQL);
				} else {
					searchQuery = 'select Name from Financial_Sponsors__c where Name=\''+searchStr+'\' order by Name Limit 5';
				}
			}
			integer CurTmpObjPos = iElemPos.Parent_Financial_Sponsor_Obj!=''?integer.valueOf(iElemPos.Parent_Financial_Sponsor_Obj):0;
			iElemPos.Parent_Financial_Sponsor_Obj = PagindDirection=='Next'?''+(CurTmpObjPos + ElemPerPage):(CurTmpObjPos>ElemPerPage?''+(CurTmpObjPos - ElemPerPage):'0');
		}

		///////////////////////////////////////// Deal_Client_Contact ///////////////////////////////////////// Project_Client_Contact__c
		if(sortExp=='Deal_Client_Contact') {
			if(PagindDirection=='Next') {
				List<Project_Client_Contact__c> tmp = [select ID,Name from Project_Client_Contact__c where id=:sLastElemID.Deal_Client_Contact_Obj limit 1];
				Project_Client_Contact__c CurObj = new Project_Client_Contact__c();
				if (tmp.size() > 0) {
					CurObj = tmp[0];
				}
				searchQuery = SSearch_Additional.getSearchQueryWhere(SearchTxt, ElemPerPage, 'Project_Client_Contact__c', sSortDirectionComm.Deal_Client_Contact_Obj, CurObj.Name, CurObj.ID);
			}
			if(PagindDirection=='Prev') {
				String sddSQL = '';
				String sQuery = '';
				List<List<SObject>> searchListTmp1;
				List<Project_Client_Contact__c> tmp = [select ID,Name from Project_Client_Contact__c where id=:sFirstElemID.Deal_Client_Contact_Obj limit 1];
				Project_Client_Contact__c CurObj = new Project_Client_Contact__c();
				if (tmp.size() > 0) {
					CurObj = tmp[0];
				}
				if (isTest==false) {
					//sQuery = 'FIND {'+SearchTxt+'} IN ALL FIELDS RETURNING Project_Client_Contact__c('+Deal_Client_Contact_FldList+' where Name'+(sSortDirectionComm.Deal_Client_Contact_Obj=='DESC'?'>':'<')+'=\''+CurObj.Name+'\' and ID not in (\''+CurObj.ID+'\') order by Name '+(sSortDirectionComm.Deal_Client_Contact_Obj=='DESC'?'ASC':'DESC')+' Limit '+ElemPerPage+')';
					sQuery = 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING Project_Client_Contact__c('+Deal_Client_Contact_FldList+' where Name'+(sSortDirectionComm.Deal_Client_Contact_Obj=='DESC'?'>':'<')+'=\''+CurObj.Name+'\' and ID not in (\''+CurObj.ID+'\') order by Name '+(sSortDirectionComm.Deal_Client_Contact_Obj=='DESC'?'ASC':'DESC')+' Limit '+ElemPerPage+')';
					searchListTmp1 = search.query(sQuery);
				} else {
					sQuery = 'select Name from Project_Client_Contact__c where Name=\''+searchStr+'\' order by Name Limit 5';
					searchListTmp1 = new List<List<Sobject>>();
					searchListTmp1.add(database.query(sQuery));
				}
				
				List<Project_Client_Contact__c> lObjsTmp1 = (List<Project_Client_Contact__c>)searchListTmp1[0];
				
				for(Project_Client_Contact__c tmpObj : lObjsTmp1){ sddSQL += ',\''+tmpObj.ID+'\'';}
				sddSQL = '\''+CurObj.ID + '\'' + sddSQL;
				if (isTest==false) {
					searchQuery = SSearch_Additional.getSearchQueryWhereIn(SearchTxt, ElemPerPage, 'Project_Client_Contact__c', sSortDirectionComm.Deal_Client_Contact_Obj, sddSQL);
				} else {
					searchQuery = 'select Name from Project_Client_Contact__c where Name=\''+searchStr+'\' order by Name Limit 5';
				}
			}
			integer CurTmpObjPos = iElemPos.Deal_Client_Contact_Obj!=''?integer.valueOf(iElemPos.Deal_Client_Contact_Obj):0;
			iElemPos.Deal_Client_Contact_Obj = PagindDirection=='Next'?''+(CurTmpObjPos + ElemPerPage):(CurTmpObjPos>ElemPerPage?''+(CurTmpObjPos - ElemPerPage):'0');
		}

		///////////////////////////////////////// Deal_Related_Party ///////////////////////////////////////// Deal_Related_Parties__c
		if(sortExp=='Deal_Related_Party') {
			if(PagindDirection=='Next') {
				List<Deal_Related_Parties__c> tmp = [select ID,Name from Deal_Related_Parties__c where id=:sLastElemID.Deal_Related_Party_Obj limit 1];
				Deal_Related_Parties__c CurObj = new Deal_Related_Parties__c();
				if (tmp.size() > 0) {
					CurObj = tmp[0];
				}
				searchQuery = SSearch_Additional.getSearchQueryWhere(SearchTxt, ElemPerPage, 'Deal_Related_Parties__c', sSortDirectionComm.Deal_Related_Party_Obj, CurObj.Name, CurObj.ID);
			}
			if(PagindDirection=='Prev') {
				String sddSQL = '';
				String sQuery = '';
				List<List<SObject>> searchListTmp1;
				List<Deal_Related_Parties__c> tmp = [select ID,Name from Deal_Related_Parties__c where id=:sFirstElemID.Deal_Related_Party_Obj limit 1];
				Deal_Related_Parties__c CurObj = new Deal_Related_Parties__c();
				if (tmp.size() > 0) {
					CurObj = tmp[0];
				}
				if (isTest==false) {
					sQuery = 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING Deal_Related_Parties__c('+Deal_Related_Party_FldList+' where Name'+(sSortDirectionComm.Deal_Related_Party_Obj=='DESC'?'>':'<')+'=\''+CurObj.Name+'\' and ID not in (\''+CurObj.ID+'\') order by Name '+(sSortDirectionComm.Deal_Related_Party_Obj=='DESC'?'ASC':'DESC')+' Limit '+ElemPerPage+')';
					searchListTmp1 = search.query(sQuery);
				} else {
					sQuery = 'select Name from Deal_Related_Parties__c where Name=\''+searchStr+'\' order by Name Limit 5';
					searchListTmp1 = new List<List<Sobject>>();
					searchListTmp1.add(database.query(sQuery));
				}
				
				List<Deal_Related_Parties__c> lObjsTmp1 = (List<Deal_Related_Parties__c>)searchListTmp1[0];
				
				for(Deal_Related_Parties__c tmpObj : lObjsTmp1){ sddSQL += ',\''+tmpObj.ID+'\'';}
				sddSQL = '\''+CurObj.ID + '\'' + sddSQL;
				if (isTest==false) {
					searchQuery = SSearch_Additional.getSearchQueryWhereIn(SearchTxt, ElemPerPage, 'Deal_Related_Parties__c', sSortDirectionComm.Deal_Related_Party_Obj, sddSQL);
				} else {
					searchQuery = 'select Name from Deal_Related_Parties__c where Name=\''+searchStr+'\' order by Name Limit 5';
				}
			}
			integer CurTmpObjPos = iElemPos.Deal_Related_Party_Obj!=''?integer.valueOf(iElemPos.Deal_Related_Party_Obj):0;
			iElemPos.Deal_Related_Party_Obj = PagindDirection=='Next'?''+(CurTmpObjPos + ElemPerPage):(CurTmpObjPos>ElemPerPage?''+(CurTmpObjPos - ElemPerPage):'0');
		}

		///////////////////////////////////////// Target_Buyer_Contacts ///////////////////////////////////////// Potential_Buyer_Investor_Contact__c
		if(sortExp=='Target_Buyer_Contacts') {
			if(PagindDirection=='Next') {
				List<Potential_Buyer_Investor_Contact__c> tmp = [select ID,Name from Potential_Buyer_Investor_Contact__c where id=:sLastElemID.Target_Buyer_Contacts_Obj limit 1];
				Potential_Buyer_Investor_Contact__c CurObj = new Potential_Buyer_Investor_Contact__c();
				if (tmp.size() > 0) {
					CurObj = tmp[0];
				}
				searchQuery = SSearch_Additional.getSearchQueryWhere(SearchTxt, ElemPerPage, 'Target_Buyer_Contacts__c', sSortDirectionComm.Target_Buyer_Contacts_Obj, CurObj.Name, CurObj.ID);
			}
			if(PagindDirection=='Prev') {
				String sddSQL = '';
				String sQuery = '';
				List<List<SObject>> searchListTmp1;
				List<Potential_Buyer_Investor_Contact__c> tmp = [select ID,Name from Potential_Buyer_Investor_Contact__c where id=:sFirstElemID.Target_Buyer_Contacts_Obj limit 1];
				Potential_Buyer_Investor_Contact__c CurObj = new Potential_Buyer_Investor_Contact__c();
				if (tmp.size() > 0) {
					CurObj = tmp[0];
				}
				if (isTest==false) {
					sQuery = 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING Potential_Buyer_Investor_Contact__c('+Target_Buyer_Contacts_FldList+' where Name'+(sSortDirectionComm.Target_Buyer_Contacts_Obj=='DESC'?'>':'<')+'=\''+CurObj.Name+'\' and ID not in (\''+CurObj.ID+'\') order by Name '+(sSortDirectionComm.Target_Buyer_Contacts_Obj=='DESC'?'ASC':'DESC')+' Limit '+ElemPerPage+')';
					searchListTmp1 = search.query(sQuery);
				} else {
					sQuery = 'select Name from Potential_Buyer_Investor_Contact__c where Name=\''+searchStr+'\' order by Name Limit 5';
					searchListTmp1 = new List<List<Sobject>>();
					searchListTmp1.add(database.query(sQuery));
				}
				
				List<Potential_Buyer_Investor_Contact__c> lObjsTmp1 = (List<Potential_Buyer_Investor_Contact__c>)searchListTmp1[0];
				
				for(Potential_Buyer_Investor_Contact__c tmpObj : lObjsTmp1){ sddSQL += ',\''+tmpObj.ID+'\'';}
				sddSQL = '\''+CurObj.ID + '\'' + sddSQL;
				if (isTest==false) {
					searchQuery = SSearch_Additional.getSearchQueryWhereIn(SearchTxt, ElemPerPage, 'Target_Buyer_Contacts__c', sSortDirectionComm.Target_Buyer_Contacts_Obj, sddSQL);
				} else {
					searchQuery = 'select Name from Potential_Buyer_Investor_Contact__c where Name=\''+searchStr+'\' order by Name Limit 5';
				}
			}
			integer CurTmpObjPos = iElemPos.Target_Buyer_Contacts_Obj!=''?integer.valueOf(iElemPos.Target_Buyer_Contacts_Obj):0;
			iElemPos.Target_Buyer_Contacts_Obj = PagindDirection=='Next'?''+(CurTmpObjPos + ElemPerPage):(CurTmpObjPos>ElemPerPage?''+(CurTmpObjPos - ElemPerPage):'0');
		}

		///////////////////////////////////////// Moelis_Employee_Relationship ///////////////////////////////////////// Employee_Relationships__c
		if(sortExp=='Moelis_Employee_Relationship') {
			if(PagindDirection=='Next') {
				List<Employee_Relationships__c> tmp = [select ID,Name from Employee_Relationships__c where id=:sLastElemID.Moelis_Employee_Relationship_Obj limit 1];
				Employee_Relationships__c CurObj = new Employee_Relationships__c();
				if (tmp.size() > 0) {
					CurObj = tmp[0];
				}
				searchQuery = SSearch_Additional.getSearchQueryWhere(SearchTxt, ElemPerPage, 'Employee_Relationships__c', sSortDirectionComm.Moelis_Employee_Relationship_Obj, CurObj.Name, CurObj.ID);
			}
			if(PagindDirection=='Prev') {
				String sddSQL = '';
				String sQuery = '';
				List<List<SObject>> searchListTmp1;
				List<Employee_Relationships__c> tmp = [select ID,Name from Employee_Relationships__c where id=:sFirstElemID.Moelis_Employee_Relationship_Obj limit 1];
				Employee_Relationships__c CurObj = new Employee_Relationships__c();
				if (tmp.size() > 0) {
					CurObj = tmp[0];
				}
				if (isTest==false) {
					sQuery = 'FIND \''+SearchTxt+'\' IN ALL FIELDS RETURNING Employee_Relationships__c('+Moelis_Employee_Relationship_FldList+' where Name'+(sSortDirectionComm.Moelis_Employee_Relationship_Obj=='DESC'?'>':'<')+'=\''+CurObj.Name+'\' and ID not in (\''+CurObj.ID+'\') order by Name '+(sSortDirectionComm.Moelis_Employee_Relationship_Obj=='DESC'?'ASC':'DESC')+' Limit '+ElemPerPage+')';
					searchListTmp1 = search.query(sQuery);
				} else {
					sQuery = 'select Name from Employee_Relationships__c where Name=\''+searchStr+'\' order by Name Limit 5';
					searchListTmp1 = new List<List<Sobject>>();
					searchListTmp1.add(database.query(sQuery));
				}
				
				List<Employee_Relationships__c> lObjsTmp1 = (List<Employee_Relationships__c>)searchListTmp1[0];
				
				for(Employee_Relationships__c tmpObj : lObjsTmp1){ sddSQL += ',\''+tmpObj.ID+'\'';}
				sddSQL = '\''+CurObj.ID + '\'' + sddSQL;
				if (isTest==false) {
					searchQuery = SSearch_Additional.getSearchQueryWhereIn(SearchTxt, ElemPerPage, 'Employee_Relationships__c', sSortDirectionComm.Moelis_Employee_Relationship_Obj, sddSQL);
				} else {
					searchQuery = 'select Name from Employee_Relationships__c where Name=\''+searchStr+'\' order by Name Limit 5';
				}
			}
			integer CurTmpObjPos = iElemPos.Moelis_Employee_Relationship_Obj!=''?integer.valueOf(iElemPos.Moelis_Employee_Relationship_Obj):0;
			iElemPos.Moelis_Employee_Relationship_Obj = PagindDirection=='Next'?''+(CurTmpObjPos + ElemPerPage):(CurTmpObjPos>ElemPerPage?''+(CurTmpObjPos - ElemPerPage):'0');
		} 
		
		if (isTest == false) initList();
		
		return null;
	} /* END ViewPagingData() FUNCTION*/
   

	public class CommDetailObj
	{ 
		public String AccountObj {get; set;}
		public String ContactObj {get; set;}
		public String ContactByAccountObj {get; set;}
		public String DealObj {get; set;}
		public String DealIdeaObj {get; set;}
		public String EmployeeObj {get; set;}
		public String TargetBuyersObj {get; set;}

		public String Parent_Financial_Sponsor_Obj {get;set;}
		public String Deal_Client_Contact_Obj {get;set;}
		public String Deal_Team_Obj {get;set;}
		public String Deal_Related_Party_Obj {get;set;}
		public String Target_Buyer_Contacts_Obj {get;set;}
		public String Deal_Idea_Client_Obj {get;set;}
		public String Moelis_Employee_Relationship_Obj {get;set;}
		
		public CommDetailObj()
        {
        	AccountObj = '';
        	ContactObj = '';
        	ContactByAccountObj = '';
        	DealObj = '';
        	DealIdeaObj = '';
        	EmployeeObj = '';
        	TargetBuyersObj = '';

        	Parent_Financial_Sponsor_Obj = '';
        	Deal_Client_Contact_Obj = '';
        	Deal_Team_Obj = '';
        	Deal_Related_Party_Obj = '';
        	Target_Buyer_Contacts_Obj = '';
        	Deal_Idea_Client_Obj = '';
        	Moelis_Employee_Relationship_Obj = '';
        }
	}
	
	//**********************************//
	//   Pagination by Deal Team List   //
	//**********************************//
	private Integer dealTeamCur = 1; // Number of corrent page
	private List<Project_Resource__c> dealTeamList_p = null; //Temp list to getting DealTeam list
	public List<Project_Resource__c> dealTeamList { //Getting dealTeam list
		get {
			// Transformation search string to Array of search words
			if (dealTeamList_p == null) {dealTeamList_p = new List<Project_Resource__c>();}
			String searchString = '';
			if (this.searchStr != null) {
				if (this.searchStr != '') {
					searchString = this.searchStr;
					searchString.replace('', '\n');
					searchString = searchString.replaceAll('\'', '\\\\\''); //Ecraning Escape symbols

					List<String> searchArray = searchString.split(',');
					String localQuery = 'SELECT ' + Deal_Team_FldList + ' FROM Project_Resource__c WHERE ' +
					SSearch_Additional.getWhereForSearchArray(searchArray, 'Banker__r.Name');
					localQuery += ' Limit 1000';
					dealTeamList_p = database.query(localQuery);	
				}
			}
			return dealTeamList_p;
		}
		set {
			dealTeamList_p = value;
		}
	}
	public String getDeal_Team_ListSize() {
		if(isNeedInitList) initList();
		if(searchList==null || searchList.size()==0) return '0';
		if(dealTeamList.size()>ElemPerPage) return ''+ElemPerPage+'+';
		else return ''+dealTeamList.size();
	}
	public List<Project_Resource__c> getDealTeamPage() { //Get a sublist from dealTeamList relating to curr page
		Integer first,last; //Number of first &last elements of page in list
		first = (dealTeamCur * elemPerPage - (elemPerPage-1))-1;
		if (dealTeamList.size() <= dealTeamCur*elemPerPage) {
			last = dealTeamList.size()-1;
		} else {
			last = dealTeamCur*elemPerPage - 1;
		}
		List<Project_Resource__c> tmp = new List<Project_Resource__c>(); //Sublist to current page
		for (Integer i=first; i<=last; i++) {
			tmp.add(dealTeamList[i]);
		}
		dealTeam_pos = '('+(first+1)+'-'+(last+1)+')'; //Create a plural title of pagign position
		return tmp;
	}
	public void dealTeam_next() { //On press 'Next' button
		dealTeamCur++;
	}
	public void dealTeam_prev() { //On press 'Previous' button
		dealTeamCur--;
	}
	public String dealTeam_IsNext { //If there is a next page
		get {
			String isNext = '0';
			if (dealTeamList.size() > dealTeamCur*elemPerPage) {
				isNext = '1';
			}
			return isNext;
		}
	}
	public String dealTeam_isPrev {//If there is a previous page
		get {
			String isPrev = dealTeamCur<=1?'0':'1';
			return isPrev;
		}
	}
	public String dealTeam_pos {get;set;}
	public String dealTeam_isPaging {//If paging is present (more than one page)
		get {
			String isPaging = dealTeamList.size() > elemPerPage ? '1' : '0';
			return isPaging; 
		}
	}
	//**************** End of pagination by Deal Team List ******************//

}