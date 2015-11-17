public class RevenueReportPrint {
	public pse__Proj__c params 			{get;set;}
	public string reportDate			{get;set;}
	public list<Project> reportdata;

	public Decimal totalBA 				{get;set;}
	public Decimal totalAdj				{get;set;}
	public Decimal totalRev				{get;set;}	
	
	private list<pse__Proj__c> projects;
	private map<Id,decimal> mapTimecards;
	private map<Id,decimal> mapInvoices;
	
	public RevenueReportPrint() {
		init();
	}
	
	public void refresh() {
		projects = getProjects();
		mapTimecards = getMapTimecards();
		mapInvoices = getMapInvoices();
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
		reportDate = String.ValueOf(initdate).replace(' 00:00:00','');
		try {
			initdate = Date.parse(ApexPages.currentPage().getParameters().get('date'));
		} catch (exception e) {
			system.debug('Error:: ' + e.getMessage());
		}
		params = new pse__Proj__c(pse__End_Date__c = initdate);
		refresh();
	}
	
	private list<pse__Proj__c> getProjects() {
		list<pse__Proj__c> result = new List<pse__Proj__c>();
		//if (projects == null) {
			result = [Select Id, Name FROM pse__Proj__c WHERE pse__Is_Active__c=true AND pse__Project_Type__c='Customer' ORDER BY Name];
		//}
		return result;
	}
	
	private map<Id,Decimal> getMapTimecards() {
		map<Id,decimal> result = new map<Id,decimal>();
		//if (mapTimecards == null && projects!=null) {
		if (projects!=null) {
			/*for (AggregateResult item:[Select SUM(pse__Total_Billable_Amount__c) sum, pse__Project__c 
										FROM pse__Timecard__c WHERE pse__End_Date__c<=:params.pse__End_Date__c 
										AND pse__Billed__c = false AND pse__Invoiced__c = false  
										AND (pse__Project__r.pse__Billing_Type__c = 'Time and Materials' OR pse__Project__r.pse__Billing_Type__c='T&M') 
										GROUP BY pse__Project__c HAVING pse__Project__c IN :projects]) {*/
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
		//if (mapInvoices == null && projects!=null) {
		if (projects!=null) {
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
}