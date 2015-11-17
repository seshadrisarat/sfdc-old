@isTest
private class Test_Companies_DSummary {

    static testMethod void Companies_DSummary_CSearch_Test() {
        Test.startTest();
        Companies_DSummary_CSearch_filter filter = new Companies_DSummary_CSearch_filter();
        Companies_DSummary_CSearch cls = new Companies_DSummary_CSearch(filter);
        String s = cls.dealFilter;
        s = cls.drpFilter;
        s = cls.pbiFilter;
        List<String> lst = cls.productTypeList;
        lst = cls.expectedTimingList;
        lst = cls.dealRegionList;
        lst = cls.dealIndustryList;
        lst = cls.dealStatusList;
        lst = cls.dealSubSectorList;
        List<List<sObject>> lst2 = cls.searchResult;
        s = cls.dealTableSize;
        s = cls.pbiTableSize;
        s = cls.drpTableSize;
        Test.stopTest();
    }
    
    static testMethod void Companies_DSummary_CSearch_filter_Test() {
        Test.startTest();
        Companies_DSummary_CSearch_filter cls = new Companies_DSummary_CSearch_filter();
        cls.addFilter();
        cls.clearFilter();
        List<SelectOption> lst = cls.dealIndustrySO;
        lst = cls.dealRegionSO;
        lst = cls.dealStatusSO;
        lst = cls.dealSubSectorSO;
        lst = cls.expectedTimingSO;
        lst = cls.productTypeSO;
        List<Ibanking_Project__c> lst2 = cls.dealTable;
        lst2 = cls.drpTable;
        lst2 = cls.pbiTable;
        Test.stopTest();
    }
    
    static testMethod void Companies_DSummary_CSearch_logic_Test() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Test.startTest();
        Companies_DSummary_CSearch_logic.getCompanyName(acc.Id);
        Companies_DSummary_CSearch_logic.getParamString(new List<String>{'1', '2'}, '1');
        Companies_DSummary_CSearch_logic.getParamStringIncludes(new List<String>{'1', '2'}, '1');
        Companies_DSummary_CSearch_logic.getSearchResult('Name=\'1\''
        											   , 'Name=\'1\''
        											   , 'Name=\'1\''
        											   , new List<String>{'1'}
        											   , new List<String>{'1'}
        											   , new List<String>{}
        											   , new List<String>{'1'}
        											   , new List<String>{'1'}
        											   , new List<String>{'1'});
        Test.stopTest();
    }
}