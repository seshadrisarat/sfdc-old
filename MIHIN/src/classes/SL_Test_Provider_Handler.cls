/*
*Class: SL_Test_Provider_Handler
*Description: This class is used to test functionality of Provider trigger and its code coverage
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
private class SL_Test_Provider_Handler {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Account objAccount = new Account(Name = 'TestAcc');
		insert objAccount;
		
		Contact objContact = new Contact(LastName = 'test', AccountId = objAccount.Id);
		insert objContact;
		
		Profile validProf = [Select Name, Id From Profile where Name = 'HPD - Population Admin' LIMIT 1];
		
		User user1 = [Select ProfileId, Id From User where ProfileId =: validProf.Id AND IsActive = true LIMIT 1];
        
        objContact.OwnerId = user1.Id;
        
        try {
        		update objContact;
        	
        }
        
        catch (Exception e){
			
			system.debug('------- e -------' + e);
			//System.assert(e.getMessage().contains('You can only transfer Records you have Read/Write access to'));
		
		}
		
    }
}