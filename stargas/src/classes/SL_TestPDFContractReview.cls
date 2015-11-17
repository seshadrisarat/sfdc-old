/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SL_TestPDFContractReview {

   	private static Prospect_Service_Contract__c objServiceContract;
   	private static Service_Plan_Code__c objServicePlanCode;
	private static Welcome_Kit__c objWelcomeKit; 
	private static User objUser;
	Private static Opportunity objOpportunity;
	
	//Testing SL_ContractReview page
    static testMethod void myUnitTest() 
    {
    	createData();
    	system.runAs(objUser)
    	{
	    	system.test.startTest();
	    	Apexpages.currentPage().getParameters().put('id',objWelcomeKit.Id);
	    	ApexPages.currentPage().getParameters().put('oppid', objOpportunity.Id);
	        ApexPages.currentPage().getHeaders().put('True-Client-IP','12.23.33.111');
	        ApexPages.currentPage().getHeaders().put('X-Salesforce-SIP','12.23.33.111');
	        SL_ContractReviewPDF objContractReviewController = new SL_ContractReviewPDF();
	    	system.test.stopTest();
    	}
    	
    }
    
    //Creating test data
    private static void createData()
    {
		Profile pro = [Select id from Profile where name = 'Standard User'];
		objUser = new User(LastName = 'Test1', Alias = 'Test2', Email = 'Test1224@test.com', username ='test41234@test.com', communitynickname = 'testnick', 
		emailencodingkey = 'ISO-8859-1', timezonesidkey='America/New_York', localeSIDKey='en_US', languagelocalekey='en_US', profileid=pro.ID);
		insert objUser;
		
		DivOilPriceGrp__c objDivOilPriceGrp = new DivOilPriceGrp__c(Name = 'Test DivOilPrice');
		insert objDivOilPriceGrp;
		
		Division__c objDiv = new Division__c(Name='test', Division__c ='41', Database__c = '10',Service_Company__c = 'DivCompany', DivOilPriceGrpLU__c = objDivOilPriceGrp.Id);
		insert objDiv;
		
		Territory__c objTerr = new Territory__c(Name='TestTerriority', Division__c = objDiv.Id, Zip_Postal_Code__c = '1140',RESS_Rep__c = objUSer.Id);
		insert objTerr;
		
		Account objAcc = new Account(LastName='TestAcc', Territory__c = objTerr.Id);
		insert objAcc;
		
		objOpportunity = new Opportunity(Name='TestOppt', CloseDate=Date.today(), StageName='Open',Pricing_Type__c='Ceiling', HHAU__c='test',   AccountId =objAcc.Id );
		insert objOpportunity;
		objServicePlanCode = new Service_Plan_Code__c(Service_Plan_Template__c = 'Value' );
		insert objServicePlanCode;
		objServiceContract  = new Prospect_Service_Contract__c(Opportunity__c = objOpportunity.Id,Service_Plan_Code__c  = objServicePlanCode.Id);
		insert objServiceContract;
		objWelcomeKit = new Welcome_Kit__c(Opportunity__c = objOpportunity.Id, Client_Name__c = objAcc.Id);
		insert objWelcomeKit;
    }
}