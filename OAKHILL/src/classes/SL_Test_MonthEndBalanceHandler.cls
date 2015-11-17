/**  
* \arg ClassName      : SL_Test_MonthEndBalanceHandler
* \arg JIRATicket     : OAKHILL-15
* \arg CreatedOn      : 22/OCT/2014
* \arg LastModifiedOn : 22/OCT/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as test class for SL_MonthEndBalanceHandler and used to check functionality of SL_MonthEndBalance trigger.
*/
@isTest
private class SL_Test_MonthEndBalanceHandler
{
    static Legal_Entity__c objLegalEntity;
    static Related_Account__c objRelatedAccount;
    static Account objAccount;
    static List<Month_End_Balance__c> lstMonthEndBalance;
    static void createData()
    {
    	objAccount = new Account(Name = 'Test Account');
    	insert objAccount;
    	
    	objLegalEntity = new Legal_Entity__c(Organization__c = objAccount.Id, Tax_Number__c = '1111');
    	insert objLegalEntity;
    	
    	objRelatedAccount = new Related_Account__c(Legal_Entity__c = objLegalEntity.Id);
    	insert objRelatedAccount;
    	
    	
    	
    	lstMonthEndBalance = new List<Month_End_Balance__c>{
    															new Month_End_Balance__c(Name = '20141010', Related_Account__c = objRelatedAccount.Id, Commitment_Funded_c__c = 123, Net_Balance__c = 8977),
    															new Month_End_Balance__c(Name = '20141011', Related_Account__c = objRelatedAccount.Id, Commitment_Funded_c__c = 124, Net_Balance__c = 8978),
    															new Month_End_Balance__c(Name = '20141012', Related_Account__c = objRelatedAccount.Id, Commitment_Funded_c__c = 125, Net_Balance__c = 8979),
    															new Month_End_Balance__c(Name = '20141013', Related_Account__c = objRelatedAccount.Id, Commitment_Funded_c__c = 126, Net_Balance__c = 8970)
    														};
    	insert lstMonthEndBalance;
    }
    
    static testMethod void checkForInsert()
    {
    	createData();
    	System.assertEquals([SELECT Commitment_Funded__c FROM Related_Account__c WHERE Id =:objRelatedAccount.Id].Commitment_Funded__c, 126);
    }
    
    static testMethod void checkForUpdate()
    {
    	createData();
    	lstMonthEndBalance[0].Commitment_Funded_c__c = 2222;
    	Test.startTest();
    	update lstMonthEndBalance[0];
    	Test.stopTest();
    }
    
    static testMethod void checkForDelete()
    {
    	createData();
    	Test.startTest();
    	delete lstMonthEndBalance[0];
    	Test.stopTest();
    }
    
    static testMethod void checkForUnDelete()
    {
    	createData();
    	delete lstMonthEndBalance[0];
    	Test.startTest();
    	undelete lstMonthEndBalance[0];
    	Test.stopTest();
    }
}