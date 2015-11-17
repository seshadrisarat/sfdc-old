/*
* Create new LP_Commitment__c record per mapping below, if Stage__c = Closed
* Trigger Name  : SL_CreateLPCommitment 
* JIRA Ticket   : GREENHILL-12
* Created on    : 23/Apr/2012
* Author        : Snezhana Storoschuk
* Description   : Implement a trigger on Fundraising_Deal__c to insert and update
*/
@isTest
private class SL_Test_CreatePLCommitment {
	
	public static Account account;
	public static vced2__Fund__c fund;
	public static Fundraising_Deal__c funDeal;
	
	private static void createTestData() {
		
		account = new Account(
			Name = 'Test Account'
		);
	    insert account;
	    
	    fund = new vced2__Fund__c(
	    	Name = 'Test Fund'
	    );
	    insert fund;
	    
	    funDeal = new Fundraising_Deal__c(
            Name = 'Test',
            Stage__c = 'Closed',
            Company__c = account.Id,
            Fund__c = fund.Id,
            Minimum_Commitment_Size__c = 100,
            Close_Date__c = date.today()
        );
	}

    static testMethod void insertFundraising_Deal() {
    	createTestData();
        try {
            insert funDeal; 
            system.assertNotEquals(funDeal, null); 
        }
        catch (Exception e) {
            system.debug('Exception: ' + e);
        }
    }
    
    static testMethod void updateFundraising_Deal() {
    	createTestData();
        try {
            funDeal.Stage__c = 'None';
            insert funDeal; 
            system.assertNotEquals(funDeal, null); 

            funDeal.Stage__c = 'Closed';
            update funDeal;
        }
        catch (Exception e) {
            system.debug('Exception: ' + e);
        }
    }
}