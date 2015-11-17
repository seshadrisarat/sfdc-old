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
private class SL_Test_BatchUpdateTimeCardOwner {

    static testMethod void test_updateTimeCardOwner() {
    
	    Profile objProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
	    List<User> lstUser = new List<User>{new User(Alias = 'User1', Email='user1@user.com', EmailEncodingKey='UTF-8', LastName='Testing', 
		    								 		LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = objProfile.Id, 
		    								 		TimeZoneSidKey='America/Los_Angeles', UserName='user211.79874@user.com'),
		    								new User(Alias = 'User2', Email='user3424@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', 
	    								 			LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = objProfile.Id, 
		    								 		TimeZoneSidKey='America/Los_Angeles', UserName='user5461.79874@user.com'),
									 		new User(Alias = 'User3', Email='user34256@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', 
	    								 			LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = objProfile.Id, 
		    								 		TimeZoneSidKey='America/Los_Angeles', UserName='user5489.79874@user.com')};	
		    								 
		 insert lstUser;
		 
	  	Account objAccount = new Account(Name = 'Test Account-01'); 
	  	insert objAccount;
	      
	 	List<Business_Unit__c> lstBusinessUnit = new List<Business_Unit__c>{new Business_Unit__c(Name = 'Test BU-01'),
	        																new Business_Unit__c(Name = 'Test BU-02'),
	        																new Business_Unit__c(Name = 'Test BU-03'),
	    																	new Business_Unit__c(Name = 'Test BU-04')};
	    insert lstBusinessUnit;
	      
	  	List<Opportunity> lstOpportunity = new List<Opportunity>{new Opportunity(Name = 'TestOpp-01', StageName = 'Active Mandate', AccountId = objAccount.Id, 
	                            													CloseDate = date.today(), Business_Group__c = lstBusinessUnit[0].Id),
	            												new Opportunity(Name = 'TestOpp-02', StageName = 'Prospective Mandate', AccountId = objAccount.Id, 
	                            												CloseDate = date.today(), Business_Group__c = lstBusinessUnit[1].Id)};
	  	insert lstOpportunity;
	 	List<Time_Card__c> lstTimeCrads = new  List<Time_Card__c> {new Time_Card__c(Project__c = lstOpportunity[0].Id,Resource__c=lstUser[0].Id, Start_Date__c = date.today(),End_Date__c= date.today(),OwnerId =lstUser[0].Id),
	    														    new Time_Card__c(Project__c = lstOpportunity[1].Id,Resource__c=lstUser[1].Id, Start_Date__c = date.today(),End_Date__c= date.today(),OwnerId =lstUser[1].Id)};
	    																 
	 	insert lstTimeCrads;
		 	
	 	Staffer__c objStaffer = new Staffer__c(UserId__c = lstUser[2].Id);
	 	insert objStaffer;
	 	
	 	Test.startTest();
	 	SL_Batch_UpdateTimeCardOwner obj = new SL_Batch_UpdateTimeCardOwner();
	 	Database.executeBatch(obj);	 
	 	Test.stopTest();
		// Checking that Owner of time card is updated to custom setting user
		system.assertEquals([Select Id,OwnerId FROM Time_Card__c WHERE Id =:lstTimeCrads[0].Id].OwnerId, objStaffer.UserId__c);	
		system.assertEquals([Select Id,OwnerId FROM Time_Card__c WHERE Id =:lstTimeCrads[1].Id].OwnerId, objStaffer.UserId__c);
		// checking that Locked_for_Time_Entry__c field is updated to true
		system.assertEquals([Select Id,OwnerId,Locked_for_Time_Entry__c  FROM Time_Card__c WHERE Id =:lstTimeCrads[0].Id].Locked_for_Time_Entry__c , true);	
		system.assertEquals([Select Id,OwnerId,Locked_for_Time_Entry__c  FROM Time_Card__c WHERE Id =:lstTimeCrads[1].Id].Locked_for_Time_Entry__c , true);		
    }
}