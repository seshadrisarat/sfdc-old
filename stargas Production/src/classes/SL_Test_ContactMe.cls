/**  
* \arg ClassName      : SL_Test_ContactMe
* \arg JIRATicket     : STARGAS-12
* \arg CreatedOn      : 15/JAN/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as test class to check the functionality of contact me page
*/
@isTest
private class SL_Test_ContactMe 
{
    static Welcome_Kit__c objWelcomeKit;
    static Account objAccount;
    static Opportunity objOpportunity;
    
    private static void createData()
    {
    	DivOilPriceGrp__c objDivOilPriceGrp1 = new DivOilPriceGrp__c(Name = 'Test DivOilPrice');
		insert objDivOilPriceGrp1;
		
		Division__c objDiv1 = new Division__c(Name='test', Division__c ='41', Database__c = '10',Service_Company__c = 'DivCompany', DivOilPriceGrpLU__c = objDivOilPriceGrp1.Id);
		insert objDiv1;
		
		Territory__c objTerr1 = new Territory__c(Name='TestTerriority', Division__c = objDiv1.Id, Zip_Postal_Code__c = '1140');
		insert objTerr1;
    	
    	objAccount = new Account(LastName = 'Test Account', Territory__c = objTerr1.Id);
    	insert objAccount;
    	
    	objOpportunity = new Opportunity(Name='TestOppt', CloseDate=Date.today(), StageName='Open', AccountId = objAccount.Id, Delivery_Street2__c = '10', HHAU__c = 'Email');
    	insert objOpportunity;
    	
    	objWelcomeKit = new Welcome_Kit__c(Client_Name__c = objAccount.Id, Opportunity__c = objOpportunity.Id);
    	insert objWelcomeKit;
    }
    
    static testMethod void checkForContactMe() 
    {
        createData();
        Apexpages.currentPage().getParameters().put('welcomekitId',objWelcomeKit.Id);
        SL_ContactMe objContactMe = new SL_ContactMe();
        objContactMe.strHomePhone = '0228373333';
        objContactMe.strMobile = '0228373333';
        
        Test.startTest();
        objContactMe.saveDetails();
        Test.stopTest();
    }
    
    static testMethod void checkForNullWelcomeKit()
    {
    	createData();
        Apexpages.currentPage().getParameters().put('welcomekitId',null);
        Test.startTest();
        SL_ContactMe objContactMe = new SL_ContactMe();
        Test.stopTest();
    }
    
    static testMethod void checkForContactPreferences()
    {
    	createData();
        Apexpages.currentPage().getParameters().put('welcomekitId',objWelcomeKit.Id);
        SL_ContactMe objContactMe = new SL_ContactMe();
        
        Test.startTest();
        objContactMe.getContactPreferences();
        Test.stopTest();
    }
}