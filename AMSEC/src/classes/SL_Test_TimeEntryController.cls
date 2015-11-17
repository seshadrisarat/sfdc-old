/**
* \arg ClassName        : SL_Test_TimeEntryController
* \arg JIRATicket       : AMSEC-TimeEntry
* \arg CreatedOn        : 21/MAY/2015
* \arg LastModifiedOn   : 31/MAY/2015
* \arg CreatededBy      : Gordon Arnold
* \arg ModifiedBy       : Lodhi
* \arg Description      : Test class for SL_TimeEntryController class. 
*/
@isTest
private class SL_Test_TimeEntryController 
{
    static List<AS_Project__c> lstAsProject;
    static List<Contact> lstContact;
    static List<User> lstUser;
    static List<External_Working_Group_Member__c> lstWGM;
    static List<Project_Time_Tracking__c> lstPTTracking;
    static List<Account> lstAccount;
    static List<Project_Closed_Date__c> lstPrjClsDate;
    
    private static void createData()
    {
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole objUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = :'Resource_Group_Member' LIMIT 1];
        lstUser = new List<User>{
                        new User(Alias = 'stdusr1', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = objProfile.Id, userRoleId =objUserRole.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='test879user122.64@1332testsl.com'),
                        new User(Alias = 'stdusr2', Email='standarduse14r@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = objProfile.Id, userRoleId =objUserRole.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='test45454user122.64@1332testsl.com')         
        };
        
        System.runAs(new user(Id = UserInfo.getUserId()))
        {
            insert lstUser;
        }
        
        lstAccount = new List<Account>{
            new Account(Name = 'TestAcc-01')
        };            
	    insert lstAccount;
	    
	    lstContact = new List<Contact>{
	        new Contact(LastName = 'TestContact-01', Title = 'CEO', AccountId = lstAccount[0].Id, Salesforce_User__c = UserInfo.getUserId()),
	        new Contact(LastName = 'TestContact-02', Title = 'CEO', AccountId = lstAccount[0].Id, Salesforce_User__c = lstUser[0].Id),
	        new Contact(LastName = 'TestContact-03', Title = 'CEO', AccountId = lstAccount[0].Id, Salesforce_User__c = UserInfo.getUserId()),
	        new Contact(LastName = 'TestContact-04', Title = 'CEO', AccountId = lstAccount[0].Id, Salesforce_User__c = lstUser[1].Id)
	    };	        
	    insert lstContact;
	    
	    Delegate__c del = new Delegate__c(Delegate__c=UserInfo.getUserId(), Manager__c=lstUser[0].Id,Active__c=true);
	    insert del;

	    lstAsProject = new List<AS_Project__c>{
	        new AS_Project__c(Name = 'TestProject-01',Start_Date__c = Date.today(), Project_Type__c = 'Risk', EBITDA_Value__c = '646',
	                          Portfolio_Company__c = lstAccount[0].Id, End_Date__c = Date.today()),
	        new AS_Project__c(Name = 'TestProject-02', Portfolio_Company__c = lstAccount[0].Id, Start_Date__c = Date.today(), 
	                          Project_Type__c = 'Risk', EBITDA_Value__c = '646', End_Date__c = Date.today().addMonths(2))
	    };
	    insert lstAsProject;
	    
	    lstWGM = new List<External_Working_Group_Member__c>{
	        new External_Working_Group_Member__c(AS_Project__c = lstAsProject[0].Id, Contact__c = lstContact[0].Id, End_Date__c = Date.today()),
	        new External_Working_Group_Member__c(AS_Project__c = lstAsProject[1].Id, Contact__c = lstContact[1].Id, End_Date__c = Date.today()),
	        new External_Working_Group_Member__c(AS_Project__c = lstAsProject[0].Id, Contact__c = lstContact[2].Id)
	    };
	    insert lstWGM;
	    
	    lstPTTracking = new List<Project_Time_Tracking__c>{
	        new Project_Time_Tracking__c(Hours__c = 6, Project_Name__c = lstAsProject[0].Id, Resource_User__c =UserInfo.getUserId(),
	                                     Date__c = Date.valueOf(Date.today().year()+'-'+Date.today().month()+'-'+'01'), Locked__c = true),
            new Project_Time_Tracking__c(Hours__c = 5, Project_Name__c = lstAsProject[1].Id, Resource_User__c =UserInfo.getUserId(),
	                                     Date__c = Date.valueOf(Date.today().year()+'-'+Date.today().month()+'-'+'01'))	                                     
	    };
	    insert lstPTTracking;
	     AS_Project_Status__c stat = new AS_Project_Status__c(Month_Ending__c=Date.valueOf(Date.today().year()+'-'+Date.today().month()+'-'+'01'),AS_Project__c=lstAsProject[0].Id);
	    insert stat;
	    stat.Comments__c = 'test';
	    update stat;
	    lstPrjClsDate = new List<Project_Closed_Date__c>{
	        new Project_Closed_Date__c(Name = 'Systemprojcloseddate', Day_of_Month__c = 22.0)
	    };
	    insert lstPrjClsDate;
    }
    
    
	private static testMethod void test_MethodOne() 
	{
	    createData();
	    ApexPages.CurrentPage().getParameters().put('isInsert', lstUser[0].Id);
        SL_TimeEntryController objTimeEntryCon = new SL_TimeEntryController();
        SL_TimeEntryController.tempStatusStorage temp = new SL_TimeEntryController.tempStatusStorage();
        objTimeEntryCon.dailyOrMonthly = 'Monthly';
        objTimeEntryCon.selectDate= String.valueOf(Date.today());
        objTimeEntryCon.strCompanyId = lstAccount[0].Id;
        objTimeEntryCon.populateContact();
        objTimeEntryCon.prepareGroupMemberWrapper();
        objTimeEntryCon.createProject();
        
        objTimeEntryCon.selectedProject = lstAccount[0].Name+' - '+lstAsProject[0].Name;
        objTimeEntryCon.statusStorage.put(lstAccount[0].Name+' - '+lstAsProject[0].Name, null);
        objTimeEntryCon.addProject = lstAccount[0].Name+' - '+lstAsProject[0].Name;
        objTimeEntryCon.loadStatus();
        objTimeEntryCon.addToProject();
        
        objTimeEntryCon.getDate();
		objTimeEntryCon.selectDate = Date.today().year()+'-'+Date.today().month()+'-'+'01';
		objTimeEntryCon.mtdHours();
		objTimeEntryCon.selectedProject ='testproj';
		objTimeEntryCon.statusStorage.put('testproj',temp);
		objTimeEntryCon.loadStatus();
		objTimeEntryCon.statusChanged();
		objTimeEntryCon.submitStatus();
		Test.StartTest();
// 		objTimeEntryCon.deleteTime();
		objTimeEntryCon.fillTempDaily();
		objTimeEntryCon.updateDateRange();
// 		objTimeEntryCon.unlockTimeStatusRecords();
		SL_TimeEntryController.checkClosed(String.valueOf(lstAccount[0].Name+' - '+lstAsProject[0].Name));
		SL_TimeEntryController.closeProject(String.valueOf(lstAccount[0].Name+' - '+lstAsProject[0].Name));
		SL_TimeEntryController.removeProject(String.valueOf(lstAccount[0].Name+' - '+lstAsProject[0].Name), lstUser[0].Id);
		objTimeEntryCon.getProjectCategoryOptions();
		objTimeEntryCon.checkDiligenceOnInvOpportunity();
		objTimeEntryCon.populateFields();
		objTimeEntryCon.getPortfolioCompanies();
		objTimeEntryCon.unlockTimeRecords();
		objTimeEntryCon.getMonthWord(1);
		objTimeEntryCon.getMonthWord(2);
		objTimeEntryCon.getMonthWord(3);
		objTimeEntryCon.getMonthWord(4);
		objTimeEntryCon.getMonthWord(5);
		objTimeEntryCon.getMonthWord(6);
		objTimeEntryCon.getMonthWord(7);
		objTimeEntryCon.getMonthWord(8);
		objTimeEntryCon.getMonthWord(9);
		objTimeEntryCon.getMonthWord(10);
		objTimeEntryCon.getMonthWord(11);
		objTimeEntryCon.getMonthWord(12);
		String deleteMonth=Date.today().year()+'-'+Date.today().month()+'-'+'01';
		SL_TimeEntryController.radioChanged(lstUser[0].Id,'Daily',deleteMonth);
		SL_TimeEntryController.radioChanged(lstUser[0].Id,'Monthly',deleteMonth);
		Test.StopTest(); 
	    /*SL_TimeEntryController.SubmitTimeEntry('{"TestAcc-01 - TestProject-01":"6.00"}', UserInfo.getUserId(), Date.today().year()+'-'+Date.today().month()+'-'+'01', 
	                                                'Mon', String.valueOf(lstAccount[0].Name+' - '+lstAsProject[0].Name) +'_'+ Date.today().month()+'/'+'06'+'/'+Date.today().year());
	    SL_TimeEntryController.SubmitTimeEntry('{"TestProject-01":"6.00"}', UserInfo.getUserId(), Date.today().year()+'-'+Date.today().month()+'-'+'01', 
	                                                'Tue', String.valueOf(lstAccount[0].Name+' - '+lstAsProject[0].Name) +'_'+ Date.today().month()+'/'+'06'+'/'+Date.today().year());
	    SL_TimeEntryController.SubmitTimeEntry('{"TestProject-01":"6.00"}', UserInfo.getUserId(), Date.today().year()+'-'+Date.today().month()+'-'+'01', 
	                                                'Wed', String.valueOf(lstAccount[0].Name+' - '+lstAsProject[0].Name) +'_'+ Date.today().month()+'/'+'06'+'/'+Date.today().year());
	    SL_TimeEntryController.SubmitTimeEntry('{"TestProject-01":"6.00"}', UserInfo.getUserId(), Date.today().year()+'-'+Date.today().month()+'-'+'01', 
	                                                'Thu', String.valueOf(lstAccount[0].Name+' - '+lstAsProject[0].Name) +'_'+ Date.today().month()+'/'+'06'+'/'+Date.today().year());
	    SL_TimeEntryController.SubmitTimeEntry('{"TestProject-01":"6.00"}', UserInfo.getUserId(), Date.today().year()+'-'+Date.today().month()+'-'+'01', 
	                                                'Fri', String.valueOf(lstAccount[0].Name+' - '+lstAsProject[0].Name) +'_'+ Date.today().month()+'/'+'06'+'/'+Date.today().year());
	    SL_TimeEntryController.SubmitTimeEntry('{"TestProject-01":"6.00"}', UserInfo.getUserId(), Date.today().year()+'-'+Date.today().month()+'-'+'01', 
	                                                'Sat', String.valueOf(lstAccount[0].Name+' - '+lstAsProject[0].Name) +'_'+ Date.today().month()+'/'+'06'+'/'+Date.today().year());
	    SL_TimeEntryController.SubmitTimeEntry('{"TestProject-01":"6.00"}', UserInfo.getUserId(), Date.today().year()+'-'+Date.today().month()+'-'+'01', 
	                                                'Sun', String.valueOf(lstAccount[0].Name+' - '+lstAsProject[0].Name) +'_'+ Date.today().month()+'/'+'06'+'/'+Date.today().year());*/
	}
	private static testMethod void test_Methodtwo() 
	{
	    createData();
	    ApexPages.CurrentPage().getParameters().put('isInsert', lstUser[0].Id);
        SL_TimeEntryController objTimeEntryCon = new SL_TimeEntryController();
        //SL_TimeEntryController.tempStatusStorage temp = new SL_TimeEntryController.tempStatusStorage();

        objTimeEntryCon.dailyOrMonthly = 'Monthly';
        objTimeEntryCon.selectDate= String.valueOf(Date.today());
        objTimeEntryCon.strCompanyId = lstAccount[0].Id;
        objTimeEntryCon.populateContact();
        objTimeEntryCon.prepareGroupMemberWrapper();
        objTimeEntryCon.createProject();
        
        objTimeEntryCon.selectedProject = lstAccount[0].Name+' - '+lstAsProject[1].Name;
        objTimeEntryCon.addProject = lstAccount[0].Name+' - '+lstAsProject[1].Name;
        objTimeEntryCon.statusStorage.put(lstAccount[0].Name+' - '+lstAsProject[1].Name, null);
        objTimeEntryCon.statusChanged();
        objTimeEntryCon.loadStatus();
        objTimeEntryCon.addToProject();
        
        objTimeEntryCon.getDate();
		objTimeEntryCon.selectDate = Date.today().year()+'-'+Date.today().month()+'-'+'01';
		objTimeEntryCon.mtdHours();
		objTimeEntryCon.selectedProject ='testproj';
		//objTimeEntryCon.statusStorage.put('testproj',temp);
		objTimeEntryCon.loadStatus();
		objTimeEntrycon.currentPercentComplete = 5;
		objTimeEntrycon.currentLastSteps= 'test';
		objTimeEntrycon.currentNextSteps='test2';
		//objTimeEntrycon.currentComments='test3';
		objTimeEntryCon.statusChanged();
		objTimeEntryCon.submitStatus();
		Test.StartTest();
// 		objTimeEntryCon.deleteTime();
		objTimeEntryCon.fillTempDaily();
		//objTimeEntryCon.updateDateRange();
// 		objTimeEntryCon.unlockTimeStatusRecords();
		objTimeEntryCon.nextWeek();
		SL_TimeEntryController.checkClosed(String.valueOf(lstAccount[0].Name+' - '+lstAsProject[1].Name));
		SL_TimeEntryController.closeProject(String.valueOf(lstAccount[0].Name+' - '+lstAsProject[1].Name));
		SL_TimeEntryController.removeProject(String.valueOf(lstAccount[0].Name+' - '+lstAsProject[1].Name), lstUser[0].Id);
		objTimeEntryCon.getProjectCategoryOptions();
		objTimeEntryCon.checkDiligenceOnInvOpportunity();
		objTimeEntryCon.populateFields();
		objTimeEntryCon.getPortfolioCompanies();
		objTimeEntryCon.unlockTimeRecords();
		String deleteMonth=Date.today().year()+'-'+Date.today().month()+'-'+'01';
		SL_TimeEntryController.radioChanged(lstUser[0].Id,'Daily',deleteMonth);
		SL_TimeEntryController.radioChanged(lstUser[0].Id,'Monthly',deleteMonth);
		Test.StopTest(); 
	   /* SL_TimeEntryController.SubmitTimeEntry('{"TestAcc-01 - TestProject-01":"6.00"}', UserInfo.getUserId(), Date.today().year()+'-'+Date.today().month()+'-'+'01', 
	                                                	'', String.valueOf(lstAccount[0].Name+' - '+lstAsProject[1].Name) +'_'+ Date.today().year()+'/'+Date.today().month()+'/'+'06');*/
	}
	private static testMethod void test_Methodthree() 
	{
	    createData();
	    ApexPages.CurrentPage().getParameters().put('isInsert', lstUser[0].Id);
        SL_TimeEntryController objTimeEntryCon = new SL_TimeEntryController();
        //SL_TimeEntryController.tempStatusStorage temp = new SL_TimeEntryController.tempStatusStorage();

        objTimeEntryCon.dailyOrMonthly = 'Monthly';
        objTimeEntryCon.selectDate= String.valueOf(Date.today());
        objTimeEntryCon.strCompanyId = lstAccount[0].Id;
        objTimeEntryCon.populateContact();
        objTimeEntryCon.prepareGroupMemberWrapper();
        objTimeEntryCon.createProject();
        
        objTimeEntryCon.selectedProject = lstAccount[0].Name+' - '+lstAsProject[1].Name;
        objTimeEntryCon.addProject = lstAccount[0].Name+' - '+lstAsProject[1].Name;
        objTimeEntryCon.statusStorage.put(lstAccount[0].Name+' - '+lstAsProject[1].Name, null);
        objTimeEntryCon.statusChanged();
        objTimeEntryCon.loadStatus();
        objTimeEntryCon.addToProject();
        
        objTimeEntryCon.getDate();
		objTimeEntryCon.selectDate = Date.today().year()+'-'+Date.today().month()+'-'+'01';
		objTimeEntryCon.mtdHours();
		objTimeEntryCon.selectedProject ='testproj';
		//objTimeEntryCon.statusStorage.put('testproj',temp);
		objTimeEntryCon.loadStatus();
		objTimeEntrycon.currentPercentComplete = 5;
		objTimeEntrycon.currentLastSteps= 'test';
		objTimeEntrycon.currentNextSteps='test2';
		//objTimeEntrycon.currentComments='test3';
		objTimeEntryCon.statusChanged();
		objTimeEntryCon.submitStatus();
		Test.StartTest();
// 		objTimeEntryCon.deleteTime();
		objTimeEntryCon.fillTempDaily();
		//objTimeEntryCon.updateDateRange();
// 		objTimeEntryCon.unlockTimeStatusRecords();
		objTimeEntryCon.prevWeek();
		SL_TimeEntryController.checkClosed(String.valueOf(lstAccount[0].Name+' - '+lstAsProject[1].Name));
		SL_TimeEntryController.closeProject(String.valueOf(lstAccount[0].Name+' - '+lstAsProject[1].Name));
		SL_TimeEntryController.removeProject(String.valueOf(lstAccount[0].Name+' - '+lstAsProject[1].Name), lstUser[0].Id);
		objTimeEntryCon.getProjectCategoryOptions();
		objTimeEntryCon.checkDiligenceOnInvOpportunity();
		objTimeEntryCon.populateFields();
		objTimeEntryCon.getPortfolioCompanies();
		//objTimeEntryCon.unlockTimeRecords();
		String deleteMonth=Date.today().year()+'-'+Date.today().month()+'-'+'01';
		SL_TimeEntryController.radioChanged(lstUser[0].Id,'Daily',deleteMonth);
		SL_TimeEntryController.radioChanged(lstUser[0].Id,'Monthly',deleteMonth);
		Test.StopTest(); 
	    /*SL_TimeEntryController.SubmitTimeEntry('{"TestAcc-01 - TestProject-01":"6.00"}', UserInfo.getUserId(), Date.today().year()+'-'+Date.today().month()+'-'+'01', 
	                                                	'', String.valueOf(lstAccount[0].Name+' - '+lstAsProject[1].Name) +'_'+ Date.today().year()+'/'+Date.today().month()+'/'+'06');*/
	}

}