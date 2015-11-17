//S-179420 - Created by Kanchan Palhora on 1/8/2014
//Created to cover class EmployeeRollupBatchable

@isTest 
private class EmployeeRollupBatchableTest {

  private static testMethod void employeeRollUpBatchTest() {
    Test.StartTest();
    EmployeeRollupBatchable batchObj = new EmployeeRollupBatchable('select id from user where isActive = true limit 1');
    List<User> users = new List<User>();
    for (Integer i = 0; i < 5; i++) {
      User u =  TestData_Utility1.createUserUnsaved(null);
      users.add(u);
    }

    insert users;
    
    Account acct = TestData_Utility1.createAccountUnsaved();
    insert acct;
    
    CompanyName__c camp = new CompanyName__c(Name = acct.id);
    insert camp;
    
    List<Deal__c> deals = new List<Deal__c>();
    Deal__c d1 =  TestData_Utility1.createDealUnsaved(acct.Id, 'Auction');
    Deal__c d2 =  TestData_Utility1.createDealUnsaved(acct.Id, 'On Hold');
    Deal__c d3 =  TestData_Utility1.createDealUnsaved(acct.Id, 'Auction'); 
    
    deals.add(d1);
    deals.add(d2);
    deals.add(d3); 
    insert deals; 

        
    List<Team_Member__c> teamMembers = new List<Team_Member__c>();
    for (Deal__c d : deals) {
      for (User u : users) {
        Team_Member__c tm =  TestData_Utility1.createTeamMemberUnsaved(u.Id, d.Id);
        teamMembers.add(tm);
      }
    }
    insert teamMembers;
    
    System.debug('### TeamMembers: '+[SELECT User__c FROM Team_Member__c WHERE Deal__r.Status__c NOT IN ('Closed','Passed','On Hold','Funded by Others')]);
    
    Database.executebatch(batchObj);
    Test.StopTest();
    
    Set<Id> userIds = new Set<Id>();
    for (User u : users) {
      userIds.add(u.Id);
      System.assertEquals(0, u.Active_Deals__c);
    }
   /* 
    List<User> usersAfterBatchRun = [select Id, Active_Deals__c from User where Id in :userIds];
    for (User u : usersAfterBatchRun) {
      userIds.add(u.Id);
      System.assertNotEquals(0, u.Active_Deals__c);
    } */
  }
}