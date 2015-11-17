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
private class SL_test_AddLiteratureRequestController {

    static testMethod void myUnitTest() 
    {
        /* Insert Account */        
        Account objAccount = new Account(Name = 'TestAccount');
        insert objAccount;
        
        /* Insert Contact */
        Contact objContact = new Contact(LastName ='TestContact', AccountId = objAccount.Id);
        insert objContact;
        
        /* Insert Fund__c */
        Fund__c objFund = new Fund__c(Name = 'TestFund');
        insert objFund;
        
        /* Insert Literature_Item__c */ 
        Literature_Item__c objLitratureItem = new Literature_Item__c(Name = 'Test', Fund__c = objFund.Id, PPM__c = true, Type__c = 'testType1');
        insert  objLitratureItem;
        
        Literature_Item__c objLitratureItem1 = new Literature_Item__c(Name = 'TestLitItem', Fund__c = objFund.Id, PPM__c = true, Type__c = 'testType2');
        insert  objLitratureItem1;
        
        /* Insert Due_Diligence__c */
        Due_Diligence__c objDueDiligence = new Due_Diligence__c(Name = 'TestDueDiligence', Account__c = objAccount.Id, Fund__c = objFund.Id, 
                                                                Received_Approval__c = true, Offering__c = 'TestOfering'); 
        insert objDueDiligence;
        
        /* Insert Literature_Request__c */
        Literature_Requests__c objLiteratureRequest = new Literature_Requests__c(Contact__c = objContact.Id);
        insert objLiteratureRequest;
        
        /* Insert Literature_Requested_Item__c */
        Literature_Requested_Item__c objLitItemReq = new Literature_Requested_Item__c(Literature_Item__c = objLitratureItem.Id, Literature_Request__c = objLiteratureRequest.Id, 
                                                                                      Investor__c = '', Quantity__c = 5 );
        insert objLitItemReq;
        
        /* Insert Literature_Requested_Item__c */
        Literature_Requested_Item__c objLitItemReq1 = new Literature_Requested_Item__c(Literature_Item__c = objLitratureItem1.Id, Literature_Request__c = objLiteratureRequest.Id, 
                                                                                      Investor__c = 'TestInvestor', Quantity__c = 5 );
        insert objLitItemReq1;
        
        /* Setting Contact Id */
        //
        
        
        /* Instantiating Wrapper class */
        SL_AddLiteratureRequestController.LiteratureItemsWrapper objLitWrapper = 
            new SL_AddLiteratureRequestController.LiteratureItemsWrapper(objLitItemReq, true, true,
                                                        objLitratureItem.Type__c, objLitratureItem.Id, objLitratureItem.Name); 
        
        
        SL_AddLiteratureRequestController.LiteratureItemsWrapper objLitWrapper1 = 
            new SL_AddLiteratureRequestController.LiteratureItemsWrapper(objLitItemReq1, true, true, 
                                                        objLitratureItem1.Type__c, objLitratureItem1.Id, objLitratureItem1.Name);
        
        ApexPages.currentPage().getParameters().put('Id',objContact.id);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(objLiteratureRequest);
        SL_AddLiteratureRequestController objSLAddLiteratureRequestController1 = new SL_AddLiteratureRequestController(sc1);
        
        ApexPages.currentPage().getParameters().put('Id',objLiteratureRequest.id);
        
        /* Instantiating Controller class */
        ApexPages.StandardController sc = new ApexPages.StandardController(objLiteratureRequest);
        SL_AddLiteratureRequestController objSLAddLiteratureRequestController = new SL_AddLiteratureRequestController(sc);
        
        /* Calling methods */
        objSLAddLiteratureRequestController.addLiteratureRequestItems();
        
        objSLAddLiteratureRequestController.strSelectedAddress = 'other';
        objSLAddLiteratureRequestController.saveLitratureReqAndItems();
        
        objSLAddLiteratureRequestController.strSelectedAddress = 'primary';
        objSLAddLiteratureRequestController.saveLitratureReqAndItems();
        
        objSLAddLiteratureRequestController.strSelectedAddress = 'secondary';
        objSLAddLiteratureRequestController.saveLitratureReqAndItems();
        
        objSLAddLiteratureRequestController.strSelectedAddress = 'custom';
        objSLAddLiteratureRequestController.strCustomAddress = '';
        objSLAddLiteratureRequestController.saveLitratureReqAndItems();
        
        objSLAddLiteratureRequestController.strCustomAddress = 'Test';
        objSLAddLiteratureRequestController.strCustomCity = 'test';
        objSLAddLiteratureRequestController.strCustomState = 'CA';
        objSLAddLiteratureRequestController.strCustomZip = '12345';
        
        objSLAddLiteratureRequestController.saveLitratureReqAndItems();
        objSLAddLiteratureRequestController.strSelectedAddress = '';
        objSLAddLiteratureRequestController.saveLitratureReqAndItems();
        
        
        
        SL_AddLiteratureRequestController.LiteratureItemsWrapper objLitWrapper2 = 
            new SL_AddLiteratureRequestController.LiteratureItemsWrapper(objLitItemReq1, true, true, 
                                                        '', null, objLitratureItem1.Name);
        objSLAddLiteratureRequestController.lstLiteratureItemsWrapper.add(objLitWrapper2);
        
        objSLAddLiteratureRequestController.saveLitratureReqAndItems();
        
        System.debug('=====size========='+objSLAddLiteratureRequestController.lstLiteratureItemsWrapper.size());
        
        for(Integer i=0; i < objSLAddLiteratureRequestController.lstLiteratureItemsWrapper.size(); i++)
        {
            objSLAddLiteratureRequestController.lstLiteratureItemsWrapper[i].isDisplay = true;
            
            
        }
        
        System.debug('==========122=='+objSLAddLiteratureRequestController.lstLiteratureItemsWrapper);  
        
        objSLAddLiteratureRequestController.getLiteratureItemsDetails();
        objSLAddLiteratureRequestController.addLiteratureRequestItems();
        objSLAddLiteratureRequestController.updateItems();
        objSLAddLiteratureRequestController.removeLiteratureRequestItems();
        
        /* Setting Literature request Id */
        //ApexPages.currentPage().getParameters().put('Id',objLiteratureRequest.id);

        SL_AddLiteratureRequestController.getLiteratureItemTypeValues();
        
    }
}