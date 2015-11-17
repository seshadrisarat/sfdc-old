@isTest
private class Tests_for_Triggers 
{
  public static testMethod void testDeals() 
  {
    Account testCompany = new Account(name='testCompany');
    insert testcompany;
    Contact testTutor = new Contact(FirstName='testFirst', LastName='testLast',Title='test',Phone='test',Email='test@mail.ru',MailingState='NY',MailingCity='test', AccountId=testcompany.Id);
    insert testTutor;
        ID UserID = UserInfo.getUserId();
        
        Ibanking_Project__c testIbankingProject = new Ibanking_Project__c(
              EmailTriggerParamsFlag__c='MOELIS_TEAM, ProjectClosedWon',Client__c = testcompany.Id, Name = 'testPrivladTargetBuyers1' ,
              Business_Type__c = 'Capital',
              Full_Description_of_Transaction__c = 'test',Stage__c='Idea');
        insert testIbankingProject;
        
        List<Employee_Profile__c> lstEmployeeProfile = new List<Employee_Profile__c>{
                                                new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst',
                                                            User_ID__c = UserID),
                                                new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst',
                                                            User_ID__c = UserID),
                                                new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst',
                                                            User_ID__c = UserID)
                                              };
        insert lstEmployeeProfile;    
        
    TimeSheet_Summary__c testTimeSheetSummary = new TimeSheet_Summary__c(Employee__c = lstEmployeeProfile[2].Id,Stage__c = 'New');
    insert testTimeSheetSummary;
    Time_Tracker__c testTT = new Time_Tracker__c(Time_Sheet_Summary__c = testTimeSheetSummary.Id, Deal__c = testIbankingProject.Id);
    insert testTT;
        
    testTutor.LastName = 'testLast1';
    update testTutor; 
    
    List<Employee_Profile__c> lstEmployeeToUpdate = new List<Employee_Profile__c>{
                                            new Employee_Profile__c(Id = lstEmployeeProfile[0].Id, Title__c = 'Senior Advisor'),
                                            new Employee_Profile__c(Id = lstEmployeeProfile[2].Id, Title__c = 'Senior Advisor')
                                           };
    update lstEmployeeToUpdate;
        
    //delete testProjectResource;
    delete testIbankingProject;
    
  }
  
  public static testMethod void testCallLog() 
  {
    Account testCompany = new Account(name='testCompany');
    insert testcompany;
    Contact testTutor = new Contact(FirstName='testFirst', LastName='testLast', AccountId=testcompany.Id);
    insert testTutor;
        ID UserID = UserInfo.getUserId();
        
        Ibanking_Project__c testIbankingProject = new Ibanking_Project__c(Client__c = testcompany.Id, Name = 'testIP',Full_Description_of_Transaction__c = 'test',Stage__c='Idea');
        insert testIbankingProject;
        
        List<Employee_Profile__c> List_EPs   = new List <Employee_Profile__c>{};
        
        
        Employee_Profile__c testEmployeeProfile = new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        testEmployeeProfile.User_ID__c = UserID;
        //insert testEmployeeProfile;
        List_EPs.add(testEmployeeProfile);
        
    Employee_Profile__c testEmployeeProfile2 = new Employee_Profile__c(Assistant__c = testEmployeeProfile.id,Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        testEmployeeProfile2.User_ID__c = UserID;
        //insert testEmployeeProfile2;
        List_EPs.add(testEmployeeProfile2);
        
        Employee_Profile__c testEmployeeProfile3 = new Employee_Profile__c(Title__c = 'Managing Director', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        testEmployeeProfile3.User_ID__c = UserID;
        //insert testEmployeeProfile3;
        List_EPs.add(testEmployeeProfile3);
        
        insert List_EPs;
        
        List<Employee_Profile__c> update_EPs = new List<Employee_Profile__c>{};
        update_EPs.add(testEmployeeProfile);
        update_EPs.add(testEmployeeProfile2);
        //update testEmployeeProfile;
        //update testEmployeeProfile2;
        update update_EPs;
    
    
    Call_Log__c testCallLog = new Call_Log__c(Type__c = 'Face to Face', Subject__c='test', Organizer__c=testEmployeeProfile.Id, Date__c = date.newinstance(1960, 2, 17));
        insert testCallLog;
        
        Call_Log_Deal__c testCallLogDeal = new Call_Log_Deal__c(Call_Log__c = testCallLog.Id, Deal__c=testIbankingProject.id);
        insert testCallLogDeal;
        
        Call_Log_Contact__c testCallLogContact = new Call_Log_Contact__c(Call_Log__c = testCallLog.Id, Contact__c = testTutor.id, Company__c = testcompany.ID);
        insert testCallLogContact;

        Call_Log_Moelis_Attendee__c testCallLogMoelisAttendee = new Call_Log_Moelis_Attendee__c(Employee__c=testEmployeeProfile.Id,Call_Log__c = testCallLog.Id);
        insert testCallLogMoelisAttendee;
        
        //test.startTest();
        
    
    
    //delete testProjectResource;
    delete testIbankingProject;
    delete testEmployeeProfile2;
    
    //test.stopTest();
    
    
    
  }
  public static testMethod void testPBI() 
  {
    Account testCompany = new Account(name='testCompany');
    insert testcompany;
    Contact testTutor = new Contact(FirstName='testFirst', LastName='testLast');
    insert testTutor;
        ID UserID = UserInfo.getUserId();
        
        Ibanking_Project__c testIbankingProject = new Ibanking_Project__c(Client__c = testcompany.Id, Name = 'testIP',Full_Description_of_Transaction__c = 'test',Stage__c='Idea');
        insert testIbankingProject;
        
        Employee_Profile__c testEmployeeProfile = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        testEmployeeProfile.User_ID__c = UserID;
        insert testEmployeeProfile;
    Employee_Profile__c testEmployeeProfile2 = new Employee_Profile__c(Assistant__c = testEmployeeProfile.id,Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        testEmployeeProfile2.User_ID__c = UserID;
        insert testEmployeeProfile2;
        
        update testEmployeeProfile;
        update testEmployeeProfile2;
        
        Potential_Buyer_Investor__c testPBI = new Potential_Buyer_Investor__c(Name = 'test', Project__c = testIbankingProject.Id,TargetBuyer__c = testCompany.Id);
    insert testPBI;
    Potential_Buyer_Investor_Deal_Team__c testPBI_DT = new Potential_Buyer_Investor_Deal_Team__c(Banker__c = testEmployeeProfile.id, Target_Buyer__c = testPBI.id);
        insert testPBI_DT;
    Potential_Buyer_Investor_Contact__c testPBI_C = new Potential_Buyer_Investor_Contact__c (Target_Buyer__c = testPBI.id,Contact__c =testTutor.id);
    insert testPBI_C;
    
    delete testEmployeeProfile2;
  }
  public static testMethod void testThis() {
    Account testCompany = new Account(name='testCompany');
    insert testcompany;
    
    Contact testTutor = new Contact(FirstName='testFirst', LastName='testLast');
    insert testTutor;
    

        ID UserID = UserInfo.getUserId();
        
        Employee_Profile__c testEmployeeProfile = new Employee_Profile__c(Title__c='Analyst', Office_Location__c='New York', Name='AnalystNY', Last_Name__c='Test LN', Group__c='Capital Markets', First_Name__c='test FN', Business_Function__c='Analyst');
        testEmployeeProfile.User_ID__c = UserID;
        insert testEmployeeProfile;
        
    Employee_Relationships__c testEmployeeRelationships = new Employee_Relationships__c(
      Contact__c=testTutor.Id, 
      Company_relationship__c=testCompany.Id,
      Employee__c=testEmployeeProfile.Id);
    insert testEmployeeRelationships;
    
    testTutor.LastName = 'testLast1';
    update testTutor; 
  }
  
  public static testMethod void testProjectClientContact()
  {
    Account testCompany = new Account(name='testCompany');
    insert testcompany;
    
    Contact testTutor = new Contact(FirstName='testFirst', LastName='testLast', AccountId = testcompany.Id);
    insert testTutor;
    
    Ibanking_Project__c testIbankingProject = new Ibanking_Project__c(
              EmailTriggerParamsFlag__c='MOELIS_TEAM, ProjectClosedWon',Client__c = testcompany.Id, Name = 'testPrivladTargetBuyers1' ,
              Business_Type__c = 'Capital',
              Full_Description_of_Transaction__c = 'test',Stage__c='Idea');
        insert testIbankingProject;
    
    Test.startTest();
    Project_Client_Contact__c testProjectClientContact = new Project_Client_Contact__c (Client_Contact__c = testTutor.Id, 
                                              Moelis_Project__c = testIbankingProject.Id
                                              );
    insert testProjectClientContact;
    Test.stopTest();
  }
}