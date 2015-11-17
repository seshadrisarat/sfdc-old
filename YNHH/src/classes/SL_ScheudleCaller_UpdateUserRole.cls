/**
* \arg ClassName        : SL_ScheudleCaller_UpdateUserRole
* \arg JIRATicket     	: YNHH-162
* \arg CreatedOn      	: 25/AUG/2015
* \arg LastModifiedOn	: 
* \arg CreatededBy    	: Harsh 
* \arg ModifiedBy     	: 
* \arg Description      : class for schedule the batch for updating the UserRole on the Contact.Portal_User.
*/
public with sharing class SL_ScheudleCaller_UpdateUserRole {
	/* Start - Constructor and This class calls Schedular */
	public SL_ScheudleCaller_UpdateUserRole() {
		SL_Scheduler_UpdateUserRoleOfContacts objScheduler = new SL_Scheduler_UpdateUserRoleOfContacts();
       	String scheduleBatch = '0 0 0 * * ?';
       	if(!Test.isRunningTest()) 
       		System.schedule('Update Contact Acceptance DateTime.', scheduleBatch, objScheduler);
       	else
       		System.schedule('Update Contact Acceptance DateTime for Testing', scheduleBatch, objScheduler);
	}
	/* End - Constructor */
}