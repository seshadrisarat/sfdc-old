public class UserUtil {
	public static User CurrentUser {
		get {
			if (currentUser == null) {
				currentUser = getCurrentUser();	
			}
			return currentUser;
		}
	}
	
	public static boolean isImportingLeads() {
		return CurrentUser.Importing_Leads__c;	
	}
	
	public static boolean isDisableBoatTrigger() {
		return CurrentUser.Disable_Boat_Trigger__c;
	}
	
	private static User getCurrentUser() {
		return [select Id, Importing_Leads__c, Disable_Boat_Trigger__c from User where Id=:UserInfo.getUserId()][0];
	}
}