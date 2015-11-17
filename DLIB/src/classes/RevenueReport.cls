public without sharing class RevenueReport {
	public pse__Proj__c params 			{get;set;}
	public String strRecPerPage         {get;set;}
	public list<Project> reportdata;
	
	public Decimal totalBA 				{get;set;}
	public Decimal totalAdj				{get;set;}
	public Decimal totalRev				{get;set;}
	
	private list<pse__Proj__c> projects;
	private map<Id,decimal> mapTimecards;
	private map<Id,decimal> mapInvoices;
    private String sortDirection = 'ASC';
    private String sortExp = 'Name';
    private Boolean isRefresh = true;
		
	public RevenueReport() {
		init();
	}
	
	public void refresh() {
		isRefresh = true;
		controller = null;
		processdata();
	}
	
	public void searchProjects() {
		isRefresh = false;
		updateProjects();
		controller = null;
		processdata();
	}
	
	public void fullrefresh() {
		isRefresh = true;
		updateProjects();
		controller = null;
		processdata();
	}
	
	public void processdata() {
		projects = getProjects();
		mapTimecards = getMapTimecards();
		mapInvoices = getMapInvoices();
		reportdata = getReportData();
	}
	
	public void updateProjects() {
		projects = new list<pse__Proj__c>([Select Id, Name, tmpBillableAmount__c, tmpInvoiceTotal__c, tmpRevenue__c 
				//FROM pse__Proj__c WHERE pse__Is_Active__c=true AND (pse__Billing_Type__c='Time and Materials' OR pse__Billing_Type__c='T&M')]);
				FROM pse__Proj__c WHERE pse__Is_Active__c=true AND pse__Project_Type__c='Customer']);
		mapTimecards = getMapTimecards();
		mapInvoices = getMapInvoices();
		for (pse__Proj__c item:projects) {
			item.tmpBillableAmount__c = mapTimecards.get(item.Id);
			item.tmpInvoiceTotal__c = mapInvoices.get(item.Id);
			item.tmpRevenue__c = item.tmpBillableAmount__c + item.tmpInvoiceTotal__c;
		}

		Database.SaveResult[] updateResults = Database.Update(projects, false);
		for (Database.SaveResult item:updateResults) {
			if(!item.isSuccess()) {
				system.debug('Error:: '+item.getErrors().get(0));
			}
		}

		controller = null;
		projects = getProjects();
		reportdata = getReportData();
	}
	
	public list<Project> getReportData() {
		list<Project> result = new List<Project>();
		totalBA = 0;
		totalAdj = 0;
		totalRev = 0;
		Project proj;
		for (pse__Proj__c item:projects) {
			proj = new Project(item, mapTimecards.get(item.Id), mapInvoices.get(item.Id));
			result.add(proj);
			totalBA += proj.BillableAmount;
			totalAdj += proj.TotalInvoice;
			totalRev += proj.Revenue;
		}
		return result;
	}
	
	private void init() {
		Date initdate = date.today();
		strRecPerPage = '400';

		try {
			initdate = Date.parse(ApexPages.currentPage().getParameters().get('date'));
		} catch (exception e) {
			system.debug('Error:: ' + e.getMessage());
		}
		params = new pse__Proj__c(pse__End_Date__c = initdate);
		refresh();
	}
	
	private ApexPages.StandardSetController controller {
        get {
            if(controller == null) {
            	string searchpart = '';
            	if (params.pse__Notes__c!=null && !isRefresh) searchpart = ' AND Name like \'%'+params.pse__Notes__c+'%\'';
            	string soql = 'Select Id, Name, tmpBillableAmount__c, tmpInvoiceTotal__c, tmpRevenue__c FROM pse__Proj__c WHERE pse__Is_Active__c=true AND pse__Project_Type__c=\'Customer\' '+searchpart+' ORDER BY '+sortExpression+' '+sortDirection;
                controller = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
                controller.setPageSize(intRecPerPage);
            }
            return controller;
        }
        set;
    }
	
	private list<pse__Proj__c> getProjects() {
		return (List<pse__Proj__c>)controller.getRecords();
	}
	
	private map<Id,Decimal> getMapTimecards() {
		map<Id,decimal> result = new map<Id,decimal>();
		if (projects!=null) {
			for (AggregateResult item:[Select SUM(pse__Total_Billable_Amount__c) sum, pse__Project__c 
										FROM pse__Timecard__c WHERE pse__End_Date__c<=:params.pse__End_Date__c 
										AND pse__Billed__c = false AND pse__Billable__c = true
										AND pse__Status__c = 'Approved'  
										AND pse__Project__r.pse__Project_Type__c = 'Customer'
										AND pse__Project__r.pse__Is_Active__c = true
										GROUP BY pse__Project__c HAVING pse__Project__c IN :projects]) {
				result.put((ID)item.get('pse__Project__c'), double.ValueOf(item.get('sum')));				
			}
		}
		fillEmptyKeys(result);
		return result;
	}

	private map<Id,Decimal> getMapInvoices() {
		map<Id,decimal> result = new map<Id,decimal>();
		decimal sum = 0;
		decimal prepsasum = 0;
		if (projects!=null) {
			/*for (AggregateResult item:[Select SUM(Total_Invoice_Amount__c) sum, SUM(Total__c) prepsasum, PSA_Project__c 
										FROM Invoice__c WHERE Expenses__c = 0 
										GROUP BY PSA_Project__c HAVING PSA_Project__c IN :projects AND pse__Project__r.pse__Billing_Type__c = 'Time and Materials']) {
				sum = item.get('sum')==null?0:double.ValueOf(item.get('sum'));
				prepsasum = item.get('prepsasum')==null?0:double.ValueOf(item.get('prepsasum'));
				result.put((ID)item.get('PSA_Project__c'), sum + prepsasum);					
			}*/
			for (AggregateResult item:[Select SUM(pse__Amount__c) sum, pse__Project__c 
										FROM pse__Miscellaneous_Adjustment__c WHERE pse__Effective_Date__c<=:params.pse__End_Date__c 
										AND pse__Billed__c = false 
										AND pse__Project__r.pse__Project_Type__c = 'Customer'
										AND pse__Project__r.pse__Is_Active__c = true
										AND pse__Project__r.pse__Practice__r.Name = 'Services' 
										GROUP BY pse__Project__c HAVING pse__Project__c IN :projects]) {
				result.put((ID)item.get('pse__Project__c'), double.ValueOf(item.get('sum')));			
			}
		}
		fillEmptyKeys(result);
		return result;
	}
	
	private void fillEmptyKeys(map<Id,decimal> dMap) {
		for (pse__Proj__c item:projects) {
			if (!dMap.containsKey(item.id)) {
				dMap.put(item.Id,0);
			}
		}
	}
	
	public class Project {
		public pse__Proj__c project		{get;set;}
		public decimal BillableAmount	{get;set;}
		public decimal TotalInvoice		{get;set;}
		public decimal Revenue			{get;set;}
		public Project(pse__Proj__c p_project, decimal p_BillableAmount, decimal p_TotalInvoice) {
			this.project = p_project;
			this.BillableAmount = p_BillableAmount;
			this.TotalInvoice = p_TotalInvoice;
			this.Revenue = p_BillableAmount + p_TotalInvoice;
		}
	}
	
	private integer intRecPerPage {
        get {
            integer res;
            try {
                res = Integer.valueOf(strRecPerPage);
            } catch (exception e) {
                res = 0;
            }
            return res;
        }
        set;
    }

    public String sortExpression {
        get {
            return sortExp;
        }
        set
        {
           //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
           else
                sortDirection = 'ASC';
           sortExp = value;
        }
    }

    public String getSortDirection()
    {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
         return sortDirection;
    }

    public void setSortDirection(String value)
    {  
       sortDirection = value;
    }
    
    public list<SelectOption> getNumRecords() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('20','20'));
        options.add(new SelectOption('50','50'));
        options.add(new SelectOption('100','100'));
        options.add(new SelectOption('400','400'));
        options.add(new SelectOption('1000','1000'));
        return options;
    }
	
	//this parameter is used to disable "Next", "Last" pagination buttons on the last available page 
    public Boolean hasNext  
    {  
        get  
        {  
            Boolean hn = false;
            if (controller!=null) hn = controller.getHasNext();
            return hn;  
        }  
        set;  
    }  
    
    //this parameter is used to disable "First", "Previous" pagination buttons on the first page 
    public Boolean hasPrevious  
    {  
        get  
        {  
            Boolean hp = false;
            if (controller!=null) hp = controller.getHasPrevious();
            return hp;  
        }  
        set;  
    }  
    
    //this is total number of all pages
    public Integer allPages  
    {  
        get  
        {  
            Integer p = 0;
            if (controller!=null) 
            {
                p = controller.getResultSize()/intRecPerPage;
                if (Math.mod(controller.getResultSize(),intRecPerPage)>0) p=p+1;
            }
            return p;  
        }  
        set;  
    }  
  
    //this is current page number
    public Integer pageNumber  
    {  
        get  
        {  
            Integer pn = 0;
            if (controller!=null) pn = controller.getPageNumber();
            return pn;  
        }  
        set;  
    }   
  
    //this method is used to move to the previous page
    public void previous()  
    {  
        controller.previous(); 
        processdata();
    }  
    
    //this method is used to move to the next page
    public void next()  
    {  
        controller.next();
        processdata();
    }
    
    //this method is used to move to the first page
    public void first()  
    {  
        controller.first();
        processdata();
    }  
    
    //this method is used to move to the last page
    public void last()  
    {  
        controller.last();
        processdata();
    }
	
}

	/*public void doSort() {
		ReportData = doSort(ReportData);
	}
	
	public list<Project> doSort(list<Project> p_ReportData) {
		list<Project> result = new List<Project>();
		list<string> lstSort = new list<string>();
		map<string,Project> mapReportData = new map<string,Project>();
		string key;
		for (Project item:p_ReportData) {
			if (sortExpression=='Amount') {
				key = pad(String.ValueOf(item.BillableAmount),16);
			} else if (sortExpression=='Invoice') {
				key = pad(String.ValueOf(item.TotalInvoice),16);
			} else if (sortExpression=='Revenue') {
				key = pad(String.ValueOf(item.Revenue),16);
			} else {
				key = item.project.Name;
			}
			key = key + '-' + item.project.Id;
			
			system.debug('-----key='+key);
			lstSort.add(key);
			mapReportData.put(key, item);
		}
		
		lstSort.sort();
		
		if (sortDirection=='ASC') {
			for (string keyitem:lstSort) {
				result.add(mapReportData.get(keyitem));
			}
		} else if (sortDirection=='DESC') {
			for(integer i = lstSort.size()-1; i>=0;i--)
			{
			    result.add(mapReportData.get(lstSort.get(i)));
			}
		}
		return result;
	}
	
	private string pad (string str, integer max) {
  		return str.length() < max ? pad('0' + str, max) : str;
	}*/

		/*public PageReference printXls() {
		return print('Xls');
	}
	
	public PageReference printPdf() {
		return print('Pdf');
	}
	
	private PageReference print(string ext) {
		PageReference p = new PageReference('/apex/RevenueReport'+ext+'?date=' + String.ValueOf(params.pse__End_Date__c).replace(' 00:00:00',''));
		p.setRedirect(true);
		return p;
	}*/