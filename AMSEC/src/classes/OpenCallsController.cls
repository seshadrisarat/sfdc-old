public with sharing class OpenCallsController {
	public List<Event> calls { get; private set; }
	
	public OpenCallsController() {}
	
	public void init() {
		Integer maxAge = 48;
		General_Settings__c genSettings = General_Settings__c.getInstance();
		
		if(genSettings != null && genSettings.Open_Activity_Alert_Age__c != null) {
			maxAge = Math.abs(Integer.valueOf(genSettings.Open_Activity_Alert_Age__c));
		}
		
		calls = [SELECT Id FROM Event WHERE OwnerId = :UserInfo.getUserId() AND Event_Type__c = 'Phone Call' AND Event_Status__c != 'Complete' AND StartDateTime >= :System.now().addHours(-1 * maxAge)];
	}
}