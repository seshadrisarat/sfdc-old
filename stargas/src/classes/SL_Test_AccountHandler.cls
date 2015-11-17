/**
* \arg ClassName      : SL_Test_AccountHandler
* \arg JIRATicket     : STARGAS-25
* \arg CreatedOn      : 1/Aug/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as test class for Account handler
*/
@isTest
private class SL_Test_AccountHandler 
{
    private static final String strProspectRecordType = [SELECT Id FROM RecordType WHERE DeveloperName =:'Prospect' AND SobjectType =:'Account' AND IsPersonType = true LIMIT 1].Id;
    
    private static Account objSourceClientAccount;
    private static Account objSourceClientAccount1;
    private static List<Account> lstAccount;
    private static List<Service_Contract__c> lstServiceContract;
    
    //Method to create data required to do unit testing
    private static void prepareData()
    {
        DivOilPriceGrp__c objDivOilPriceGrp = new DivOilPriceGrp__c(Name = 'Test DivOilPrice');
		insert objDivOilPriceGrp;
		
		Division__c objDiv = new Division__c(Name='test', Division__c ='41', Database__c = '10',Service_Company__c = 'DivCompany', DivOilPriceGrpLU__c = objDivOilPriceGrp.Id);
		insert objDiv;
		
		Territory__c objTerr = new Territory__c(Name='TestTerriority', Division__c = objDiv.Id, Zip_Postal_Code__c = '1140');
		insert objTerr;        
        
        objSourceClientAccount = new Account(LastName = 'Test Source Client', Territory__c = objTerr.Id);
        insert objSourceClientAccount;
        
        objSourceClientAccount1 = new Account(LastName = 'Test Source Client 1', Territory__c = objTerr.Id);
        insert objSourceClientAccount1;
        
        lstServiceContract = new List<Service_Contract__c>{
        														new Service_Contract__c(Client_Prospect__c = objSourceClientAccount.Id),
        														new Service_Contract__c(Client_Prospect__c = objSourceClientAccount.Id),
        														new Service_Contract__c(Client_Prospect__c = objSourceClientAccount.Id),
        														new Service_Contract__c(Client_Prospect__c = objSourceClientAccount1.Id),
        														new Service_Contract__c(Client_Prospect__c = objSourceClientAccount1.Id)
        												  };
        insert lstServiceContract;
        
        lstAccount = new List<Account>{	
        								 new Account(FirstName = 'Test',LastName ='Account 1',RecordTypeId = strProspectRecordType, Source_Client_Account__c = objSourceClientAccount.Id, Territory__c = objTerr.Id),
        								 new Account(FirstName = 'Test',LastName ='Account 2', RecordTypeId = strProspectRecordType, Source_Client_Account__c = objSourceClientAccount.Id, Territory__c = objTerr.Id),
        								 new Account(FirstName = 'Test',LastName ='Account 3', RecordTypeId = strProspectRecordType, Source_Client_Account__c = objSourceClientAccount.Id, Territory__c = objTerr.Id),
        								 new Account(FirstName = 'Test',LastName ='Account 4', RecordTypeId = strProspectRecordType, Source_Client_Account__c = objSourceClientAccount1.Id, Territory__c = objTerr.Id),
        								 new Account(FirstName = 'Test',LastName ='Account 5', RecordTypeId = strProspectRecordType, Source_Client_Account__c = objSourceClientAccount1.Id, Territory__c = objTerr.Id),
        								 new Account(FirstName = 'Test',LastName ='Account 6', RecordTypeId = strProspectRecordType, Territory__c = objTerr.Id)
        							  };
    }
    
    //test method to check the values after firing of trigger
    static testMethod void TestforInsert()
    {
    	//calling function to create data for test code
    	prepareData();
    	
    	Test.startTest();
    	//inserting the list of accounts
    	insert lstAccount;
    	Test.stopTest();
    	
    	//assertion for checking value of Associated_Prospect__c field on service contract record
    	System.assertEquals([SELECT Associated_Prospect__c FROM Service_Contract__c WHERE Id =: lstServiceContract[0].Id].Associated_Prospect__c, lstAccount[2].Id);
    	//assertion for checking count of energy service contract records associated with particular account
    	System.assertEquals([SELECT (SELECT Id FROM Energy_Service_Contracts__r) FROM Account WHERE Id =: lstAccount[2].Id].Energy_Service_Contracts__r.size(), 3);
    	
    	System.assertEquals([SELECT Associated_Prospect__c FROM Service_Contract__c WHERE Id =: lstServiceContract[3].Id].Associated_Prospect__c, lstAccount[4].Id);
    	System.assertNotEquals([SELECT Associated_Prospect__c FROM Service_Contract__c WHERE Id =: lstServiceContract[3].Id].Associated_Prospect__c, lstAccount[3].Id);
    	System.assertEquals([SELECT (SELECT Id FROM Energy_Service_Contracts__r) FROM Account WHERE Id =: lstAccount[4].Id].Energy_Service_Contracts__r.size(), 2);
    	
    	System.assertEquals([SELECT (SELECT Id FROM Energy_Service_Contracts__r) FROM Account WHERE Id =: lstAccount[5].Id].Energy_Service_Contracts__r.size(), 0);
    }
}