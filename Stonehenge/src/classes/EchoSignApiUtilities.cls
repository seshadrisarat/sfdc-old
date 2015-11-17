public class EchoSignApiUtilities {

    @future( callout = true )
    public static void setSignedStage(List<String> agreementIds) {
        String apiKey = '2GU68FXI3PXS2U';
        apiEchosign.EchoSignDocumentService12HttpPort api = new apiEchosign.EchoSignDocumentService12HttpPort();
        
        List<echosign_dev1__SIGN_Agreement__c> agreements = [SELECT Id, Name, echosign_dev1__Opportunity__c, echosign_dev1__Document_Key__c 
            from echosign_dev1__SIGN_Agreement__c where Id IN :agreementIds];
        
        List<Opportunity> opps = new List<Opportunity>();
        
        for( echosign_dev1__SIGN_Agreement__c agreement : agreements ) {
            if( ( agreement.echosign_dev1__Opportunity__c == null ) ||
                ( agreement.Name.startsWith('Guarantor Form -') ) ) {
                continue;
            }
            
            String documentKey = agreement.echosign_dev1__Document_Key__c;
            if( documentKey == null ) {
                documentKey = calloutDocumentKey(api, agreement.Id, apiKey);
            }
            
            dto12ApiEchosign.DocumentInfo docInfo = api.getDocumentInfo(apiKey, documentKey);
        
            setOppStage(api, opps, agreement, docInfo);
        }
        
        update opps;
    }
    
    public static void setOppStage(apiEchosign.EchoSignDocumentService12HttpPort api,
        List<Opportunity> opps, 
        echosign_dev1__SIGN_Agreement__c agreement, 
        dto12ApiEchosign.DocumentInfo docInfo) {
            
        dto11ApiEchosign.ArrayOfParticipantInfo participantInfos = docInfo.participants;
            
        dto11ApiEchosign.ParticipantInfo[] participants = participantInfos.ParticipantInfo;
            
        //Boolean isSigned = true;
        //for( dto11ApiEchosign.ParticipantInfo participant : participants ) {
        //    if( ( participant.email.endsWith('stonehengenyc.com') ) ||
        //         ( participant.email.endsWith('stonehengenyc.com.uat') ) ) {
        //         continue;
        //    }
                
        //    if( participant.status == 'WAITING_FOR_MY_SIGNATURE' ) {
        //        isSigned = false;
        //    }
        //}

        //if( isSigned ){
           //Opportunity opp = new Opportunity(Id = agreement.echosign_dev1__Opportunity__c, 
           //     StageName = 'Awaiting Rent/Security Payment');
          //  opps.add(opp);
        //}
    }
        
    private static dtoApiEchosign.ExternalId getExternalId(String agreementId) {
        dtoApiEchosign.ExternalId externalId = new dtoApiEchosign.ExternalId();
        
        String namespace = 'SALESFORCE';
        String groupName = UserInfo.getOrganizationId();
        String id = agreementId.substring(0, 15);
        
        externalId.namespace = namespace;
        externalId.group_x = groupName;
        externalId.id = id;
        
        return externalId;
    }
    
    public static String calloutDocumentKey(apiEchosign.EchoSignDocumentService12HttpPort api, String agreementId, String apiKey) {
        //Search all doc info for the entire account associated with the api key for this document
        String email = null;
        String password = null;
        
        //Contruct the document external id: namespace (salesforce) + group (org id) + id (agreement object id)
        dtoApiEchosign.ExternalId externalId = getExternalId(agreementId);
        
        System.debug('Invoking EchoSign getDocumentInfosByExternalId web service callout with external id: ' + externalId);
        
        //Callout to the es web service to get the doc info
        dto12ApiEchosign.DocumentInfoList docInfoList = api.getDocumentInfosByExternalId(apiKey, email, password, externalId);
        
        System.debug('Received response from the EchoSign web service: ' + docInfoList);
        
        return parseDocumentKey(docInfoList, agreementId);
    }
    
    public static String parseDocumentKey(dto12ApiEchosign.DocumentInfoList docInfoList, String agreementId) {
         if( docInfoList == null ) {
            throw new EchoSignException('The DocumentInfoList returned by the EchoSign web service call getDocumentInfosByExternalId is null');
        }
        
        if( !docInfoList.success ) {
            throw new EchoSignException('The call to the EchoSign web service call to retrieve the agreement document key returned an error message \'' + docInfoList.errorMessage +
                '\' and error code \'' + docInfoList.errorCode + '\'');
        }
        
        dto12ApiEchosign.DocumentInfo[] documentInfos = docInfoList.documentInfos.DocumentInfo;
        if( documentInfos == null || documentInfos.size() == 0 ) {
            throw new EchoSignException('The specified agreement with the ID \'' + agreementId + '\' does not exist. Make sure that the agreement has been sent and signed.');
        }
        
        String documentKey = documentInfos.get(0).documentKey;
        
        System.debug('Retrieved document key: ' + documentKey);
        
        return documentKey;
    }
    
    public class EchoSignException extends Exception {}    
}