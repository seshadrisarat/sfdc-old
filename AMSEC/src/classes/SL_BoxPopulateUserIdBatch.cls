global class SL_BoxPopulateUserIdBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	String query;
	SL_BoxAPI handler = new SL_BoxAPI();
	global SL_BoxPopulateUserIdBatch() {
		
	}
	
	global Iterable<sObject> start(Database.BatchableContext BC) {
		List<User> allUsers = [SELECT ID, Box_User_ID__c,Email from User where id=:'0051300000BPj1s'];
		if(handler.checkAuthentication())
		{
			return allUsers;
		}
		return null;
	}

   	global void execute(Database.BatchableContext BC, List<User> scope) {
		Map<String,String> allBoxUsers = handler.getBoxUserIds();

		for(User us:scope)
		{
			if(allBoxUsers.get(us.Email)!=null)
			{
				us.Box_User_ID__c = allBoxUsers.get(us.Email);
			}
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}