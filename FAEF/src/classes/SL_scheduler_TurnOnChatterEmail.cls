global with sharing class SL_scheduler_TurnOnChatterEmail implements Schedulable {

		private Set<Id> userId;

		global SL_scheduler_TurnOnChatterEmail(){ }

   	global void execute(SchedulableContext sc) 
   	{	
	    List<User> users = [SELECT Id, UserPreferencesDisableAllFeedsEmail 
	    										FROM User 
  												WHERE UserPreferencesDisableAllFeedsEmail = true 
  												AND Profile.UserLicense.Name='Partner Community'];
			for(User u : users){
				u.UserPreferencesDisableAllFeedsEmail = false;
			}
			update users;
   	}
}