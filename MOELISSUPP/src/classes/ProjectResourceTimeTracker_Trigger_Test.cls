public class ProjectResourceTimeTracker_Trigger_Test 
{
	static testMethod void TriggerTest() 
	{
		
		Account acc = new Account();
        acc.Name = 'Test';
        Test.startTest();
        insert acc;
				
		Ibanking_Project__c ibp = new Ibanking_Project__c(Name = 'Test Deal',Client__c = acc.Id, Status__c = 'Active');
		insert ibp;
		
		Profile newProfile = [select Id from Profile limit 1];
		Id UserId1 = UserInfo.getUserId();
		
		List<User> lstUser = new List<User>{
												new User(Username='demo784785@yandex.ru',LastName='testdemo658422',Email='testdemo57489543@yandex.ru',Alias='EuKr225d',CommunityNickname='EugenKrdemo',TimeZoneSidKey='Pacific/Fiji',LocaleSidKey='ar',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',ProfileId=newProfile.Id),
												new User(Username='demo34784785@yandex.ru',LastName='test43demo658422',Email='testdemo4357489543@yandex.ru',Alias='EuKr2efd',CommunityNickname='E32ugenKrdemo',TimeZoneSidKey='Pacific/Fiji',LocaleSidKey='ar',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',ProfileId=newProfile.Id)
											};
		insert lstUser;
        
		List<Employee_Profile__c> lstEmployeeProfile = new List<Employee_Profile__c>{
																						new Employee_Profile__c(First_Name__c='Eugen', Last_Name__c='Kryvobok',Title__c = 'Managing Director', User_Id__c=UserId1),
																						new Employee_Profile__c(First_Name__c='Eugengfg', Last_Name__c='Kryvoboktrt',Title__c = 'Managing Director', User_Id__c=lstUser[0].Id),
																						new Employee_Profile__c(First_Name__c='Eugengfgfdf', Last_Name__c='Kryvoboktrtdfdf',Title__c = 'Analyst', User_Id__c=lstUser[1].Id)
																					};
		insert lstEmployeeProfile;
		
		Project_Resource__c pr  = new Project_Resource__c(Project__c = ibp.Id,Status__c='Active', Banker__c = lstEmployeeProfile[0].Id);
		insert pr;
		
		List<TimeSheet_Summary__c> lstTimeSheetSummary = new List<TimeSheet_Summary__c>{
																							new TimeSheet_Summary__c(Name = 'Test TimeSheetSummary',Employee__c = lstEmployeeProfile[0].Id, Stage__c = 'New', Week_Start_Date__c = Date.today()),
																							new TimeSheet_Summary__c(Name = 'Test TimeSheetSummary1',Employee__c = lstEmployeeProfile[1].Id, Stage__c = 'New', Week_Start_Date__c = Date.today()+7)
																						};
		insert lstTimeSheetSummary;		
		
		/*Time_Tracker__c tt = new Time_Tracker__c();
		tt.Week_Start_Date__c = tss.Week_Start_Date__c;
		tt.Employee__c = tss.Employee__c;
		tt.Time_Sheet_Summary__c = tss.Id;
		tt.Deal__c = ibp.Id;
		tt.Stage__c = 'New';
		upsert tt;*/
		pr.Banker__c = lstEmployeeProfile[1].Id;
		//update pr;
		delete pr;
		Test.stopTest();
		
	}
}