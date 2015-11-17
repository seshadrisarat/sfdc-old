/**
* \arg ClassName      : SL_Test_InvestorContactAndFundController
* \arg JIRATicket     : OAKHILL-9, OAKHILL-34
* \arg CreatedOn      : 13/OCT/2014
* \arg LastModifiedOn : 9/OCT/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as test class for checking the functionality of investor contact component controller.
*/
@isTest
private class SL_Test_InvestorContactAndFundController 
{
    static Apexpages.Standardcontroller objStandardController;
    static Contact objContact;
    static Account objAccount;
    static Legal_Entity__c objLegalEntity;
    static Related_Account__c objRelatedAccount;
    static Fund_Family__c objFundFamily;
    static Fund__c objFund;
    static List<Investor_Contact__c> lstInvestorContact;
    static List<Fund_of_Interest__c> lstFundOfInterest;
    static SL_InvestorContactInlineVFController objInvestorContactInlineVFController;
    static SL_InvestorContactAndFundVFController objInvestorContactAndFundVFController;
    static List<Custom_Field_Ids__c> lstCustomFieldIds;
    
    //Method for preparing data to test the functionality
    static void createData()
    {
    	objContact = new Contact(LastName = 'Test Contact');
    	insert objContact;
    	
    	objAccount = new Account(Name = 'Test Account');
    	insert objAccount;
    	
    	objLegalEntity = new Legal_Entity__c(Organization__c = objAccount.Id, Tax_Number__c = '1111');
    	insert objLegalEntity;
    	
    	objRelatedAccount = new Related_Account__c(Legal_Entity__c = objLegalEntity.Id);
    	insert objRelatedAccount;
    	
    	objFundFamily = new Fund_Family__c(Name = 'Test Fund Family');
    	insert objFundFamily;
    	
    	objFund = new Fund__c(Name = 'Test Fund', Fund_Family__c = objFundFamily.Id);
    	insert objFund;
    	
    	lstInvestorContact = new List<Investor_Contact__c>{
    															new Investor_Contact__c(Contact__c = objContact.Id, Investment__c = objRelatedAccount.Id),
    															new Investor_Contact__c(Contact__c = objContact.Id, Investment__c = objRelatedAccount.Id)
    													  };
    	insert lstInvestorContact;
    	
    	lstFundOfInterest = new List<Fund_of_Interest__c>{
    															new Fund_of_Interest__c(Fund_Family__c = objFundFamily.Id, Contact__c = objContact.Id, Estimate__c = true),
    															new Fund_of_Interest__c(Fund_Family__c = objFundFamily.Id, Contact__c = objContact.Id, Estimate__c = true)
    													 };
    	insert lstFundOfInterest;
    	
    	lstCustomFieldIds = new List<Custom_Field_Ids__c>{
    														 new Custom_Field_Ids__c(Name = 'Fund_of_Interest__c', FieldId__c = '00N8438744422'),
    														 new Custom_Field_Ids__c(Name = 'Investor_Contact__c', FieldId__c = '00N8438742244')
    													 };
    	insert lstCustomFieldIds;
    	
    	objStandardController = new Apexpages.Standardcontroller(objContact);
    	objInvestorContactInlineVFController =  new SL_InvestorContactInlineVFController(objStandardController);
    	objInvestorContactAndFundVFController = new SL_InvestorContactAndFundVFController();
    	objInvestorContactAndFundVFController.ContactId = objStandardController.getId();
    }
    
    //Method to check functionality for records display
    static testMethod void checkforRecordDisplay() 
    {
    	createData();
       
        Test.startTest();
        objInvestorContactAndFundVFController.initializeElements();
        Test.stopTest();
        
        System.assertEquals(objInvestorContactAndFundVFController.lstRecordWrapper.size(), 4);
    }
    
    //Method to check functionality for records delete
    static testMethod void checkForDelete()
    {
    	createData();
    	objInvestorContactAndFundVFController.initializeElements();
    	objInvestorContactAndFundVFController.strObjectId = objInvestorContactAndFundVFController.lstRecordWrapper[0].objSobject.Id;
    	
    	Test.startTest();
    	objInvestorContactAndFundVFController.deleteRecords();
    	Test.stopTest();
    	
    	System.assertEquals([SELECT COUNT() FROM Investor_Contact__c WHERE Id =:lstInvestorContact[0].Id], 0);
    }
    
    //Method for checking edit
    static testMethod void checkForEditAndRedirect()
    {
    	createData();
    	
    	Test.startTest();
    	objInvestorContactAndFundVFController.editRecords();
    	objInvestorContactAndFundVFController.redirectFundOfInterest();
    	objInvestorContactAndFundVFController.redirectInvestorContact();
    	Test.stopTest();
    	
    	System.assertEquals(objInvestorContactAndFundVFController.isEditable, true);
    }
    
    //Method for checking save button functionality
    static testMethod void checkForSave()
    {
    	createData();
    	objInvestorContactAndFundVFController.initializeElements();
    	
    	List<SL_InvestorContactAndFundVFController.RecordWrapper> lstRecordWrapperForTest = objInvestorContactAndFundVFController.lstRecordWrapper;
    	lstRecordWrapperForTest[0].objSobject.put('Capital_Call__c',false);
    	lstRecordWrapperForTest[1].objSobject.put('Capital_Call__c',false);
    	
    	Test.startTest();
    	objInvestorContactAndFundVFController.saveRecords();
    	Test.stopTest();
    }
    
    //Method for covering meeting notes stuff in the code
    static testMethod void coverageForMeetingNotesStuff()
    {
    	createData();
    	objInvestorContactAndFundVFController.FundFamilyIdString = String.join(new List<String>{objFundFamily.Id},',');
    	objInvestorContactAndFundVFController.LaunchContext = 'mn';
    	objInvestorContactAndFundVFController.initializeElements();
    	
    	Test.startTest();
    	objInvestorContactAndFundVFController.saveRecords();
    	Test.stopTest();
    }
}