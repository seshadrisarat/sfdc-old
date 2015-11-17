@isTest
private class SL_test_GenericPagination {
	
	static Account objTestAccount1;
    static Account objTestAccount2;
    static Account objTestAccount3;

    //Create records for Test Coverage
    private static void createTestRecords()
    {
        objTestAccount1 = new Account(Name = 'Test Account 1');
        objTestAccount2 = new Account(Name = 'Test Account 2');
        objTestAccount3 = new Account(Name = 'Test Account 3');
        List<Account> lstTestAccount = new List<Account>{objTestAccount1,objTestAccount2,objTestAccount3};
        insert lstTestAccount;
    }

    //How to pass values for Constructor
    private static testMethod void SL_Generic_Pagination()
    {
        createTestRecords();

        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        //string fieldset = '';
        
        SL_Generic_Pagination objPaginatorClass = new SL_Generic_Pagination(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition ,false);

        system.assert(objPaginatorClass.fieldDefinition == 'Id,Name');
        system.assert(objPaginatorClass.strObjectName == 'Account');
        system.assert(objPaginatorClass.intPageSize == 1);
        system.assert(objPaginatorClass.mapPageNumber_StartIndex.size() == 3);
    }

    //How to fetch values when we pass for specific page
    private static testMethod void SL_Generic_Pagination_goToSpecificPage()
    {
        createTestRecords();

        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        string fieldset = '';
        SL_Generic_Pagination objPaginatorClass = new SL_Generic_Pagination(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition ,false);

        objPaginatorClass.goToSpecificPage(paramPageNumber);
        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1); // Page Size we have kept as 1
    }

    //How to fetch values for Next button
    private static testMethod void SL_Generic_Pagination_gotoNextPage()
    {
        createTestRecords();

        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        string fieldset = '';
        SL_Generic_Pagination objPaginatorClass = new SL_Generic_Pagination(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, false);

        objPaginatorClass.intPageNumber = paramPageNumber;
        objPaginatorClass.gotoNextPage();
        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1); // Page Size we have kept as 1
    }

    //How to fetch values for previous button
    private static testMethod void SL_Generic_Pagination_gotoPrevPage()
    {
        createTestRecords();

        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        string fieldset = '';
        SL_Generic_Pagination objPaginatorClass = new SL_Generic_Pagination(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition , false);

        objPaginatorClass.intPageNumber = paramPageNumber;
        objPaginatorClass.gotoNextPage();
        objPaginatorClass.gotoPrevPage();
        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1); // Page Size we have kept as 1
    }

    //How to fetch values for first page
    private static testMethod void SL_Generic_Pagination_gotoFirstPage()
    {
        createTestRecords();

        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        string fieldset = '';
        SL_Generic_Pagination objPaginatorClass = new SL_Generic_Pagination(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition , false);

        objPaginatorClass.intPageNumber = paramPageNumber;
        objPaginatorClass.gotoFirstPage();
        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1); // Page Size we have kept as 1
    }

    //How to fetch values for Last Page
    private static testMethod void SL_Generic_Pagination_gotoLastPage()
    {
        createTestRecords();

        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 2;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        string fieldset = '';
        SL_Generic_Pagination objPaginatorClass = new SL_Generic_Pagination(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, false);

        objPaginatorClass.intPageNumber = paramPageNumber;
        objPaginatorClass.goToSpecificPage(paramPageNumber);
        objPaginatorClass.gotoLastPage();
        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1); // Page Size we have kept as 1
    }

    //How to fetch values when we are dealing with sorting
    private static testMethod void SL_Generic_Pagination_getSortingRecords()
    {
        createTestRecords();

        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        string fieldset = '';
        String paramFieldName = 'Name';
        String paramDirection = 'ASC';

        SL_Generic_Pagination objPaginatorClass = new SL_Generic_Pagination(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, false);

        objPaginatorClass.getSortingRecords( paramFieldName,1 );

        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1); // Page Size we have kept as 1
    }

    //How to fetch values when we pass for specific page
    private static testMethod void SL_Generic_Pagination_getListSobjectWrappers()
    {
        createTestRecords();

        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        String paramDirection = 'ASC';
        string fieldset = '';
        SL_Generic_Pagination objPaginatorClass = new SL_Generic_Pagination(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, false);

        objPaginatorClass.goToSpecificPage(paramPageNumber);
        system.assert(objPaginatorClass.getListSobjectWrappers().size() == 1); // Page Size we have kept as 1
    }

    //How to clear any selected Ids
    private static testMethod void SL_Generic_Pagination_clearSelectedItems()
    {
        createTestRecords();

        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        String paramDirection = 'ASC';
        string fieldset = '';
        SL_Generic_Pagination objPaginatorClass = new SL_Generic_Pagination(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, false);

        objPaginatorClass.clearSelectedItems();
    }

    //How to fetch selected Ids while going to and fro in pagination
    private static testMethod void SL_Generic_Pagination_getSelectedItems()
    {
        createTestRecords();

        String paramCSVFields = 'Id,Name';
        Integer paramPageSize = 1;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 1;
        String paramDirection = 'ASC';
        string fieldset = '';
        SL_Generic_Pagination objPaginatorClass = new SL_Generic_Pagination(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, false);

        objPaginatorClass.goToSpecificPage(paramPageNumber);

        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 1);

        objPaginatorClass.lstSObjectWrappers[0].isChecked = true;
        objPaginatorClass.gotoNextPage();

        objPaginatorClass.lstSObjectWrappers[0].isChecked = true;
        objPaginatorClass.gotoPrevPage();

        objPaginatorClass.lstSObjectWrappers[0].isChecked = false;
        objPaginatorClass.gotoNextPage();

        system.assert(objPaginatorClass.getSelectedItems().size() == 1);

    }

    //How to set List of SobjectWrapper to class local List
    private static testMethod void SL_Generic_Pagination_setListSobjectWrappers()
    {
        createTestRecords();

        List<SL_Generic_Pagination.SobjectWrapper> lstLocalSObjectWrapper = new List<SL_Generic_Pagination.SobjectWrapper>();

        String paramCSVFields = 'AccountFieldSet';
        Integer paramPageSize = 2;
        String paramObjectName = 'Account';
        String paramWhereCondition = '';
        Integer paramPageNumber = 2;
        String paramDirection = 'ASC';
        string fieldset = '';
        SL_Generic_Pagination objPaginatorClass = new SL_Generic_Pagination(paramCSVFields, paramPageSize, paramObjectName, paramWhereCondition, true);
        lstLocalSObjectWrapper.addAll(objPaginatorClass.lstSObjectWrappers);
        objPaginatorClass.setListSobjectWrappers(objPaginatorClass.lstSObjectWrappers);
        system.assert(objPaginatorClass.lstSObjectWrappers.size() == 0);
    }
	
}