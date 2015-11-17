public with sharing class SL_TestSetupUtils {
	
	private static Integer userCounter = 74019;
	
	static public void createConfigurationSettings(){
		Region__c objRegion = new Region__c(Name = 'testRegion');
        insert objRegion;
    	
    	Page__c objPage = new Page__c(Name = 'testPage9');
		insert objPage;
    	
    	PageRegion__c objPageRegion = new PageRegion__c(Page__c = objPage.id ,Region__c = objRegion.id, Page__r = objPage ,Region__r = objRegion);
    	insert objPageRegion;
    	
    	Widget__c objWidget = new Widget__c(Name = 'testMG',Type__c = 'SL_IntranetUserInfo');
    	insert objWidget;
    	
    	PageRegionWidget__c objPageRegionWidget = new PageRegionWidget__c(Page_Region__c = objPageRegion.id, Widget__c = objWidget.id,
    																		Page_Region__r = objPageRegion, Widget__r = objWidget);
    	insert objPageRegionWidget;
	}
	
	/**
	* Creates user and fills mandatory fields 
	**/
	static public User createUserPrototype() {
		userCounter++; 
		Id profileId = [SELECT Name,Id FROM Profile WHERE Id = : Userinfo.getProfileId()].Id;
		User u = new User(
			LastName = 'TestUser' + String.valueOf(userCounter), 
			Email = 'TestUser' + String.valueOf(userCounter) + '@gmail.com',
			Username = 'TestUser' + String.valueOf(userCounter) + '@gmail.com',
			Alias = 'tu' + String.valueOf(userCounter),
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'ISO-8859-1', 
			LanguageLocaleKey = 'en_US',
			ProfileId = profileId
		);
		return u;
	}
}