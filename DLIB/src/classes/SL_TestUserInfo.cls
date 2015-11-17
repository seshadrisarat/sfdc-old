@isTest
private with sharing class SL_TestUserInfo {
	static testMethod void testOfficesData() {
		Office_Locations__c officeA = new Office_Locations__c(Name = 'Test Office A');
    	insert officeA;    	
    	Office_Locations__c officeB = new Office_Locations__c(Name = 'Test Office B');
    	insert officeB;
		
		
		Set<String> s = new Set<String>{officeA.Id, officeB.Id};
		
		User u = SL_TestSetupUtils.createUserPrototype();
		// due to trigger validation we neee to set offices names
		u.User_Offices__c = officeA.Name + '\n' + officeB.Name;
		u.Selected_Offices_Ids__c = String.valueOf(officeA.Id) + ';' + String.valueOf(officeB.Id);
		
		insert u;
		
		System.runAs(u) {
			system.assertEquals(s, SL_UserInfo.getInstance().getOfficesIds());			
		}
	
	}
}