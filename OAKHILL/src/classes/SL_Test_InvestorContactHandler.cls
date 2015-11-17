/**
 * \arg \b ClassName      : SL_Test_InvestorContactHandler
 * \arg \b JIRATicket     : OAKHILL-10
 * \arg \b CreatedOn      : 09/OCT/2014
 * \arg \b CreatededBy    : Pankaj Ganwani
 * \arg \b ModifiedBy     : 
 * \arg \b Description    : This class serves as test class for SL_InvestorContactHandler Apex class 
*/
@isTest
private class SL_Test_InvestorContactHandler 
{
	private static Fund_of_Interest__c objFund_of_Interest ;
	//Function to prepare data
    private static void createData()
    {
    	Account objAccount = new Account(Name = 'Account1');
    	insert objAccount;
    	
		Contact objContact = new Contact(LastName = 'Contact1', AccountId = objAccount.Id );
		insert objContact;
		
		Fund_Family__c objFundFamily = new Fund_Family__c(Name = 'Fund_Family_1');
		insert objFundFamily;
		
		Fund__c objFund = new Fund__c(Name = 'Name', Fund_Family__c = objFundFamily.Id );
		insert objFund;
		
		
		objFund_of_Interest = new Fund_of_Interest__c(Contact__c = objContact.Id, Fund_Family__c = objFundFamily.Id, Status__c = 'Active');
		insert objFund_of_Interest;
		
		Legal_Entity__c objLegal_Entity = new Legal_Entity__c(Organization__c = objAccount.Id, 
																	Name = 'LegalEntity1', 
																	Tax_Number__c = '123450');
		insert objLegal_Entity;
		
		Related_Account__c objRelated_Account = new  Related_Account__c(Name = 'RelatedAccount1', 
																			Legal_Entity__c = objLegal_Entity.Id, Fund__c = objFund.Id);
		insert	objRelated_Account;
		
		Investor_Contact__c objInvestor_Contact = new Investor_Contact__c(Contact__c = objContact.Id , Investment__c = objRelated_Account.Id);
		insert 	objInvestor_Contact ;
		
    }
    
     //Function to check for Fund_of_Interest Status
    static testMethod void checkForFOIStatus() 
    {
    	createData();
    	Test.startTest();
    	SL_InvestorContactHandler objICH = new SL_InvestorContactHandler();
    	Test.stopTest();
    	System.assertEquals([SELECT Status__c FROM Fund_of_Interest__c WHERE ID =:objFund_of_Interest.Id].Status__c, 'Inactive');
    }
}