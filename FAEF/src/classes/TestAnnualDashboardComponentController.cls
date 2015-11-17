@isTest
private class TestAnnualDashboardComponentController {
	static testMethod void testController() {
		// Start of Preparing test data
		AnnualGoals__c objAnnualGoal = new AnnualGoals__c(Name = 'Test Annual Goal-01',FMAGrossMarginGoal__c = 50000,FundedCGMBacklog__c=null,FundedCGM__c = 250000, Year__c = String.valueOf(Date.today().year()),CSCGrossMarginGoal__c = 75000);
		insert objAnnualGoal;
        
        AnnualGoals__c objAnnualGoal2 = new  AnnualGoals__c(Name = 'Test Annual Goal-02',FMAGrossMarginGoal__c = 275000,FundedCGMBacklog__c=null,NewAccountsFMVFMATransactions__c=0,FundedCGM__c = 500000, Year__c = String.valueOf(Date.today().year()-1),CSCGrossMarginGoal__c = 250000);
		insert objAnnualGoal2;
        
        User objUser = new User(Email='standarduser@testorg.com', LastName='Testing',AnnualGoalsManagerView__c=TRUE, FundedCGMCareerToDate__c=0);
       		
		system.debug('=====objAnnualGoal=======' + objAnnualGoal);
		
		// Setting Url Parameters
		ApexPages.currentPage().getParameters().put('id', objAnnualGoal.Id);
		
		AnnualGoalsDashboardComponentController annDBcontroller1 = new AnnualGoalsDashboardComponentController();
		AnnualGoalsDashboardComponentController annDBcontroller = new AnnualGoalsDashboardComponentController(objAnnualGoal.id);
		
		ApexPages.currentPage().getParameters().put('id', null);
		
		AnnualGoalsDashboardComponentController annDBcontroller2 = new AnnualGoalsDashboardComponentController();
		
		ApexPages.currentPage().getParameters().put('id', objAnnualGoal.Id);
		AnnualGoalsDashboardComponentController annDBcontroller3 = new AnnualGoalsDashboardComponentController();
        
        ApexPages.currentPage().getParameters().put('id', objAnnualGoal.Id);
		AnnualGoalsDashboardComponentController annDBcontroller4 = new AnnualGoalsDashboardComponentController(objUser.id);
        
        ApexPages.currentPage().getParameters().put('id', objAnnualGoal2.Id);
		AnnualGoalsDashboardComponentController annDBcontroller5 = new AnnualGoalsDashboardComponentController();
    }

    //tamarack 1-27-15
    static testMethod void testAnnualGoalsPicklist() {

    	//createTestData
    	Profile p = [SELECT Id FROM Profile WHERE Profile.Name LIKE 'Sales%' LIMIT 1];
        
        User u = new User ();
        u.Username = 'test@test121212.' + System.Math.random(); // make sure we don't create a user that already exists
        u.LastName = 'someuser';
        u.Email = 't@t.com';
        u.Alias = 'test12';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
        u.AnnualGoalsManagerView__c = true;
        u.IsActive = true;
        u.Exclude_Dashboard__c = 'FALSE';
        u.CurrentTitle__c = 'AVP1';
        u.Date_of_Hire_into_Sales__c = System.today()-4;

        insert u;

        System.debug(LoggingLevel.INFO, 'Creating user: ' + u);

		
		AnnualGoals__c goal2014 = new AnnualGoals__c();
		goal2014.Name = 'Test Annual Goal-01';
		goal2014.FMAGrossMarginGoal__c = 50000;
		goal2014.FundedCGMBacklog__c=null;
		goal2014.FundedCGM__c = 250000;
		goal2014.Year__c = String.valueOf(Date.today().year()-1);
		goal2014.CSCGrossMarginGoal__c = 75000;
		goal2014.User__c = u.Id;
		goal2014.OwnerId = u.Id;

		insert goal2014;

		AnnualGoals__c goalThisYear = new AnnualGoals__c();
		goalThisYear.Name = 'Test Annual Goal-02';
		goalThisYear.FMAGrossMarginGoal__c = 50000;
		goalThisYear.FundedCGMBacklog__c=null;
		goalThisYear.FundedCGM__c = 250000;
		goalThisYear.Year__c = String.valueOf(Date.today().year());
		goalThisYear.CSCGrossMarginGoal__c = 75000;
		goalThisYear.User__c = u.Id;
		goalThisYear.OwnerId = u.Id;

		insert goalThisYear;

		Test.setCurrentPage(Page.AnnualGoalsDashboard);

		System.runAs(u) {
			//test out no data found
			AnnualGoalsDashboardComponentController dbCon1 = new AnnualGoalsDashboardComponentController();
			dbCon1.rerenderDashboard();
			
			AnnualGoalsDashboardComponentController dbCon = new AnnualGoalsDashboardComponentController();
			dbCon.userId = u.Id; //select our test user
			dbCon.rerenderDashboard();

			System.assertEquals(String.valueOf(Date.today().year()), dbCon.selectedYear, 'Default year is not selected.');
			System.assertNotEquals(null, dbCon.annualGoals, 'No annual goals found.');
			System.assertNotEquals(true, dbCon.goalYears.isEmpty(), 'Goal years picklist is empty.');

			dbCon.getUserOptions();
			dbCon.getData();
		}
    }
}