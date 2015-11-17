/*
*Class: SL_Test_Case_handler
*Description: This test class is used to check the functionality of Case trigger and its code coverage
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
private class SL_Test_Case_handler {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
    	
		Case objCase = new Case(Status = 'New', Origin = 'Email', Type = 'HPD');
		insert objCase;
		
		Profile validProf = [Select Name, Id From Profile where Name = 'HPD - Population Admin' LIMIT 1];
		
		User user1 = [Select ProfileId, Profile.PermissionsTransferAnyEntity, Id From User where ProfileId =: validProf.Id AND IsActive = true LIMIT 1];
        
        user1.Profile.PermissionsTransferAnyEntity = true;
        update user1;
        
        
        CaseShare objcaseShare = new CaseShare(UserOrGroupId = user1.Id, CaseId = objCase.Id, CaseAccessLevel = 'Read');
        insert objcaseShare;
        
        try {
	        	objCase.OwnerId = user1.Id;
	            update objCase;
        
        }
        catch (Exception e){
			
			system.debug('------- e -------' + e);
		
		}
        
    }
}