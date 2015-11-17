@isTest
private class Test_CompanyListSearch_Controller 
{
	public static testMethod void testMethod1() {
		System.currentPageReference().getParameters().put('target','2');
		System.currentPageReference().getParameters().put('picklist','recordtypeid');
		CompanyListSearch_Controller controller = new CompanyListSearch_Controller();

		system.debug('======== hasNext ======== >>>> '+controller.hasNext);
		system.debug('======== hasPrevious ======== >>>> '+controller.hasPrevious);
		system.debug('======== pageNumber ======== >>>> '+controller.pageNumber);
		system.debug('======== pageSize ======== >>>> '+controller.pageSize);

		String cid;
		Company_List__c compLst = new Company_List__c();
		insert compLst;
		cid = compLst.Id;
		System.currentPageReference().getParameters().put('clid',''+cid);
		
		controller.doSearch();
		
		system.debug('======== CompanyList ======== >>>> '+controller.CompanyList);
		controller.sortExpression = 'Name';
		controller.setSortDirection('ASC');
		system.debug('======== getSortDirection ======== >>>> '+controller.getSortDirection());
		List<Account> accs = new List<Account>();
		accs.add(new Account(Name = 'Test 1'));
		accs.add(new Account(Name = 'Test 2'));
		accs.add(new Account(Name = 'Test 3'));
		insert accs;
		controller.m_std_controller = new ApexPages.Standardsetcontroller([select Id from Account limit 3]);
		system.debug('======== getAccounts ======== >>>> '+controller.getAccounts());
		controller.process();
		system.debug('======== hasNext ======== >>>> '+controller.hasNext);
		system.debug('======== hasPrevious ======== >>>> '+controller.hasPrevious);
		system.debug('======== pageNumber ======== >>>> '+controller.pageNumber);
		system.debug('======== pageSize ======== >>>> '+controller.pageSize);
		controller.first();
		controller.last();
		controller.previous();
		controller.next();
		controller.cancel();
		controller.doAdd();
		controller.doAddContinue();
		
		Account currComp = new Account(Name = 'Test Company 1');
		insert currComp;
		Company_List__c cmpList = new Company_List__c();
		insert cmpList;
		Company_List_Member__c clm = new Company_List_Member__c(Company__c = currComp.Id, Company_List__c = cmpList.Id);
		insert clm;
		
		controller.addCLObj = clm;
		controller.doSearch();
		controller.addCLObj = null;
		

		
		controller.addCLObj = clm;
		controller.SearchSection = 'CL';
		controller.doSearch();
		controller.addCLObj = null;
		
		
		controller.SearchQ = 'question';
		controller.SearchParam = 'param';
		controller.SearchSection = 'F';
		controller.doSearch();
		controller.SearchQ = null;
		
		controller.SearchQ = '';
		controller.SearchParam = '';
		controller.SearchObj = '3';
		controller.doSearch();
		
		controller.doCancel();
		system.debug('======== event ======== >>>> '+controller.event);
		system.debug('======== filterSet ======== >>>> '+controller.filterSet);
		system.debug('======== filterAdvenced ======== >>>> '+controller.filterAdvenced);
		system.debug('======== picklistName ======== >>>> '+controller.picklistName);
		
		controller.EventHandler();
		
		CompanyListSearch_Controller.JSONObject JSobj = new CompanyListSearch_Controller.JSONObject();
		system.debug('======== JSobj.Json ======== >>>> '+JSobj.Json);
		
		controller.doReset();
		controller.clSearch();
		controller.getLCPickListValue();
		
		controller2 controller2 = new controller2();
		
		CompanyList_Search cl_s_controller = new CompanyList_Search();
		cl_s_controller.filterIndex = 0;
		cl_s_controller.filterField = 'Name';
		cl_s_controller.addFilter();
		cl_s_controller.changeFilter1();
		cl_s_controller.changeFilter2();
		cl_s_controller.changeType();
		
		CompanyListSearch_Controller.parseCSV('test',true);
	} 
	
	public static testMethod void testMethod2() { // Test CompanyList_Search_Filter.cls
		CompanyList_Search_Filter controller = new CompanyList_Search_Filter('Account');
		
		for (Integer i=0; i<controller.filters.size(); i++) {
			controller.filters[i].field = 'Name';
			controller.filters[i].operator = 'e';
			controller.filters[i].param1 = '1';
			controller.filters[i].param2 = '2';
		}
		system.debug('==== getSimpleQuery() ==== >>>> '+controller.getSimpleQuery());
		system.debug('==== prepareQuery() ==== >>>> '+controller.prepareQuery());

		for (Integer i=0; i<controller.filters.size(); i++) {
			controller.filters[i].field = 'CreatedDate';
			controller.filters[i].operator = 'ge';
			controller.filters[i].param1 = '2010-12-12T01:01:01.000Z';
			controller.filters[i].param2 = '2';
		}
		system.debug('==== getSimpleQuery() ==== >>>> '+controller.getSimpleQuery());
		system.debug('==== prepareQuery() ==== >>>> '+controller.prepareQuery());

		for (Integer i=0; i<controller.filters.size(); i++) {
			controller.filters[i].field = 'Id';
			controller.filters[i].operator = 'ge';
			controller.filters[i].param1 = '1';
			controller.filters[i].param2 = '2';
		}
		system.debug('==== getSimpleQuery() ==== >>>> '+controller.getSimpleQuery());
		system.debug('==== prepareQuery() ==== >>>> '+controller.prepareQuery());
		for (Integer i=0; i<controller.filters.size(); i++) {
			controller.filters[i].field = 'Activity_Score__c';
			controller.filters[i].operator = 'l';
			controller.filters[i].param1 = '1';
			controller.filters[i].param2 = '2';
		}
		system.debug('==== getSimpleQuery() ==== >>>> '+controller.getSimpleQuery());
		system.debug('==== prepareQuery() ==== >>>> '+controller.prepareQuery());
		
		for (Integer i=0; i<controller.filters.size(); i++) {
			controller.filters[i].field = 'Activity_Score__c';
			controller.filters[i].operator = 'le';
			controller.filters[i].param1 = '1';
			controller.filters[i].param2 = '2';
		}
		system.debug('==== getSimpleQuery() ==== >>>> '+controller.getSimpleQuery());
		system.debug('==== prepareQuery() ==== >>>> '+controller.prepareQuery());
		
		controller.currentIndex = 0;
		controller.removeFilter();
	}
	
	class Controller2 extends CompanyListSearch_Controller {
		public controller2() {
			CompanyListSearch_Controller obj = new CompanyListSearch_Controller();
			obj.eventActionLoad();
			obj.eventActionSearch();
			obj.getPicklistJson();
			obj.m_sort_expresion = 'Name';
			obj.m_sort_direction = 'ASC';
			obj.sortExpression = 'Name';
			
			List<JSONObject> lst = new List<JSONObject>();
			lst.add(new JSONObject());
			lst.add(new JSONObject());
			lst[0].Value = 'Test Val 1';
			lst[1].Value = 'Test Val 2';
			
			system.Debug('==== getItemByNameFromList() ==== >>>> '+getItemByNameFromList(lst, 'Test Val 1'));
		}
	}
	
}