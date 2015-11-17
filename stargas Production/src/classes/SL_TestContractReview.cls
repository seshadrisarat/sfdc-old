/**  
* \arg ClassName      : SL_TestContractReview
* \arg JIRATicket     : STARGAS-12
* \arg CreatedOn      : 25/JUL/2014
* \arg LastModifiedOn : 16/SEPT/2014
* \arg CreatededBy    : SRUTI
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as test class for checking status of welcome kits sent
*/
@isTest
private class SL_TestContractReview 
{
	private static SL_ContractReviewDoc__c objContractReview;
	private static Welcome_Kit__c objWelcomeKit; 
	private static User objUser;
	
	//Testing SL_ContractReview page
    static testMethod void checkForSignedStatus() 
    {
    	createData();
    	system.runAs(objUser)
    	{
	    	Test.startTest();
	    	Apexpages.currentPage().getParameters().put('id',objWelcomeKit.Id);
	        
	        SL_ContractReview objContractReviewController = new SL_ContractReview();
	        objContractReviewController.save();
	        
	        objContractReviewController.objWelcomeKit.Electronic_Signature__c = 'Test Electronic';
	        objContractReviewController.objWelcomeKit.Email__c = 'test@silverlinecrm.com';
	        objContractReviewController.isConfirmed = true;
	        objContractReviewController.save();
	    	
	    	Test.stopTest();
	    	System.assertEquals([SELECT Letter_Status__c FROM Welcome_Kit__c WHERE Id =:objWelcomeKit.Id].Letter_Status__c, 'Signed');
	    	System.assertEquals([SELECT Confirm_Name_Email_IP__c FROM Welcome_Kit__c WHERE Id =:objWelcomeKit.Id].Confirm_Name_Email_IP__c,true);	    	
    	}    	
    }
    
    static testMethod void checkForContactMe()
    {
    	createData();
    	system.runAs(objUser)
    	{
    		Test.startTest();
	    	Apexpages.currentPage().getParameters().put('id',objWelcomeKit.Id);
	    	SL_ContractReview objContractReviewController = new SL_ContractReview();
	    	objContractReviewController.contactMe();
	    	Test.stopTest();
    	}
    }
    
    static testmethod void checkForNull()
    {
    	createData();
    	System.runAs(objUser)
    	{
	    	Test.startTest();
	    	Apexpages.currentPage().getParameters().put('id',objWelcomeKit.Id);
	        
	        SL_ContractReview objContractReviewController = new SL_ContractReview();
	        objContractReviewController.save();
	        
	        objContractReviewController.objWelcomeKit.Electronic_Signature__c = 'test signature';
	        objContractReviewController.objWelcomeKit.Email__c = 'test@silverlinecrm.com';
	        objContractReviewController.isConfirmed = true;
	        objContractReviewController.contactMe();    	
	    	Test.stopTest();
    	}
    }
    
    static testMethod void checkForRedirectContactMe()
    {
    	createData();
    	System.runAs(objUser)
    	{
    		Test.startTest();
	    	Apexpages.currentPage().getParameters().put('id',objWelcomeKit.Id);
	        
	        SL_ContractReview objContractReviewController = new SL_ContractReview();
	        objContractReviewController.save();
	        
	        objContractReviewController.objWelcomeKit.Electronic_Signature__c = 'Test signature';
	        objContractReviewController.objWelcomeKit.Email__c = 'test@silverlinecrm.com';
	        objContractReviewController.isConfirmed = false;
	        objContractReviewController.contactMe();    	
	    	Test.stopTest();
    	}
    }
    
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
		
		Profile pro = [Select id from Profile where name = 'System Administrator'];
		objUser = new User(LastName = 'Test1', Alias = 'Test2', Email = 'Test1224@test.com', username ='test41234@test.com', communitynickname = 'testnick', 
		emailencodingkey = 'ISO-8859-1', timezonesidkey='America/New_York', localeSIDKey='en_US', languagelocalekey='en_US', profileid=pro.ID);
		insert objUser;
		
		DivOilPriceGrp__c objDivOilPriceGrp1 = new DivOilPriceGrp__c(Name = 'Test DivOilPrice');
		insert objDivOilPriceGrp1;
		
		Division__c objDiv1 = new Division__c(Name='test', Division__c ='41', Database__c = '10',Service_Company__c = 'DivCompany', DivOilPriceGrpLU__c = objDivOilPriceGrp1.Id);
		insert objDiv1;
		
		Territory__c objTerr1 = new Territory__c(Name='TestTerriority', Division__c = objDiv1.Id, Zip_Postal_Code__c = '1140');
		insert objTerr1;
		
		Account objAcc = new Account(LastName='TestAcc', Territory__c = objTerr1.Id);
		insert objAcc;
		
		Contact objContact = new Contact(LastName = 'test-001');
		insert objContact;
		
		Opportunity objOpportunity = new Opportunity(Name='TestOppt', CloseDate=Date.today(), StageName='Open',   HHAU__c = '5Linx', AccountId =objAcc.Id );
		insert objOpportunity;
		
		DivOilPriceGrp__c objDivOilPriceGrp = new DivOilPriceGrp__c(Name= 'test-001');
		insert objDivOilPriceGrp;
		
		Division__c objDivision = new Division__c(Name = 'test', DivOilPriceGrpLU__c = objDivOilPriceGrp.Id, GM__c = 'test');
		insert objDivision;
		
		Territory__c objTerritory = new Territory__c(Name='testTerr' , Division__c = objDivision.Id);
		insert objTerritory;
		
		objWelcomeKit = new Welcome_Kit__c(Opportunity__c = objOpportunity.Id, Client_Name__c = objAcc.Id);
		insert objWelcomeKit;
		
		String str = [Select e.Name, e.FolderId,HtmlValue From EmailTemplate e WHERE DeveloperName = 'Welcome_Kit' LIMIT 1].HtmlValue;
		str += '{!Welcome_Kit__c.Id}';
		str += '{!Welcome_Kit__c.Client_Name__c}';
		str += '{!Opportunity.Division_GM__c}';
		
    }
}