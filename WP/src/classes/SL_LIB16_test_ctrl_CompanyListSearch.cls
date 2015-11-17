@isTest(SeeAllData=true)
private class SL_LIB16_test_ctrl_CompanyListSearch 
{
	public static testMethod void testMethod1() {

		String cid;
		Company_List__c compLst = new Company_List__c();
		insert compLst;
		cid = compLst.Id;
		System.currentPageReference().getParameters().put('clid',''+cid);

		SL_LIB16_ctrl_CompanyListSearch controller = new SL_LIB16_ctrl_CompanyListSearch();
		SL_LIB16_ctrl_CompanyListSearch.CompanyExtend sObjInnerClass = new SL_LIB16_ctrl_CompanyListSearch.CompanyExtend();//Added bys andeep
		
		system.debug('======== hasNext ======== >>>> '+controller.hasNext);
		system.debug('======== hasPrevious ======== >>>> '+controller.hasPrevious);
		system.debug('======== pageNumber ======== >>>> '+controller.pageNumber);
		system.debug('======== pageSize ======== >>>> '+controller.pageSize);
		
		controller.checkUserPermission();
		controller.doSearch();
		String str = controller.CompanyListID;
		
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
		
		Account currComp = new Account(Name = 'Test 201502 Company 1');
		insert currComp;
		
		Contact objContact = new Contact(AccountId=currComp.Id, LastName='Test');
		insert objContact;
		
		Account currComp2 = new Account(Name = 'Test 2015.02 Company 2');
		insert currComp2;
		Account currComp3 = new Account(Name = 'Test 3 Company 3');
		insert currComp3;
		Company_List__c cmpList = new Company_List__c();
		insert cmpList;
		Company_List_Member__c clm = new Company_List_Member__c(Company__c = currComp.Id, Company_List__c = cmpList.Id);
		insert clm;
		
		Company_List_Member__c clm1 = new Company_List_Member__c(Contact__c =objContact.Id, Company_List__c = cmpList.Id );
		insert clm1;
		/*added by sandeep*/
		controller.calculatePaginationMetrics();
		controller.FirstPage = 1;
		controller.CurrentPageSize = 5;
		controller.TotalRows = 12;
		controller.previousPage();
		controller.lastPage();
		controller.nextPage();
		
		
		controller.strClickedFromAccountOrContact = 'Account';
		controller.firstPage();
		sObjInnerClass.Checked = true;
		sObjInnerClass.Item = currComp;
		controller.doAddCompanyContact();
		controller.doAddContactCompanyContinue();
		sObjInnerClass.Checked= false;
		controller.doSearchForCompanies();
		controller.doSearchForContacts();
		controller.strClickedFromAccountOrContact = 'Contact';
		sObjInnerClass.Checked = true;
		controller.doSearchForCompanies();
		controller.doSearchForContacts();
		controller.doAddCompanyContact();
		controller.doAddContactCompanyContinue();
		controller.updateIECheckbox();
		controller.doSearch();
		controller.strClickedFromAccountOrContact = 'Account';
		controller.doSearchForCompanies();
		controller.strClickedFromAccountOrContact = 'Contact';
		controller.doSearchForContacts();
		
		
		
		SL_LIB16_ctrl_CompanyListSearch.CompanyExtend CEItem = new SL_LIB16_ctrl_CompanyListSearch.CompanyExtend();
		CEItem = new SL_LIB16_ctrl_CompanyListSearch.CompanyExtend(currComp2);
		CEItem = new SL_LIB16_ctrl_CompanyListSearch.CompanyExtend(currComp2,true);
		SL_LIB16_ctrl_CompanyListSearch.CompanyExtend CEItem2 = new SL_LIB16_ctrl_CompanyListSearch.CompanyExtend(currComp3,false);
		
		List<SL_LIB16_ctrl_CompanyListSearch.CompanyExtend> lstMComps = new List<SL_LIB16_ctrl_CompanyListSearch.CompanyExtend>();
		lstMComps.add(CEItem);
		lstMComps.add(CEItem2);
		
		
		
		System.currentPageReference().getParameters().put('clid',''+cmpList.ID);
		System.currentPageReference().getParameters().put('target','2');
		
		controller = new SL_LIB16_ctrl_CompanyListSearch();
		
		controller.setMCompanies(lstMComps);

		Company_List__c tmpCLItem = controller.CompanyList;
		controller.sortExpression = 'ASC';
		String tmnpVal2 =  controller.sortExpression;
		controller.sortExpression = 'ASC';
		controller.sortExpression = 'DESC';
		controller.sortExpression = 'DESC';
		controller.sortExpression = 'DESC';
		controller.getAccounts();
		controller.process();
		
		controller.clSearch();
		
		controller.setMCompanies(lstMComps);
		controller.doAdd();
		
		List<SearchColumns__c> tmpSCList = controller.aSearchColumns;
		
		controller.addCLObj = clm;
		controller.doSearch();
		controller.addCLObj = null;
		
		controller.trace = 'Debug Start>>>>>>>>>';
		String logInfo = controller.trace;
		String  currTarget = controller.target;
		
		ApexPages.currentPage().getParameters().put('event', 'load');
		ApexPages.currentPage().getParameters().put('picklist', 'type');
		ApexPages.currentPage().getParameters().put('filters','REFERENCE___AccountId___equal___ABS Capital Partners___000000000000000##REFERENCE___AccountId___equal___ABS Capital Partners___001P0000003pJmH');
		ApexPages.currentPage().getParameters().put('target', '2');
		controller.EventHandler();
		
		
		currTarget = controller.TargetObject;
		currTarget = controller.event;
		currTarget = controller.filterSet;
		currTarget = controller.picklistName;
		controller.JSONResponse = '';
		currTarget = controller.JSONResponse;
		
		ApexPages.currentPage().getParameters().put('picklist', 'recordtypeid');
		controller.getLCPickListValue();
		ApexPages.currentPage().getParameters().put('picklist', 'type');
		controller.getLCPickListValue();
	
		
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
		system.debug('======== picklistName ======== >>>> '+controller.picklistName);
		
		controller.EventHandler();
		
		SL_LIB16_ctrl_CompanyListSearch.JSONObject JSobj = new SL_LIB16_ctrl_CompanyListSearch.JSONObject();
		system.debug('======== JSobj.Json ======== >>>> '+JSobj.Json);
		
		controller.doReset();
		
		controller2 controller2 = new controller2();
		
	} 
	
	
	class Controller2 extends SL_LIB16_ctrl_CompanyListSearch {
		public controller2() {
			SL_LIB16_ctrl_CompanyListSearch obj = new SL_LIB16_ctrl_CompanyListSearch();
			obj.eventActionLoad();
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
	
	static testMethod void wb_Search_Controller() {
    	Company_List__c cl = new Company_List__c();
        cl.Name = 'Test Company List';
        insert cl;

    	System.currentPageReference().getParameters().put('clid', cl.Id);
    	
        SL_LIB16_ctrl_CompanyListSearch cl_search_control = new SL_LIB16_ctrl_CompanyListSearch();
        test.startTest();
        
        String tmpCompanyListID = cl_search_control.CompanyListID;
        Company_List__c tmpCompanyList = cl_search_control.CompanyList;
        String tmpsortDirection = cl_search_control.getSortDirection();
		cl_search_control.setSortDirection('ASC');
		String tmpsortExpression = cl_search_control.sortExpression;
		cl_search_control.sortExpression = 'Name';
		List<SL_LIB16_ctrl_CompanyListSearch.CompanyExtend> tmpgetAccounts = cl_search_control.getAccounts();
		cl_search_control.process();
		cl_search_control.doAdd();
		
		
		cl_search_control.SearchQ = 'SELECT Id, Name FROM Account';
		cl_search_control.SearchParam = 'EBITDA__c >0';
		cl_search_control.doSearch();
		
		cl_search_control.SearchObj = '1';
		cl_search_control.doSearch();
		
		cl_search_control.SearchObj = '3';
		cl_search_control.doSearch();
		
		Company_List__c CompList = new Company_List__c();
		CompList.Name = 'test comp 1';
		CompList.Status__c = 'Current';
		insert CompList;
		
		Account ac = new Account(Name='j@j.com');
        insert ac;
		
		Company_List_Member__c CompListMem = new Company_List_Member__c();
		CompListMem.Company_List__c = CompList.Id;
		CompListMem.Company__c = ac.Id;
		insert CompListMem;
		
		cl_search_control.addCLObj = CompListMem;
		cl_search_control.doSearch();

		
		
		
		cl_search_control.doCancel();
		cl_search_control.doReset();
		
        test.stopTest(); 
    }	
	
}