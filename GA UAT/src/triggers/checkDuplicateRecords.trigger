trigger checkDuplicateRecords on Relationship_Strength__c (before insert) {
Map<id,id> contactAnduserId = new Map<id,id>();
Map<id,id> existingcontAndUserId = new Map<id,id>();
    for(Relationship_Strength__c str : trigger.new)
    {
        contactAnduserId.put(str.Contact__c, str.User__c);
    }
    for(Relationship_Strength__c str : [select id,Contact__c,User__c  from Relationship_Strength__c where Contact__c in :contactAnduserId.keyset() and User__c in : contactAnduserId.values()])
    {
        existingcontAndUserId.put(str.Contact__c, str.User__c);
    }
     for(Relationship_Strength__c str : trigger.new)
    {
        if(existingcontAndUserId.containsKey(str.Contact__c) && (existingcontAndUserId.get(str.Contact__c)== str.user__c))
        {
            str.addError('Same User already have relationship with this contact.');
        }
    }
}