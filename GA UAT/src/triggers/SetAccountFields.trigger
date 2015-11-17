trigger SetAccountFields on Account (before insert, before update) {
    for (Account a : Trigger.new) {
        a.Owner__c = a.OwnerId;
        if((trigger.isInsert && a.Tiered_Status__c !='') ||(trigger.isUpdate && a.Tiered_Status__c != trigger.oldmap.get(a.ID).Tiered_Status__c ) ){
           if(a.Tiered_Status__c == 'Tier 0 - Early Investigation'){
               a.Status__c = 'Early Investigation'; 
           }
           else if(a.Tiered_Status__c == 'Tier 1 - Monitor'){
               a.Status__c = 'Monitor';
           }
           else if(a.Tiered_Status__c == 'Tier 2 - Top Prospect'){
               a.Status__c = 'Top Prospect';
           }
           else if(a.Tiered_Status__c == 'Tier 3 - Primary Target'){
               a.Status__c = 'Primary Target';
           }
           else if(a.Tiered_Status__c == 'Tier 4 - Live Deal'){
               a.Status__c = 'Live Deal';
           }
           else if(a.Tiered_Status__c == 'Pass' || a.Tiered_Status__c == 'Divested'|| a.Tiered_Status__c == 'Portfolio' ){
               a.Status__c = a.Tiered_Status__c;
           } 
           /*else{
               a.Tiered_Status__c = 'Tier 0 - Early Investigation'; 
               a.Status__c = 'Early Investigation';               
           }*/    
        }
        
        if (a.Description == null) {
            continue;
        }

        String description = a.Description;
        if (description.length() > 255) {
            description = description.substring(0,252) + '...';
        }
        a.Short_Description__c = description;
    }
}