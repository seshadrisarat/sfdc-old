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
private class SL_TestSendWelcomeKit {
	private static SL_ContractReviewDoc__c objContractReview;
	private static Welcome_Kit__c objWelcomeKit; 
	private static User objUser;
	private static Opportunity objOpportunity;
	
	//Testing SL_ContractReview page
    static testMethod void myUnitTest() {
    	createData();
    	system.runAs(objUser)
    	{
	    	//system.test.startTest();
	        //SL_CreateWelcomeKit.createWelcomeKit(objOpportunity.Id);
	    	//system.test.stopTest();
	    	system.assertEquals([Select Id From Welcome_Kit__c].size(), 1);//Record is created 
    	}
    	
    }
    
    //Testing SL_ContractReview page
    static testMethod void testSendWelcomeKit() { 
    	createData();
    	system.runAs(objUser)
    	{
	    	//system.test.startTest();
	        //SL_CreateWelcomeKit.sendWelcomeKit(objWelcomeKit.Id, objOpportunity.Id);
	    	//system.test.stopTest();
    	}
    }
    //Create test data
    private static void createData()
    {
    	objContractReview  = new SL_ContractReviewDoc__c(Rights_And_Responsibilities__c = 'test' , 
    	Rights_And_Responsibilities_1__c = 'test' , 
    	Name = 'test' , 
    	Id_Verification_Text__c = 'test' , 
		Contract__c = 'test' , 
		Confirmation_Text__c = 'test' , 
		Condition__c = 'test' ,  
		AgreementConfirmation__c = 'test' );
		
		insert objContractReview;
		
		Profile pro = [Select id from Profile where name = 'system administrator'];
		objUser = new User(LastName = 'Test1', Alias = 'Test2', Email = 'Test1224@test.com', username ='test41234@test.com', communitynickname = 'testnick', 
		emailencodingkey = 'ISO-8859-1', timezonesidkey='America/New_York', localeSIDKey='en_US', languagelocalekey='en_US', profileid=pro.ID);
		insert objUser;
		
		DivOilPriceGrp__c objDivOilPriceGrp = new DivOilPriceGrp__c(Name = 'Test DivOilPrice');
		insert objDivOilPriceGrp;
		
		Division__c objDiv = new Division__c(Name='test', Division__c ='41', Database__c = '10',Service_Company__c = 'DivCompany', DivOilPriceGrpLU__c = objDivOilPriceGrp.Id);
		insert objDiv;
		
		Territory__c objTerr = new Territory__c(Name='TestTerriority', Division__c = objDiv.Id, Zip_Postal_Code__c = '1140');
		insert objTerr;
		
		Account objAcc = new Account(LastName='TestAcc', Territory__c = objTerr.Id);
		insert objAcc;
		
		
		Contact objCon = new Contact(LastName='TestAcc', FirstName = 'Test',Email ='test@test.com');
		insert objCon;
		objAcc.Primary_Contact__c = objCon.Id;
		update objAcc;
		
		objOpportunity = new Opportunity(Name='TestOppt', Customer_s_Email_Address__c = 'test@test.com', HHAU__c = '5Linx', 
											CloseDate=Date.today(), StageName='Open',  AccountId =objAcc.Id );
		insert objOpportunity;
		
		objWelcomeKit = new Welcome_Kit__c(Opportunity__c = objOpportunity.Id);
		insert objWelcomeKit;
    }
}