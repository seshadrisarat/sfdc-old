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
private class SL_Test_ManageNRIVFFilesController 
{
	static Apexpages.Standardcontroller objStandardController;
    static Contact objContact;
    static Account objAccount;
    static Opportunity objOpp;
    static Matter__c objMatter;
    static Client__c objClient;
    static Attachment objAttachment;
    static SL_ManageNRIVFFilesController objSLManageNRIVFFilesController; 
    static SL_ManageNRIVFFilesController.AttachmentsWrapper objAttachWrapper;
    static List<Attachment> lstAttachment;  
	
	static void createData()
	{
    	/* Inserting Account */
    	objAccount = new Account(Name = 'Test Account', Status__c = 'Client');
    	insert objAccount;
    	
    	/* Inserting Contact */
    	objContact = new Contact(LastName = 'Test Contact');
    	insert objContact;
    	
    	/* Inserting Opportunity */
        objOpp = new Opportunity(Name = 'Test Job', Probability = 50, StageName = 'Prospect', CloseDate = System.today());
        insert objOpp;
        
        /* Inserting Client */
        objClient = new Client__c(Name = 'TestClientName', Account__c = objAccount.Id, Client_Number__c = '12312', StartDate__c = System.today()); 
        insert objClient;
        
        /* Inserting Matter */
        objMatter = new Matter__c(Name = 'TestMatterName', Client__c = objClient.Id, Matter_Number__c = '563', Matter_Start_Date__c = System.today()); 
        insert objMatter; 
        
        /* Inserting Attachments */
        objAttachment = new Attachment(Name = 'TestAttachment11.nrl', Body = Blob.valueOf('EastDMSuuuu:!document:555,1:'), ParentId = objAccount.Id);
        insert objAttachment ;
        
        lstAttachment = new List<Attachment >();
        for(Integer i=1; i<=5; i++ )
        {
        	Attachment objAttach = new Attachment(Name = 'TestAttachmentName' + i + '.nrl', Body = Blob.valueOf('WestDMS:!document:552,1:'), ParentId = objAccount.Id);
        	lstAttachment.add(objAttach);
        }
        
        insert lstAttachment; 
        
        DocumentLocation__c objDocumentLocation = new DocumentLocation__c(Name = 'Test');
        insert objDocumentLocation;
        
        /* Passing recoord Id of Account */ 
        objStandardController = new ApexPages.standardController(objAccount);
        SL_ManageAccountsNRIFilesController objSLManageAccountsNRIFilesController = new SL_ManageAccountsNRIFilesController(objStandardController);
        
        /* Passing recoord Id of Contact */
        objStandardController = new Apexpages.Standardcontroller(objContact);
      	SL_ManageContactsNRIFilesController objSLManageContactsNRIFilesController = new SL_ManageContactsNRIFilesController(objStandardController);
      	
      	/* Passing recoord Id of Opportunity */
      	objStandardController = new Apexpages.Standardcontroller(objOpp);
      	SL_ManageOppNRIFilesController objSLManageOppNRIFilesController = new SL_ManageOppNRIFilesController(objStandardController);
      	
      	/* Passing recoord Id of Client object*/
      	objStandardController = new Apexpages.Standardcontroller(objClient);
       	SL_ManageClientNRIFilesController objSLManageClientNRIFilesController = new SL_ManageClientNRIFilesController(objStandardController); 
        
        /* Passing recoord Id of Matter object */
        objStandardController = new Apexpages.Standardcontroller(objMatter);
        SL_ManageMatterNRIFilesController objSLManageMatterNRIFilesController = new SL_ManageMatterNRIFilesController(objStandardController);
        
        /* Iterating over the list of attachements and adding it to wrapper */
        for(Attachment objAtt : lstAttachment )
        {
        	objAttachWrapper = new SL_ManageNRIVFFilesController.AttachmentsWrapper(objAtt, null, false, true, false, '123', false, null);
        }
        
        objAttachWrapper = new SL_ManageNRIVFFilesController.AttachmentsWrapper(objAttachment, null, false, true, false, '124', false, null);
        
    }
    static testMethod void ChecNRIFIlesForAddCancel()
    {
    	/* Calling create data method */
    	createData();
    	
    	objSLManageNRIVFFilesController = new SL_ManageNRIVFFilesController();
        objSLManageNRIVFFilesController.sObjectRecordId = objAccount.Id;
        objSLManageNRIVFFilesController.fetchNRIDocAttachments();
        
        System.assertEquals(objSLManageNRIVFFilesController.lstAttachmentsWrapper.size(), lstAttachment.size()+1);
        
        objSLManageNRIVFFilesController.getDocumentType();
        objSLManageNRIVFFilesController.getDocumentLocation();
        
        objSLManageNRIVFFilesController.isHeadCheck = true;
        objSLManageNRIVFFilesController.checkAllRecords();
        
        objSLManageNRIVFFilesController.isHeadCheck = false;
        objSLManageNRIVFFilesController.checkAllRecords();
       
        objSLManageNRIVFFilesController.isHeadCheck = true;
        objSLManageNRIVFFilesController.unSelectCheckRecords();
        
        objSLManageNRIVFFilesController.strSaveAllOrOne = 'All';
        objSLManageNRIVFFilesController.saveAllRecords();
        
        for(SL_ManageNRIVFFilesController.AttachmentsWrapper  objAttachmentsWrapper : objSLManageNRIVFFilesController.lstAttachmentsWrapper)
        {
        	objAttachmentsWrapper.isSave= true;
        }
        
        objSLManageNRIVFFilesController.lstAttachmentsWrapper[0].objAttachment.Name = '';
        /* Calling savesDocuments method */  
        objSLManageNRIVFFilesController.savesDocuments();
        
         objSLManageNRIVFFilesController.lstAttachmentsWrapper[0].strRefNumber = ''; 
        /* Calling savesDocuments method */  
        objSLManageNRIVFFilesController.savesDocuments();
        
        objSLManageNRIVFFilesController.lstAttachmentsWrapper[0].objAttachment.Name = 'Test Attachment';
        objSLManageNRIVFFilesController.lstAttachmentsWrapper[0].strRefNumber = '1532';
        
        objSLManageNRIVFFilesController.savesDocuments();
        
        /* Calling addNewNRIDocument method */
        objSLManageNRIVFFilesController.addNewNRIDocument();
        
		System.assertEquals(objSLManageNRIVFFilesController.lstAttachmentsWrapper.size(), lstAttachment.size()+2);
		
		objSLManageNRIVFFilesController.lstAttachmentsWrapper[0].isCancel = true;  
        /* Calling canceDocuments method */
        objSLManageNRIVFFilesController.canceDocuments();
        
        /* Calling saveAllRecords method */
        objSLManageNRIVFFilesController.saveAllRecords();
        
        objSLManageNRIVFFilesController.strRemoveSelectedOrOne = 'One';
        objSLManageNRIVFFilesController.selectActionId = objAttachment.Id;
        objSLManageNRIVFFilesController.isRemoveSelected = true;
        
        /* Calling deleteNRIDocument method */
        objSLManageNRIVFFilesController.deleteNRIDocument();
    }
}