/** 
* \author Sergey Karnyushin
* \date 10/16/2012
* \see https://silverline.jira.com/browse/WP-9
* \details Financial Trigger Handler
* \
*/
public without sharing class SL_Financial_Trigger_Handler
{
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
     
    public SL_Financial_Trigger_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
         
    public void OnBeforeInsert(list<Financial__c> newFinancials){ }
     
    public void OnAfterInsert(map<ID,Financial__c> newFinancialMap){
        updateRelatedAccountByLatestData(newFinancialMap.values());
    }
     
    @future public static void OnAfterInsertAsync(Set<ID> newFinancialIDs){ }
     
    public void OnBeforeUpdate(map<ID,Financial__c> oldFinancialMap, map<ID,Financial__c> newFinancialMap){ }
     
    public void OnAfterUpdate(map<ID,Financial__c> oldFinancialMap, map<ID,Financial__c> newFinancialMap){
        updateRelatedAccountByLatestData(newFinancialMap.values());
    }
     
    @future public static void OnAfterUpdateAsync(Set<ID> updatedFinancialIDs){ }
     
    public void OnBeforeDelete(map<ID,Financial__c> oldFinancialMap){ }
     
    public void OnAfterDelete(map<ID,Financial__c> oldFinancialMap){
        updateRelatedAccountByLatestData(oldFinancialMap.values());
    }
     
    @future public static void OnAfterDeleteAsync(Set<ID> deletedFinancialIDs){ }
     
    public void OnUndelete(list<Financial__c> restoredFinancials){
        updateRelatedAccountByLatestData(restoredFinancials);
    }
             
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
     
    public boolean IsVisualforcePageContext{
        get{ return !IsTriggerContext;}
    }
     
    public boolean IsWebServiceContext{
        get{ return !IsTriggerContext;}
    }
     
    public boolean IsExecuteAnonymousContext{
        get{ return !IsTriggerContext;}
    }
    
    private void updateRelatedAccountByLatestData(list<Financial__c> financials) {
        
        // get all companies related to changed financial objects
        Set<ID> relatedAccountsIDs = new Set<ID>();
        for (Financial__c financial: financials) {
            relatedAccountsIDs.add(financial.Company__c);
        }
        Map<ID,Account> companies = new Map<ID,Account>([SELECT
                ID,
                Period_Ended__c,
                EBITDA__c,
                Enterprise_Value__c,
                Net_Income__c,
                Market_Cap__c,
                Period_Type__c,
                Revenues__c,
                Book_Value__c,
                CAPEX__c
                /*,Recently_Updated_Flag__c*/
                /*,Recently_Updated_Notes__c*/
            FROM Account WHERE ID IN :relatedAccountsIDs]);
        
        // get all financial objects related to companies recieved before
        List<Financial__c> allFinancials = [SELECT
                ID,
                Company__c,
                Period_Ended__c,
                EBITDA__c,
                Enterprise_Value__c,
                Net_Income__c,
                Market_Cap__c,
                Period_Type__c,
                Revenues__c,
                Book_Value__c,
                CAPEX__c
                /*, Recently_Updated_Flag__c*/
                /*, Recently_Updated_Notes__c*/
            FROM Financial__c WHERE Company__c IN :relatedAccountsIDs];
        
        // flag array
        Map<ID,Date> companiesLatestPeriods = new Map<ID,Date>();

        // we must change company data if we found financial object with greater Period_Ended__c field then we used before
        for (Financial__c financial: allFinancials) {
            if ((companiesLatestPeriods.get(financial.Company__c) == null) ^ (companiesLatestPeriods.get(financial.Company__c) < financial.Period_Ended__c)) {
                companiesLatestPeriods.put(financial.Company__c, financial.Period_Ended__c);
                companies.get(financial.Company__c).Period_Ended__c             = financial.Period_Ended__c;//String.valueOf(financial.Period_Ended__c);
                companies.get(financial.Company__c).EBITDA__c                   = financial.EBITDA__c;
                companies.get(financial.Company__c).Enterprise_Value__c         = financial.Enterprise_Value__c;
                companies.get(financial.Company__c).Net_Income__c               = financial.Net_Income__c;
                companies.get(financial.Company__c).Market_Cap__c               = financial.Market_Cap__c;
                companies.get(financial.Company__c).Period_Type__c              = String.valueOf(financial.Period_Type__c);
                companies.get(financial.Company__c).Revenues__c                 = financial.Revenues__c;
                companies.get(financial.Company__c).Book_Value__c               = financial.Book_Value__c;
                companies.get(financial.Company__c).CAPEX__c                 = financial.CAPEX__c;
                //companies.get(financial.Company__c).Recently_Updated_Flag__c    = financial.Recently_Updated_Flag__c;
                //companies.get(financial.Company__c).Recently_Updated_Notes__c   = financial.Recently_Updated_Notes__c;
            }
        }
        
        // we must cleanup data for te companies which not related to any financial objects
        for (Account company: companies.values()) {
            if (companiesLatestPeriods.get(company.ID) == null) {
                company.Period_Ended__c             = null;
                company.EBITDA__c                   = null;
                company.Enterprise_Value__c         = null;
                company.Net_Income__c               = null;
                company.Market_Cap__c               = null;
                company.Period_Type__c              = null;
                company.Revenues__c                 = null;
                company.Book_Value__c               = null;
                company.CAPEX__c               = null;
                //company.Recently_Updated_Flag__c    = false;
                //company.Recently_Updated_Notes__c   = null;
            }
        }
        
        update companies.values();
        
    }
 
}