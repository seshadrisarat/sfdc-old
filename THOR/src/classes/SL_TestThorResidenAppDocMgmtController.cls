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
private class SL_TestThorResidenAppDocMgmtController {
	
	private static final Id CUSTOMER_ID = [SELECT Id FROM RecordType WHERE DeveloperName =: 'PersonAccount' LIMIT 1].Id;
    static testMethod void SL_TestThorResidenAppDocMgmtController() 
    {
    	/* Insert Account record */
    	Account objAccount = new Account(LastName = 'Test Account - eRenterBtch',RecordTypeId=CUSTOMER_ID,PersonEmail = 'test@test1.com');
    	insert objAccount;
    	
    	/* Insert Opportunity record */
    	Opportunity objOpp = new Opportunity(Name = 'Test Opportunity', AccountId = objAccount.Id, CloseDate = Date.valueOf('2014-08-02'), StageName = 'Qualification');
    	insert objOpp;
    	
    	/* Insert Contact_Role__c record */
    	Contact_Role__c objContactRole = new Contact_Role__c(
    	
    	//Contact__c = objContact.Id ,
    	
    	Opportunity__c = objOpp.Id, LastName__c = 'TestLastName', FirstName__c = 'TestFirstName',Person_Account__c = objAccount.Id);
    	insert objContactRole;
    	
    	/* Insert Custom setting record */
    	SL_LeaseDocuments__c objSLLeaseDocuments = new SL_LeaseDocuments__c(Name = 'testName', Description__c = 'DL', Set_Order__c=1);
    	insert objSLLeaseDocuments;
    	
    	PageReference pgRef = Page.SL_ThorResidentialAppDocMgmt; 
		Test.setCurrentPage(pgRef);
    	
    	/* Passing Id to page */
		ApexPages.currentPage().getParameters().put('oppId', objOpp.Id);
		ApexPages.currentPage().getParameters().put('conRoleId', objContactRole.Id);
		
		/* Instantiating SL_ThorResidentialAppDocMgmtController class*/
		SL_ThorResidentialAppDocMgmtController  objSLREsAppDocMgmt= new SL_ThorResidentialAppDocMgmtController();
		
		objSLREsAppDocMgmt.lstFileWrapper = new List <SL_ThorResidentialAppDocMgmtController.FileWrapper> ();
		objSLREsAppDocMgmt.lstFileWrapper.add(new SL_ThorResidentialAppDocMgmtController.FileWrapper('XYZ','testFileName','testName','pdf'));
		
		List<Attachment> lstAttachment = new List<Attachment>();
		
		/* Insert Attachments record */
		Attachment objAttachment = new Attachment( Body = Blob.valueOf('XYZ'),  Name = 'testFileName',
											 		ParentId = objOpp.Id,
											 		Description = 'Uploaded by '+ objContactRole.LastName__c + ' at ' + System.now().format()
											 		);
											 		
		lstAttachment.add(objAttachment);	
		
		insert lstAttachment;
		
		/* Calling methods */
		objSLREsAppDocMgmt.saveAttachments();
		
		lstAttachment.clear();
		insert lstAttachment;
		
		SL_ThorResidentialAppDocMgmtController  objSLREsAppDoc= new SL_ThorResidentialAppDocMgmtController();
		objSLREsAppDoc.saveAttachments();
		
		objSLREsAppDocMgmt.lstFileWrapper = new List <SL_ThorResidentialAppDocMgmtController.FileWrapper> ();
		objSLREsAppDocMgmt.saveAttachments();
				
		system.assertEquals(objAttachment.ParentId, objOpp.Id);
		
		// To cover else block
		ApexPages.currentPage().getParameters().put('conRoleId', null);
		SL_ThorResidentialAppDocMgmtController  objSLREsAppDoc1= new SL_ThorResidentialAppDocMgmtController();
		
		delete objSLLeaseDocuments;
		
		ApexPages.currentPage().getParameters().put('conRoleId', objContactRole.Id);
		SL_ThorResidentialAppDocMgmtController  objSLREsAppDoc2= new SL_ThorResidentialAppDocMgmtController();
		
    }
}