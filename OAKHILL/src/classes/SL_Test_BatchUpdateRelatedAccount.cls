/**  
* \arg ClassName      : SL_Test_BatchUpdateRelatedAccount
* \arg JIRATicket     : OAKHILL-15
* \arg CreatedOn      : 24/OCT/2014
* \arg LastModifiedOn : 24/OCT/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as test class for SL_Batch_UpdateRelatedAccount to check its functionality
*/
@isTest
private class SL_Test_BatchUpdateRelatedAccount 
{
    static Legal_Entity__c objLegalEntity;
    static Related_Account__c objRelatedAccount;
    static Account objAccount;
    static List<Month_End_Balance__c> lstMonthEndBalance;
    
    //function to create data for testing functionality
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
    
    //function to check the functionality of related account record update
    static testMethod void checkForRecordUpdate()
    {
    	createData();
    	
    	Test.startTest();
    	Database.executeBatch(new SL_Batch_UpdateRelatedAccount(),200);
    	Test.stopTest();
    	
    	System.assertEquals([SELECT Current_NAV__c FROM Related_Account__c WHERE Id =:objRelatedAccount.Id].Current_NAV__c, 8970);
    	System.assertEquals([SELECT Commitment_Funded__c FROM Related_Account__c WHERE Id =:objRelatedAccount.Id].Commitment_Funded__c, 126);
    }
}