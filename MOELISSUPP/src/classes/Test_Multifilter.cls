@isTest
private class Test_Multifilter {

    static testMethod void Multifiler_controller_Test() {
        Test.startTest();
        Multifilter_controller cls = new Multifilter_controller();
        cls.addFilter();
        ApexPages.currentPage().getParameters().put('fidx', '0');
        cls.removeFilter();
        Test.stopTest();
    }
    
    static testMethod void Multifiler_filter_Test() {
        Test.startTest();
        Multifilter_filter cls = new Multifilter_filter();
        Multifilter_filter.FilterWrapper f = new Multifilter_filter.FilterWrapper();
        cls.compileStatment('field', f);
        f.operator = 'equals'; cls.compileStatment('field', f);
        f.operator = 'notEqual'; cls.compileStatment('field', f);
        f.operator = 'startsWith'; cls.compileStatment('field', f);
        f.operator = 'contains'; cls.compileStatment('field', f);
        f.operator = 'notContain'; cls.compileStatment('field', f);
        string s = cls.errMsg;
        cls.errMsg = s;
        s = cls.dealResultFilter;
        cls.dealResultFilter = s;
        s = cls.targetResultFilter;
        cls.targetResultFilter = s;
        
        Test.stopTest();
    }
}