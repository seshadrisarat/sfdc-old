/**
 * \author Vika Osmak 
 * \date 06/15/11
 * \see https://silverline.jira.com/browse/MOELIS-115
 * \brief Test Class for trigger SL_RecentTransactionAnnouncements on Recent_Transaction_Announcements__c  
 updated by: Rahul Majumdar
 Last modifed on: 19/11/2013
 
 */
@isTest(SeeAllData=false)
public class SL_Test_RecentTransactionTrigger   
{
	    /*** Start: Test Code for SL_RecentTransactionAnnouncements trigger */
    
    //For test Case1: After insert, the field should map with the parent Deal
    static testMethod void SL_Test_TransactionHandlerInsertWithRelatedDeal() 
    {
        test.startTest();
        
        Account objAccount = new Account();
        objAccount.Name = 'Test';
        insert objAccount;
        
        List<Ibanking_Project__c> lstDeals = new List<Ibanking_Project__c>();
        
        lstDeals.add(new Ibanking_Project__c(Client__c= objAccount.Id ,Name= 'test--' ));
        insert lstDeals;
        
        Recent_Transaction_Announcements__c objTransaction = new Recent_Transaction_Announcements__c(Deal_RTA__c= lstDeals[0].Id,Industry__c = 'test');
        insert objTransaction;
        
        
        Test.stopTest();
        
                    
        for(Recent_Transaction_Announcements__c objRecentTransaction :[ Select Deal_RTA__r.Industry__c , Industry__c, Company_Name__c, Deal_RTA__c  
                    From Recent_Transaction_Announcements__c 
                    ])
        {
            //Field on related Transaction should also be updated
            system.assertEquals(objRecentTransaction.Company_Name__c,objAccount.Id);
            system.assertEquals(objRecentTransaction.Industry__c,objRecentTransaction.Deal_RTA__r.Industry__c);
        }
    }
    
    //For test Case2: when no Deal is related 
    static testMethod void SL_Test_BeforeInsertWhenNoRelatedDeal() 
    {
 		test.startTest();
        
        Account objAccount = new Account();
        objAccount.Name = 'Test';
        insert objAccount;
        
        
        Recent_Transaction_Announcements__c objTransaction = new Recent_Transaction_Announcements__c(Industry__c = 'test');
        insert objTransaction;
        
        
        Test.stopTest();
        
                    
        for(Recent_Transaction_Announcements__c objRecentTransaction :[ Select  Industry__c, Company_Name__c, Deal_RTA__c  
                    From Recent_Transaction_Announcements__c 
                    ])
        {
            //Field on related Transaction should also be updated
            system.assertEquals(objRecentTransaction.Industry__c,null);
            system.assertNotEquals(objRecentTransaction.Industry__c,'test');
        }
    }
	
	//For test Case1: Before insert, the field should map with the parent Deal
    static testMethod void SL_Test_TransactionHandler_BeforeUpdateWithDealVal() 
    {
        test.startTest();
        
        Account objAccount = new Account();
        objAccount.Name = 'Test';
        insert objAccount;
        
        List<Ibanking_Project__c> lstDeals = new List<Ibanking_Project__c>();
        
        lstDeals.add(new Ibanking_Project__c(Client__c= objAccount.Id ,Name= 'test--',Industry__c='Media'));
        insert lstDeals;
        
        Recent_Transaction_Announcements__c objTransaction = new Recent_Transaction_Announcements__c(Deal_RTA__c= lstDeals[0].Id,Industry__c = 'test');
        insert objTransaction;
        
        objTransaction.Industry__c = 'test2';
        update objTransaction;
        
        Test.stopTest();
        
                    
        for(Recent_Transaction_Announcements__c objRecentTransaction :[ Select Deal_RTA__r.Industry__c , Industry__c, Company_Name__c, Deal_RTA__c  
                    From Recent_Transaction_Announcements__c 
                    ])
        {
            //Field on related Transaction should also be updated
            system.assertNotEquals(objRecentTransaction.Industry__c,'test2');
            system.assertEquals(objRecentTransaction.Industry__c,'Media');
        }
    }
    
    //For test Case4: transaction is inserted
    static testMethod void SL_Test_AfterInsert() 
    {
        test.startTest();
        
        Recent_Transaction_Announcements__c objTransaction = new Recent_Transaction_Announcements__c(Industry__c = 'test');
        insert objTransaction;
        
        Test.stopTest();

        List<SLSI__Recent_Updates__c> listRecentUpdates = [Select Id 
			From SLSI__Recent_Updates__c where SLSI__Sobject_Type__c = 'Recent_Transaction_Announcements__c' AND SLSI__Related_To__c != null order by SLSI__Last_Updated__c desc nulls last limit 1000];
		system.assertEquals(listRecentUpdates.size(),1);
    }
    
    //For test Case5: when deal field on transaction is updated 
    static testMethod void SL_Test_AfterUpdate() 
    {
        test.startTest();
        
        Recent_Transaction_Announcements__c objTransaction = new Recent_Transaction_Announcements__c(Industry__c = 'test');
        insert objTransaction;
        
        objTransaction.Industry__c = 'test2';
        update objTransaction;
        
        Test.stopTest();

        List<SLSI__Recent_Updates__c> listRecentUpdates = [Select Id 
			From SLSI__Recent_Updates__c where SLSI__Sobject_Type__c = 'Recent_Transaction_Announcements__c' AND SLSI__Related_To__c != null order by SLSI__Last_Updated__c desc nulls last limit 1000];
		system.assertEquals(listRecentUpdates.size(),1);
    }
    
    //For test Case6: when deal field on transaction is deleted
    static testMethod void SL_Test_AfterDelete() 
    {
        test.startTest();
        
        Account objAccount = new Account();
        objAccount.Name = 'Test';
        insert objAccount;
        
        List<Ibanking_Project__c> lstDeals = new List<Ibanking_Project__c>();
        
        lstDeals.add(new Ibanking_Project__c(Client__c= objAccount.Id ,Name= 'test--',Industry__c='Media'));
        insert lstDeals;
        
        Recent_Transaction_Announcements__c objTransaction = new Recent_Transaction_Announcements__c(Deal_RTA__c= lstDeals[0].Id,Industry__c = 'test');
        insert objTransaction;
        
        
        delete objTransaction;
        
        Test.stopTest();
        
        
        List<SLSI__Recent_Updates__c> listRecentUpdates = [Select Id 
			From SLSI__Recent_Updates__c where SLSI__Sobject_Type__c = 'Recent_Transaction_Announcements__c' AND SLSI__Related_To__c != null order by SLSI__Last_Updated__c desc nulls last limit 1000];
		system.assertEquals(listRecentUpdates.size(),0);
    }

    /*** End: Test Code for SL_Deals trigger */
}