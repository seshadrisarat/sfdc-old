/**
* \arg ClassName        : SL_Scheduler_UpdateUserRoleOfContacts
* \arg JIRATicket     	: YNHH-162
* \arg CreatedOn      	: 25/AUG/2015
* \arg LastModifiedOn	: 
* \arg CreatededBy    	: Harsh 
* \arg ModifiedBy     	: 
* \arg Description      : Scheduler class to call the batch class named as 'SL_BatchToUpdateUserRoleForContacts'
*/
global class SL_Scheduler_UpdateUserRoleOfContacts implements Schedulable {
	/*
        @MethodName: execute 
        @param : SchedulableContext sc
        @Description: It is overriden method of Schedulable interface.
    */
	global void execute(SchedulableContext sc) {
		SL_BatchToUpdateUserRoleForContacts objBatch = new SL_BatchToUpdateUserRoleForContacts();
		database.executebatch(objBatch);
	}
}