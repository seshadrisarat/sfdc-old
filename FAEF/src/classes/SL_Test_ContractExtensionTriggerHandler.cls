/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SL_Test_ContractExtensionTriggerHandler {

    static testMethod void myUnitTest() 
    {
        // TO DO: implement unit test
        
        // Start of preparing test data\
        
        Profile objProfile = [SELECT Name,Id FROM Profile Where Name= 'System Administrator'];
        
        User objUser1 = new User(Lastname = 'User-001', Email = 'user001@gmail.com', Username = 'us4343er001@gmail.com',ProfileId = objProfile.Id,  
        						 					 Alias = 'use44r31', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        insert objUser1;
        
        Letter_of_Intent__c objLOI = new Letter_of_Intent__c(Facility_Rating__c='1');
		insert objLOI;
		
		Schedule__c objSchedule = new Schedule__c(Name='Test-Schedule-01',Project_Manager__c=objUser1.Id,Count_for_A_A__c='Yes',Letter_of_Intent__c=objLOI.Id);
		insert objSchedule;
		
		Contract_Extension__c objCT1 = new Contract_Extension__c(Schedule__c = objSchedule.Id,Contract_Extension_Renew__c = 'monthly',Contract_Extension_Renewal_Amount__c = 15000,Contract_Extension_Amount__c=20.0, Contract_Extension_Start__c = Date.today(), Contract_Extension_Term_Months__c = 1);
		insert objCT1;
		
		Contract_Extension__c objCT2 = new Contract_Extension__c(Schedule__c = objSchedule.Id,Contract_Extension_Renew__c = 'monthly',Contract_Extension_Renewal_Amount__c = 22000,Contract_Extension_Amount__c=29.0, Contract_Extension_Start__c = Date.newInstance(2015, 3, 2));
		insert objCT2;
		
		list<Proceeds__c> lstProceeds = [ select Id,Schedule__c from Proceeds__c where Schedule__c =: objSchedule.Id];
		
		system.assert(lstProceeds.size() == 2);
		
		objCT2.Contract_Extension_Renewal_Amount__c = 34000;
		update objCT2;
		
		Schedule__c objUpdatedSchedule = [ Select Contract_Extension_Renewal_Rental_Amount__c,Contract_Extension_Renewal_Frequency__c
											from Schedule__c
											where Id=:objSchedule.Id ];
											
	   
	   //added by Pankaj Ganwani for checking the functionality of FAEF-62 
	   System.assertEquals([SELECT Proceed__r.Type__c FROM Contract_Extension__c WHERE Id=:objCT1.Id LIMIT 1].Proceed__r.Type__c, 'Contracted Extension');	
	   System.assertEquals([SELECT Proceed__r.Type__c FROM Contract_Extension__c WHERE Id=:objCT2.Id LIMIT 1].Proceed__r.Type__c, 'Contracted Extension');
	   System.assertEquals([SELECT Contract_Extension_End__c FROM Contract_Extension__c WHERE Id=:objCT2.Id LIMIT 1].Contract_Extension_End__c, Date.newInstance(2015, 3, 31));
	   //System.assertEquals([SELECT Contract_Extension_End__c FROM Contract_Extension__c WHERE Id=:objCT1.Id LIMIT 1].Contract_Extension_End__c, Date.newInstance(2015, 4, 30));									
    }
}