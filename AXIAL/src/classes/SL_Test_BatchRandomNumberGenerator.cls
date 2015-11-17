/**
	* ClassName      : SL_Test_BatchRandomNumberGenerator
	* JIRATicket     : AXIAL-3
	* CreatedOn      : 29/Jun/2015
	* ModifiedBy     : Prakash
	* Description    : This test class is execute the SL_Batch_RandomNumberGeneratorOnAcc to test the Random number generated for Accounts
*/
@isTest
private class SL_Test_BatchRandomNumberGenerator {
	/*
    	Checking with the Account related Random_Number__c field update with random number
    */
    static testMethod void randomNumberGeneratorOnAccount() {
        list<Account> lstAcc = new list<Account>{new Account(Name='Test Acc1',Investor_Classification__c='Client',Company_Type_full_name__c='Accountant'),
        							new Account(Name='Test Acc2',Investor_Classification__c='Early Access',Company_Type_full_name__c='Law Firm')	};
        insert lstAcc;
        
        system.assert([SELECT Random_Number__c FROM Account limit 1][0].Random_Number__c == null);
        
        test.startTest();
        	database.executebatch(new SL_Batch_RandomNumberGeneratorOnAcc());
        test.stopTest();
        
        system.assert([SELECT Random_Number__c FROM Account limit 1][0].Random_Number__c != null);		
    }
    /*
    	Checking with the bulk Account Random_Number__c records update with random number
    */
    static testMethod void randomNumberGeneratorOnAccount_Bulk() {
    	list<Account> lstAcc = new list<Account>();
    	
    	for(Integer i=0;i<100;i++){
    		lstAcc.add(new Account(Name='Test Acc'+i,Investor_Classification__c='Client',Company_Type_full_name__c='Accountant'));
    	}
        insert lstAcc;
        
        system.assertEquals([SELECT id FROM Account where Random_Number__c != null].size(),0);
        
        test.startTest();
        	database.executebatch(new SL_Batch_RandomNumberGeneratorOnAcc());
        test.stopTest();
        
        
        system.assertEquals([SELECT id FROM Account where Random_Number__c != null].size(),100);
    }
}