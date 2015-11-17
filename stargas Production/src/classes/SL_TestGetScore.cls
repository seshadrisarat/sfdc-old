/**  
* \arg ClassName      : SL_TestGetScore
* \arg JIRATicket     : STARGAS-11
* \arg CreatedOn      : 22/JUL/2014
* \arg LastModifiedOn : 18/NOV/2014
* \arg CreatededBy    : SRUTI
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This is controller is used to test functionality of HART call out
*/
@isTest
private class SL_TestGetScore {

	Private static Credit_Check_History__c objCreditCheckHistory ;
	Private static SL_HARTCalloutInputs__c objHartCalloutInputs ;
	Private static Opportunity objOpportunity ;

	private static void createData()
	{
		
		objHartCalloutInputs = new SL_HARTCalloutInputs__c(Name='test', Account__c='Test', Callout_URL__c= 'www.test.com',
														Password__c='testpwd', 
														Process__c='process', 
														Bureau__c='BU');
		insert objHartCalloutInputs;
		
		Profile pro = [Select id from Profile where name = 'Standard User'];
		User objUSer = new User(LastName = 'Test1', Alias = 'Test2', Email = 'Test1224@test.com', username ='test41234@test.com', communitynickname = 'testnick', 
		emailencodingkey = 'ISO-8859-1', timezonesidkey='America/New_York', localeSIDKey='en_US', languagelocalekey='en_US', profileid=pro.ID);
		insert objUSer;
		
		DivOilPriceGrp__c objDivOilPriceGrp = new DivOilPriceGrp__c(Name = 'Test DivOilPrice');
		insert objDivOilPriceGrp;
		
		Division__c objDiv = new Division__c(Name='test', Division__c ='41', Database__c = '10',Service_Company__c = 'DivCompany', DivOilPriceGrpLU__c = objDivOilPriceGrp.Id);
		insert objDiv;
		
		Territory__c objTerr = new Territory__c(Name='TestTerriority', Division__c = objDiv.Id, Zip_Postal_Code__c = '1140',RESS_Rep__c = objUSer.Id);
		insert objTerr;
		
		Account objAcc = new Account(LastName='TestAcc', Territory__c = objTerr.Id);
		insert objAcc;
		
		objOpportunity = new Opportunity(Name='TestOppt', CloseDate=Date.today(), StageName='Open',  AccountId =objAcc.Id, HHAU__c='test', SSN__c= '565769878' );
		insert objOpportunity;
		
		objCreditCheckHistory = new Credit_Check_History__c(
							SSN__c = '890', Requester__c = objUSer.Id,
							Opportunity__c = objOpportunity.Id, Last_Name__c = 'Test',
							First_Name__c  = 'Test', Name = 'Test Name');
		insert objCreditCheckHistory;
														
		
	}
	//Testing createCreditCheckRecord method, the CreditHistoryCheck record should be created 
	static testMethod void Test_CreateCreditHistory() 
	{        
		createData();		// Create records
        
        Test.startTest();
        SL_GetScore.createCreditCheckRecord(objOpportunity.Id);
        Test.stopTest();
        
        system.assertEquals([Select Id From Credit_Check_History__c].size(), 2);//Record is created 
    }    
    
    //Testing CreditScoreCheck method, the CreditHistoryCheck record should be updated with a  Score value
    static testMethod void Test_UpdateCreditScore() 
	{        
		createData();	// Create test records
        
        Test.startTest();
        objOpportunity.Years__c = 2;  
        update objOpportunity;
        SL_GetScore.CreditScoreCheck(objCreditCheckHistory.Id, objOpportunity.Id);
        
        Test.stopTest();
        system.assertEquals([Select Id From Credit_Check_History__c where Score__c != null].size(), 1);//Record is created and Score has been updated
    } 
    
    //Testing CreditScoreCheck method for Opportunity Year less than 1, the CreditHistoryCheck record should be updated with a  Score value
    static testMethod void Test_UpdateCreditScoreOnCreditHistory() 
	{        
		createData();		// Create records
        
        Test.startTest();
        SL_GetScore.CreditScoreCheck(objCreditCheckHistory.Id, objOpportunity.Id);
        
        Test.stopTest();
        system.assertEquals([Select Id From Credit_Check_History__c where Score__c != null].size(), 1);//Record is created and Score has been updated
    } 
}