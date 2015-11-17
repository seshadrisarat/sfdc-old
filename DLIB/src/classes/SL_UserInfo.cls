public with sharing class SL_UserInfo {
	
	private static SL_UserInfo instance = null;
	private User user;
	private Set<String> officesIds = new Set<String>();
	
	
	public SL_UserInfo() {
		user = [
			SELECT Id, Selected_Offices_Ids__c, Name, SmallPhotoUrl FROM User WHERE Id=:UserInfo.getUserId()
		];
			
		if(!String.isEmpty(user.Selected_Offices_Ids__c)) {
			officesIds.addAll(user.Selected_Offices_Ids__c.split(';'));
		}	
	}
	
	public static SL_UserInfo getInstance() {
		
		if(instance == null) {
			instance = new SL_UserInfo();
		}		
		
		return instance;
	} 
	
	public Set<String> getOfficesIds() {
		return officesIds; 
	}
}