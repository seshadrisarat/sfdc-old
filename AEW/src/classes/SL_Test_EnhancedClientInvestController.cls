/**
* \arg ClassName      : SL_Test_EnhancedClientInvestController
* \arg JIRATicket     : AEW-11
* \arg CreatedOn      : 20/JULY/2015
* \arg LastModifiedOn : 20/JULY/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as controller for SL_EnhancedClientInvestmentRelatedList page.
*/

@isTest
private class SL_Test_EnhancedClientInvestController 
{   
    static Fund__c objFund;
    static List<Client_Investment__c> lstClientInvestment;
    static Account objAccount;
    static Client_Investment_Field_Ids__c objCI;

    private static void createData()
    {
        objCI = new Client_Investment_Field_Ids__c(Name = 'Fund__c', Field_Id__c = '00N848848484');
        insert objCI;
        
        objAccount = new Account(Name = 'Test Account');
        insert objAccount;
        
        objFund = new Fund__c(Name = 'Test Fund');
        insert objFund;

        lstClientInvestment = new List<Client_Investment__c>{
                                                                new Client_Investment__c(Name = 'Test Client Investment 1', As_Of__c = Date.today(), Fund__c = objFund.Id, NAV__c = 4390, Status__c = 'Pending', Organization__c = objAccount.Id),
                                                                new Client_Investment__c(Name = 'Test Client Investment 2', As_Of__c = Date.today(), Fund__c = objFund.Id, NAV__c = 4390.02, Status__c = 'Active', Organization__c = objAccount.Id)
                                                            };
                                                        
        insert lstClientInvestment;
    }

    @isTest static void checkForPageParameters() 
    {
        createData();

        ApexPages.currentPage().getParameters().put('id',objFund.Id);
        SL_EnhancedClientInvestmentController objClientInvestmentController = new SL_EnhancedClientInvestmentController();
        SL_EnhancedClientInvestmentController.query('SELECT Id FROM Client_Investment__c WHERE Fund__c ='+objFund.Id);
        String strFundName = objClientInvestmentController.getFundName();
        System.assertEquals('Test Fund', strFundName);
        System.assertEquals('$',objClientInvestmentController.currencyIso);
    }

    @isTest static void coverageForStaticMethods()
    {
        SL_EnhancedClientInvestmentController.describe('Client_Investment__c');
        SL_EnhancedClientInvestmentController.describeFieldSet('Client_Investment__c','SL_ClientInvestmentRelatedList');
        SL_EnhancedClientInvestmentController.getCurrencySymbolFromIso('USD');
    }    
}