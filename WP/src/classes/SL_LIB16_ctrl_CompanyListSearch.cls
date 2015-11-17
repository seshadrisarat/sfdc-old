/*
  created: Serg Brull & Vladidmir Prishlyak
*/
public virtual with sharing class SL_LIB16_ctrl_CompanyListSearch
{
 	
 	public String strClickedFromAccountOrContact {get;set;}
 	
 	public Boolean isEmployee	{get;set;}
    public Boolean hasSearched {get; set;}
    public Integer tickTableRows {get; set;}
    public String Query {get; set;}
    public Set<ID> curSelIDsSet;
    public Boolean isOnLoad{get;set;}
    
    public String SearchParam {get; set;}
    public String SearchQ {get; set;}
    public String SearchObj {get; set;}
    public String SearchSection {get; set;}
    public Boolean isReadWriteAccess{get;set;}
    public String listId{get;set;}
    public List<CompanyExtend> lstWrapper{get;set;}//Added by sandeep for WP-99
    /*Main*/
    public List<JSONObject> m_target_object_fields_list_company;
    public List<JSONObject> m_target_object_fields_list_Contact;
    public SL_LIB16_FilterSOQLCompiler m_filters = new SL_LIB16_FilterSOQLCompiler();
    protected SL_LIB16_ME_DescribeObject_Core m_describe_object_core = null;
    protected List<CompanyExtend> m_companies {get; set;}
    public Company_List_Member__c addCLObj { get; set; }
    public Blob csvContentFile { get; set; }
    public String csvNameFile { get; set; }
    // using to switch search result in the VF page
    public Boolean isAccount {get;set;}
    public Boolean isAccountAndContact {get;set;}
    public Boolean isOutlookSync {get;set;} // find whether current logged-in user.contact.OutlookSync is true or false
    private String strTarget_Permanent;
    
    public SL_LIB16_ctrl_CompanyListSearch()
    {
        m_describe_object_core = SL_LIB16_ME_DescribeObject_Core.getInstance();
        m_target_object_fields_list_company = new List<JSONObject>();
        m_target_object_fields_list_Contact = new List<JSONObject>();
        lstWrapper = new List<CompanyExtend>();
        addCLObj = new Company_List_Member__c();
        tickTableRows = 30;
        Query = '';
        listId = '';
        hasSearched = false;
        isEmployee = false;
        SearchSection='F';
        curSelIDsSet = new Set<ID>();
        isAccount = true;
        isAccountAndContact = isOutlookSync = false;
        isReadWriteAccess = false;
        strTarget_Permanent = '';
        isOnLoad = false;
        strClickedFromAccountOrContact = '';
        
        fetchUserContactDetail();
	}
	
	/*This is added by Sandeep to check whether a user is having read/write access on this list or not.*/
	public PageReference checkUserPermission()
	{
		listId = Apexpages.currentPage().getParameters().get('clid');
		Set<Id> setGroupIds = new Set<Id>();
       	String accessLevel = '';
       	String ownerId= '';
       	for(Company_List__c sobj : [Select Id, OwnerId from Company_List__c where Id =:listId])
       	{
       		ownerId = sobj.OwnerId;
       	}
       	
       	for(Group objGroup : [Select Id, Type from Group where Type =:'Organization'])
       	{
       		setGroupIds.add(objGroup.Id);
       	}
       	
		/*This is to query group id if user exist in any group.*/       
        for(GroupMember objGroupMember : [Select UserOrGroupId, Id, GroupId From GroupMember where UserOrGroupId =: UserInfo.getUserId()])
        {
        	setGroupIds.add(objGroupMember.GroupId);
        }
        
		
		
		//This is to query Access permission for current user on selected list
	    for(Company_List__Share objShareObject :[Select Id, ParentId, AccessLevel, UserOrGroupId  
	    										From Company_List__Share
	    										Where ParentId =:listId
	    										AND (UserOrGroupId =: UserInfo.getUserId()
	    										OR UserOrGroupId =:setGroupIds)
	    										
        										])
        {
	    	accessLevel =  objShareObject.AccessLevel;
	    	system.debug('------accessLevel-------'+accessLevel);
	    	
        }
        
        String adminProfileId;//To store admin profile Id
       
       	/*This is to get admin profile id*/
        for(Profile objProfile : [Select Id, Name from Profile where Name=:'System Administrator'])
        {
        	adminProfileId = objProfile.Id;
        }
        
        
        if(accessLevel == 'Read' )
        {
        	if(Userinfo.getProfileId()!=adminProfileId)
        	{
        		if(ownerId !=Userinfo.getUserId())
        		{
        			isReadWriteAccess = true;
        			/*PageReference pageRef = new PageReference('/' + listId);   
		            pageRef.setRedirect(true);   
		            return pageRef; */
        		}
        	}
        	
        }
		return null;
	}
	
	private void fetchUserContactDetail()
	{
		String strUserId = '';
		try
		{
			User objUser = [select Id, Related_Contact_Id__c from User where Id = :userinfo.getUserId() limit 1];
			
			if(objUser.Related_Contact_Id__c != null && String.valueOf(objUser.Related_Contact_Id__c).length()> 14)
			{
				Contact objContact = [Select Id, Outlook_Sync__c from Contact where Id = :objUser.Related_Contact_Id__c limit 1];
				// check Users contact
				if(objContact.Outlook_Sync__c)
					isOutlookSync = true;
			}
			else
				isOutlookSync = false;
		}
		catch(Exception ex)
		{
			// do nothing.
		}
		//u.Related_Contact_Id__c isOutlookSync	
	}
	
    public void setMCompanies(List<CompanyExtend> inList){ this.m_companies = inList;}
    public String CompanyListID{ get { return System.currentPageReference().getParameters().get('clid');}}
	
    private void refreshSelIDs()
    {
    	if(m_companies!=null && m_companies.size()>0)
    	{
    		for(CompanyExtend awObj:m_companies)
			{
				if(awObj.Item != Null)
				{
	            	if(awObj.checked )
	            		curSelIDsSet.add(awObj.Item.ID);
	                else 
	                	curSelIDsSet.remove(awObj.Item.ID);
				}
				else if(awObj.objContact != Null)
				{
					if(awObj.checked)
	                	curSelIDsSet.add(awObj.objContact.ID);
	                else 
	                	curSelIDsSet.remove(awObj.objContact.ID);
				}
			}
    	}
    }
    

    Company_List__c m_company_list = null;
    public Company_List__c CompanyList {
        get {
        	
            if(!isNullOrEmpty(CompanyListID)) {
            	system.debug('==============-----------121=================' + CompanyListID);
                if(m_company_list == null || CompanyListID != m_company_list.Id)
                m_company_list = [select Id, Name from Company_List__c where id=:CompanyListID limit 1];
            }
            return m_company_list;
        }
    }


    /* Sorting */
    protected String m_sort_direction = 'ASC'; 
    protected String m_sort_expresion = 'Name';
    public String sortExpression {
        get { 
            return m_sort_expresion;
        }
        set {
            /*if the column is clicked on then switch between Ascending and Descending modes*/
            if (value == m_sort_expresion) {
                m_sort_direction = (m_sort_direction == 'ASC')? 'DESC' : 'ASC';
            } else { 
                m_sort_direction = 'ASC';
            }
            m_sort_expresion = value;
        }
    }
    
    
    public String getSortDirection()
    {
        /*if not column is selected */
        if (m_sort_expresion == null || m_sort_expresion == '') return 'ASC';
        else return m_sort_direction;
    }

    public void setSortDirection(String value)
    {  
        m_sort_expresion = value;
    }
    
    
    /* instantiate the StandardSetController from a query locator*/
    public ApexPages.StandardSetController m_std_controller {get; set;}
    public ApexPages.StandardSetController m_std_controllerForContact {get; set;}
     
   /* returns a list of wrapper objects for the sObjects in the current page set*/
    public List<CompanyExtend> getAccounts() 
   	{
        m_companies = new List<CompanyExtend>();
          
        if(m_std_controller!=null) {
        	// assign the taget value which indicates whether the search is for Acccount/Contact
        	if(strTarget_Permanent == Null )
        		strTarget_Permanent = target;
        	if(strTarget_Permanent == '2' )
        	{
        		// type cast all Account records.
	            for (Account company : (List<Account>)m_std_controller.getRecords())
	            {
					m_companies.add(new CompanyExtend(company, curSelIDsSet.contains(company.ID)));
	            }
	            // this will exe only when user search from Contact list
	            if(m_std_controllerForContact != Null)
	            {
	            	// type cast all Contact records.
	            	for (Contact objContact : (List<Contact>)m_std_controllerForContact.getRecords())
		            {
						m_companies.add(new CompanyExtend(objContact, curSelIDsSet.contains(objContact.ID)));
		            }
		            
	            }
        	}
            else if(strTarget_Permanent == '1' )
            {
            	// this will exe only when user search from Account/Contact
            	if(m_std_controllerForContact == Null)
            	{
            		// type cast all Contact records.
		            for (Contact objContact : (List<Contact>)m_std_controller.getRecords())
		            {
						m_companies.add(new CompanyExtend(objContact, curSelIDsSet.contains(objContact.ID)));
		            }
            	}
	            // this will exe only when user search from Contact list
	            if(m_std_controllerForContact != Null)
	            {
	            	// type cast all Account records.
	            	for (Account company : (List<Account>)m_std_controller.getRecords())
		            {
						m_companies.add(new CompanyExtend(company, curSelIDsSet.contains(company.ID)));
		            }
		            // type cast all Contact records.
	            	for (Contact objContact : (List<Contact>)m_std_controllerForContact.getRecords())
		            {
						m_companies.add(new CompanyExtend(objContact, curSelIDsSet.contains(objContact.ID)));
		            }
		            
	            }
            }   
        }
        system.debug('====m_companies======>>>'+m_companies);
        return m_companies;
    }
     
    /* displays the selected items */
    public PageReference process() {
        for (CompanyExtend company : m_companies) {
        	system.debug('=======company=======>>>'+company);
            if (company.checked)
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, company.Item.name));
        }
        return null;
    }
    
    /*Pager*/ 
    /* indicates whether there are more records after the current page set. */
    public Boolean hasNext {
        get {
            if(m_std_controller==null ) return false;
            	
        	return m_std_controller.getHasNext();
        }
    }
     
    /* indicates whether there are more records before the current page set. */
    public Boolean hasPrevious {
        get {
            if(m_std_controller==null) return false;
                return m_std_controller.getHasPrevious();
            }
        }
     
    /* returns the page number of the current page set */
    public Integer pageNumber {
        get {
            if(m_std_controller==null) return null;
            return m_std_controller.getPageNumber();
        }
    }
        
    public Integer pageSize {
        get {
            if(m_std_controller==null) return 0;
            Integer prefix =  (Math.mod((Long)m_std_controller.getResultSize(),(Long)m_std_controller.getPageSize()) != 0)? 1 : 0;
            return  (m_std_controller.getResultSize() / m_std_controller.getPageSize())+prefix;
        }
    }
     
    /* returns the first page of records */
    public void first()
    {
        if(m_std_controller!=null)
        {
        	refreshSelIDs();
        	m_std_controller.first();
        }
    }
     
    /* returns the last page of records */
    public void last()
    {
        if(m_std_controller!=null)
        {
        	refreshSelIDs();
        	m_std_controller.last();
        }
    }
     
    /* returns the previous page of records */
    public void previous() {
        if(m_std_controller!=null)
        {
        	refreshSelIDs();
        	m_std_controller.previous();
        }
    }
     
    /* returns the next page of records */
    public void next() {
        if(m_std_controller!=null)
        {
        	refreshSelIDs();
        	m_std_controller.next();
        }
    }
     
    /* returns the PageReference of the original page, if known, or the home page. */
    public void cancel() {
            if(m_std_controller!=null)
            {
            	curSelIDsSet.clear();
            	m_std_controller.cancel();
            }
    }   
    
    /* add to this Company List */
    public PageReference doAdd()
    {
    	   
            refreshSelIDs();
            system.debug('====curSelIDsSet=========>>>'+curSelIDsSet);
            if(curSelIDsSet.size()>0)
            {
            	List<Company_List_Member__c> list2Insert = new List<Company_List_Member__c>();
				Company_List_Member__c tmpCLObj = null;
				
				for(ID itemID:curSelIDsSet)
                {
                	if(strTarget_Permanent == '2' && String.valueOf(itemID).substring(0,3) == '001')
                	{
						tmpCLObj = new Company_List_Member__c();
						tmpCLObj.Company__c = itemID;
	                    tmpCLObj.Company_List__c = CompanyList.ID;
	                    list2Insert.add(tmpCLObj);
                	}
                	else if(strTarget_Permanent =='1' && String.valueOf(itemID).substring(0,3) == '003')
                	{
                		tmpCLObj = new Company_List_Member__c();
						tmpCLObj.Contact__c = itemID;
	                    tmpCLObj.Company_List__c = CompanyList.ID;
	                    list2Insert.add(tmpCLObj);
                	}
                	else if(String.valueOf(itemID).substring(0,3) == '001')
                	{
                		tmpCLObj = new Company_List_Member__c();
						tmpCLObj.Company__c = itemID;
	                    tmpCLObj.Company_List__c = CompanyList.ID;
	                    list2Insert.add(tmpCLObj);
                	}
                	else if(String.valueOf(itemID).substring(0,3) == '003')	
                	{
                		tmpCLObj = new Company_List_Member__c();
						tmpCLObj.Contact__c = itemID;
	                    tmpCLObj.Company_List__c = CompanyList.ID;
	                    list2Insert.add(tmpCLObj);
                	}
                }
                
                curSelIDsSet.clear();
                system.debug('====list2Insert=========>>>'+list2Insert);
                if(list2Insert.size()>0) insert list2Insert;
            }
            
            PageReference pageRef = new PageReference('/' + CompanyListID);   
            pageRef.setRedirect(true);   
            return pageRef;         
            
            
            /* System.debug('--------------- '+accounts); */
            /* return null; */
    }
    
    /* Added by sandeep - add to this Company List */
    public PageReference doAddCompanyContact()
    {
    	List<Company_List_Member__c> list2Insert = new List<Company_List_Member__c>();
		Company_List_Member__c tmpCLObj = null;
		Boolean isAnyChecked = false;
    	for(CompanyExtend sObjCE : lstWrapper)
    	{
    		if(sObjCE.Checked == true)
    		{
    			isAnyChecked=true;
    			if(sObjCE.Item !=null)
    			{
    				tmpCLObj = new Company_List_Member__c();
    				tmpCLObj.Company__c = sObjCE.Item.Id;
    				tmpCLObj.Company_List__c = CompanyList.ID;
    				list2Insert.add(tmpCLObj);
    			}
    			else if(sObjCE.objContact !=null)
    			{
    				tmpCLObj = new Company_List_Member__c();
    				tmpCLObj.Contact__c = sObjCE.objContact.Id;
    				tmpCLObj.Company_List__c = CompanyList.ID;
    				list2Insert.add(tmpCLObj);
    			}
    		}
    	}
    	system.debug('===============list2Insert======================' + list2Insert);
    	if(list2Insert.size()>0) insert list2Insert;
    	PageReference pageRef = new PageReference('/' + CompanyListID);   
        pageRef.setRedirect(true);  
        return pageRef;  
    }
    
    public PageReference doAddContinue() {
        csvContentFile = null;
        doAdd();
        doSearch();
        return null;    
    }
    
    /*This is added by sandeep- to add contact and company*/
    public PageReference doAddContactCompanyContinue() {
    	csvContentFile = null;
    	system.debug('------1-----');
        doAddCompanyContact();
        doSearch();
        return null;    
    }
    
    public PageReference clSearch()
    {
        hasSearched = true;
        m_companies = new List<CompanyExtend>();
        m_std_controller = null;
        
        listToUpdateAccountIds = new Set<Id>();
        csvContentFile = null;
        return null;
    }
    
    private Set<Id> listToUpdateAccountIds = new Set<Id>();
    
    public List<SearchColumns__c> aSearchColumns
    {
    	get
    	{
    		Map<Integer, SearchColumns__c> aColumns = new Map<Integer, SearchColumns__c>();
    		for ( SearchColumns__c oItem : SearchColumns__c.getAll().values())
    		{
    			if(oItem.ObjectName__c=='Account'){ aColumns.put( (Integer)oItem.Order__c, oItem );}
    		}
    		
    		Integer nMaxOrder = 0;
    		for ( Integer nKey : aColumns.keySet())
    		{
    			if ( nKey > nMaxOrder ){ nMaxOrder = nKey;}
    		}
    		
    		List<SearchColumns__c> aResult = new List<SearchColumns__c>();
    		
    		for ( Integer nI = 0; nI <= nMaxOrder; nI++ )
    		{
    			if ( aColumns.containsKey( nI ) ){ aResult.add( aColumns.get( nI ) );}
    		}
    		
    		return aResult;
    	}
    }
    /*start - add by sathya WP-98, have created a custom setting for columns displayed in contact search*/
    public List<ContactSearchColumns__c> lstContactSearchColumns
    {
    	get
    	{
    		Map<Integer, ContactSearchColumns__c> aColumns = new Map<Integer, ContactSearchColumns__c>();
    		for (ContactSearchColumns__c objContactFields : ContactSearchColumns__c.getAll().values())
    		{
    			if(objContactFields.ObjectName__c=='Contact'){ aColumns.put( (Integer)objContactFields.Order__c, objContactFields );}
    		}
    		
    		Integer nMaxOrder = 0;
    		for ( Integer nKey : aColumns.keySet())
    		{
    			if ( nKey > nMaxOrder ){ nMaxOrder = nKey;}
    		}
    		
    		List<ContactSearchColumns__c> aResult = new List<ContactSearchColumns__c>();
    		
    		for ( Integer nI = 0; nI <= nMaxOrder; nI++ )
    		{
    			if ( aColumns.containsKey( nI ) ){ aResult.add( aColumns.get( nI ) );}
    		}
    		
    		return aResult;
    	}
    }
    /*Stop*/
    
    
    
    /*This method is added by sandeep toc calculate pagination metrics*/
    public void calculatePaginationMetrics()
    {
    	
        FirstPage = 0;            // first row number in the list.
	    CurrentPageSize = 20;     // number of rows per page. 
	    TotalRows = lstWrapper.size();
	    LastPage = Math.mod(TotalRows, CurrentPageSize) == 0 ? TotalRows / CurrentPageSize : TotalRows / CurrentPageSize + 1;    // row index of the first record in the last page
    }
    
    /*This method is added by sandeep*/
    public void updateIECheckbox()
    {
    	isEmployee = !isEmployee;
    	system.debug('==================isEmployee=============+'+isEmployee);
    }
    
    
    /*  Search block for Selected Deal in the bottom Lookup */
    /*  Search from Company List */
    public PageReference doSearch() 
    {
    		isOnLoad = true;
            m_companies = new List<CompanyExtend>();
            lstWrapper = new List<CompanyExtend>();
            m_std_controller = null;
            String sNames = '';
            
            for ( SearchColumns__c oItem : aSearchColumns ) {
            	sNames += oItem.Name + ', ';
            }
			if ( sNames.length() > 0 ) {
				sNames = sNames.substring( 0, sNames.length() - 2 );
			} else {
				sNames = 'Name';
			}
			
            // this if will populate the target value (Account/Contact), once select few record and add it, then page needs to re-load and populate remining records 
            if(target != Null)
            	strTarget_Permanent = target;
            	
            if(addCLObj!=null && addCLObj.Company_List__c!=null && SearchSection == 'CL')
            {
            	isAccountAndContact = true;
            	system.debug('----sNames-------'+sNames);
            	system.debug('=====insidd=e first search as expected=====>>>');
            	system.debug('----CL------');
                hasSearched = true;
                string sortFullExp = m_sort_expresion  + ' ' + m_sort_direction;
                String SQLTxt = 'Select ' + sNames + ' From Account '
                + 'where Id in (Select c.Company__c From Company_List_Member__c c where c.Company_List__c=\''+addCLObj.Company_List__c+'\') '
                + 'AND Id NOT IN (select Company__c from Company_List_Member__c where Company_List__c=\''+CompanyList.ID+'\') '
                + 'Order BY '+sortFullExp+' limit 5000';
                
                String strFieldNames = '';
        		system.debug('======lstContactSearchColumns========>>>'+lstContactSearchColumns);
        		for ( ContactSearchColumns__c oItem : lstContactSearchColumns ) {
	            	strFieldNames += oItem.Name + ', ';
	            }
				if ( strFieldNames.length() > 0 ) {
					strFieldNames = strFieldNames.substring( 0, strFieldNames.length() - 2 );
				} else {
					strFieldNames = 'Name';
				}
					String strSQL_FetchContact;
				
					strSQL_FetchContact = '';
					strSQL_FetchContact = 'Select ' + strFieldNames + ' From Contact '
	                + 'where Id in (Select c.Contact__c From Company_List_Member__c c where c.Company_List__c=\''+addCLObj.Company_List__c+'\') '
	                + 'AND Id NOT IN (select Contact__c from Company_List_Member__c where Company_List__c=\''+CompanyList.ID+'\') '
	                + 'Order BY '+sortFullExp+' limit 4000';
				
				
                
                m_std_controllerForContact = null;
                try
                {
                   // m_std_controller = new ApexPages.StandardSetController(Database.getQueryLocator(SQLTxt));
                   // m_std_controllerForContact = new ApexPages.StandardSetController(Database.getQueryLocator(strSQL_FetchContact));
                   /*This is added by sandeep to query account and contact records*/
                   for(Account sObjAcc : Database.query(SQLTxt))
                   {
                   		lstWrapper.add(new CompanyExtend(sObjAcc, false));
                   }
                   for(Contact sObjCon : Database.query(strSQL_FetchContact))
                   {
                   		lstWrapper.add(new CompanyExtend(sObjCon, false));
                   }
                   
                   system.debug('==========3=========='+lstWrapper);
                }
                catch(Exception e) {
                    m_std_controller = null;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Incorrect existing Contact List!'));
                }
            }
            /*  Search with Filter */
            else if(SearchQ!=null && SearchParam!=null && SearchSection == 'F')
            {
            	system.debug('----F------');
            	isAccount =true;
            	isAccountAndContact = false;
            	String strSQLQuery = '';
            	if(strTarget_Permanent == '2' || target == '2')
            	{
	                hasSearched = true;
	                m_filters.Initialize(SearchQ, SearchParam, TargetObject);
	                String MFilters_SOQL_VALUE = m_filters.SOQL;
	                string sortFullExp = m_sort_expresion  + ' ' + m_sort_direction;
	                String addWhere = '';
	                system.debug('==================' + MFilters_SOQL_VALUE);
	                /* trace = '{"SearchQ": "' + SearchQ + '", \n "SearchParam" :"' + SearchParam + '", \n"filter": "( ' + MFilters_SOQL_VALUE + ')"}'; */
	                /* trace = m_filters.trace; */
	                system.debug('-----------------------------------{"SearchQ": "' + SearchQ + '", \n "SearchParam" :"' + SearchParam + '", \n"filter": "( ' + MFilters_SOQL_VALUE + ')"}');
	                if(MFilters_SOQL_VALUE!=null && MFilters_SOQL_VALUE!='') addWhere = ' '+MFilters_SOQL_VALUE;
	                
	                if (addWhere==''){
	                    addWhere = ' WHERE Id NOT IN (select Company__c from Company_List_Member__c where Company_List__c=\''+CompanyList.ID+'\')';
	                }
	                else
	                {
	                    addWhere = ' WHERE (Id NOT IN (select Company__c from Company_List_Member__c where Company_List__c=\''+CompanyList.ID+'\'))'
	                             + ' AND ' 
	                             + '('+addWhere+')';
	                }
	               	// Query formation
	                strSQLQuery = 'Select ' + sNames + ' From Account '
	                +addWhere+' Order BY '+sortFullExp+' limit 9000';
	                
	                system.debug('==========strSQLQuery=========' + strSQLQuery);
            	}
            	else if(strTarget_Permanent == '1'|| target == '1')
            	{
            		isAccount = false;
            		isAccountAndContact = false;
            		sNames = '';
            		for ( ContactSearchColumns__c oItem : lstContactSearchColumns ) {
		            	sNames += oItem.Name + ', ';
		            }
		            system.debug('=======sNames======111====>>>'+sNames);
					if ( sNames.length() > 0 ) {
						sNames = sNames.substring( 0, sNames.length() - 2 );
					} else {
						sNames = 'Name';
					}
            		
            		hasSearched = true;
	                m_filters.Initialize(SearchQ, SearchParam, TargetObject);
	                
	                String MFilters_SOQL_VALUE = m_filters.SOQL;
	                string sortFullExp = m_sort_expresion  + ' ' + m_sort_direction;
	                String addWhere = '';
	                
	                /* trace = '{"SearchQ": "' + SearchQ + '", \n "SearchParam" :"' + SearchParam + '", \n"filter": "( ' + MFilters_SOQL_VALUE + ')"}'; */
	                /* trace = m_filters.trace; */
	                system.debug('-----------------------------------{"SearchQ>>>": "' + SearchQ + '", \n "SearchParam>>>>" :"' + SearchParam + '", \n"filter>>>": "( ' + MFilters_SOQL_VALUE + ')"}');
	                if(MFilters_SOQL_VALUE!=null && MFilters_SOQL_VALUE!='') addWhere = ' '+MFilters_SOQL_VALUE;
	                
	                if(isEmployee)
	                {
	                	if (addWhere==''){
	                    addWhere = ' WHERE Id NOT IN (select Contact__c from Company_List_Member__c where Company_List__c=\''+CompanyList.ID+'\')';
	                    			
	                	}
		                else
		                {
		                    addWhere = ' WHERE (Id NOT IN (select Contact__c from Company_List_Member__c where Company_List__c=\''+CompanyList.ID+'\'))'
		                             + ' AND ' 
		                             + '('+addWhere+')';
		                             
		                }
	                }
	                else
	                {
	                	if (addWhere==''){
	                    addWhere = ' WHERE Id NOT IN (select Contact__c from Company_List_Member__c where Company_List__c=\''+CompanyList.ID+'\')'
	                    			+ 'AND RecordType.Name != \'Employee\'';
	                	}
		                else
		                {
		                    addWhere = ' WHERE (Id NOT IN (select Contact__c from Company_List_Member__c where Company_List__c=\''+CompanyList.ID+'\'))'
		                             + ' AND ' 
		                             + '('+addWhere+')'
		                             + 'AND RecordType.Name != \'Employee\'';
		                }
	                }
	                
	               	// Query formation
	                strSQLQuery = 'Select Id, '+sNames+' From Contact '
	                +addWhere+' Order BY '+sortFullExp+' limit 9000';
	                
	                system.debug('=======strSQLQuery======>>>'+strSQLQuery);
            	}
				
				
                try
                {
                    /* ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'query:: ' + SQLTxt)); */
                    m_std_controller = new ApexPages.StandardSetController(Database.getQueryLocator(strSQLQuery));
                }
                catch(Exception e) {
                    m_std_controller = null;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: invalid search filter values or invalid Advanced filter.'));
                }
                system.debug('====m_std_controller====inside search==>>>'+m_std_controller);
                /*  sets the number of records in each page set */
                if(m_std_controller!=null)
                {
                    m_std_controller.setPageSize(tickTableRows);
                    m_std_controller.first();
                }
            }
            
            calculatePaginationMetrics();
            
            return null;
        } 
        
        
        
        // Sandeep(25/July/2013)
        /**** Method called if any of column headers of Company is clicked. (Do sort for Companies only and put them at first of list)   ****/
        public void doSearchForCompanies()
        {
        	String sNames = '';
            
            for ( SearchColumns__c oItem : aSearchColumns ) {
            	sNames += oItem.Name + ', ';
            }
			if ( sNames.length() > 0 ) {
				sNames = sNames.substring( 0, sNames.length() - 2 );
			} else {
				sNames = 'Name';
			}
        	
        	List<CompanyExtend> lstWrappersForLocalContacts = new List<CompanyExtend> ();
			Map<Id, CompanyExtend> mapAccIdToWrappersForLocalAccounts = new Map<Id, CompanyExtend> ();
			List<CompanyExtend> lstWrappersForAccountsToReplace = new List<CompanyExtend> ();
			
			Set<Id> setAccountIds = new Set<Id>();
			
			for(Integer i=FirstPage ; i<( totalRows < (FirstPage + currentpagesize) ? (TotalRows-1) : (FirstPage + currentpagesize) ); i++)
			{
			    // Check from where it is clicked
				if(strClickedFromAccountOrContact == 'Account')  // it is clicked from Account, so take Contacts in separate list
				{		
					if(lstWrapper[i].Item == null) // means it is Contact
					{
						lstWrappersForLocalContacts.add(lstWrapper[i]);
					}
					else // it is Account
					{
						mapAccIdToWrappersForLocalAccounts.put(lstWrapper[i].Item.Id, lstWrapper[i]);
						setAccountIds.add(lstWrapper[i].Item.Id);
					}
				}
			}
			
			
			if(mapAccIdToWrappersForLocalAccounts.keyset().isEmpty())	return;
			
			for(Account acc : Database.query('Select '+ sNames + ' FROM Account Where Id IN: setAccountIds ORDER BY ' + sortExpression + ' '+getSortDirection() + ' Nulls Last' ))
			{
				lstWrappersForAccountsToReplace.add(new CompanyExtend( acc, 	
																	   mapAccIdToWrappersForLocalAccounts.get(acc.Id).Checked)														  														  
																	  );
			}
			
			Integer positionToAppendContact = 0;
			Integer countAccount = 0;
			
			for(Integer i=FirstPage ; i< (lstWrappersForAccountsToReplace.size() + FirstPage) ; i++)
			{
				lstWrapper.remove(i);
				
				if(i >= lstWrapper.size())
				{
					lstWrapper.add(lstWrappersForAccountsToReplace[countAccount]);
				}
				else
					lstWrapper.add(i, lstWrappersForAccountsToReplace[countAccount]);
				
				positionToAppendContact = i;
				countAccount++;
			}
			
			
			Integer counterOfContact = 0;
			// Add the Contacts
			
			positionToAppendContact++;
			
			for(Integer i= (positionToAppendContact ) ; i<(positionToAppendContact + lstWrappersForLocalContacts.size()); i++)
			{
				lstWrapper.remove(i);
				if(i >= lstWrapper.size())
				{
					lstWrapper.add(new CompanyExtend( new Account(), null));
				}
				else
					lstWrapper.add(i, new CompanyExtend( new Account(), null));
					
				counterOfContact++;
			}
			
			if(!lstWrappersForLocalContacts.isEmpty())
			{
				Integer countLocalVar = 0;
				for(Integer i=(positionToAppendContact) ; i < (counterOfContact + positionToAppendContact) ; i++)
				{
					//lstWrapper.remove(i-1);
					lstWrapper.remove(i);
					if(i >= lstWrapper.size())
					{
						lstWrapper.add(lstWrappersForLocalContacts[countLocalVar]);
					}
					else
						lstWrapper.add(i, lstWrappersForLocalContacts[countLocalVar]);
					
					countLocalVar ++;
				}
			}
        	
        }
        
        
        //sandeep
        public void doSearchForContacts()
        {
        	// Get all fields of Contact for dynamic query      	
            String sNames = '';
    		for ( ContactSearchColumns__c oItem : lstContactSearchColumns ) {
            	sNames += oItem.Name + ', ';
            }
			if ( sNames.length() > 0 ) {
				sNames = sNames.substring( 0, sNames.length() - 2 );
			} else {
				sNames = 'Name';
			}
        	
        	List<CompanyExtend> lstWrappersForLocalAccounts = new List<CompanyExtend> ();
			Map<Id, CompanyExtend> mapConIdToWrappersForLocalContacts = new Map<Id, CompanyExtend> ();
			List<CompanyExtend> lstWrappersForContactsToReplace = new List<CompanyExtend> ();
			
			Set<Id> setContactIds = new Set<Id>();
			
			for(Integer i=FirstPage ; i<( totalRows < (FirstPage + currentpagesize) ? (TotalRows) : (FirstPage + currentpagesize) ); i++)
			{
			    // Check from where it is clicked
				if(strClickedFromAccountOrContact == 'Contact')  // it is clicked from Contact, so take Accounts in separate list
				{	
					
					if(lstWrapper[i].Item != null) // means it is Account
					{
						lstWrappersForLocalAccounts.add(lstWrapper[i]);
					}
					else // it is Contact
					{
						mapConIdToWrappersForLocalContacts.put(lstWrapper[i].objContact.Id, lstWrapper[i]);
						setContactIds.add(lstWrapper[i].objContact.Id);
					}
				}
			}
			
			
			if(mapConIdToWrappersForLocalContacts.keyset().isEmpty())   return;
			
			for(Contact con : Database.query('Select '+ sNames + ' FROM Contact Where Id IN: setContactIds ORDER BY ' + sortExpression + ' '+getSortDirection() + ' Nulls Last' ))
			{
				lstWrappersForContactsToReplace.add(new CompanyExtend( con, 	
																	   mapConIdToWrappersForLocalContacts.get(con.Id).Checked)														  														  
																	  );
			}
			
			Integer positionToAppendContact = 0;
			Integer countContact = 0;

			for(Integer i=FirstPage ; i< (lstWrappersForContactsToReplace.size() + FirstPage) ; i++)
			{
				lstWrapper.remove(i);
				
				if(i >= lstWrapper.size())
				{
					lstWrapper.add(lstWrappersForContactsToReplace[countContact]);
				}
				else
					lstWrapper.add(i, lstWrappersForContactsToReplace[countContact]);
				
				positionToAppendContact = i;
				countContact++;
			}
			
			
			Integer counterOfContact = 0;
			positionToAppendContact++;
			
			for(Integer i= (positionToAppendContact ) ; i<(positionToAppendContact + lstWrappersForLocalAccounts.size()); i++)
			{
				    
				lstWrapper.remove(i);
				if(i >= lstWrapper.size())
				{
					lstWrapper.add(new CompanyExtend( new Contact(), null));
				}
				else
					lstWrapper.add(i, new CompanyExtend( new Contact(), null));
					
				counterOfContact++;
			}
			
			if(!lstWrappersForLocalAccounts.isEmpty())
			{
				Integer countLocalVar = 0;
												
				for(Integer i=(positionToAppendContact) ; i < (counterOfContact + positionToAppendContact) ; i++)
				{
					lstWrapper.remove(i);
					if(i >= lstWrapper.size())
					{
						lstWrapper.add(lstWrappersForLocalAccounts[countLocalVar]);
					}
					else
						lstWrapper.add(i, lstWrappersForLocalAccounts[countLocalVar]);
						
					countLocalVar ++;
				}
			}
        }
        
        public PageReference doCancel()
        {
            PageReference pageRef = new PageReference('/' + CompanyListID);   
            pageRef.setRedirect(true);   
            return pageRef;
        }
    
        public PageReference doReset()
        {
        	system.debug('--------------------==========CompanyListID===============---------------------' + CompanyListID);
            PageReference pageRef = new PageReference('/apex/SL_LIB16_CompanyListSearch?clid=' + CompanyListID);   
            pageRef.setRedirect(true);   
            return pageRef;
        }   
    
    /*  Sergey CODE */
    String m_trace = 'trace:: ';
    public String trace {
        get {
            return m_trace; 
        }
        set {
            m_trace += value + ' | \n' ;
        }
    }
    
    public String target {
        get{
        	if(System.currentPageReference().getParameters().get('target') != Null)
        		strTarget_Permanent = System.currentPageReference().getParameters().get('target');
        		
            return System.currentPageReference().getParameters().get('target');     
        }
    }
    
    public String event {
        get{
            return System.currentPageReference().getParameters().get('event');      
        }
    }

    public String filterSet {
        get{
            return System.currentPageReference().getParameters().get('filters');        
        }
    }

    public String picklistName {
        get{
            return System.currentPageReference().getParameters().get('picklist');       
        }
    }
    
    public String JSONResponse {
        get;
        set; 
    } 
    
    public String TargetObject {
        get {
           String result = 'Account';
			if(target == '1') {
				result = 'Contact';
			} else if(target == '2') {
				result = 'Account';
			} 
			return result;	 
        }
    } 
    
    public Pagereference EventHandler()
    {
        if(event == 'load'){ eventActionLoad();}
        return null;
    } 

    protected void eventActionLoad()
    {
        /* if( m_target_object_fields_list_project.isEmpty() || m_target_object_fields_list_company.isEmpty() || m_target_object_fields_list_calllog.isEmpty()) { */
        if(m_target_object_fields_list_company.isEmpty() || m_target_object_fields_list_Contact.isEmpty()) {
                getFieldsByObject();
        } 
        if(isNullOrEmpty(picklistName) == false) {
            JSONResponse = getPicklistJson();       
        }
        /*added by Sathya as per WP-98*/
        else if(target == '2')
	        JSONResponse = getJsonFromFieldsList(m_target_object_fields_list_company);
        else if(target == '1')
        	JSONResponse = getJsonFromFieldsList(m_target_object_fields_list_Contact);
        	system.debug('============JSONResponse==========='+JSONResponse);
    }
    
    protected String getJsonFromFieldsList(List<JSONObject> p_fields_list) {
        String result = '';
        for(Integer i = 0; i < p_fields_list.size(); i++)
        {
            result += p_fields_list[i].Json;
            if(i != p_fields_list.size()-1){ result += ', ';}
        }
        return '{"fields" : [' + result + ']}';
    }
    
    
    protected List<JSONObject> sortingFields(List<JSONObject> p_list) {
        List<JSONObject> res = new List<JSONObject>();
		while (p_list.size()>0)
		{
			JSONObject mo = p_list.get(0);
			p_list.remove(0);
			integer i = 0;
			while (i<p_list.size())
			{
				if (p_list.get(i).Value < mo.Value)
				{
					p_list.add(mo);
					mo = p_list.get(i);
					p_list.remove(i);
				}
				else{ i++;}
			}
            res.add(mo);
        }
        return res; 
    }
    
    protected JSONObject getItemByNameFromList(List<JSONObject> p_list, String p_item_name) {
        JSONObject result = null;
        for(JSONObject current_object : p_list) { 
            if(current_object.Value == p_item_name) {
                result = current_object;
                break;
            }
        }
        return result;
    }

    public List<LookUpPickListValue> getLCPickListValue()
    {
        List<LookUpPickListValue> returnList = new List<LookUpPickListValue>();
        integer ccounter = 0;
        try
        { 
            if (picklistName=='recordtypeid')
            {
                String so = '';
                if(target == '1') {
					so = 'Contact';
				} else if(target == '2') {
					so = 'Account';
				}
                
                List<RecordType> rtLst = [SELECT Id, Name FROM RecordType WHERE SobjectType=:so ORDER BY Name];
                for (RecordType rt : rtLst){
                    /* if (rt.Name.indexOf('Investment ')>=0) continue; */
                    returnList.add(new LookUpPickListValue(''+ccounter,String.escapeSingleQuotes(rt.Name)));
                    ccounter++;
                }
            }
            else
            {
				/* System.debug('Target::::::::::::'+TargetObject.toLowerCase()); */
                Map<String, Schema.DescribeFieldResult> describe_result = m_describe_object_core.getDecribedFieldsByObject(TargetObject.toLowerCase());
                /* System.debug('picklistName::::::::::::'+picklistName); */
                /* System.debug('describe_result.get(picklistName)::::::::::::'+describe_result.get(picklistName)); */
                List<Schema.PicklistEntry> picklist_list = describe_result.get(picklistName).getPicklistValues();
                for( Schema.PicklistEntry picklist_value : picklist_list ) {
                    returnList.add(new LookUpPickListValue(''+ccounter,picklist_value.getValue()));
                    ccounter++;
                }
            }
        }catch(Exception e) {
            return null;
        }
        
        return returnList;
    }
    
    protected String getPicklistJson()
    {
        JSONObject item = new JSONObject();
        try { 
            if (picklistName=='recordtypeid')
            {
                String so = '';
                 if(target == '1') {
					so = 'Contact';
				} else if(target == '2') {
					so = 'Account';
				}
				
				system.debug('==============JSON PROJECT=================');
				
                List<RecordType> rtLst = [SELECT Id, Name FROM RecordType WHERE SobjectType=:so ORDER BY Name];
                for (RecordType rt : rtLst){
                    /* if (rt.Name.indexOf('Investment ')>=0) continue; */
                    item.picklistValues.add(String.escapeSingleQuotes(rt.Name));
                }
            } else {
                Map<String, Schema.DescribeFieldResult> describe_result = m_describe_object_core.getDecribedFieldsByObject(TargetObject.toLowerCase());
                List<Schema.PicklistEntry> picklist_list = describe_result.get(picklistName).getPicklistValues();
                for( Schema.PicklistEntry picklist_value : picklist_list ) {
                    item.picklistValues.add(picklist_value.getValue());
                }
            }
        }catch(Exception e) {
            return '{"error" : "' + e.getMessage() + '"}';
        }
        return '{' + item.jProperty(picklistName, item.picklistValues) + '}';
    }
    
    protected void getFieldsByObject()
    {
        Set<String> forbidFields_Account = new Set<String>{};
        Set<String> forbidFields_Contact = new Set<String>{};
        Map<String, Schema.DescribeFieldResult> describe_result = m_describe_object_core.getDecribedFieldsByObject(TargetObject.toLowerCase());
       /*=============================================================================*/
        /*------------------------------------------------------------------------------*/
        set<string> setFields = new set<string>();
        Map<String, Schema.SObjectType> GlobalDescribeMap  = new Map<String, Schema.SObjectType>(); 
        Schema.SObjectType SObjectTypeObj = Schema.getGlobalDescribe().get(TargetObject);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('Contact_List_Excluded_Fields');
        if(fieldSetObj != null)
        {
            for(Schema.FieldSetMember field : fieldSetObj.getFields())
            {
                setFields.add(field.getFieldPath());
            }
        }
        
        /*----------------------------------------------------------------------------------*/
        Map<String,JSONObject> m_target_object_fields_list_company_PreMAP = new Map<String,JSONObject>();
        Map<String,JSONObject> m_target_object_fields_list_Contact_PreMAP = new Map<String,JSONObject>();
        Integer i = 0;
        for (String field_name : describe_result.keySet()) 
        {
        	system.debug('=========================='+describe_result.get(field_name));
        	system.debug('=========================='+describe_result.get(field_name).isAccessible());
        	if(!setFields.contains(describe_result.get(field_name).getName()))
        	{
        		
	    		if(describe_result.get(field_name).isAccessible())
	    		{
	        		String field_type = describe_result.get(field_name).getType().name();
	            
		            if(field_type == 'TEXTAREA') {
		                continue;
		            }
	
	            	JSONObject item = new JSONObject(
	                    field_name, 
	                    describe_result.get(field_name).getLabel(), 
	                    field_type
	            	);
	            
		            if (item.FieldType == 'REFERENCE') 
		            {
		                if (field_name=='recordtypeid')
		                {
		                    item.FieldType = 'PICKLIST';
		                } 
		                else 
		                {
		                    List<Schema.sObjectType> refereced_to_list = describe_result.get(field_name).getReferenceTo();
		                    if(!refereced_to_list.isEmpty()) 
		                    {
		                        item.Prefix = refereced_to_list.get(0).getDescribe().getKeyPrefix();
		                    }
		                }
		            } 
	
		            if(TargetObject == 'Account' && !forbidFields_Account.contains(field_name)) {
		                /* m_target_object_fields_list_company.add(item); */
		                m_target_object_fields_list_company_PreMAP.put(field_name,item);
		            }
		            else if(TargetObject == 'Contact' && !forbidFields_Contact.contains(field_name)) {
		            	 m_target_object_fields_list_Contact_PreMAP.put(field_name,item);
		            }
	        	}
        	}
        }
        
        if(m_target_object_fields_list_company_PreMAP.size()>0) m_target_object_fields_list_company = m_target_object_fields_list_company_PreMAP.values();
        /* system.debug('=========================================== countFields: ' + m_target_object_fields_list_company.size()); */
        m_target_object_fields_list_company = sortingFields(m_target_object_fields_list_company);
        
        if(m_target_object_fields_list_Contact_PreMAP.size()>0) m_target_object_fields_list_Contact = m_target_object_fields_list_Contact_PreMAP.values();
        m_target_object_fields_list_Contact = sortingFields(m_target_object_fields_list_Contact);
    }
    
    
    
    protected Boolean isNullOrEmpty(String p_str) {
        return (p_str == null || p_str == ''); 
    }

    public class LookUpPickListValue
    {
        public String  ID   {get;set;}
        public String  Value {get;set;}
        
        public LookUpPickListValue(String inID, String inValue) {
            ID = inID;
            Value = inValue;
        }
    }
    /* JSONObject class */
    public class JSONObject {
        public String  Name                 {get;set;}
        public String  Value                {get;set;}
        public String  FieldType            {get;set;} 
        public List<String> picklistValues  {get;set;}
        public String Prefix                {get;set;}
        
        public String Json {
            get{
                String result = '';
                result += jProperty('name', Value) + ', ';
                result += jProperty('value', Name) + ', ' ;
                result += jProperty('type', FieldType) ;
                if(Prefix != null && Prefix != '') {
                    result += ', ' + jProperty('prefix', Prefix) ;  
                }
                /*(if (FieldType == 'PICKLIST') {
                    result += ', ';
                    result += jProperty('picklistValues', picklistValues);
                }*/
                return '{' +  result + '}';             
            }
        }
         
        public JSONObject() {
            picklistValues = new List<String>();
        }
        
        public JSONObject(String p_name, String p_value, String p_type) {
            picklistValues = new List<String>();
            Name = p_name; Value = p_value; FieldType = p_type;
        }
        
        public JSONObject(String p_name, String p_value, String p_type, List<String> p_picklist_values) {
            Name = p_name; Value = p_value; FieldType = p_type;
            picklistValues = p_picklist_values;
        }
    
        public String jQ(String p_str) {
            return '"' + p_str + '"';
        }
        
        public String jProperty(String p_name, String p_value) {
            return jQ(p_name) + ' : ' + jQ(p_value);
        }

        public String jProperty(String p_name, List<String> p_value) {
            String result = '';
            for(Integer i = 0; i < p_value.size(); i++) {
                result += '{' + jProperty('value', p_value[i]) + '}';
                if(i != p_value.size()-1) {
                    result += ', ';
                }
            }
            return jQ(p_name) + ' : ' + '['+ result +']';
        }
    }
    
    public with sharing class CompanyExtend {
        public Boolean Checked{ get; set; }
        public Account Item { get; set;}
        public Contact objContact {get;set;}
 
        public CompanyExtend() {
            Item = new Account();
            Checked = false;
        }
 
        public CompanyExtend(Account p_company) {
            Item = p_company;
            Checked = false;
        }
        
        public CompanyExtend(Account p_company, boolean inCheck) {
        	Item = p_company;
            Checked = inCheck;
        }
        
        public CompanyExtend(Contact objContacts, boolean inCheck) {
        	objContact = objContacts;
            Checked = inCheck;
        }
    }
    
    
    /**************************** Code for Pagination logic START *********************************/
    
    
    public Integer FirstPage    {get; set;} // first row number in the list.
    public Integer CurrentPageSize     {get; set;} // number of rows per page. //previously currentPageCount
    public Integer LastPage     {get; set;} // row index of the first record the in the last page
    public Integer TotalRows    {get;set;}// total rows in all pages.
    public Integer currentPageNum	{get;set;}
    
    public String displayResult {get;set;}
   
    //navigates to previous page
    public void previousPage()
    {
        if(FirstPage - CurrentPageSize >= 0)
        {
            FirstPage -= CurrentPageSize ;
            displayResult = 'Displaying '+ (FirstPage + 1) + '-' + (FirstPage + CurrentPageSize) +' Results';
        }
    }
    
    //navigates to last page
    public void lastPage()
    {
        FirstPage = calcLastPage();
        displayResult = 'Displaying ' + (FirstPage + 1) + ' - ' + TotalRows +' Results';
        
    }
    
    //calculates page number of last page
    private Integer calcLastPage()  
    {
        if(TotalRows >= CurrentPageSize )
        {            
            return (LastPage-1)* CurrentPageSize; 
        }
        else
        {
            return 0;
        }
    } 
    
    //navigates to next page
    public void nextPage()  
    {
    	system.debug('-------------- In next page -----------');
    	system.debug('-------------- TotalRows -----------'+TotalRows);
    	system.debug('-------------- CurrentPageSize -----------'+CurrentPageSize);
    	system.debug('-------------- FirstPage -----------'+FirstPage);
    	
        if(TotalRows== null || CurrentPageSize == null) return;    
        if(FirstPage + CurrentPageSize < TotalRows)
        {
            FirstPage += CurrentPageSize ;
            if((FirstPage + CurrentPageSize) <= TotalRows)
                displayResult = 'Displaying '+ (FirstPage + 1) + ' - ' + (FirstPage + CurrentPageSize) +' Results';
            else
                 displayResult = 'Displaying ' + (FirstPage + 1) + ' - ' + TotalRows +' Results';
        }
        
        system.debug('-------------- FirstPage end -----------'+FirstPage);
        system.debug('-------------- displayResult -----------'+displayResult);
    }
    
    //navigates to first page
    public void firstPage()
    {
        FirstPage = 0;
        displayResult = 'Displaying '+ (FirstPage + 1) + ' - ' + (FirstPage + CurrentPageSize) +' Results';
    }   
    
    //navigates to specific page
    
    
    /***************************** Code for Pagination logic END ********************************/
    
}