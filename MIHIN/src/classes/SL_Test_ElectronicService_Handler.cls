/*
*Class: SL_Test_ElectronicService_Handler
*Description: This test class is used to test electronic service trigger functionality and its code coverage
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
private class SL_Test_ElectronicService_Handler {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Electronic_Service__c objElect = new Electronic_Service__c(Name = 'Test-001', Type__c = 'test' , Protocol__c = 'Test', Payload__c = 'Test', Address__c = 'Test', OwnerId = userInfo.getUserId());
		insert objElect;
		
		Profile validProf = [Select Name, Id From Profile where Name = 'HPD - Population Admin' LIMIT 1];
		
		User user1 = [Select ProfileId, Id, Profile.PermissionsTransferAnyEntity From User where ProfileId =: validProf.Id AND Id !=: objElect.OwnerId AND IsActive = true LIMIT 1];
		user1.Profile.PermissionsTransferAnyEntity = true;
		
		User user2 = [Select ProfileId, Id From User where Id !=: objElect.OwnerId AND IsActive = true LIMIT 1];
        
        objElect.OwnerId = user2.Id;
        
        
        try {
        	
        		update objElect;
        }
        
        catch (Exception e){
			
			system.debug('------- e -------' + e);
		
		}
    }
    
    static testMethod void test_ServiceDestinationUpdate() 
    {
        List<Electronic_Service_Mapping__c> lstCustomSettingsToInsert = new List<Electronic_Service_Mapping__c>{
	                                                                                                            new Electronic_Service_Mapping__c(Name='Immunizations' , API_Name__c='SD_Immunizations__c'),
	                                                                                                            new Electronic_Service_Mapping__c(Name='Quality Measures' , API_Name__c='SD_Quality_Measures__c')
	                                                                                                            };
        insert lstCustomSettingsToInsert;    
        
        Electronic_Service__c objElect = new Electronic_Service__c(Name = 'Test-001', Type__c = 'test' , Protocol__c = 'Test', Payload__c = 'Test', Address__c = 'Test', OwnerId = userInfo.getUserId() , SD_Immunizations__c= true);
		Test.startTest();
		    
		    insert objElect;
		    Electronic_Service__c objElectronicSvc = [Select Id ,Service_Destinations__c from Electronic_Service__c where Id =:objElect.Id LIMIT 1];
		    
		    system.assert(objElectronicSvc!= null);
		    system.assertEquals('Immunizations', objElectronicSvc.Service_Destinations__c);
		    
		    objElect.SD_Quality_Measures__c = true;
		    objElect.SD_Immunizations__c = false;
		    update objElect;
		    objElectronicSvc = [Select Id ,Service_Destinations__c from Electronic_Service__c where Id =:objElect.Id LIMIT 1];
		    
		    system.assert(objElectronicSvc!= null);
		    system.assertEquals('Quality Measures', objElectronicSvc.Service_Destinations__c);
		   
	    Test.stopTest();	                                                                                                        
    }
}