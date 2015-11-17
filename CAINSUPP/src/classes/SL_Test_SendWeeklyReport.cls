/**
* \arg ClassName      : SL_Test_SendWeeklyReport
* \arg JIRATicket     : CAINSUPP-14
* \arg CreatedOn      : 11/03/2015
* \arg CreatededBy    : Sanath
* \arg ModifiedBy     : -
* \arg Description    : -
*/
@isTest
private class SL_Test_SendWeeklyReport 
{
    @testSetup
    private static void setupData()
    {
        Account objAccount = new Account(Name = 'Cain Brothers 1');
        insert objAccount;
        
        List<Contact> lstContact = new List<Contact>{
                                                        new Contact(LastName = 'Contact 1', Email = 'sanath@g.com', Status__c = 'Active', AccountId = objAccount.Id),
                                                        new Contact(LastName = 'Test Contact 2', Email = 'sanat11h@g.com', Status__c = 'Active', AccountId = objAccount.Id)
                                                    };
        insert lstContact;
        
        Deal__c objDeal = new Deal__c(Name = 'Test Deal 1', Proj_Closing_Date__c = Date.Today().addDays(60), Status__c = 'In Progress', Client_Name__c = objAccount.Id);
        insert objDeal;
        
        Deal__c objDeal1 = new Deal__c(Name = 'Test Deal 1', Proj_Closing_Date__c = Date.Today().addDays(24), Status__c = 'In Progress', Client_Name__c = objAccount.Id);
        insert objDeal1;
        
        List<Cain_Deal_Team__c> lstDealTeam = new List<Cain_Deal_Team__c>{
                                                                                new Cain_Deal_Team__c(Deal__c = objDeal.Id, Team_Member__c = lstContact[0].Id),
                                                                                new Cain_Deal_Team__c(Deal__c = objDeal.Id, Team_Member__c = lstContact[1].Id)
                                                                         };
        insert lstDealTeam;
    }
    
    static testMethod void test_SendWeeklyReport() 
    {
        Test.startTest();
        Database.executeBatch(new SL_SendWeeklyReport());
        Test.StopTest();
    }
}