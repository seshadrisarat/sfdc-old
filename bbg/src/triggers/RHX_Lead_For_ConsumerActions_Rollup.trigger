trigger RHX_Lead_For_ConsumerActions_Rollup on Lead (after insert, after update, after delete, after undelete) {
    if (trigger.isAfter) {
        Type rollClass = System.Type.forName('rh2', 'ParentUtil');
        if(rollClass != null) {
            rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
            Database.update(pu.performTriggerRollups(trigger.oldMap, trigger.newMap,  'ConsumerActions__c', null), false);
        }         				
    }
}