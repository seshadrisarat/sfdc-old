trigger TaskAdallomTrigger on Task (after delete, after insert, after update) { 
    try{
        AdallomAudit__c audit = new AdallomAudit__c();
        audit.UserId__c = UserInfo.getUserId();
        audit.Timestamp__c = System.now(); 
        audit.ObjectName__c = 'Task';
        if (Trigger.isDelete) {
            if (Trigger.old.size() == 1) {
                String serializedValue = System.JSON.serialize(Trigger.old[0]); 
                if (serializedValue.length() <= 32768) { 
                   audit.OldObjectJSON__c = serializedValue; 
                }
                audit.ActionType__c = 'DELETE';
                audit.ObjectId__c = Trigger.old[0].Id;
                audit.ObjectTitle__c = Trigger.old[0].Subject;
            } else {
               audit.ActionType__c = 'MASS_DELETE';
               audit.ObjectIds__c = System.JSON.serialize(Trigger.oldMap.keySet());
            }
        } else {
            if (Trigger.isInsert) {
                if (Trigger.new.size() == 1) {
                    String serializedValue = System.JSON.serialize(Trigger.new[0]); 
                    if (serializedValue.length() <= 32768) { 
                        audit.NewObjectJSON__c = serializedValue; 
                    }
                    audit.ActionType__c = 'INSERT';
                    audit.ObjectId__c = Trigger.new[0].Id;
                    audit.ObjectTitle__c = Trigger.new[0].Subject;
                } else {
                    audit.ActionType__c = 'MASS_INSERT';
                    audit.ObjectIds__c = System.JSON.serialize(Trigger.newMap.keySet());
                }
            } else {
                if (Trigger.new.size() == 1) {
                    String serializedValue = System.JSON.serialize(Trigger.old[0]); 
                    if (serializedValue.length() <= 32768) { 
                       audit.OldObjectJSON__c = serializedValue; 
                    }
                    serializedValue = System.JSON.serialize(Trigger.new[0]); 
                    if (serializedValue.length() <= 32768) { 
                        audit.NewObjectJSON__c = serializedValue; 
                    }
                    audit.ActionType__c = 'UPDATE';
                    audit.ObjectId__c = Trigger.new[0].Id;
                    audit.ObjectTitle__c = Trigger.new[0].Subject;
                } else {
                    audit.ActionType__c = 'MASS_UPDATE';
                    audit.ObjectIds__c = System.JSON.serialize(Trigger.newMap.keySet());
                } 
            } 
        } 
        insert audit; 
    } catch (Exception e) {} 
}