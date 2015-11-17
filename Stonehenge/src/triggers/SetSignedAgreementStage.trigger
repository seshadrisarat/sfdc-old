trigger SetSignedAgreementStage on echosign_dev1__SIGN_AgreementEvent__c (after insert) {
    List<Id> agreementIds = new List<Id>();
    
    for( echosign_dev1__SIGN_AgreementEvent__c event : Trigger.new ) {
        if( ( event.echosign_dev1__Description__c == null ) ||
            ( !event.echosign_dev1__Description__c.contains('signed') ) ) {
            continue;
        }
        
        agreementIds.add( event.echosign_dev1__SIGN_Agreement__c );   
    }
    
    if( agreementIds.size() > 0 ) {
        EchoSignApiUtilities.setSignedStage(agreementIds);
    }
}