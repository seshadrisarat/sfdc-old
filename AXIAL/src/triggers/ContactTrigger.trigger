trigger ContactTrigger on Contact (before insert, before update, after update, after insert) {
    if(trigger.isBefore && trigger.isInsert){
        LeadAssignment.assignLeads(trigger.new, trigger.oldMap, true);
    }

    if(trigger.isBefore && trigger.isUpdate){
        LeadAssignment.assignLeads(trigger.new, trigger.oldMap, false);
        
        /* Start - Added By Pankaj Ganwani on 29/JUNE/2015 as per the requirement of AXIAL-2 */
        // Updating the Contact Owners  
        List<Contact> lstContactsToRotateOwner = LeadAssignment.rotateOwner(trigger.oldMap, new Map<Id, Contact>(trigger.new));
        /* End - Added By Pankaj Ganwani on 29/JUNE/2015 as per the requirement of AXIAL-2 */
    }
}