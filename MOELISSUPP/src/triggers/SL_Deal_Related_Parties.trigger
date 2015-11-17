/** 
 * \author Vishnu
 * \date 07/29/11
 * \see http://silverline.jira.com/browse/MC-7
 * \brief trigger on Deal_Related_Parties__c(Deal). 
 * \test 
 */
trigger SL_Deal_Related_Parties on Deal_Related_Parties__c (after insert) 
{
    SL_Moelis_DealRelatedParty_Hanlder dealPartyHandler = new SL_Moelis_DealRelatedParty_Hanlder(Trigger.isExecuting, Trigger.size);
    
    if(trigger.isAfter && trigger.isInsert)
        dealPartyHandler.OnAfterInsert(trigger.new);
}