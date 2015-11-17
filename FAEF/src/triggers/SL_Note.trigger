/*Trigger on insert of Note
* Trigger Name  : SL_Note 
* JIRA Ticket   : FAEF-1
* Created on    : 02/07/2013
* Created by   : Sandeep
* Description   : Implement a trigger on insert of Notes which updates related parent fields.
*/
trigger SL_Note on Note (after insert, after update, after delete) {
	
	//Handler class for calling functions based on event
	SL_Note_Handler objNoteHandler = new SL_Note_Handler();
	
	if(trigger.isAfter && trigger.isInsert)
	{
		// calling functions of handler class on after insert of Note
		objNoteHandler.onAfterInsert(Trigger.newMap); 
	} 
	
	if(trigger.isAfter && trigger.isUpdate)
	{
		// calling functions of handler class on after insert of Note
		objNoteHandler.onAfterUpdate(Trigger.newMap);  
	} 
	
	if(trigger.isAfter && trigger.isDelete)
	{
		// calling functions of handler class on after insert of Note
		objNoteHandler.onAfterDelete(Trigger.oldMap);  
	} 
}