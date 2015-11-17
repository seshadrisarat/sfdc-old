/**  
* \arg TestClass        : SL_Test_Investor_Entity
* \arg JIRATicket       : GA-18
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 04/13/15
* \arg CreatededBy      : 
* \arg ModifiedBy       : Sandeep
* \arg Description      : Test Class for SL_Investor_EntityHelper
*/
@isTest
private class SL_Test_Investor_Entity {

	private static testMethod void test() {
	    
	    Account objAccount = new Account(Name = 'TestAccount-1');
        Insert objAccount;
        
        Account objAccount1 = new Account(Name = 'TestAccount-2');
        Insert objAccount1;
        
        List<Investor_Entity__c> lstInvestor_Entity = new List<Investor_Entity__c>{
                                                           new Investor_Entity__c(Name = 'TestInvestor - 1', Account__c = objAccount.Id, Commitment_Amount__c = 10),
                                                           new Investor_Entity__c(Name = 'TestInvestor - 2', Account__c = objAccount.Id, Commitment_Amount__c = 20),
                                                           new Investor_Entity__c(Name = 'TestInvestor - 1', Account__c = objAccount1.Id, Commitment_Amount__c = 10),
                                                           new Investor_Entity__c(Name = 'TestInvestor - 1', Account__c = objAccount1.Id, Commitment_Amount__c = 5)
                                                        };
        insert lstInvestor_Entity;
        system.assertEquals([SELECT Commitment_Amount_Rolled_Up__c FROM Account WHERE Id =: objAccount.Id].Commitment_Amount_Rolled_Up__c,
                                        lstInvestor_Entity[0].Commitment_Amount__c + lstInvestor_Entity[1].Commitment_Amount__c);
                                        
        system.assertEquals([SELECT Commitment_Amount_Rolled_Up__c FROM Account WHERE Id =: objAccount1.Id].Commitment_Amount_Rolled_Up__c,
                                        lstInvestor_Entity[2].Commitment_Amount__c + lstInvestor_Entity[3].Commitment_Amount__c);
        /* Account__c in MD relationship
        lstInvestor_Entity[0].Account__c = objAccount1.Id;
        lstInvestor_Entity[1].Account__c = objAccount1.Id;
        lstInvestor_Entity[2].Account__c = objAccount.Id;
        lstInvestor_Entity[3].Account__c = objAccount.Id;
        
        update lstInvestor_Entity;
        
        system.assertEquals([SELECT Commitment_Amount_Rolled_Up__c FROM Account WHERE Id =: objAccount1.Id].Commitment_Amount_Rolled_Up__c,
                                        lstInvestor_Entity[0].Commitment_Amount__c + lstInvestor_Entity[1].Commitment_Amount__c);
                                        
        system.assertEquals([SELECT Commitment_Amount_Rolled_Up__c FROM Account WHERE Id =: objAccount.Id].Commitment_Amount_Rolled_Up__c,
                                        lstInvestor_Entity[2].Commitment_Amount__c + lstInvestor_Entity[3].Commitment_Amount__c);
	    */
	    delete lstInvestor_Entity[0];
	    system.assertEquals([SELECT Commitment_Amount_Rolled_Up__c FROM Account WHERE Id =: objAccount.Id].Commitment_Amount_Rolled_Up__c,
                                        lstInvestor_Entity[1].Commitment_Amount__c);
	    
	    undelete lstInvestor_Entity[0];
	    system.assertEquals([SELECT Commitment_Amount_Rolled_Up__c FROM Account WHERE Id =: objAccount.Id].Commitment_Amount_Rolled_Up__c,
                                        lstInvestor_Entity[0].Commitment_Amount__c + lstInvestor_Entity[1].Commitment_Amount__c);
	}
}