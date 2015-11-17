/**
 * \author Vika Osmak 
 * \date 06/15/11
 * \see http://silverline.jira.com/browse/MC-1, http://silverline.jira.com/browse/Moelis-115, http://silverline.jira.com/browse/Moelissupp-31
 * \brief Test Class for trigger SL_Deal  on Ibanking_Project__c  
 modified on    : 18/11/2013
* modified by    : Sruti Srivastava
 Last modifed on: 20/8/2014
 
 */
@isTest(SeeAllData=false)
private class SL_Test_Deal_Trigger_Handler 
{
	private final static String strProfileId = [Select Id From Profile Where name = 'System Administrator' limit 1].Id;
	private static Contact objContact;
	private static Account objAcc;
	private static Account objAcc2;
	private static User objUser;
	private static Employee_Profile__c empl;
	private static Employee_Profile__c emp2;
	private static List<Ibanking_Project__c> lstDeals;
	private static List<Project_Resource__c> lstprojects; 
	
    static testMethod void SL_Test_Deal_Trigger_Handler_coverage() 
    {
    	objUser = new User(alias = 'user', email='test@user.com', title='test',
        emailencodingkey='UTF-8', lastName='testUser', languagelocalekey='en_US', localesidkey='en_US', profileid = strProfileId, timezonesidkey='America/Los_Angeles', userName='UserAug01@test.com');
        insert objUser;
        system.runAs(objUser)
        {
	        Account acc = new Account();
	        acc.Name = 'Test';
	        insert acc;
	        Ibanking_Project__c ip = new Ibanking_Project__c(Client__c = acc.Id);
	        insert ip;
	        update ip;
	        delete ip;
        }
    }
    
	/*** Start: Test Code for SL_Deals trigger */
 
    //For test Case1: After Update when a field is updated on Deal, the field on related Transaction should also be updated 
    static testMethod void SL_Test_DealHandler_AfterUpdate() 
    {
    	set<Id> setDealIds = new set<Id>();
        objUser = new User(alias = 'user', email='test@user.com', title='test',
        emailencodingkey='UTF-8', lastName='testUser', languagelocalekey='en_US', localesidkey='en_US', profileid = strProfileId, timezonesidkey='America/Los_Angeles', userName='UserAug01@test.com');
        insert objUser;
        system.runAs(objUser)
        {
	        test.startTest();
	        
	        List<Account> lstAccount = new List<Account>();
	        Account objAccount = new Account(Name = 'Test');
	        Account objAccount1 = new Account(Name = 'Test1');
	        lstAccount.add(objAccount);
	        lstAccount.add(objAccount1);
	        insert lstAccount;
	        
	        SL_RecursionHelper.setisUpdate(false);//To avoid the update called from After insert on another trigger
	        lstDeals = new List<Ibanking_Project__c>();
	        for(Integer i=0; i<5; i++)
	        {
	            lstDeals.add(new Ibanking_Project__c(Client__c= objAccount.Id ,Name= 'test--'));
	        }
	        insert lstDeals;
	        Recent_Transaction_Announcements__c objTransaction = new Recent_Transaction_Announcements__c(Deal_RTA__c= lstDeals[0].Id,Industry__c = 'test');
	        insert objTransaction;
	        
	        List<Ibanking_Project__c> lstDealsToBeUpdated = new List<Ibanking_Project__c>();
	        for(Ibanking_Project__c objDeal : lstDeals)
	        {
	            lstDealsToBeUpdated.add( new Ibanking_Project__c( Id= objDeal.Id,Client__c = objAccount1.Id, Industry__c ='Media' ));
	            setDealIds.add(objDeal.Id);
	        }
	        SL_RecursionHelper.setisUpdate(true);
	        
	        update lstDealsToBeUpdated;
	        Test.stopTest();
	        for(Recent_Transaction_Announcements__c objRecentTransaction :[ Select Company_Name__c, Industry__c, Deal_RTA__c  
	                    From Recent_Transaction_Announcements__c where Deal_RTA__c In: setDealIds
	                    ])
	        {
	            //Field on related Transaction should also be updated
	            system.assertEquals(objRecentTransaction.Company_Name__c,objAccount1.Id);
	            system.assertEquals(objRecentTransaction.Industry__c,'Media');
	        }
        }
    }
    
    //For test Case1: After Insert on Deal, an EMail should be sent 
    static testMethod void SL_Test_DealHandler_AfterInsert() 
    {
        objUser = new User(alias = 'user', email='sruti@silverlinecrm.com', title='test',
        emailencodingkey='UTF-8', lastName='testUser', languagelocalekey='en_US', localesidkey='en_US', profileid = strProfileId, 
        timezonesidkey='America/Los_Angeles', userName='UserAug01@test.com');
        insert objUser;
        
        system.runAs(objUser)
        {
        	createTestData();
        	system.Test.startTest();
	        empl = new Employee_Profile__c(Name='Admin 1', First_Name__c = 'Schmoe', Last_Name__c = 'Test', Title__c = 'Title', 
	                                                           Business_Type__c = 'Advisory', Group__c = 'Group', Status__c = 'Active', 
	                                                           Office_Location__c = 'Boston', User_Id__c = objUser.id);
	        insert empl;
        	SL_RecursionHelper.setisUpdate(false);//To avoid the update called from After insert on another trigger
	        lstDeals = new List<Ibanking_Project__c>{new Ibanking_Project__c(Client__c= objAcc.Id ,Name= 'test--',Business_Conflict_Checked_Status__c = 'Approved')
	        };
	        insert lstDeals;
	        lstprojects = new List<Project_Resource__c>{new Project_Resource__c( Banker__c=empl.Id,  Project__c = lstDeals[0].Id,  Status__c = 'Active')};
			insert lstprojects;
        	system.Test.stopTest();
        	for(Ibanking_Project__c objdeal :[ Select Id,Business_Conflict_Checked_Status__c From Ibanking_Project__c  ])
	        {
	            //Asserting whether Ibanking_Project__c is Inserted correctly 
	            system.assertEquals(objdeal.Business_Conflict_Checked_Status__c, 'Approved');
	            system.assertNotEquals(objdeal.Business_Conflict_Checked_Status__c, 'Not Approved');
	        }
        }
    }
    /** Update Trigger test code **/
    
    //For test Case1: If an Ibanking_Project__c record is updated with newMap.Send_Conflict_Clearance__c == true and oldMap.Send_Conflict_Clearance__c == false, 
    //an email should be sent
    static testMethod void SL_Test_DealHandler_UpdateConflictClearance() 
    {
        objUser = new User(alias = 'user', email='sruti@silverlinecrm.com', title='test',
        emailencodingkey='UTF-8', lastName='testUser', languagelocalekey='en_US', localesidkey='en_US', profileid = strProfileId, 
        timezonesidkey='America/Los_Angeles', userName='UserAug01@test.com');
        insert objUser;
        
        system.runAs(objUser)
        {
        	createTestData();
        	system.Test.startTest();
	        emp2 = new Employee_Profile__c(Name='Admin 2', First_Name__c = 'Schmoe1', Last_Name__c = 'Test1', Title__c = 'Title', 
	                                                           Business_Type__c = 'Advisory', Group__c = 'Group', Status__c = 'Active', 
	                                                           Office_Location__c = 'Boston', User_Id__c = objUser.id);
	        insert emp2;
	        
        	SL_RecursionHelper.setisUpdate(false);//To avoid the update called from After insert on another trigger
	        lstDeals = new List<Ibanking_Project__c>{new Ibanking_Project__c(Client__c= objAcc.Id ,Name= 'test--',Business_Conflict_Checked_Status__c = 'Approved'),
	         new Ibanking_Project__c(Client__c= objAcc.Id ,Name= 'test--1',Business_Conflict_Checked_Status__c = 'Approved')};
	        insert lstDeals;
	        lstprojects = new List<Project_Resource__c>{new Project_Resource__c( Banker__c=empl.Id,  Project__c = lstDeals[0].Id,  Status__c = 'Active'),
	        new Project_Resource__c( Banker__c=emp2.Id,  Project__c = lstDeals[1].Id,  Status__c = 'Active')};
			insert lstprojects;
	       	 
			lstDeals[0].Send_Conflict_Clearance__c = true;
			lstDeals[1].Send_Conflict_Clearance__c = true;
			update lstDeals;
        	system.Test.stopTest();
        	
        	for(Ibanking_Project__c objdeal :[ Select Id, Send_Conflict_Clearance__c From Ibanking_Project__c  ])
	        {
	            //Asserting whether Ibanking_Project__c is updated correctly 
	            system.assertEquals(objdeal.Send_Conflict_Clearance__c, true);
	            system.assertNotEquals(objdeal.Send_Conflict_Clearance__c, false);
	        }
        }
    }
    
    //For test Case 2: If an Ibanking_Project__c record is updated with newMap.Send_NDA_CDA_Review__c== true and 
    //oldMap.Send_NDA_CDA_Review__c== false, an email should be sent
    static testMethod void SL_Test_DealHandler_Update_SendNDACDAReview() 
    {
        objUser = new User(alias = 'user', email='sruti@silverlinecrm.com', title='test',
        emailencodingkey='UTF-8', lastName='testUser', languagelocalekey='en_US', localesidkey='en_US', profileid = strProfileId, 
        timezonesidkey='America/Los_Angeles', userName='UserAug01@test.com');
        insert objUser;
        
        system.runAs(objUser)
        {
        	createTestData();
        	
        	system.Test.startTest();
        	
        	SL_RecursionHelper.setisUpdate(false);//To avoid the update called from After insert on another trigger
	        lstDeals = new List<Ibanking_Project__c>{new Ibanking_Project__c(Client__c= objAcc.Id ,Name= 'test--',Business_Conflict_Checked_Status__c = 'Approved')};
	        insert lstDeals;
	        lstprojects = new List<Project_Resource__c>{new Project_Resource__c( Banker__c=empl.Id,  Project__c = lstDeals[0].Id,  Status__c = 'Active')};
			insert lstprojects;
	        
			lstDeals[0].Send_NDA_CDA_Review__c = true;
			update lstDeals;
        	system.Test.stopTest();
        	
        	for(Ibanking_Project__c objdeal :[ Select Id, Send_NDA_CDA_Review__c From Ibanking_Project__c  ])
	        {
	            //Asserting whether Ibanking_Project__c is updated correctly 
	            system.assertEquals(objdeal.Send_NDA_CDA_Review__c, true);
	            system.assertNotEquals(objdeal.Send_NDA_CDA_Review__c, false);
	        }
        }
    }
    //For test Case 3: If an Ibanking_Project__c record is updated with newMap.Business_Conflict_Checked_Status__c == 'Approved' and 
    //oldMap.Business_Conflict_Checked_Status__c != 'Approved', an email should be sent
    static testMethod void SL_Test_DealHandler_Update_Business_Conflict_Checked_Status() 
    {
        objUser = new User(alias = 'user', email='sruti@silverlinecrm.com', title='test',
        emailencodingkey='UTF-8', lastName='testUser', languagelocalekey='en_US', localesidkey='en_US', profileid = strProfileId, 
        timezonesidkey='America/Los_Angeles', userName='UserAug01@test.com');
        insert objUser;
        
        system.runAs(objUser)
        {
        	createTestData();
        	system.Test.startTest();
        	SL_RecursionHelper.setisUpdate(false);//To avoid the update called from After insert on another trigger
	        lstDeals = new List<Ibanking_Project__c>{new Ibanking_Project__c(Client__c= objAcc.Id ,Name= 'test--',Business_Conflict_Checked_Status__c = 'Not Approved')};
	        insert lstDeals;
	        lstprojects = new List<Project_Resource__c>{new Project_Resource__c( Banker__c=empl.Id,  Project__c = lstDeals[0].Id,  Status__c = 'Active')};
			insert lstprojects;
	       	 
			lstDeals[0].Business_Conflict_Checked_Status__c = 'Approved' ;
			update lstDeals;
        	system.Test.stopTest();
        	
        	for(Ibanking_Project__c objdeal :[ Select Id, Business_Conflict_Checked_Status__c From Ibanking_Project__c  ])
	        {
	            //Asserting whether Ibanking_Project__c is updated correctly 
	            system.assertEquals(objdeal.Business_Conflict_Checked_Status__c, 'Approved');
	            system.assertNotEquals(objdeal.Business_Conflict_Checked_Status__c, null);
	        }
        }
    }
    
    //For test Case 3: If an Ibanking_Project__c record is updated with newMap.Send_AML_KYC__c== true 
    //and oldMap.Send_AML_KYC__c == false, an email should be sent
    static testMethod void SL_Test_DealHandler_Update_Send_AML_KYC() 
    {
        objUser = new User(alias = 'user', email='sruti@silverlinecrm.com', title='test',
        emailencodingkey='UTF-8', lastName='testUser', languagelocalekey='en_US', localesidkey='en_US', profileid = strProfileId, 
        timezonesidkey='America/Los_Angeles', userName='UserAug01@test.com');
        insert objUser;
        
        system.runAs(objUser)
        {
        	createTestData();
        	system.Test.startTest();
        	
	        
        	SL_RecursionHelper.setisUpdate(false);//To avoid the update called from After insert on another trigger
        	
	       	lstDeals = new List<Ibanking_Project__c>{new Ibanking_Project__c(Client__c= objAcc.Id ,Name= 'test--',Business_Conflict_Checked_Status__c = 'Not Approved')};
	        insert lstDeals;
	        lstprojects = new List<Project_Resource__c>{new Project_Resource__c( Banker__c=empl.Id,  Project__c = lstDeals[0].Id,  Status__c = 'Active')};
			insert lstprojects;
	       	 
			lstDeals[0].Send_AML_KYC__c = true;
			update lstDeals;
			
        	system.Test.stopTest();
        	
        	for(Ibanking_Project__c objdeal :[ Select Id, Send_AML_KYC__c From Ibanking_Project__c  ])
	        {
	            //Asserting whether Ibanking_Project__c is updated correctly 
	            system.assertEquals(objdeal.Send_AML_KYC__c, true);
	            system.assertNotEquals(objdeal.Send_AML_KYC__c, false);
	        }
        }
    }
    
    /** END: Updata case**/
    
    //Creating test Data
    private static void createTestData()
    {
    	List<Account> lstAccount = new List<Account>();
        objAcc = new Account(Name = 'Test');
        objAcc2 = new Account(Name = 'Test2');
        lstAccount.add(objAcc);
        lstAccount.add(objAcc2);
        insert lstAccount;
        
        objContact = new Contact(LastName = 'katie', FirstName= 'test', Email = 'brock@silverlinecrm.com', AccountId= objAcc.Id);
        insert objContact;
        empl = new Employee_Profile__c(Name='Admin 1', First_Name__c = 'Schmoe', Last_Name__c = 'Test', Title__c = 'Title', 
	                                                           Business_Type__c = 'Advisory', Group__c = 'Group', Status__c = 'Active', 
	                                                           Office_Location__c = 'Boston', User_Id__c = objUser.id);
		insert empl;
    }
    /*** End: Test Code for SL_Deals trigger */
}