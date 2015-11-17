/**
* \arg ClassName        : SL_Test_ManageContactAddress
* \arg JIRATicket       : AMSEC-292, 293
* \arg CreatedOn        : 21/MAY/2015
* \arg LastModifiedOn   : 22/MAY/2015
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : Lodhi
* \arg Description      : Test class for SL_ManageContactAddress class.
*/
@isTest
private class SL_Test_ManageContactAddress 
{
    static Account objAccount;
    static List<Contact> lstContact;
    
    private static void createData() 
    {
        objAccount = new Account(Name = 'Test Account', BillingStreet = '52454', BillingCity = 'Test B City', BillingState = 'Test B State',
                                 BillingPostalCode = '8798795', BillingCountry = 'Test Country', ShippingStreet = 'Test S Street', 
                                 ShippingCity = 'Test S City', ShippingState = 'Test S State', ShippingPostalCode = '879525', 
                                 ShippingCountry = 'Test S Country');
        insert objAccount;
        
        lstContact = new List<Contact>{
                        new Contact(LastName = 'Test-01', AccountId = objAccount.Id, MailingCity = 'Test M City-01', MailingStreet = 'Test M Street-01', 
                                    MailingState = 'Test M state-01', MailingPostalCode = '87921', MailingCountry = 'Test M Country-01'),
                        new Contact(LastName = 'Test-02', AccountId = objAccount.Id, MailingCity = 'Test M City-02', MailingStreet = 'Test M Street-02', 
                                    MailingState = 'Test M state-02', MailingPostalCode = '87921', MailingCountry = 'Test M Country-02'),
                        new Contact(LastName = 'Test-03', AccountId = objAccount.Id, MailingCity = 'Test M City-03', MailingStreet = 'Test M Street-03', 
                                    MailingState = 'Test M state-03', MailingPostalCode = '87921', MailingCountry = 'Test M Country-03')                                                
        };
        insert lstContact;
    }
    
    private static testMethod void Test_AccountManageAddress()
    {
        createData();
        Apexpages.currentPage().getParameters().put('Id', objAccount.Id);
        SL_ManageContactAddress objManageAddress = new SL_ManageContactAddress();
        objManageAddress.lstContactWrapper[0].strBusinessAddType = 'business1';
        objManageAddress.lstContactWrapper[1].strBusinessAddType = 'business2';
        objManageAddress.lstContactWrapper[2].strBusinessAddType = 'business1';
        objManageAddress.getBusinessOptions();
        objManageAddress.save();
        List<Contact> lstCon = [SELECT Id, MailingState, MailingPostalCode, MailingCountry, MailingStreet FROM Contact WHERE Id IN : lstContact];
        system.assertEquals(lstCon[0].MailingState, 'Test B State');
        system.assertEquals(lstCon[0].MailingPostalCode, '8798795');
        system.assertEquals(lstCon[1].MailingStreet, 'Test S Street');
        system.assertEquals(lstCon[1].MailingCountry, 'Test S Country');
        system.assertEquals(lstCon[2].MailingCountry, 'Test Country');
        system.assertEquals(lstCon[2].MailingStreet, '52454');
    }
    
    private static testMethod void Test_ContactManageAddress()
    {
        createData();
        Apexpages.currentPage().getParameters().put('Id', lstContact[0].Id);
        SL_ManageContactAddress objManageAddress = new SL_ManageContactAddress();
        objManageAddress.lstContactWrapper[0].strBusinessAddType = 'business1';
        objManageAddress.getBusinessOptions();
        objManageAddress.save();
        List<Contact> lstCon = [SELECT Id, MailingState, MailingPostalCode, MailingCountry, MailingStreet FROM Contact WHERE Id IN : lstContact];
        system.assertEquals(lstCon[0].MailingState, 'Test B State');
        system.assertEquals(lstCon[0].MailingPostalCode, '8798795');
    }
}