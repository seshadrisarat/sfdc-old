public with sharing class kjo_TaskReportController {
	
	private final Company_List__c company_list;
	
	List<Task> tasks;
    List<TaskSummary> summary_results;    
    public String TodayDate { get; set; }
    public String ListName  { get; set; }
    
    public kjo_TaskReportController(ApexPages.StandardController stdController) {
        this.company_list = (Company_List__c)stdController.getRecord();
        this.TodayDate = datetime.now().format('EEEEE, MMMM dd, yyyy'); 
        this.ListName =  getCompanyList(company_list.Id).Name;
    }
	
    public List<TaskSummary> getListTasksSummary() {
    	if ( summary_results == null ) {
    		CreateReport();
    	}
    	return summary_results;
    }
    
    public Company_List__c getCompanyList(String ListId) {
    	List<String> ids = new List<string>();
    	ids.add(ListId);
    	return
    	[
            SELECT Id, Name 
            FROM Company_List__c
            WHERE Id In: ids
        ];     	
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
    
    class ContactListInfo {
        ID m_Id;
        String m_Name;
        
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
        List<CompanyListInfo> m_OtherLists;
        List<CompanyFinancialInfo> m_Financials;
        List<ContactListInfo> m_OtherContacts;
        List<ContactListInfo> m_OtherFollowupContacts;        
        ContactInfo m_ListContact;
        
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
        
        public List<CompanyListInfo> GetOtherLists() {
        	return m_OtherLists;
        }
        
        public List<CompanyFinancialInfo> GetFinancials() {
        	return m_Financials;
        }
        
        public List<ContactListInfo> GetOtherContacts() {
        	return m_OtherContacts;
        }
        
        public List<ContactListInfo> GetOtherFollowUpContacts() {
        	return m_OtherFollowUpContacts;
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
    }
        
    public PageReference CreateReport() {
        summary_results = CreateSummaryResults(company_list.Id);
        return null;
    }
    
    public static List<TaskSummary> createSummaryResults(String ListId) {
    	
        TaskSummary s;
        Schema.SObjectType token;

        List<TaskSummary> summary_results = new List<TaskSummary>();
        Integer rowNumber = 0;

        // Get ID of Contact and/or Company List
        ID list_id = ID.valueOf(ListId);
        
        // This will contain a list of ids for companies on the list along 
        // with any deals linked to those companies.
        List<ID> ids = new List<ID>();
        Map<ID, CompanyInfo> company_ids = new Map<ID, CompanyInfo>();
        Map<ID, List<CompanyListInfo>> other_list_ids =  new Map<ID, List<CompanyListInfo>>(); 
        List<ID> taskContactIds = new List<ID>();        
        
        List<ID> contactCompanyListIds = new List<ID>(); 
        Map<ID, ContactInfo> contactCompanyids =  new Map<ID, ContactInfo>(); 

        // Assemble a list of companies on the list        
        List<Company_List_Member__c> company_list_members = [
            Select c.Id, c.Company__r.Id, c.Company__r.Name, 
            c.Company__r.LastActivityDate, c.Company__c, c.Company__r.Description, c.Company__r.Sector__c, c.Company__r.Geographies__c,
            c.Category__c, c.Contact__c, c.Contact__r.Name, c.Contact__r.Id, c.Contact__r.Title, c.Title__c, c.Contact_Full_Name__c
            From Company_List_Member__c c where Company_List__c = :list_id
            And ( Company__r.Id != null or Contact__r.Id != null )     
        ];
            
        for ( Company_List_Member__c m : company_list_members ) {
        	if ( m.Company__r.Id != null ) {
	            ids.add(m.Company__r.Id);
	            company_ids.put(m.Company__r.Id, 
	            	new CompanyInfo(m.Company__r.Id, m.Company__r.Name, m.Company__r.Description, m.Category__c, m.Company__r.Sector__c, m.Company__r.Geographies__c));
        	}
        	else
        	{
        		if(m.Contact__r.Id != null) {
        			contactCompanyListIds.add(m.Contact__r.Id);
        			contactCompanyids.put(m.Contact__r.Id, new ContactInfo(m.Contact__r.Id, m.Contact__r.Name, m.Title__c,  m.Category__c ));
        			system.debug(' Adding contact to list with Id: ' + m.Contact__r.Id); 
        		}
        	}
        }       

        // Get a list of any other lists on which the companies are present
        List<Company_List_Member__c> other_lists = [
            SELECT Company__c, Company__r.Id, Company_Name__c, Company_List__r.Id, Company_List__r.Name, Category__c 
            FROM Company_List_Member__c
            WHERE Company__c in :ids 
        ];
        
        List<CompanyListInfo> temp_l;
        for ( Company_List_Member__c m : other_lists ) {
        	temp_l = other_list_ids.get(m.Company__r.Id); 
        	if ( temp_l == null ) {
        		temp_l = new List<CompanyListInfo>();
        	}
        	if ( m.Company_List__r.Id != list_id ) {
        	   temp_l.add(new CompanyListInfo(m.Company_List__r.Id, m.Company_List__r.Name));
                other_list_ids.put( m.Company__r.Id, temp_l );
        	}
        }
        
        // Get the financials associated with the companies on the list
        Map<ID, Date> most_recent_financial_map = new Map<ID, Date>();
        Map<ID, List<CompanyFinancialInfo>> company_financial_map = new Map<ID, List<CompanyFinancialInfo>>();
        List<Financial__c> financials_list = [
            SELECT Book_Value__c, CAPEX__c, Company__c, Company_Currency__c, 
                CurrencyIsoCode, EBITDA__c, Enterprise_Value__c, 
                Market_Cap__c, Net_Income__c, Period_Ended__c, Period_Type__c, 
                Id, Revenues__c, Company__r.Id, Company__r.Name
            FROM Financial__c  
            WHERE
                Company__c in :ids AND
                IsDeleted = false
            ORDER BY 
                Company__r.Name, Period_Ended__c
        ];
        
        CompanyFinancialInfo temp_f;
        List<CompanyFinancialInfo> temp_f_list;
        for ( Financial__c f : financials_list ) {
        	Date d_f = most_recent_financial_map.get(f.Company__r.Id);
        	if ( d_f == null ) {
        		most_recent_financial_map.put(f.Company__r.Id, f.Period_Ended__c);
        		d_f = f.Period_Ended__c;
        	}
        	
        	if(d_f != null) {
	        	// Is d_f later that PeriodEnded
	        	if ( d_f.daysBetween(f.Period_Ended__c) <= 0 ) {
	        		temp_f_list = company_financial_map.get(f.Company__r.Id);
	        		if ( temp_f_list == null ) {
	        			temp_f = new CompanyFinancialInfo(
		                    f.Id,
		                    f.Book_Value__c,
		                    f.CAPEX__c,
		                    f.Company_Currency__c,
		                    f.CurrencyIsoCode,
		                    f.EBITDA__c,
		                    f.Enterprise_Value__c,
		                    f.Market_Cap__c,
		                    f.Net_Income__c,
		                    f.Period_Ended__c,
		                    f.Period_Type__c,
		                    f.Revenues__c
	        			);
	        			temp_f_list = new List<CompanyFinancialInfo>();
	        			temp_f_list.add(temp_f);
	        			company_financial_map.put(f.Company__r.Id, temp_f_list);
	        		} else {
	        			
	        			temp_f = temp_f_list[0];
	        			
	        			temp_f.m_BookValue = f.Book_Value__c;
	        			temp_f.m_CAPEX = f.CAPEX__c;
	        			temp_f.m_CompanyCurrency = f.Company_Currency__c;
	        			temp_f.m_CurrencyIsoCode = f.CurrencyIsoCode;
	        			temp_f.m_EBITDA = f.EBITDA__c;
	        			temp_f.m_EnterpriseValue = f.Enterprise_Value__c;
	        			temp_f.m_Id = f.Id;
	        			temp_f.m_MarketCap = f.Market_Cap__c;
	        			temp_f.m_NetIncome = f.Net_Income__c;
	        			temp_f.m_PeriodEnded = f.Period_Ended__c;
	        			temp_f.m_PeriodType = f.Period_Type__c;
	        			temp_f.m_Revenues = f.Revenues__c;
	        		}
	        	}
        	}
        }
        
        // Get a list of deals associated with the companies on the list            
        List<Deal__c> deal_list = [
           Select d.Id, d.Company__c From Deal__c d
           Where d.Company__c in :ids
        ];
            
        for ( Deal__c d : deal_list ) {
            ids.add(d.Id);
        }
        
        List<Task> all_tasks = [
		        Select
		            t.AccountId, t.WhoId, t.WhatId, t.Type, t.Subject, t.Status, 
		            t.ReminderDateTime, t.RecurrenceType, t.Priority, 
		            t.OwnerId, t.IsClosed, t.Id, t.Description, t.CreatedDate, 
		            t.CreatedById, t.CallType, t.CallObject, t.ActivityDate,
		            t.Owner.Name,
		            t.Account.Name, t.What.Name, t.What.Type, t.Who.Name, t.Who.Id, t.Who.Type,
		            t.Account.Description , t.Classification__c,
		            (Select Id, RelationId, TaskId, IsWhat, AccountId From TaskRelations )
		            From Task t
		            WHERE
		            /* 
		            OwnerId IN (
		                Select c.User_ID__c
		                From Contact c 
		                WHERE c.User_ID__c <> NULL 
		                AND c.User_ID__r.IsActive = true)
		            AND
		            */
		                (
		                /* exclude deal realated task as per IAS */
		                	 ( t.What.Type IN ('Account') AND t.What.Id IN :ids )
		                    OR ( t.Account.Id in :ids AND t.What.Type IN ('Account')) 
		                /*
		                    ( t.What.Type IN ('Account', 'Deal__c') AND t.What.Id IN :ids )
		                    OR ( t.Account.Id in :ids AND t.What.Type IN ('Account', 'Deal__c'))  */
		                )
		            ORDER BY ActivityDate DESC
        ];
        
        Map<ID, CompanyInfo>deal_lookup = new Map<ID, CompanyInfo>();
        
        for (Task t : all_tasks) {
            if ( t.AccountId == null ) {
                if ( t.WhatId != null ) {
                    token = t.WhatId.getSObjectType();
                    Schema.DescribeSObjectResult dr = token.getDescribe();
                    if (  dr.getName() == 'Deal__c' ) {
                        Deal__c deal = [SELECT Id, Company__r.Id, Company__r.Name, Company__r.Description, Company__r.Sector__c, Company__r.Geographies__c FROM Deal__c WHERE Id = :t.WhatId];
                        deal_lookup.put(deal.Id, new CompanyInfo(deal.Company__r.Id, deal.Company__r.Name, deal.Company__r.Description, null, deal.Company__r.Sector__c, deal.Company__r.Geographies__c));                    
                    }
                }
            }
            
           //Get an id list for all task contacts 
           if(t.TaskRelations != null) {
           		for(TaskRelation tr: t.TaskRelations) {
            		taskContactIds.add(tr.RelationId);
            	}
           }
        }
        
        Map<ID, Contact> contact_lookup = new Map<ID, Contact>();        
        contact_lookup = new map<ID, Contact>([Select c.Name, c.LastName, c.Id, c.Full_Name__c, c.FirstName FROM Contact c WHERE c.ID in :taskContactIds]);
                    
        Map<ID, TaskSummary> summary_lookup = new Map<ID, TaskSummary>();

        for (Task t : all_tasks) {
            
            CompanyInfo company_info = deal_lookup.get(t.WhatId);

            ID company_id = company_info != null ? company_info.m_Id : t.AccountId;
            String company_name = company_info != null ? company_info.m_Name : t.Account.Name;
            String company_description = company_info != null ? company_info.m_Description : (company_ids.get(company_id) != null ? company_ids.get(company_id).m_Description : '');
            String company_sector = company_info != null ? company_info.m_Sector : null;
            String company_geographies = company_info != null ? company_info.m_Geographies : null;
            
            List<ContactListInfo> cInfoList = new List<ContactListInfo>();
            ContactListInfo cInfo;            
            
            s = summary_lookup.get(company_id);
            if ( s == null ) {
                s = new TaskSummary();
	            s.m_CompanyId = company_id;
	            s.m_CompanyName = company_name;
	            s.m_CompanyDescription = company_description;
	            s.m_OtherLists = other_list_ids.get(company_id); 
	            s.m_Financials = company_financial_map.get(company_id);	
	            s.m_Sector = company_sector;
	            s.m_Geographies =   company_geographies;         
            }
            
            if(t.TaskRelations != null) {
            	cInfoList = new List<ContactListInfo>();
            	for(TaskRelation tr: t.TaskRelations) {
            		Contact contact = contact_lookup.get(tr.RelationId);
            		if(contact != null) {
            			cInfo = new ContactListInfo(contact.Id, contact.FirstName + ' ' + contact.LastName);
            			cInfoList.add(cInfo); 
            		}
            	}
            }            
      
            if ( t.IsClosed && (s.m_ActivityDate == null || s.m_ActivityDate < t.ActivityDate)) {
                s.m_Id = t.Id;
                s.m_Subject = t.Subject;
                s.m_Classification = t.Classification__c;
                s.m_Type = t.Type;
                s.m_ActivityDate = t.ActivityDate;
                s.m_ActivityOwnerName = t.Owner.Name;
                s.m_Description = t.Description;
                s.m_Status = t.Status;
                s.m_IsClosed = t.IsClosed;
                
                if(cInfoList.size() > 0) {
            		s.m_OtherContacts = cInfoList; 
            	}
                
            } else if ( !t.IsClosed && ( s.m_NextActivityDate == null || s.m_NextActivityDate < t.ActivityDate )) {
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
            }
            
            if ( company_info != null ) {
                s.m_DealId = t.WhatId;
                s.m_DealName = t.What.Name;
            }
            
            summary_lookup.put(company_id, s);
        }
        
        for ( ID list_company_id : company_ids.keySet() ) {
            s = summary_lookup.get(list_company_id);
            if ( s == null ) {
                s = new TaskSummary();
            }
            s.m_CompanyId = list_company_id;
            s.m_CompanyName = company_ids.get(list_company_id).m_Name;
            s.m_CompanyDescription = company_ids.get(list_company_id).m_Description;
            s.m_OtherLists = other_list_ids.get(list_company_id); 
            s.m_Financials = company_financial_map.get(list_company_id);
            s.m_CompanyCategory = company_ids.get(list_company_id).m_Category;
            s.m_Sector = company_ids.get(list_company_id).m_Sector;
	        s.m_Geographies =  company_ids.get(list_company_id).m_Geographies;  
            s.m_RowNumber = rowNumber;
            summary_results.add(s);
            rowNumber++;
        }
        
        

       //Add any contacts in the list to the task summary 
                      
        List<Task> contactTasks = [
        Select
            t.AccountId, t.WhoId, t.WhatId, t.Type, t.Subject, t.Status, 
            t.ReminderDateTime, t.RecurrenceType, t.Priority, 
            t.OwnerId, t.IsClosed, t.Id, t.Description, t.CreatedDate, 
            t.CreatedById, t.CallType, t.CallObject, t.ActivityDate,
            t.Owner.Name,
            t.Account.Name, t.What.Name, t.What.Type, t.Who.Name, t.Who.Id, t.Who.Type,
            t.Account.Description , t.Classification__c,
            (Select Id, RelationId, TaskId, IsWhat, AccountId From TaskRelations )
            From Task t
            WHERE   
                (
                    ( t.Who.Id IN :contactCompanyListIds )                    
                )
            ORDER BY ActivityDate DESC
        ];
        
        Map<ID, TaskSummary> contact_summary_lookup = new Map<ID, TaskSummary>();
         
        for (ContactInfo ci: contactCompanyids.values()) {
			TaskSummary sTaskContact = new TaskSummary();
       		//sTaskContact.m_CompanyName = ci.m_Name;
       		sTaskContact.m_ContactName  = ci.m_Name;
       		sTaskContact.m_ContactTitle = ci.m_Title; 
       		sTaskContact.m_ContactId = ci.m_Id; 
       		sTaskContact.m_RowNumber = rowNumber; 
       		contact_summary_lookup.put(ci.m_Id, sTaskContact);
       		summary_results.add(sTaskContact); 
       		rowNumber++;
        }
        
        //reset the ids for contacts
        taskContactIds = new List<ID>();   
        
        for (Task t : contactTasks) 
        {
          //Get an id list for all task contacts 
           if(t.TaskRelations != null) {
           		for(TaskRelation tr: t.TaskRelations) {
            		taskContactIds.add(tr.RelationId);
            	}
           }
        }
        contact_lookup = new map<ID, Contact>([Select c.Name, c.LastName, c.Id, c.Full_Name__c, c.FirstName FROM Contact c WHERE c.ID in :taskContactIds]);
                    
        
           for (Task t : contactTasks) 
           {        		       		
        		ContactInfo contact_info = contactCompanyids.get(t.WhoId);
            	//ID contact_id = contact_info != null ? contact_info.m_Id : t.WhoId; 
            	ID contact_id =contact_info.m_Id;        	  		
 		   		s = contact_summary_lookup.get(contact_id); 		   		
 		   		List<ContactListInfo> cInfoList = new List<ContactListInfo>();
 		   		ContactListInfo cInfo;
 		   			   		
 		   		system.debug(' Who Id: ' + t.WhoId); 
 		   		system.debug(' Contact Id: ' + contact_id); 
 		   		system.debug(' Contact Name: ' + contact_info.m_Name);
 		   		system.debug(' Subject: ' + t.Subject);
 		   		system.debug(' IsClosed: ' + t.IsClosed);
 		   		system.debug(' Activity Date last : ' + s.m_ActivityDate);
 		   		system.debug(' Activity Date task : ' + t.ActivityDate);
 		   		
 		   		if(t.TaskRelations != null) {
	            	cInfoList = new List<ContactListInfo>();
	            	for(TaskRelation tr: t.TaskRelations) {
	            		Contact contact = contact_lookup.get(tr.RelationId);
	            		if(contact != null) {
	            			cInfo = new ContactListInfo(contact.Id, contact.FirstName + ' ' + contact.LastName);
	            			cInfoList.add(cInfo); 
	            		}
            		}
            	}  		   		
 		   		
 		   		
            	//if ( s == null ) { 
			   		if ( t.IsClosed && (s.m_ActivityDate == null || s.m_ActivityDate < t.ActivityDate)) 
			   		{			   			
			            s.m_Id = t.Id;
			            s.m_Subject = t.Subject;		            
			            
			            s.m_Classification = t.Classification__c;
			            s.m_Type = t.Type;
			            s.m_ActivityDate = t.ActivityDate;
			            s.m_ActivityOwnerName = t.Owner.Name;
			            s.m_Description = t.Description;
			            s.m_Status = t.Status;
			            s.m_IsClosed = t.IsClosed;			            
			            
			            if(cInfoList.size() > 0) {
			        		s.m_OtherContacts = cInfoList; 
			        	} 			            
			        }
			        else if ( !t.IsClosed && ( s.m_NextActivityDate == null || s.m_NextActivityDate < t.ActivityDate ))
			        {
			            s.m_FollowUpId = t.Id;
			            s.m_FollowUpType = t.Type;
			            s.m_FollowUpSubject = t.Subject;
			            system.debug(' Subject follow up: ' + t.Subject);			            
			            s.m_NextActivityDate = t.ActivityDate;
			            s.m_NextActivityOwnerName = t.Owner.Name;
			            s.m_FollowupDescription = t.Description;
			            s.m_FollowUpStatus = t.Status;
			            s.m_FollowUpIsClosed = t.IsClosed;
			            s.m_FollowUpClassification = t.Classification__c;
			           
			            if(cInfoList.size() > 0) {
			        		s.m_OtherFollowupContacts = cInfoList; 
			        	} 
			        } 
            	}
           //}	
      
        /*
        for (ContactInfo ci: contactCompanyids.values()) {
        	s = contact_summary_lookup.get(ci.m_Id);
            	if ( s != null ) { 
            		summary_results.add(s);
            	}      
        } 
        */
        
        return summary_results;

    	
    }
    
    @RemoteAction
    public static List<TaskSummary> getTaskSummaryInformation(String ListId) {
    	return CreateSummaryResults(ListId);
    }
    
    public List<TaskSummary> getTaskSummaryInformationAsExcel() {
        return CreateSummaryResults(this.company_list.Id);
    }

	public List<Task> getListTasks() {
		
        ID list_id = ID.valueOf('a0rL00000014g6X');
        
        List<ID> ids = new List<ID>();
		
		List<Company_List_Member__c> company_list_members = [
            Select c.Id, c.Company__r.Id, c.Company__r.Name, 
            c.Company__r.LastActivityDate, c.Company__c
            From Company_List_Member__c c where Company_List__c = :list_id     
		];
		
        for ( Company_List_Member__c m : company_list_members ) {
            ids.add(m.Company__r.Id);
        }
        
        List<Deal__c> deal_list = [
           Select d.Id, d.Company__c From Deal__c d
           Where d.Company__c in :ids
        ];
        
        for ( Deal__c d : deal_list ) {
        	ids.add(d.Id);
        }

        tasks = [Select
                    t.AccountId, t.WhoId, t.WhatId, t.Type, t.Subject, t.Status, 
                    t.ReminderDateTime, t.RecurrenceType, t.Priority, 
                    t.OwnerId, t.IsClosed, t.Id, t.Description, t.CreatedDate, 
                    t.CreatedById, t.CallType, t.CallObject, t.ActivityDate,
                    t.Owner.Name,
                    t.Account.Name, t.What.Name, t.What.Type, t.Who.Name, t.Who.Id, t.Who.Type 
                    From Task t
                    WHERE OwnerId IN (
                        Select c.User_ID__c
                        From Contact c 
                        WHERE c.User_ID__c <> NULL 
                        AND c.User_ID__r.IsActive = true)
                    AND
                        (
                            ( t.What.Type IN ('Account', 'Deal__c') AND t.What.Id IN :ids )
                            OR ( t.Account.Id in :ids AND t.What.Type IN ('Account', 'Deal__c')) 
                        )
                    ORDER BY 
                        t.ActivityDate DESC
        ];
        
	   return tasks;
	}
	
    public List<Task> getCompanyAndDealTasks() {
        if ( tasks == null ) {
        	
        	List<ID> ids = new List<ID>();
        	ids.add(ID.valueOf(System.currentPageReference().getParameters().get('id')));

            List<Deal__c> assoc_deals = [SELECT Id FROM Deal__c where Company__r.Id IN :ids];
        	
        	for ( Deal__c d : assoc_deals ) {
        		ids.add(d.Id);
        	}
        	
            tasks = [Select
		                    t.AccountId, t.WhoId, t.WhatId, t.Type, t.Subject, t.Status, 
		                    t.ReminderDateTime, t.RecurrenceType, t.Priority, 
		                    t.OwnerId, t.IsClosed, t.Id, t.Description, t.CreatedDate, 
		                    t.CreatedById, t.CallType, t.CallObject, t.ActivityDate,
		                    t.Owner.Name,
		                    t.Account.Name, t.What.Name, t.What.Type, t.Who.Name, t.Who.Id, t.Who.Type 
                        From Task t
                        WHERE OwnerId IN (
                            Select c.User_ID__c
                            From Contact c 
                            WHERE c.User_ID__c <> NULL 
                            AND c.User_ID__r.IsActive = true)
                        AND
                            What.Type IN ('Account', 'Deal__c') AND 
                            What.Id IN :ids
                        ORDER BY 
                            t.ActivityDate DESC
            ];
        }
        return tasks;
    }   

    public List<Task> getCompanyAndDealTasksByTeam() {
    	
        if ( tasks == null ) {
            
            /* ids.add(ID.valueOf(System.currentPageReference().getParameters().get('id'))); */

            tasks = [Select
		                    t.AccountId, t.WhoId, t.WhatId, t.Type, t.Subject, t.Status, 
		                    t.ReminderDateTime, t.RecurrenceType, t.Priority, 
		                    t.OwnerId, t.IsClosed, t.Id, t.Description, t.CreatedDate, 
		                    t.CreatedById, t.CallType, t.CallObject, t.ActivityDate,
		                    t.Owner.Name,
		                    t.Account.Name, t.What.Name, t.What.Type, t.Who.Name, t.Who.Id, t.Who.Type 
                        From Task t
                        WHERE OwnerId IN (
                            Select c.User_ID__c
                            From Contact c 
                            WHERE c.User_ID__c <> NULL 
                            AND c.User_ID__r.IsActive = true
                            AND WP_Group__c = 'TMT')
                        AND
                            What.Type IN ('Account', 'Deal__c')
                        ORDER BY 
                            t.ActivityDate DESC
            ];
        }
        return tasks;
    }
    
    public List<Task> getUsersTasks() {
 
        tasks = [Select
                        t.AccountId, t.WhoId, t.WhatId, t.Type, t.Subject, t.Status, 
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
    
    public List<Task> getUsersTasksActiveAndByDate() {
 
        tasks = [Select
                        t.AccountId, t.WhoId, t.WhatId, t.Type, t.Subject, t.Status, 
                        t.ReminderDateTime, t.RecurrenceType, t.Priority, 
                        t.OwnerId, t.IsClosed, t.Id, t.Description, t.CreatedDate, 
                        t.CreatedById, t.CallType, t.CallObject, t.ActivityDate,
                        t.Owner.Name,
                        Account.Name, What.Name, What.Type, Who.Name, Who.Id, Who.Type 
                        From Task t
                        WHERE
                            What.Type IN ('Account', 'Deal__c') 
                            AND t.OwnerId = :UserInfo.getUserId()
                            AND ( t.IsClosed = false OR ( t.ActivityDate >= :date.today() AND t.ActivityDate < :date.today().addDays(7)) )
                        ORDER BY 
                            t.ActivityDate DESC
        
        ];
        
        return tasks;
    }

    public String getUserTasksAsHTML() {
    	
    	getUsersTasksActiveAndByDate();
    	
    	List<String> message = new List<String>();
    	String task_info;
    	
    	message.add('<table border="1" cellpadding="4" cellspacing="0">');
    	for( Task t : tasks ) {
    		task_info = String.format(
    		  '<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td></tr>', 
    		  new String[] {
    		  	t.What.Name != null ? t.What.Name : t.Account.Name,
    		  	String.valueOf(t.ActivityDate), 
    		  	t.Subject,
                t.Description,
                t.IsClosed == true ? 'Complete' : 'Pending'
    		  	}
    	    );
    		message.add(task_info);
    	}
        message.add('</table>');
    	return String.join(message, '<br/>');
    }
    
    public void sendEmailDigest() {
    	
        String testvar = System.currentPageReference().getParameters().get('testvar');
        
		Messaging.reserveSingleEmailCapacity(2);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		String[] toAddresses = new String[] {'kieran.owens@warburgpincus.com'}; 
		
		mail.setToAddresses(toAddresses);
		
		mail.setReplyTo('kieran.owens@warburgpincus.com');
		mail.setSenderDisplayName('Salesforce Prospecting Task Digest');
		mail.setSubject('Salesforce Prospecting Task Digest');
		mail.setBccSender(false);
		mail.setUseSignature(false);
		
		String htmlBody = getUserTasksAsHTML();
		mail.setHtmlBody(htmlBody);
		
		// Send the email you have created.
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    	
    }   

}