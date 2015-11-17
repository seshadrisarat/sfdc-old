trigger sendEmailsTrigger_Before on Ibanking_Project__c (before insert, before update) {
    
    system.debug('=== BEFORE ===');
    system.debug('trigger.new.size()===' + trigger.new.size());
    
    for(integer i=0; i<trigger.new.size(); i++)
    {   
        // fetching the new & old deals
        Ibanking_Project__c oldDeal = (Trigger.isInsert)?null:((Ibanking_Project__c) Trigger.old[i]); 
        Ibanking_Project__c newDeal = (Ibanking_Project__c) Trigger.new[i];
        
        // fetching the new & old EmailTriggerParams fields
        final String oldEmailTriggerParams = (oldDeal==null)?'':oldDeal.EmailTriggerParams__c;
        final String newEmailTriggerParams = (newDeal==null)?'':newDeal.EmailTriggerParams__c;
        system.debug('======== oldEmailTriggerParams===' + oldEmailTriggerParams);
        system.debug('======== newEmailTriggerParams===' + newEmailTriggerParams);
        
        //newDeal.EmailTriggerParams__c = 'none';
        List<Id> userIdList = new List<Id>();
        
        if (newEmailTriggerParams != null && newEmailTriggerParams != '' && newEmailTriggerParams != 'none' && newEmailTriggerParams != oldEmailTriggerParams) {
            newDeal.EmailTriggerParamsFlag__c = newDeal.EmailTriggerParams__c;
        } else {
            newDeal.EmailTriggerParamsFlag__c = '';
        }
        newDeal.EmailTriggerParams__c = 'none';
    }
   
    system.debug('End of sendEmailTrigger_Before...');
}