public with sharing class MyTasksController {
	
	private final Contact m_contact;
	public MyTasksController() {
		
		this.m_contact = getCurrentContact();
	}
	
	class CompanyInfo {
    	ID m_Id;
    	String m_Name;
    	String m_Description;
    	String m_Category;
    	String m_Sector;
    	String m_Geographies;
    	
    	CompanyInfo(ID id, String Name, String Description, String Category, String Sector, String Geographies ) {
    		m_Id = id;
    		m_Name = Name;
    		m_Description = Description;
    		m_Category = Category;
    		m_Sector = Sector;
    		m_Geographies = Geographies;
    	}
    }
    
    class ContactInfo {
    	ID m_Id;
    	String m_Name;
    	String m_Title;
    	String m_Category;
    	
    	ContactInfo(ID id, String Name, String Title, String Category) {
    		m_Id = id; 
    		m_Name = Name;
    		m_Title = Title;
    		m_Category = Category;
    	}
    }
	
    class CompanyListInfo {
        ID m_Id;
        String m_Name;
        
        CompanyListInfo(ID id, String Name) {
            m_Id = id;
            m_Name = Name;
        }
        
        public String GetName() {
        	return m_Name;
        }
    }
    
    class TaskNote {
    	ID m_Id;
    	String m_Note;
    	String m_Subject;
    	String m_Classification;
    	Date m_ActivityDate;
    }
    class ContactListInfo {
        ID m_Id;
        String m_Name;
        String m_FullName;
        
        ContactListInfo(ID id, String Name) {
            m_Id = id;
            m_Name = Name;
            
        }
        
        public String GetName() {
        	return m_Name;
        }
    }
    
    class CompanyFinancialInfo {
    	
    	ID m_Id;    
        String m_CompanyCurrency;
        String m_CurrencyIsoCode;
    	Decimal m_BookValue;  
        Decimal m_CAPEX;
        Decimal m_EBITDA;
        Decimal m_EnterpriseValue; 
        Decimal m_MarketCap;
        Decimal m_NetIncome; 
        Decimal m_Revenues;
        String m_PeriodType;
        Date m_PeriodEnded;
    	
    	CompanyFinancialInfo(
           ID Id,
    	   Decimal BookValue, 
    	   Decimal CAPEX, 
           String CompanyCurrency,
           String CurrencyIsoCode,
           Decimal EBITDA,
           Decimal EnterpriseValue,
           Decimal MarketCap,
           Decimal NetIncome,
           Date PeriodEnded,
           String PeriodType,
           Decimal Revenues
    	) {
           m_BookValue = BookValue; 
           m_CAPEX = CAPEX;
           m_CompanyCurrency = CompanyCurrency;
           m_CurrencyIsoCode = CurrencyIsoCode;
           m_EBITDA = EBITDA;
           m_EnterpriseValue = EnterpriseValue;
           m_Id = Id;
           m_MarketCap = MarketCap;
           m_NetIncome = NetIncome;
           m_PeriodEnded = PeriodEnded;
           m_PeriodType = PeriodType;
           m_Revenues = Revenues;
    	}
    	
    	public Decimal getBookValue () {
    		return m_BookValue;
    	}
        public Decimal getCAPEX () {
            return m_CAPEX;
        }
        public String getCompanyCurrency () {
            return m_CompanyCurrency;
        }
        public String getCurrencyIsoCode () {
            return m_CurrencyIsoCode;
        }
        public Decimal getEBITDA () {
            return m_EBITDA;
        }
        public String getEBITDAFormatted () {
            return m_EBITDA != null ? m_EBITDA.format() : null;
        }
        public String getRevenuesFormatted () {
            return m_Revenues != null ? m_Revenues.format() : null;
        }
        
        public Decimal getEnterpriseValue () {
            return m_EnterpriseValue;
        }
        public Decimal getMarketCap () {
            return m_MarketCap;
        }
        public Decimal getNetIncome () {
            return m_NetIncome;
        }
        public Date getPeriodEnded () {
            return m_PeriodEnded;
        }
        public String getPeriodType () {
            return m_PeriodType;
        }
        public Decimal getRevenues () {
            return m_Revenues;
        }
        public String getReportString() {
        	List<String> values = new String[]{
        		m_PeriodType,
        		m_PeriodEnded.format(),
        		m_EBITDA != null ? m_EBITDA.format() : 'N/A',
        		m_Revenues != null ? m_Revenues.format() : 'N/A',
        		m_NetIncome != null ? m_NetIncome.format() : 'N/A',
        		m_CurrencyIsoCode
        	};
        	return String.format('{0} as of {1} - [EBITDA : {5} {2}] ; [Revenue : {5} {3}] ; [Net Income : {5} {4}]', values );
        }
    }

    public class TaskSummary {
    	
        ID m_Id;
        ID m_FollowUpId;
        Integer m_rowNumber;
         
        String m_OwnerId; 
        String m_Subject;
        String m_Classification;
        String m_Status;
        Boolean m_IsClosed;
        ID m_CompanyId;
        String m_CompanyName;
        String m_CompanyDescription;
        String m_Sector;
        String m_Geographies;      
        ID m_DealId;
        String m_DealName;
        String m_Marker;
        Date m_ActivityDate;
        String m_ActivityDateString;
        Date m_NextActivityDate;
        String m_Type;
        String m_FollowUpType;
        String m_FollowUpSubject;
        String m_FollowUpStatus;
        Boolean m_FollowUpIsClosed;
        String m_ActivityOwnerName;
        String m_NextActivityOwnerName;
        String m_Description;
        String m_FollowupDescription;
        String m_FollowUpClassification;
        String m_CompanyCategory; 
        ID m_ContactId;       
        String m_ContactName;
        String m_ContactTitle;
        List<String> m_OtherLists;
        CompanyFinancialInfo m_Financials;
        List<ContactListInfo> m_OtherContacts;
        List<ContactPerson> m_OtherContactsFullName;
        List<ContactListInfo> m_OtherFollowupContacts;    
        List<ContactListInfo> m_ListExternalContacts;   
        ContactInfo m_ListContact;
        List<TaskNote> m_ClosedTaskNotes;
        String m_CompanyContactforExcel;
        String m_InternaNamesforExcel;
        
        public ID getId() {
        	return m_Id;
        }

        public ID getDealId() {
            return m_DealId;
        }
        
         public Integer getRowNumber() {
            return m_RowNumber;
        }

        public String getDealName() {
            return m_DealName;
        }

        public ID getFollowUpId() {
            return m_FollowUpId;
        }

        public String getSubject() {
            return m_Subject;
        }
        
        public String getClassification() {
            return m_Classification;
        }
        
        public String getSector() {
            return m_Sector;
        }
        
        public String getGeographies() {
            return m_Geographies;
        }
        
        public String getFollowUpSubject() {
            return m_FollowUpSubject;
        }

        public ID getCompanyId() {
        	return m_CompanyId;
        }
        
        public String getCompanyName() {
            return m_CompanyName;
        }

        public String getCompanyDescription() {
            return m_CompanyDescription;
        }

        public String getMarker() {
            return m_Marker;
        }
        
        public Date getActivityDate() {
        	return m_ActivityDate;
        }
        
        public Date getNextActivityDate() {
            return m_NextActivityDate;
        }

        public String getType() {
            return m_Type;
        }
        
        public String getFollowUpType() {
            return m_FollowUpType;
        }

        public String getActivityOwnerName() {
            return m_ActivityOwnerName;
        }
        
        public String getNextActivityOwnerName() {
            return m_NextActivityOwnerName;
        }

        public String getDescription() {
            return m_Description;
        }

        public String getFollowupDescription() {
            return m_FollowupDescription;
        }
        
        public String getStatus() {
            return m_Status;
        }

        public String getFollowUpStatus() {
            return m_FollowUpStatus;
        }
        
        public Boolean IsClosed() {
        	return m_IsClosed;
        }

        public Boolean GetIsClosed() {
            return m_IsClosed;
        }

        public Boolean FollowUpIsClosed() {
            return m_FollowUpIsClosed;
        }
        
        public Boolean GetFollowUpIsClosed() {
            return m_FollowUpIsClosed;
        }
        
        Public String GetFollowUpClassification() {
        	return m_FollowUpClassification;        	
        }
        
        public String getCompanyCategory() {
        	return m_CompanyCategory;
        }
        
        public List<String> GetOtherLists() {
        	return m_OtherLists;
        }
        
        public CompanyFinancialInfo GetFinancials() {
        	return m_Financials;
        }
        
        public List<ContactListInfo> GetOtherContacts() {
        	return m_OtherContacts;
        }
        
        public List<ContactListInfo> GetOtherFollowUpContacts() {
        	return m_OtherFollowUpContacts;
        }
        
        public List<ContactListInfo> GetExternalContacts() {
        	return m_ListExternalContacts;
        }
        public ContactInfo GetListContact() {
        	return m_ListContact;
        }   
        
        public String GetContactName() {
        	return m_ContactName;
        }    
       
        public String GetContactTitle() {
        	return m_ContactTitle;
        }        
        public List<TaskNote> GetClosedTasks() {
        	return  m_ClosedTaskNotes;
        }
        public String GetCompanyContactforExcel() {
        	return m_CompanyContactforExcel;
        }
        public String GetInternaNamesforExcel() {
        	return m_InternaNamesforExcel;
        }
    }
    
        public class ContactPerson {
        String label;
        String contact_id;
        String account_id;
        String title;
        String company_name;
        String chinese_name;
        String chinese_company_name;
        
        
        public ContactPerson(
                String name, String ContactId, String AccountId, 
                String Title, String AccountName, String ChineseName, String ChineseAccountName) {
            this.label = name;
            this.account_id = AccountId;
            this.contact_id = ContactId;
            this.title = Title;
            this.company_name = AccountName;
            this.chinese_name = ChineseName;
            this.chinese_company_name = ChineseAccountName;
        }
    }
       
        public class Companyname {
        String label;
        String comp_id;
        String sub_sector;
        String geo;

               
        public Companyname (String name, String CompId, String sub_sector, String geo) {
            this.label = name;
            this.comp_id = CompId;
            this.sub_sector= sub_sector;
            this.geo= geo;
        }
    }
        
	@RemoteAction
    public static List<Task> getMyTasks() {
 
        List<Task> tasks = [Select
                        t.AccountId, t.WhoId, t.WhatId, t.Type, t.Subject, t.Status, t.Classification__c,
                        t.ReminderDateTime, t.RecurrenceType, t.Priority, 
                        t.OwnerId, t.IsClosed, t.Id, t.Description, t.CreatedDate, 
                        t.CreatedById, t.CallType, t.CallObject, t.ActivityDate,
                        t.Owner.Name,
                        Account.Name, What.Name, What.Type, Who.Name, Who.Id, Who.Type 
                        From Task t
                        WHERE OwnerId IN (
                            Select c.User_ID__c
                            From Contact c 
                            WHERE c.User_ID__c <> NULL 
                            AND c.User_ID__r.IsActive = true)
                        AND
                            What.Type IN ('Account', 'Deal__c') 
                        AND t.OwnerId = :UserInfo.getUserId()
                        ORDER BY 
                            t.ActivityDate DESC
        
        ];
        
        return tasks;
    }
    @RemoteAction
	public static List<Companyname> getCompanyList(String searchterm) {

        String query = 
            'Select Id,Sector__c,Geographies__c, Name From Account ';
    
        String restriction = String.isBlank(searchterm) ? '' : ' WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchterm) + '%\'';
        System.debug('getCompanyList:'+query+restriction );
        List<Account> acc = Database.query( query + restriction +' ORDER BY Name' );
    
        Companyname c;
        List<Companyname> lst = new List<Companyname>();
        
        
                    
        for ( Account account : acc ) {
            c = new Companyname(
                account.Name, 
                account.Id,
                account.Sector__c,
                account.Geographies__c
            );
            lst.add(c);
        }    
      
        if (lst.size()>0)
                return lst ;
        else
                return null;
    
    
    }
    
    
    @RemoteAction
    public static List<String> getClassificationList() {
    	List<String> lst = new List<String>();
     	Schema.Describefieldresult taskCat = Schema.Sobjecttype.Task.fields.Classification__c;
    	Schema.PicklistEntry [] values = taskCat.getPickListValues();
    	for(Schema.PicklistEntry val : values){
	       lst.add(val.getValue());
	    }
	    return lst;
    }
    @RemoteAction
    public static List<ContactPerson> getContactsList(String searchterm) {

        String query = 
            'Select Id, AccountId, LastName, FirstName, Name, Title, Full_Name__c, Chinese_Name__c, ' +
            'RecordType.Name, Account.Name, Account.Chinese_Company_Name__c From Contact ';
    
        String restriction = String.isBlank(searchterm) ? '' : ' WHERE LastName LIKE \'' + String.escapeSingleQuotes(searchterm) + '%\'';
        
        List<Contact> people = Database.query( query + restriction + ' ORDER BY LastName, FirstName' );
    
        ContactPerson p;
        List<ContactPerson> lst = new List<ContactPerson>();
        for ( Contact contact : people ) {
            p = new ContactPerson(
                contact.Full_Name__c, 
                contact.Id, 
                contact.AccountId,
                contact.Title,
                contact.Account.Name,
                contact.Chinese_Name__c,
                contact.Account.Chinese_Company_Name__c
            );
            lst.add(p);
        }
        return lst;
    }
    public Contact getCurrentContact() {
    	Contact contact = [
                SELECT User_ID__c, Name, Id, Full_Name__c,
                EMG_Member__c, Email, Employee_Level__c, 
                ISINVESTMENTPRO__c, Initials__c, Status__c, Title, WP_Group__c FROM Contact         
                WHERE User_ID__c = :UserInfo.getUserId() LIMIT 1];
        return contact;
    
    }
    @RemoteAction
    public static Contact getCurrentUserContactInformation() {
        Contact contact = [
                SELECT User_ID__c, Name, Id, Full_Name__c,
                EMG_Member__c, Email, Employee_Level__c, 
                ISINVESTMENTPRO__c, Initials__c, Status__c, Title, WP_Group__c FROM Contact         
                WHERE User_ID__c = :UserInfo.getUserId() LIMIT 1];
        return contact;
    }
    
     @RemoteAction
    public static List<TaskSummary> getUserTaskSummary(ID ContactId) {
    	return CreateUserSummaryResults(ContactId);
    }
    
    public List<TaskSummary> getUserTaskSummaryAsExcel(){
    	List<TaskSummary> mytasks = CreateUserSummaryResults(this.m_contact.User_ID__c);
    	
    	String viewType = ApexPages.CurrentPage().getParameters().get('v');
    	System.debug('view type is ' + viewType);
    	Integer counter = 0;
    	DateTime dt;
    	if (viewType == '1') {  //overdue tasks only
    		dt = datetime.now();
    	}
    	else if (viewType == '2') {
    		dt = datetime.now() + 7;
    	}
    	else if (viewType == '3') {
    		dt = datetime.now() + 30;
    	}
    	
    	while(counter < mytasks.size()) {
			//do the contacts stuff here
    		// public String GetCompanyContactforExcel() {
        	//public String GetInternaNamesforExcel() {
        	String excelcontact = '';
        	
        	if (mytasks[counter].m_CompanyName != null && mytasks[counter].m_CompanyName != '' ) 
        	{
        		excelcontact += mytasks[counter].m_CompanyName + '<br style=\'mso-data-placement:same-cell;\' />';
        	}
        	for(ContactListInfo contactinfo : mytasks[counter].m_ListExternalContacts)
	    	{
	    		excelcontact += contactinfo.m_Name + ', ';
	    	}
	    	mytasks[counter].m_CompanyContactforExcel = excelcontact.removeEnd(', ');
	    	
			if (mytasks[counter].m_ActivityDate > dt) {
				mytasks.remove(counter);
				System.debug('I removed!');
			}
			else {
				counter++;
			}
		}
    	return mytasks;
    	
    }
     
    @RemoteAction
    public static Boolean closeTask(String taskId, TaskSummary mytask) {
        return updateOrCloseTask(taskId, mytask, 'Close');
    }  
    @RemoteAction
    public static Boolean updateTask(String taskId, TaskSummary mytask) {
        return updateOrCloseTask(taskId, mytask, 'Edit');
    } 
    @RemoteAction
    public static Boolean addNewTask(TaskSummary mytask) {
        boolean errorFound = false;
        
        Task task = new Task();
        List<TaskRelation> relationsToAdd = new List<TaskRelation>();
        
        task.Subject = mytask.m_Subject;
        task.Description = mytask.m_Description;
        task.OwnerId = mytask.m_OwnerId;
        task.Classification__c = mytask.m_Classification;
        task.Status = 'Not Started';
        task.Priority = 'Normal';
        task.ActivityDate = string.isBlank(mytask.m_ActivityDateString) ? null : Date.parse(mytask.m_ActivityDateString);
        task.WhatId = string.isBlank(mytask.m_CompanyId) ? null : mytask.m_CompanyId; 
        insert task;
        
        if (mytask.m_OtherContacts.size() > 0) {
			for(ContactListInfo contactinfo : mytask.m_OtherContacts)
	    	{
	    		TaskRelation newContactRelationship = new TaskRelation();
	    		newContactRelationship.TaskId = task.id;
	    		newContactRelationship.RelationId =  contactinfo.m_Id;
	    		newContactRelationship.IsWhat = false;	    	
	    		//newContactRelationship.AccountId =  contact.AccountId;	    		
       			relationsToAdd.add(newContactRelationship);
        	}	
		
		}
		if(relationsToAdd.size() > 0) {
        	Database.insert(relationsToAdd);
        } 
        return !errorFound;
    } 
    public static Boolean updateOrCloseTask(String taskId, TaskSummary mytask, String EditOrClose) {
    	
    	boolean errorFound = false;
        List<Task> task = [
            SELECT 
            Id, Subject, ActivityDate, Classification__c, Status, Description
            FROM Task 
            WHERE Id = :taskId
        ];
        
        if ( task.size() > 0 ) {
        	task[0].Subject = mytask.m_Subject;
        	if (mytask.m_ActivityDateString != '')
        		task[0].ActivityDate = Date.parse(mytask.m_ActivityDateString);
        	task[0].Classification__c = mytask.m_Classification;
        	task[0].Description = mytask.m_Description;
        	if (EditOrClose == 'Close') {
        		task[0].Status = 'Completed';	
        	}
        	update task[0];        	
        }
        else 
        	errorFound = true;
		
		//task relations stuff
		List<TaskRelation> relations = [
			SELECT
			Id, RelationId
			FROM TaskRelation
			Where TaskId = :taskId
		];
		List<TaskRelation> relationsToAdd = new List<TaskRelation>();
		if (relations.size() > 0) {
			Database.delete(relations);			
		}
		if (mytask.m_OtherContacts.size() > 0) {
			for(ContactListInfo contactinfo : mytask.m_OtherContacts)
	    	{
	    		TaskRelation newContactRelationship = new TaskRelation();
	    		newContactRelationship.TaskId = taskId;
	    		newContactRelationship.RelationId =  contactinfo.m_Id;
	    		newContactRelationship.IsWhat = false;	    	
	    		//newContactRelationship.AccountId =  contact.AccountId;	    		
       			relationsToAdd.add(newContactRelationship);
        	}	
		
		}
		System.debug('companyid is ' + mytask.m_CompanyId);
			
		if (mytask.m_CompanyId != null) {
			System.debug('inside the companyinsert ' + mytask.m_CompanyId);
			
			TaskRelation newContactRelationship = new TaskRelation();
	    	newContactRelationship.TaskId = taskId;
	    	newContactRelationship.RelationId =  mytask.m_CompanyId;
	    	newContactRelationship.IsWhat = true;	    	
	    		//newContactRelationship.AccountId =  contact.AccountId;	    		
       		relationsToAdd.add(newContactRelationship);
		}
		System.debug('update task relations to add size is  '+ relationsToAdd.size());
		if(relationsToAdd.size() > 0) {
        	Database.insert(relationsToAdd);
        } 
		return !errorFound;
    }
    public static List<TaskSummary> CreateUserSummaryResults(ID ContactId) {
    	Schema.SObjectType token;
    	List<TaskSummary> summary_results = new List<TaskSummary>();
        List<ID> taskContactIds = new List<ID>();        
        TaskSummary s;
        Integer rowNumber = 0;
        Map<ID, CompanyInfo> company_ids = new Map<ID, CompanyInfo>();
        Map<ID, List<CompanyListInfo>> other_list_ids =  new Map<ID, List<CompanyListInfo>>(); 
        Map<ID, List<CompanyFinancialInfo>> company_financial_map = new Map<ID, List<CompanyFinancialInfo>>();
        CompanyFinancialInfo companyfinance;
        
        List<ID> contactCompanyListIds = new List<ID>(); 
        
        List<ID> companyListIds = new List<ID>();
        
        //System.debug('mytask contactid is '+ ContactId);
        List<Task> all_tasks = [Select
                        t.AccountId, t.WhoId, t.WhatId, t.Type, t.Subject, t.Status, t.Classification__c,
                        t.ReminderDateTime, t.RecurrenceType, t.Priority, 
                        t.OwnerId, t.IsClosed, t.Id, t.Description, t.CreatedDate, 
                        t.CreatedById, t.CallType, t.CallObject, t.ActivityDate,
                        t.Owner.Name,
                        Account.Name, What.Name, What.Type, Who.Name, Who.Id, Who.Type, 
                        (Select Id, RelationId, TaskId, IsWhat, AccountId From TaskRelations )
                        From Task t
                        WHERE OwnerId IN (
                            Select c.User_ID__c
                            From Contact c 
                            WHERE c.User_ID__c <> NULL 
                            AND c.User_ID__r.IsActive = true)                            
                        AND t.OwnerId = :ContactId
                        AND t.Status <> 'Completed'
                        ORDER BY 
                            t.ActivityDate ASC ALL ROWS
                        
        ];
        System.debug('mytask count is '+ all_tasks.size());
        Map<ID, CompanyInfo>deal_lookup = new Map<ID, CompanyInfo>();
		Integer loopcounter = 0;
		for (Task t : all_tasks) {
			//System.debug('mytask inside task loop 1 '+ t);
            if (t.AccountId != null) {
            	companyListIds.add(t.AccountId);
            }
            if(t.TaskRelations.size() > 0) {
           		for(TaskRelation tr: t.TaskRelations) {
            		taskContactIds.add(tr.RelationId);
            	}
            }
        }
        Map<ID, Account> compMap = new Map<ID,Account>([SELECT Id, Name, Description, Geographies__c, Sector__c FROM Account where Id in :companyListIds]);

		Map<ID, Contact> contact_lookup = new Map<ID, Contact>();        
        contact_lookup = new map<ID, Contact>([Select c.Name, c.LastName, c.Initials__c, c.Id, c.Full_Name__c, c.FirstName, c.Status__c, c.AccountId, c.Title, c.Account.Name, c.RecordType.Name, (Select Subject, Status, Description, IsClosed, WhoId, AccountId, Classification__c, ActivityDate From Tasks order by ActivityDate DESC), (Select Company_List__c From Prospect_Members__r) FROM Contact c WHERE c.ID in :taskContactIds ALL ROWS]);
        Map<ID, TaskSummary> summary_lookup = new Map<ID, TaskSummary>();

		//get all the closed notes associated with each companies
        //get all the company ids..
        Map<ID,Account> closedTaskMap = new map<ID,Account>([Select a.Id, (Select Subject, Status, Classification__c, AccountId, IsClosed, Id, Description, ActivityDate From Tasks order by ActivityDate DESC) From Account a where a.Id in :companyListIds ALL ROWS]);
				
        //get company financials
        //System.debug('mytask trying to get financials ');
        Map<ID,Account> myfinancialsMap = new Map<ID,Account>([Select a.Id, (Select Company__c, Period_Type__c, Period_Ended__c, EBITDA_MM__c, Net_Income_MM__c, Revenues_MM__c From Financials__r order by Period_Ended__c DESC LIMIT 1),  (Select Company_List__c From Prospect_Members__r) From Account a where a.Id in :companyListIds]);
        
        //get all the names of the list.  cant join the names of the list directly. 
        Map<ID, Company_List__c> cmap = new Map<ID,Company_List__c>([Select c.Name, c.Id From Company_List__c c]);
        
        for (Task t : all_tasks) {
        	// System.debug('mytask starting the all task loop ' + t.Id);
        	Boolean isThereaCompany = true;
			if (t.WhatId == null) {
				isThereaCompany = false;
				System.debug('mytask starting the all task loop  - no company here ' + t);
			}	
			else 
				System.debug('mytask starting the all task loop company is here ' + t);
        	Account a = compMap.get(t.AccountId);
        	//taskContactIds.clear();
        	if (a != null)
        		deal_lookup.put(t.AccountId, new CompanyInfo(a.Id, a.Name, a.Description, null, a.Sector__c, a.Geographies__c));
        	
            CompanyInfo company_info = deal_lookup.get(t.WhatId);
			//do companyfinance
			Boolean found = false;
			System.debug('mytask 1 CompanyFinancialInfo accountid is ' + t.AccountId);
			Account fina = myfinancialsMap.get(t.AccountId);
			System.debug('mytask 2 CompanyFinancialInfo ' + fina);
			List<String> myLists = new List<String>();
			List<String> myContactSubscribedLists = new List<String>();
			if (fina != null) {
				System.debug('mytask 2a CompanyFinancialInfo ' + fina.Financials__r );
				if (!fina.Financials__r.isEmpty()) {
					System.debug('mytask 2b CompanyFinancialInfo ' );
					List<Financial__c> fin = fina.Financials__r;
					System.debug('mytask CompanyFinancialInfo ' + fina);
					System.debug('mytask CompanyFinancialInfo ' + fin);
					companyfinance = new CompanyFinancialInfo(fin[0].Id, 0, 0, '', '', fin[0].EBITDA_MM__c, 0, 0, fin[0].Net_Income_MM__c, fin[0].Period_Ended__c, fin[0].Period_Type__c, fin[0].Revenues_MM__c);
					
				}
				System.debug('mytask 2c CompanyFinancialInfo ' );
			
				//do the list stuff here with the same fina object
				if (!fina.Prospect_Members__r.isEmpty()) {
					List<Company_List_Member__c> clm = fina.Prospect_Members__r;
					for(Company_List_Member__c c : clm) {
						Company_List__c clist = cmap.get(c.Company_List__c);
						myLists.add(clist.Name);
					}
					
				}
			}
			System.debug('mytask 3 CompanyFinancialInfo ');
			
			ID company_id = company_info != null ? company_info.m_Id : null;
            String company_name = company_info != null ? company_info.m_Name : null;
            String company_description = company_info != null ? company_info.m_Description : (company_ids.get(company_id) != null ? company_ids.get(company_id).m_Description : '');
            String company_sector = company_info != null ? company_info.m_Sector : null;
            String company_geographies = company_info != null ? company_info.m_Geographies : null;
                      
            List<ContactListInfo> cInfoList = new List<ContactListInfo>();
            List<ContactPerson> cInfoFullNameList = new List<ContactPerson>();
            List<ContactListInfo> cExternalInfoList = new List<ContactListInfo>();
            ContactListInfo cInfo;            
            System.debug('mytask summary_lookup '+ company_id);
            s = summary_lookup.get(company_id);
            s = new TaskSummary();
            System.debug('mytask do i get newed?  '+s);
            s.m_CompanyId = company_id;
            s.m_CompanyName = company_name;
            s.m_CompanyDescription = company_description;
            //s.m_OtherLists = other_list_ids.get(company_id);
           s.m_Financials = companyfinance;
            s.m_Sector = company_sector;
            s.m_Geographies =   company_geographies;         
            
            List<TaskNote> contactTaskNoteList = new List<TaskNote>();
            
            if(t.TaskRelations.size() > 0) {
            	cInfoList = new List<ContactListInfo>();
            	for(TaskRelation tr: t.TaskRelations) {
            		//System.debug('mytask what is taskrelations '+t.TaskRelations);
            		Contact contact = contact_lookup.get(tr.RelationId);            		
            		if(contact != null) {
            			if (contact.RecordType.Name == 'Employee' && contact.Status__c == 'Active') {
            				//cInfo = new ContactListInfo(contact.Id, contact.FirstName.substring(0,1) +  contact.LastName.substring(0,1));
            				cInfo = new ContactListInfo(contact.Id, contact.Initials__c);
            				cInfo.m_FullName = contact.FirstName + ' ' + contact.LastName;
            				cInfoList.add(cInfo); 
            				ContactPerson cp = new ContactPerson(contact.Full_Name__c, contact.Id, contact.AccountId, contact.Title, contact.Account.Name, '', '');
            				System.debug('mytask HODOR? '+cp);
            				cInfoFullNameList.add(cp); 
            			}
            			else {
            				//(m.Contact__r.Id, new ContactInfo(m.Contact__r.Id, m.Contact__r.Name, m.Title__c,  m.Category__c )
            				cInfo = new ContactListInfo(contact.Id, contact.FirstName + ' ' + contact.LastName);
            				cInfo.m_FullName = contact.FirstName + ' ' + contact.LastName;
            				//s.m_OtherFollowupContacts = cInfo;
            				System.debug('mytask yay contact ' + cInfo);
            				ContactPerson cp = new ContactPerson(contact.Full_Name__c, contact.Id, contact.AccountId, contact.Title, contact.Account.Name, '', '');
            				
            				cInfoFullNameList.add(cp);
            				cExternalInfoList.add(cInfo);
            				
            				// do the closed tasks and the Lists stuff here
            				if (!isThereaCompany) {
            					if (!contact.Tasks.isEmpty()) {
            						//contactTaskNoteList
            						Integer counter = 0;
            						List<Task> taskList = contact.Tasks;
	            					for (Task tnote : taskList) {         
	            						if (tnote.WhoId != null && counter < 2 && contact.Id != null) {
			            					if (tnote.WhoId == contact.Id && tnote.Status == 'Completed') {
							            		TaskNote tn = new TaskNote();
							            		tn.m_Id = tnote.Id;
							            		tn.m_Note = tnote.Description;
							            		tn.m_Subject = tnote.Subject;
							            		tn.m_Classification = tnote.Classification__c;
							            		tn.m_ActivityDate = tnote.ActivityDate;
							            		System.debug('mytask do i even do the note stuff2?  ' + tn);
							            		contactTaskNoteList.add(tn);
							            		counter++;
			            		        	}	   
	            						}         	
					            	}
            					}
            					
            					// do the list stuff here
            					if (!contact.Prospect_Members__r.isEmpty()) {
            						//myContactSubscribedLists
            						List<Company_List_Member__c> clm = contact.Prospect_Members__r;
									for(Company_List_Member__c c : clm) {
										Company_List__c clist = cmap.get(c.Company_List__c);
										myContactSubscribedLists.add(clist.Name);
									}
            					}            					
            				}            				
            			}            			
            		}
            	}
            }            
      
            s.m_Id = t.Id;
            s.m_Subject = t.Subject;
            s.m_Classification = t.Classification__c;
            s.m_Type = t.Type;
            s.m_ActivityDate = t.ActivityDate;
            s.m_ActivityOwnerName = t.Owner.Name;
            s.m_Description = t.Description;
            s.m_Status = t.Status;
            s.m_IsClosed = t.IsClosed;
             System.debug('mytask s.m_Subject?  '+s.m_Subject);
            if(cInfoList.size() > 0) {
        		s.m_OtherContacts = cInfoList; 
        	}
        	System.debug('mytask external ' + cExternalInfoList);
        	s.m_ListExternalContacts = cExternalInfoList;
            
            //do the closed tasks stuff here
            //m_ClosedTaskNotes (TaskNote)
            System.debug('mytask do i even do the note stuff?  ');

            Integer counter = 0;
            List<TaskNote> taskNoteList = new List<TaskNote>();
            System.debug('notes accountid is ' + t.AccountId);
            if (t.Account != null) {
            	Account accountNotes = closedTaskMap.get(t.AccountId);
	            if (!accountNotes.Tasks.isEmpty()) {
	            	List<Task> taskList = accountNotes.Tasks;
	            	for (Task tnote : taskList) {         
		            	if (tnote.AccountId == t.AccountId && counter < 2 && tnote.Status == 'Completed') {
		            		TaskNote tn = new TaskNote();
		            		tn.m_Id = tnote.Id;
		            		tn.m_Note = tnote.Description;
		            		tn.m_Subject = tnote.Subject;
		            		tn.m_Classification = tnote.Classification__c;
		            		tn.m_ActivityDate = tnote.ActivityDate;
		            		System.debug('mytask do i even do the note stuff2?  ' + tn);
		            		taskNoteList.add(tn);
		            		counter++;
		            	}	            	
	            	}
	            }
            }
            if (!isThereaCompany) {
            	s.m_ClosedTaskNotes = contactTaskNoteList;
            	System.debug('is there a company here? - nope ' + contactTaskNoteList);
            	myContactSubscribedLists.sort();
            	s.m_OtherLists =  myContactSubscribedLists;
            
            }            	
            else {
            	System.debug('is htere a company here? - yup ' + taskNoteList);
            	s.m_ClosedTaskNotes = taskNoteList;
            	myLists.sort();
            	s.m_OtherLists =  myLists;
            
            }
            s.m_FollowUpId = t.Id;
            s.m_FollowUpType = t.Type;
            s.m_FollowUpSubject = t.Subject;
            s.m_NextActivityDate = t.ActivityDate;
            s.m_NextActivityOwnerName = t.Owner.Name;
            s.m_FollowupDescription = t.Description;
            s.m_FollowUpStatus = t.Status;
            s.m_FollowUpIsClosed = t.IsClosed;
            s.m_FollowUpClassification = t.Classification__c;
            
            if(cInfoList.size() > 0) {
        		s.m_OtherFollowupContacts = cInfoList; 
        	}
        	if (cInfoFullNameList.size() > 0) {
        		
        		s.m_OtherContactsFullName = cInfoFullNameList;
        	}
        
            if ( company_info != null ) {
                s.m_DealId = t.WhatId;
                s.m_DealName = t.What.Name;
            }
            System.debug('mytask s '+s.m_Subject);
           
            //summary_lookup.put(company_id, s);
            summary_results.add(s);
           // System.debug('mytask s do i actually add it?  '+s);
            loopcounter++;
            System.debug('mytask s loop counter ?  '+loopcounter);
        }
        return summary_results;
    }  
}