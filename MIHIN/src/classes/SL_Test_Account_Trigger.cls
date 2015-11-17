/*
*Class: SL_Test_Account_Trigger
*Description: This test class is used to check the functionality for Account trigger and its code coverage
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@IsTest
public class SL_Test_Account_Trigger{
    
    @IsTest
        private static void TestAccountChange(){
        	
        	Profile validProf = [Select Name, Id From Profile where Name = 'HPD - Population Admin' LIMIT 1];
		
			User user1 = [Select ProfileId, Id From User where ProfileId =: validProf.Id LIMIT 1];
		
            Account a = new Account(Name = 'Testerson Inc.', ShippingCountry = 'TSA', ShippingStreet = 'test', ShippingState = 'TT', ShippingCity = 'Test City', ShippingPostalCode = '73S T3R');
            INSERT a;
            a.ShippingStreet = 'test1';
            UPDATE a;
            system.assertEquals(false, a.Geocoding_Required__c);
            a.ShippingStreet = '';
            UPDATE a;
            DELETE a;
            UNDELETE a;
            
            a.OwnerId = user1.Id;
            try {
        		update a;
	        }
	        
	        catch (Exception e){
				
				system.debug('------- e -------' + e);
			
			}
            
        }

}