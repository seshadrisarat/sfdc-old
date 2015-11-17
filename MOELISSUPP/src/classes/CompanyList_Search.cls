public with sharing class CompanyList_Search {
    public CompanyList_Search_Filter searchFilter {get; set;}
    public CompanyList_Search_Filter searchFilterProj {get; set;}
    public CompanyList_Search_Paging searchResults {get; set;} 
    public Company_List_Member__c relatedCompanyList {get; set;}
    public String searchType {get; set;}
    public Integer filterIndex {get; set;}
    public String filterField {get; set;}
    public String filterOperator {get; set;}
    public Id CompanyListId {get; set;}
    
    public CompanyList_Search(){
        searchFilter = new CompanyList_Search_Filter('Account');
        //searchResults = new CompanyList_Search_Paging();
        CompanyListId = ApexPages.currentPage().getParameters().get('clId');
        relatedCompanyList = new Company_List_Member__c();
        searchType = 'comp';
    }
    
    public void addFilter(){
        if (searchType=='comp'){
            searchFilter.addFilter();
        } else 
        if (searchType=='proj'){
            searchFilterProj.addFilter();
        }
    }
    
    public void changeType(){
        if (searchType=='comp') searchType = 'proj';
        else searchType = 'comp';
    }
    
    public void voidAction(){
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'searchType: ' + searchType));
    }
    
    public void changeFilter1(){
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'searchType: ' + searchType));
        if (searchType=='comp'){
            searchFilter.filters[filterIndex].field = filterField;
            searchFilter.recalcFilterValues();
        } else
        if (searchType=='proj'){
            searchFilterProj.filters[filterIndex].field = filterField;
            searchFilterProj.recalcFilterValues();
        }
    }
    
    public void changeFilter2(){
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'searchType: ' + searchType));
        searchFilter.filters[filterIndex].field = filterField;
        searchFilter.recalcFilterValues();
    }
    
    public void doSearch(){
        String query = '';
        Set<Id> inIds = new Set<Id>();
        Set<Id> notInIds = new Set<Id>();
        if (relatedCompanyList.Company_List__c!=null){
            //query = searchFilter.getSimpleQuery();
        } else 
        if (searchType=='comp'){
            try{
                query = searchFilter.prepareQuery() + ' LIMIT 1000';
                List<Account> accs = Database.query(query);
                for (Account acc : accs){
                    inIds.add(acc.Id);
                }
            } catch (Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Search type not found :: ' + searchType));
            return;
        }
        List<Company_List_Member__c> clms = [SELECT Id, Company__c FROM Company_List_Member__c WHERE Company_List__c=:CompanyListId];
        for (Company_List_Member__c clm : clms){
            notInIds.add(clm.Company__c);
        }
        searchResults = new CompanyList_Search_Paging(inIds, notInIds);
    }
}