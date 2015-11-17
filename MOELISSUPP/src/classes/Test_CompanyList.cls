/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_CompanyList {

    static testMethod void wb_Search() {
        Company_List__c cl = new Company_List__c();
        cl.Name = 'Test Company List';
        insert cl;
        ApexPages.currentPage().getParameters().put('clId', cl.Id);
        
        CompanyList_Search cl_search = new CompanyList_Search();
        test.startTest();
        cl_search.voidAction();
        cl_search.addFilter();
        cl_search.changeType();
        cl_search.filterIndex = 0;
        cl_search.filterField = 'Name';
        cl_search.filterOperator = '==';

        
        test.stopTest(); 
    }
    
    static testMethod void wb_Search_Paging() {
        CompanyList_Search_Paging cl_search_p = new CompanyList_Search_Paging();
        test.startTest();
		Boolean hasNext = cl_search_p.hasNext;
		Boolean hasPrevious = cl_search_p.hasPrevious;
		Integer pageSize = cl_search_p.pageSize;
		Integer pageNumber = cl_search_p.pageNumber;
		List<CompanyList_Search_Paging.CompanyWrapper> companies = cl_search_p.getCompanies(); 
		cl_search_p.next();
		cl_search_p.first();
		cl_search_p.last();
		cl_search_p.previous();
        cl_search_p.process();
        cl_search_p.cancel();
        test.stopTest(); 
    }
    
    /*static testMethod void wb_Search_Filter() {
        CompanyList_Search_Filter cl_search_f = new CompanyList_Search_Filter('STRING');
        test.startTest();
		cl_search_f.getSimpleQuery();
        test.stopTest(); 
    }*/
    
    static testMethod void wb_Search_Controller() {
    	Company_List__c cl = new Company_List__c();
        cl.Name = 'Test Company List';
        insert cl;

    	System.currentPageReference().getParameters().put('clid', cl.Id);
    	
        CompanyListSearch_Controller cl_search_control = new CompanyListSearch_Controller();
        test.startTest();
        
        String tmpCompanyListID = cl_search_control.CompanyListID;
        Company_List__c tmpCompanyList = cl_search_control.CompanyList;
        String tmpsortDirection = cl_search_control.getSortDirection();
		cl_search_control.setSortDirection('ASC');
		String tmpsortExpression = cl_search_control.sortExpression;
		cl_search_control.sortExpression = 'Name';
		List<CompanyListSearch_Controller.CompanyExtend> tmpgetAccounts = cl_search_control.getAccounts();
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