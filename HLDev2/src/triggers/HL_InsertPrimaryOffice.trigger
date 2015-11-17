trigger HL_InsertPrimaryOffice on Opportunity__c (before insert) {

    User UserOffice = [SELECT Office__c FROM User WHERE id = :UserInfo.getUserId()];

    for(Opportunity__c Opp : Trigger.New){
        if(Opp.Primary_Office__c == NULL){
            Opp.Primary_Office__c = UserOffice.Office__c;
        }
    }

}