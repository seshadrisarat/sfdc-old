public with sharing class CompanyFinancialsController  
{
    private Account acct;
    public Integer financialsCount { public get; private set; } 
    public List<Company_Financial__c> financials { public get; private set; }
    
    public CompanyFinancialsController(ApexPages.StandardController controller) 
    {
        acct=(Account)controller.getRecord();
        financials=[SELECT Id,Year__c,EBITDA_MM__c,Revenue_MM__c,Pre_Tax_MM__c,Revenue_Growth__c,Type__c FROM Company_Financial__c WHERE Company__c=:acct.Id ORDER BY Year__c ASC];
        financialsCount=financials.size();
    }
    
    public PageReference manageFinancials()
    {
        return new PageReference('/apex/ManageCompanyFinancials?Id='+acct.Id);
    }

}