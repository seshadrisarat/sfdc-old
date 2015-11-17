/**  
* \arg ClassName		: SL_Test_FundraisingOpportunityHandler
* \arg JIRATicket		: AEW-5
* \arg CreatedOn		: 02/Jan/2015
* \arg LastModifiedOn	: 15/OCT/2015
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: Sandeep, Pankaj Ganwani
* \arg Description		: Test class for SL_FundraisingOpportunityHandler.
*/
@isTest
private class SL_Test_FundraisingOpportunityHandler 
{
    static testMethod void Test_FundraisingOpportunityHandler()
    {
    	Account objParentAccount = new Account(Name = 'Test Parent Account');
    	insert objParentAccount;
    	
    	Account objAccount = new Account(Name = 'Test Account', ParentId = objParentAccount.Id);
    	insert objAccount;
    	
    	List<Contact> lstContact = new List<Contact>{
    												new Contact (LastName = 'Test Contact 1', AccountId = objAccount.Id, Primary_IR_Contact__c = true),
    												new Contact (LastName = 'Test Contact 2', AccountId = objAccount.Id, Primary_IR_Contact__c = true),
    												new Contact (LastName = 'Test Contact 3', AccountId = objAccount.Id, Primary_IR_Contact__c = false)};
    	insert lstContact;
    	
    	Fund__c objFund = new Fund__c(Name = 'Test Fund');
    	insert objFund;
    	SL_RecursionHelper.setisInsert(true);
    	Fundraising_Opportunity__c objFundraisingOpp = new Fundraising_Opportunity__c(Name = 'Test FO 1', Organization__c = objAccount.Id, Fund__c = objFund.Id);
    	
    	insert objFundraisingOpp;
    	
    	system.assertEquals([SELECT Id FROM Fundraising_Opportunity_Contact__c].size(), 2);
    }
    
    static testMethod void Test1()
    {
        Account objAccount1 = new Account(Name = 'Test Account1');
    	insert objAccount1;
    	
        Account objAccount = new Account(Name = 'Test Account',Consultant_Organization__c = objAccount1.Id);
    	insert objAccount;
    	
    	List<Contact> lstContact = new List<Contact>{
    												new Contact (LastName = 'Test Contact 1', AccountId = objAccount.Id, Primary_IR_Contact__c = true),
    												new Contact (LastName = 'Test Contact 2', AccountId = objAccount.Id, Primary_IR_Contact__c = true),
    												new Contact (LastName = 'Test Contact 3', AccountId = objAccount.Id, Primary_IR_Contact__c = false)};
    	insert lstContact;
    	
    	Fund__c objFund = new Fund__c(Name = 'Test Fund');
    	insert objFund;
    	
    	Fundraising_Opportunity__c objFundraisingOpp = new Fundraising_Opportunity__c(Name = 'Test FO 1', Organization__c = objAccount.Id, Fund__c = objFund.Id);
    	insert objFundraisingOpp;
    	
    	system.assertEquals([SELECT Consultant__c FROM Fundraising_Opportunity__c WHERE Id =: objFundraisingOpp.Id ].Consultant__c , objAccount1.Id);
    	
    	delete objFundraisingOpp;
    	
    	Account objAccount2 = new Account(Name = 'Test Account2');
    	insert objAccount2;
    	
    	
    	Fundraising_Opportunity__c objFundraisingOpp1 = new Fundraising_Opportunity__c(Name = 'Test FO 1', Organization__c = objAccount.Id, Fund__c = objFund.Id,
    	                                                                                Consultant__c = objAccount2.Id);
    	insert objFundraisingOpp1;
    	
    	system.assertEquals([SELECT Consultant__c FROM Fundraising_Opportunity__c WHERE Id =: objFundraisingOpp1.Id ].Consultant__c , objAccount2.Id);
    	system.assertEquals([SELECT Opportunity_Type__c FROM  Fundraising_Opportunity__c WHERE Id =: objFundraisingOpp1.Id].Opportunity_Type__c, 'Initial Investment');
    	
    	
        Account objAccount3 = new Account(Name = 'Test Account2');
    	insert objAccount3;
    	
    	Fund__c objFund1 = new Fund__c(Name = 'Test Fund');
    	insert objFund1;
    	
    	Client_Investment__c objClientInvestment = new Client_Investment__c(Name = 'Test Client Investment', Fund__c = objFund1.Id, Organization__c = objAccount3.Id,
    	                                                                    Status__c = 'Active');
    	insert objClientInvestment;
    	
    	SL_RecursionHelper.setisInsert(true);
    	
    	Fundraising_Opportunity__c objFundraisingOpp2 = new Fundraising_Opportunity__c(Name = 'Test FO 1', Organization__c = objAccount3.Id, Fund__c = objFund1.Id);
    	insert objFundraisingOpp2;
    	
    	system.assertEquals([SELECT Consultant__c FROM Fundraising_Opportunity__c WHERE Id =: objFundraisingOpp2.Id ].Consultant__c , null);
    	system.assertEquals([SELECT Opportunity_Type__c FROM Fundraising_Opportunity__c WHERE Id =: objFundraisingOpp2.Id ].Opportunity_Type__c , 'Additional Investment');
        system.assertEquals([SELECT Type_of_Client__c FROM Fundraising_Opportunity__c WHERE Id =: objFundraisingOpp2.Id ].Type_of_Client__c , 'Prior Fund Investor');
        
        Fund_Series__c objFundSeries = new Fund_Series__c(Name = 'Test Fund Series');
        insert objFundSeries;
        
        Fund__c objFund2 = new Fund__c(Name = 'Test Fund', Fund_Series__c = objFundSeries.Id);
    	insert objFund2;
    	
    	Client_Investment__c objClientInvestment1 = new Client_Investment__c(Name = 'Test Client Investment2', Fund__c = objFund2.Id, Organization__c = objAccount3.Id,
    	                                                                    Status__c = 'Active');
    	insert objClientInvestment1;
    	
    	SL_RecursionHelper.setisInsert(true);
    	
    	objFundraisingOpp2.Fund__c = objFund2.Id;
    	update objFundraisingOpp2;
    	
    	system.assertEquals([SELECT Opportunity_Type__c FROM Fundraising_Opportunity__c WHERE Id =: objFundraisingOpp2.Id ].Opportunity_Type__c , 'Additional Investment');
        system.assertEquals([SELECT Type_of_Client__c FROM Fundraising_Opportunity__c WHERE Id =: objFundraisingOpp2.Id ].Type_of_Client__c , 'Prior Fund Investor');
        
    }
    
    static testmethod void Test2()
    {
    	Account objAccount = new Account(Name = 'Test Account');
    	insert objAccount;
    	
        Account objAccount1 = new Account(Name = 'Test Account1',ParentId = objAccount.Id);
    	insert objAccount1;
    	
    	Account objAccount2 = new Account(Name = 'Test Account 2', ParentId = objAccount1.Id);
    	insert objAccount2;
    	
    	Account objAccount3 = new Account(Name = 'Test Account 3', ParentId = objAccount.Id);
    	insert objAccount3;
    	
    	Fund_Series__c objFundSeries = new Fund_Series__c(Name = 'Test Fund Series');
        insert objFundSeries;
    	
    	Fund__c objFund = new Fund__c(Name = 'Test Fund', Fund_Series__c = objFundSeries.Id);
    	insert objFund;
    	
    	Fund__c objFund1 = new Fund__c(Name = 'Test Fund1');
    	insert objFund1;
    	
    	insert new List<Client_Investment__c>{
    											  new Client_Investment__c(Name = 'Test Client Investment1', Fund__c = objFund.Id, Organization__c = objAccount.Id,
    	                                                                    Status__c = 'Active'),
    	                                          new Client_Investment__c(Name = 'Test Client Investment1', Fund__c = objFund1.Id, Organization__c = objAccount3.Id,
    	                                                                    Status__c = 'Active')
    										 };
    	insert new List<Fundraising_Opportunity__c>{
    													new Fundraising_Opportunity__c(Name = 'Test FO 1', Organization__c = objAccount.Id, Fund__c = objFund.Id),
    													new Fundraising_Opportunity__c(Name = 'Test FO 1', Organization__c = objAccount1.Id, Fund__c = objFund.Id),
    													new Fundraising_Opportunity__c(Name = 'Test FO 1', Organization__c = objAccount3.Id, Fund__c = objFund.Id),
    													new Fundraising_Opportunity__c(Name = 'Test FO 1', Organization__c = objAccount3.Id, Fund__c = objFund1.Id)
    											   };
    }
}