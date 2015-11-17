public class EmployeeProfile_UserUpd_Test {
	public static testMethod void testIt() {
		
		Profile newProfile = [select Id from Profile limit 1];

		User testUser = new User(Username='ek@yandex.ru', LastName='testLast', Email='ek@yandex.ru', Alias='EuKr', CommunityNickname='EuKr', TimeZoneSidKey='Pacific/Fiji', LocaleSidKey='ar', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=newProfile.Id);
		insert testUser;

		User testUser2 = new User(Username='ek22@yandex.ru', LastName='testLastBB', Email='ek22@yandex.ru', Alias='EuKr2', CommunityNickname='EuKr2', TimeZoneSidKey='Pacific/Fiji', LocaleSidKey='ar', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=newProfile.Id);
		insert testUser2;
		
		system.debug('user1_ID===' + testUser.Id);
		system.debug('user2_ID===' + testUser2.Id);
		
        Employee_Profile__c testEmployee = new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNYKK', Last_Name__c='AnalystNYKK', Group__c='Capital Markets', First_Name__c='', Business_Function__c='Analyst');
        testEmployee.User_ID__c = testUser.Id;
        insert testEmployee;
        Employee_Profile__c testEmployee2 = new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNYKK', Last_Name__c='AnalystNYKK', Group__c='Capital Markets', First_Name__c='', Business_Function__c='Analyst');
        testEmployee2.User_ID__c = testUser.Id;
        insert testEmployee2;

        Account testAccount1 = new Account(Name='testAccount2');
		insert testAccount1;

    	
		Contact testContact = new Contact(AccountId=testAccount1.Id,FirstName='testFirstName', LastName='testLastName');
    	insert testContact;

    	
    	Ibanking_Project__c testDeal = new Ibanking_Project__c(Client__c=testAccount1.Id);
    	insert testDeal;	
    	list<Project_Resource__c> listProgResObj= new list<Project_Resource__c>();
    	listProgResObj.add(new Project_Resource__c(Role__c='Other',Status__c='Active', Project__c=testDeal.ID, Banker__c=testEmployee.ID));
    	listProgResObj.add(new Project_Resource__c(Role__c='Other',Status__c='Active', Project__c=testDeal.ID, Banker__c=testEmployee2.ID));

		Call_Log__c testCL = new Call_Log__c(Date__c=date.newInstance(2010,8,1));
		insert testCL;
		
		Call_Log_Moelis_Attendee__c testCLMA = new Call_Log_Moelis_Attendee__c(Call_Log__c=testCL.Id, Employee__c=testEmployee.Id);
		insert testCLMA;
		
		
		List<Ibanking_Project__Share> dealSharesBeforeUpdate = [SELECT Id, ParentId, UserOrGroupId FROM Ibanking_Project__Share WHERE ParentId = :testDeal.Id and RowCause = 'Manual'];
		List<Call_Log__Share>         callSharesBeforeUpdate = [SELECT Id, ParentId, UserOrGroupId FROM Call_Log__Share WHERE ParentId = :testCL.Id and RowCause = 'Manual'];
		
		
		
		
		
		testEmployee.Name='testEmployee2';
		//update testEmployee;
		
		testEmployee.User_ID__c=testUser2.Id;
		update testEmployee;





 
		List<Ibanking_Project__Share> dealSharesAfterUpdate = [SELECT Id, ParentId, UserOrGroupId FROM Ibanking_Project__Share WHERE ParentId = :testDeal.Id and RowCause = 'Manual'];
		List<Call_Log__Share>         callSharesAfterUpdate = [SELECT Id, ParentId, UserOrGroupId FROM Call_Log__Share WHERE ParentId = :testCL.Id and RowCause = 'Manual'];


		system.debug('dealShare=== before Update');
		for(Ibanking_Project__Share item : dealSharesBeforeUpdate) system.debug('dealShare===' + item);
		for(Call_Log__Share         item : callSharesBeforeUpdate) system.debug('callShare===' + item);

		system.debug('dealShare=== after Update');
		for(Ibanking_Project__Share item : dealSharesAfterUpdate) system.debug('dealShare===' + item);
		for(Call_Log__Share         item : callSharesAfterUpdate) system.debug('callShare===' + item);
		
		
		
		
		
		delete testEmployee;
		
		dealSharesAfterUpdate = [SELECT Id, ParentId, UserOrGroupId FROM Ibanking_Project__Share WHERE ParentId = :testDeal.Id and RowCause = 'Manual'];
		callSharesAfterUpdate = [SELECT Id, ParentId, UserOrGroupId FROM Call_Log__Share WHERE ParentId = :testCL.Id and RowCause = 'Manual'];

		system.debug('dealShare=== after Delete');
		for(Ibanking_Project__Share item : dealSharesAfterUpdate) system.debug('dealShare===' + item);
		for(Call_Log__Share         item : callSharesAfterUpdate) system.debug('callShare===' + item);


	}
}