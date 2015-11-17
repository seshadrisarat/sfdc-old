trigger RHX_ConsumerActions on ConsumerActions__c (after insert, after update, after delete, after undelete) {
   if (trigger.isAfter) {
    
        Type rollClass = System.Type.forName('rh2', 'ParentUtil');
        if(rollClass != null) {
            rh2.PS_Rollup_Engine pu = (rh2.PS_Rollup_Engine) rollClass.newInstance();
            Database.update(pu.performTriggerRollups(trigger.oldMap, trigger.newMap, null), false);
         }
    }
}