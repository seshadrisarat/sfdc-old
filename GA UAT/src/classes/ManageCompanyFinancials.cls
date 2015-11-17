public class ManageCompanyFinancials {
    public transient String dmessage { get; set; }
    public List<Company_Financial__c> financials { get; private set; }
    public List<Company_Financial__c> deleteFinancials { get; private set; }
    private Id accountId;

    public ManageCompanyFinancials(ApexPages.StandardController controller) {
        accountId = controller.getRecord().Id;
        refresh();
        
    }

    public void refresh() {
        financials = new List<Company_Financial__c>();
        deleteFinancials = new List<Company_Financial__c>();
        for (Company_Financial__c f : [SELECT Revenue_MM__c, EBITDA_MM__c, Pre_Tax_MM__c, Year__c, Type__c, CurrencyIsoCode FROM Company_Financial__c WHERE Company__c=:accountId ORDER BY Year__c DESC]) {
            financials.add(f);
        }
        for (Integer i = 0; i < 5; i++) {
            add();
        }
    }

    public void add() {
        financials.add(new Company_Financial__c(
            Company__c = accountId
        ));
    }
    
    public void remove() {
        try {
            Integer row = Decimal.valueOf(ApexPages.currentPage().getParameters().get('row')).intValue();
            Company_Financial__c cf = financials.remove(row);
            if (cf.Id != null) {
                deleteFinancials.add(cf);
            }
        } catch (Exception e) {
        }        
    }
    
    public PageReference save() {
        PageReference ref = null;
        List<Company_Financial__c> financialList = new List<Company_Financial__c>();
        for (Company_Financial__c t : financials) {
            if (t.Year__c != null) {
                financialList.add(t);
            }
        }
        if (!deleteFinancials.isEmpty()) {
            Database.delete(deleteFinancials, false);
        }        
        if (!financialList.isEmpty()) {
            financials = financialList;
            upsert financials;
            refresh();
        }
        return new PageReference('/' + accountId);
    }
}