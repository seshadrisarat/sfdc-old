public with sharing class SL_Moelis_DealRelatedParty_Hanlder 
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
  
    public SL_Moelis_DealRelatedParty_Hanlder(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnAfterInsert(List<Deal_Related_Parties__c> newDealParties)
    {
        List<FeedItem> lstCompanyFeeds = new List<FeedItem>();
        set<Id> setCompanies = new set<Id>();
        for(Deal_Related_Parties__c dealParty : newDealParties)
        {
            if(dealParty.Company__c != null)
                setCompanies.add(dealParty.Company__c);           
        }
        Map<Id, Account> mapCompanies = new Map<Id, Account>([select Id, Name from Account where Id in :setCompanies]);
        for(Id companyId : setCompanies)
        {
            lstCompanyFeeds.add(new FeedItem(ParentId = companyId , Body = 'has created a Deal Related Party with ' + mapCompanies.get(companyId).Name));
        }
        
        if(!lstCompanyFeeds.isEmpty())
            insert lstCompanyFeeds;
    }
    
    @isTest
    public static void testDealPartyTrigger()
    {    
     //Test AfterInsert of DealRelatedParty
     test.startTest();
     Account objAccount = new Account(Name = 'test company');
     insert objAccount;
     Ibanking_Project__c objDeal = new Ibanking_Project__c(Name = 'test deal',  Client__c = objAccount.id, Full_Description_of_Transaction__c = 'test');
     insert objDeal;
     Deal_Related_Parties__c dealParty = new Deal_Related_Parties__c(Deal__c = objDeal.id, Company__c = objAccount.id, Role__c = 'Other');
     insert dealParty;
     test.stopTest();
    }
}