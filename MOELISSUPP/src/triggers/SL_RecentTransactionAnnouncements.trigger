/*Trigger on Ibanking_Project__c
* Trigger Name 	: SL_RecentTransactionAnnouncements
* JIRA Ticket   : Moelis-115
* Created on    : 18/11/2013
* Created by    : Rahul Majumdar
* Jira ticket   :  http://silverline.jira.com/browse/Moelis-115
* Description   : When a Recent_Transaction_Announcements__c record is inserted/updated, sync field values on Recent Transaction Announcement records with the related Deal
*/
trigger SL_RecentTransactionAnnouncements on Recent_Transaction_Announcements__c (after insert, after update, after delete, before insert, before update) 
{
		// initialize the handler class Sl_Deal_Handler
	SL_RecentTransactionAnnouncementHandler handler = new SL_RecentTransactionAnnouncementHandler(Trigger.isExecuting, Trigger.size);
	
	// called on After Insert of Deal record. 
	if(Trigger.isInsert && Trigger.isBefore) 
	{
		handler.onBeforeInsert(Trigger.new);
	}
	// called on After Update of Deal record. 
	if(Trigger.isUpdate && Trigger.isBefore)
	{
		handler.onBeforeUpdate( Trigger.new,Trigger.oldMap);
	}
	
	if(Trigger.isDelete && Trigger.isAfter)
	{
		handler.onAfterDelete(Trigger.OldMap);
	}	
	
	// fires on After Insert of ContentVersion record
    if(Trigger.isInsert && Trigger.isAfter)
    {
        handler.onAfterInsert(Trigger.newMap); 
    }  
    
    // fires on After Update of ContentVersion record
	if(Trigger.isUpdate && Trigger.isAfter)
	{
		handler.onAfterUpdate(Trigger.newMap);
	}	
	
}