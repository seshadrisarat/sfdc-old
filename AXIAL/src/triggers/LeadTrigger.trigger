trigger LeadTrigger on Lead (before insert, before update, after update, after insert) {
    if(trigger.isBefore && trigger.isInsert){
        Integer i = 1+1;
        LeadAssignment.assignLeads(trigger.new, trigger.oldMap, true);
        //EmailDispatcher.sendOutEmails(trigger.new, trigger.oldMap, true);
    }

    if(trigger.isBefore && trigger.isUpdate){
        LeadAssignment.assignLeads(trigger.new, trigger.oldMap, false);
        //EmailDispatcher.sendOutEmails(trigger.new, trigger.oldMap, false);
        
        // Updating the Lead Owners  
        List<Lead> lstLeadsToRotateOwner = LeadAssignment.rotateOwner(trigger.oldMap, new Map<Id, Lead>(trigger.new));
    }
    
    if(trigger.isBefore){
        List<Hoovers__c> hooversList = Hoovers__c.getAll().values();
        Map<String, String> hooversMap = new Map<String, String>();
        for(Hoovers__c h :hooversList)
            hooversMap.put(h.Hoovers_Mapping__c, h.Axial_Industry_Mapping__c);
        
        List<DataDotCom__c> ddcList = DataDotCom__c.getAll().values();
        Map<String, String> ddcMap = new Map<String, String>();
        for(DataDotCom__c d :ddcList)
            ddcMap.put(d.DDC_Industry__c, d.Axial_Industry_Mapping__c);
            
        
        for(Lead l :trigger.new){
            Boolean hoovers = false;
            if(l.Industry_Hoover_s__c != null){
                String hooversValue = hooversMap.get(l.Industry_Hoover_s__c);
                if(hooversValue != null){
                    l.Axial_Industry_Tier_1__c = hooversValue;
                    hoovers = true;
                }
            }
            
            if(!hoovers){
                if(l.Industry != null){
                    String ddcValue = ddcMap.get(l.Industry);
                    if(ddcValue != null){
                        l.Axial_Industry_Tier_1__c = ddcValue;
                    }
                }
                
            }
        }
    }
}