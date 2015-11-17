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
private class TestSetAgreementOppStage {

    static testMethod void testApiEchosign() {
       dto12ApiEchosign api12 = new dto12ApiEchosign();
       
       dto12ApiEchosign.DocumentInfoList documentInfoList = new dto12ApiEchosign.DocumentInfoList();
       documentInfoList.documentInfos = new dto12ApiEchosign.ArrayOfDocumentInfo();
       
       dto12ApiEchosign.DocumentInfo documentInfo = new dto12ApiEchosign.DocumentInfo();
      
       dto12ApiEchosign.ArrayOfDocumentInfo arrayOfDocumentInfo = new dto12ApiEchosign.ArrayOfDocumentInfo();
       
       dto11ApiEchosign api11 = new dto11ApiEchosign();
       
       dto11ApiEchosign.ArrayOfParticipantRole arrayOfParticipantRole = new dto11ApiEchosign.ArrayOfParticipantRole();
       dto11ApiEchosign.ArrayOfSecurityOption arrayOfSecurityOption = new dto11ApiEchosign.ArrayOfSecurityOption();
       dto11ApiEchosign.ArrayOfDocumentHistoryEvent arrayOfDocumentHistoryEvent = new dto11ApiEchosign.ArrayOfDocumentHistoryEvent();
       dto11ApiEchosign.DocumentHistoryEvent documentHistoryEvent = new dto11ApiEchosign.DocumentHistoryEvent();
      
       dto9ApiEchosign api9 = new dto9ApiEchosign();
       
       dto9ApiEchosign.ArrayOfNextParticipantInfo arrayOfNextParticipantInfo = new dto9ApiEchosign.ArrayOfNextParticipantInfo();
       dto9ApiEchosign.MergeFieldInfo mergeFieldInfo = new dto9ApiEchosign.MergeFieldInfo();
       dto9ApiEchosign.NextParticipantInfo nextParticipantInfo = new dto9ApiEchosign.NextParticipantInfo();
       dto9ApiEchosign.MergeField mergeField = new dto9ApiEchosign.MergeField();
       dto9ApiEchosign.ArrayOfMergeField arrayOfMergeField = new dto9ApiEchosign.ArrayOfMergeField();
       
       dtoApiEchosign api = new dtoApiEchosign();
       
       dtoApiEchosign.CallbackInfo callbackInfo = new dtoApiEchosign.CallbackInfo();
       dtoApiEchosign.ArrayOfFileInfo arrayOfFileInfo = new dtoApiEchosign.ArrayOfFileInfo();
       dtoApiEchosign.FileInfo fileInfo = new dtoApiEchosign.FileInfo();
       dtoApiEchosign.ExternalId externalId = new dtoApiEchosign.ExternalId();
       dtoApiEchosign.DocumentCreationInfo documentCreationInfo = new dtoApiEchosign.DocumentCreationInfo();
       dtoApiEchosign.SecurityOptions securityOptions = new dtoApiEchosign.SecurityOptions();
       dtoApiEchosign.DocumentKey documentKey = new dtoApiEchosign.DocumentKey();
       
       apiEchosign apiE = new apiEchosign();
       
       apiEchosign.getDocumentInfoResponse_element element = new apiEchosign.getDocumentInfoResponse_element();
       apiEchosign.ArrayOfString element1 = new apiEchosign.ArrayOfString();
       
       apiEchosign.EchoSignDocumentService12HttpPort apiPort = new apiEchosign.EchoSignDocumentService12HttpPort();
       apiEchosign.getDocumentInfosByExternalIdResponse_element innerElement1 = new apiEchosign.getDocumentInfosByExternalIdResponse_element();
       apiEchosign.getDocumentInfo_element innerElement2 = new apiEchosign.getDocumentInfo_element();
       apiEchosign.getDocumentInfosByExternalId_element innerElement3 = new apiEchosign.getDocumentInfosByExternalId_element();
       apiEchosign.getDocumentInfosByExternalId_element innerElement4 = new apiEchosign.getDocumentInfosByExternalId_element();

    }

    static testMethod void testOutForSignature() {
        Account account = new Account(Name='test');
        insert account;
        
        Opportunity opp = new Opportunity(Name='test', StageName='Closed / Won', CloseDate=Date.today(), AccountId = account.Id, Application_Approved__c = true);
        insert opp;
        
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c(Name='test', echosign_dev1__Opportunity__c=opp.Id);
        insert agreement;
        
        agreement.echosign_dev1__Status__c = 'Out for Signature';
        update agreement;
        
        opp = [SELECT StageName from Opportunity where Id = :opp.Id];
        //System.assertEquals('Awaiting Rent/Security Payment', opp.StageName);
    }
    
    static testMethod void testSigned() {
        Account account = new Account(Name='test');
        insert account;
        
        Opportunity opp = new Opportunity(Name='test', Application_Approved__c = true, StageName='Closed / Won', CloseDate=Date.today(), AccountId = account.Id);
        insert opp;
        
        Contact_Role__c role1 = new Contact_Role__c( Opportunity__c = opp.Id, Role__c = 'Guarantor', Contact__c = account.Id);
        insert role1;
        
        //Contact_Role__c role2 = new Contact_Role__c( Opportunity__c = opp.Id, Role__c = 'Guarantor', Contact__c = account.Id);
        //insert role2;
        
        echosign_dev1__SIGN_Agreement__c agreement1 = new echosign_dev1__SIGN_Agreement__c(Name='Guarantor Form - 1', echosign_dev1__Opportunity__c=opp.Id);
        insert agreement1;
        
        agreement1.echosign_dev1__Status__c = 'Signed';
        update agreement1;
        
        //echosign_dev1__SIGN_Agreement__c agreement2 = new echosign_dev1__SIGN_Agreement__c(Name='Guarantor Form - 1', echosign_dev1__Opportunity__c=opp.Id);
        //insert agreement2;
        
        //agreement2.echosign_dev1__Status__c = 'Signed';
        //update agreement2;
        
        opp = [SELECT StageName from Opportunity where Id = :opp.Id];
        //System.assertEquals('Awaiting Rent/Security Payment', opp.StageName);
    }
    
    static testMethod void testSetSignedStage() {
        apiEchosign.EchoSignDocumentService12HttpPort api = new apiEchosign.EchoSignDocumentService12HttpPort();
        
        Account account = new Account(Name='test');
        insert account;
        
        Opportunity opp = new Opportunity(Name='test', Application_Approved__c = true, StageName='Closed / Won', CloseDate=Date.today(), AccountId = account.Id);
        insert opp;
        
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c(Name='test', echosign_dev1__Opportunity__c=opp.Id);
        insert agreement;
        
        List<String> agreementIds = new List<String>();
        agreementIds.add( agreement.Id );
        
        EchoSignApiUtilities.setSignedStage(agreementIds);
        
        List<Opportunity> opps = new List<Opportunity>();
        opps.add(opp);
        
        dto12ApiEchosign.DocumentInfo docInfo = new dto12ApiEchosign.DocumentInfo();
        docInfo.participants = new dto11ApiEchosign.ArrayOfParticipantInfo();
        docInfo.participants.ParticipantInfo = new dto11ApiEchosign.ParticipantInfo[2];
        
        dto11ApiEchosign.ParticipantInfo info = new dto11ApiEchosign.ParticipantInfo();
        info.email = 'drudman@stonehengenyc.com';
        docInfo.participants.ParticipantInfo[0] = info;
        
        dto11ApiEchosign.ParticipantInfo info2 = new dto11ApiEchosign.ParticipantInfo();
        info2.email = 'drudman@stonehengenyc.com';
        info2.status = 'WAITING_FOR_MY_SIGNATURE';
        docInfo.participants.ParticipantInfo[1] = info2;
        
        EchoSignApiUtilities.setOppStage(api, opps, agreement, docInfo);
        
        dto12ApiEchosign.DocumentInfoList docInfoList = new dto12ApiEchosign.DocumentInfoList();
        docInfoList.success = true;
        
        docInfoList.documentInfos = new dto12ApiEchosign.ArrayOfDocumentInfo();
        docInfoList.documentInfos.DocumentInfo = new dto12ApiEchosign.DocumentInfo[1];
        
        dto12ApiEchosign.DocumentInfo documentInfo = new dto12ApiEchosign.DocumentInfo();
        documentInfo.documentKey = 'xxxxxx';
        docInfoList.documentInfos.DocumentInfo[0] = documentInfo;
        
        EchoSignApiUtilities.parseDocumentKey(docInfoList, agreement.Id);
    }
    
    static testMethod void testSetSignedStageGuarantor() {
        Account account = new Account(Name='test');
        insert account;
        
        Opportunity opp = new Opportunity(Name='test', Application_Approved__c = true, StageName='Closed / Won', CloseDate=Date.today(), AccountId = account.Id);
        insert opp;
        
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c(Name='Guarantor Form - test', echosign_dev1__Opportunity__c=opp.Id);
        insert agreement;
        
        List<String> agreementIds = new List<String>();
        agreementIds.add( agreement.Id );
        
        EchoSignApiUtilities.setSignedStage(agreementIds);
    }
    
    static testMethod void testSetSignedAgreementStage() {
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c(Name='Guarantor Form - test');
        insert agreement;
        
        echosign_dev1__SIGN_AgreementEvent__c event = new echosign_dev1__SIGN_AgreementEvent__c(echosign_dev1__SIGN_Agreement__c = agreement.Id,
            echosign_dev1__Description__c = 'signed');
        insert event;
    }
}