trigger ProspectMeetingUnflag on Event (after insert, after update, after delete)
{
    
    // Added after delete events for REQ-0000338
    
    MostRecentCommentsHandler objRecentCommentsHandler = new MostRecentCommentsHandler();
    
    if(trigger.isAfter && trigger.isInsert)
    {
        objRecentCommentsHandler.updateMostRecentForEvent(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        objRecentCommentsHandler.updateMostRecentForEvent(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isDelete)
    {
        objRecentCommentsHandler.updateMostRecentForEvent(trigger.old); 
    }
    
    
    List<Account> prospectAccounts = new List<Account>();
    if((trigger.isAfter && trigger.isUpdate) || (trigger.isAfter && trigger.isInsert))
    {
        for (Event e : Trigger.new) {
            if (e.Type == 'Prospect Meeting' && e.AccountId != null) {
                prospectAccounts.add(new Account(
                    Id = e.AccountId,
                    Add_to_call_list__c = false
                ));
            }
        }
    }
    
    if (!prospectAccounts.isEmpty()) {
        update prospectAccounts;
    }
}