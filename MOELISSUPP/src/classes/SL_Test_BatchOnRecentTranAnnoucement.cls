/*
* Class Name    : SL_BatchToUpdateRecentTranAnnoucement
* JIRA Ticket   : Moelis-119
* Created on    : 20/01/2014
* Created by    : Sruti
* Jira ticket   : http://silverline.jira.com/browse/Moelis-119
* Description   : test class for SL_BatchToUpdateRecentTranAnnoucement  
*/
@isTest
private class SL_Test_BatchOnRecentTranAnnoucement 
{
	//Test case -1, when the Deal exists on the Transaction Announcement, it should have the values mapped from Deal
    static testMethod void SL_Test_BatchRecentTranAnnoucement1() 
    {
    	
    	Account objAccount = new Account(Name = 'TestAccount1', Type = 'Corporate', Industry = 'Media', Public_Private__c = 'Public');
    	insert objAccount;
    	
    	Ibanking_Project__c objIBanking = new Ibanking_Project__c(Name = 'TestDeal1', Client__c = objAccount.Id, CurrencyIsoCode = 'USD', Stage__c = 'Idea',
    															  Notes_4__c = 'Hi Test Deal', Industry__c = 'Media');
		insert objIBanking;    															  
    	
    	Recent_Transaction_Announcements__c objRecent = new Recent_Transaction_Announcements__c(Name = 'TestRecentTransaction', CurrencyIsoCode = 'USD', Deal_RTA__c = objIBanking.Id);
    	insert objRecent;
    	
    	test.startTest();
    	SL_BatchToUpdateRecentTranAnnoucement objBatch = new SL_BatchToUpdateRecentTranAnnoucement();
        Database.executeBatch(objBatch, 200);
    	test.stopTest();
    	system.assertEquals([select Announcement_Body__c From Recent_Transaction_Announcements__c ][0].Announcement_Body__c, objIBanking.Notes_4__c );
    }
    //Test case-2, when the Deal doesnot exist on the Transaction Announcement, it should have the values as null
    static testMethod void SL_Test_BatchRecentTranAnnoucement2() 
    {
    	Account objAccount = new Account(Name = 'TestAccount1', Type = 'Corporate', Industry = 'Media', Public_Private__c = 'Public');
    	insert objAccount;

    	Recent_Transaction_Announcements__c objRecent = new Recent_Transaction_Announcements__c(Name = 'TestRecentTransaction', CurrencyIsoCode = 'USD');
    	insert objRecent;
    	
    	test.startTest();
    	SL_BatchToUpdateRecentTranAnnoucement objBatch = new SL_BatchToUpdateRecentTranAnnoucement();
        Database.executeBatch(objBatch, 200);
    	test.stopTest();
    	system.assertEquals([select Industry__c From Recent_Transaction_Announcements__c ][0].Industry__c, null );
    }
}