trigger SetAgreementOppStage on echosign_dev1__SIGN_Agreement__c (after update) {
    Map<Id,echosign_dev1__SIGN_Agreement__c> oppStage = new Map<Id,echosign_dev1__SIGN_Agreement__c>();
    
    for( echosign_dev1__SIGN_Agreement__c agreement : Trigger.new ) {
        if( ( agreement.echosign_dev1__Opportunity__c == null ) ||
            ( Trigger.oldMap.get(agreement.Id).echosign_dev1__Status__c == agreement.echosign_dev1__Status__c ) ) {
            continue;
        }
        
        oppStage.put( agreement.echosign_dev1__Opportunity__c, agreement );

    }
    
    if( oppStage.keySet().size() == 0 ) {
        return;
    }
    
    List<Opportunity> opps = [SELECT Id, StageName from Opportunity where Id IN :oppStage.keySet()];
    
    List<Contact_Role__c> roles = [SELECT Id, Opportunity__c, Role__c from Contact_Role__c where Opportunity__c IN :oppStage.keySet()];
    
    Map<Id,Integer> rolesGuarantorMap = new Map<Id,Integer>();
    
    for( Contact_Role__c role : roles ) {
        if( role.Role__c != 'Guarantor' ) {
            continue;
        }
        
        Integer guarantorCount = rolesGuarantorMap.get( role.Opportunity__c );
        if( guarantorCount == null ) {
            rolesGuarantorMap.put( role.Opportunity__c, 1 );
        } else {
            rolesGuarantorMap.put( role.Opportunity__c, guarantorCount + 1 );
        }
    }
    
    List<echosign_dev1__SIGN_Agreement__c> agreements = [SELECT Id, echosign_dev1__Opportunity__c 
        from echosign_dev1__SIGN_Agreement__c where echosign_dev1__Opportunity__c IN :oppStage.keySet() 
        AND Name LIKE 'Guarantor Form%' AND echosign_dev1__Status__c = 'Signed'];
    
    Map<Id,Integer> agreementsCountMap = new Map<Id,Integer>();
    
    for( echosign_dev1__SIGN_Agreement__c agreement : agreements ) {
        Integer agreementCount = agreementsCountMap.get( agreement.echosign_dev1__Opportunity__c );
        if( agreementCount == null ) {
            agreementsCountMap.put( agreement.echosign_dev1__Opportunity__c, 1 );
        } else {
            agreementsCountMap.put( agreement.echosign_dev1__Opportunity__c, agreementCount + 1 );
        }
    }
    
    for( Opportunity opp : opps ) {
        echosign_dev1__SIGN_Agreement__c agreement = oppStage.get( opp.Id );
        if( ( agreement.echosign_dev1__Status__c == 'Out for Signature' ) &&
            ( !agreement.Name.startsWith('Guarantor Form -') ) ) {
            opp.StageName = 'Lease out for Signature';
        }
        
        if( agreementsCountMap.get( opp.Id ) == rolesGuarantorMap.get( opp.Id ) ) {
            opp.StageName = 'Awaiting Rent/Security Payment';
        }
    }
    
    update opps;
}