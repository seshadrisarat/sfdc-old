/**
 * \author Vika Osmak 
 * \date 04/02/12
 * \see https://silverline.jira.com/browse/MBS-11
 * \brief Test Class for class SL_SeniorBankerScorecard_Report 
 */
@isTest
private class SL_Test_SeniorBankerScorecard_Report 
{
  public static Employee_Profile__c createData()
  {
    MDSC_Exclude_Groups__c MDSCExcludeGroups = new MDSC_Exclude_Groups__c(Name='Equity Research');
    insert MDSCExcludeGroups;
    MDSC_Titles__c MDSCTitles = new MDSC_Titles__c(Name='Senior Advisor');
    insert MDSCTitles;
    MDSC_Require_NonDealProjects__c MDSCRequireNonDealProjects = new MDSC_Require_NonDealProjects__c(Name='General Marketing');
    insert MDSCRequireNonDealProjects;
    
    list<Employee_Profile__c> lstEmployee_Profile = new list<Employee_Profile__c>();
    Employee_Profile__c curBanker = new Employee_Profile__c(
                 Title__c = 'Senior Advisor',
                 MD_Promotion_Date__c = Date.today() + 1,
                 Start_Date__c = Date.today(),
                 Business_Type__c = 'Advisory',
                 Status__c = 'Active',
                 User_ID__c = UserInfo.getUserId(), 
                 Office_Location__c = 'Dubai',
                 Last_Name__c = 'LTest', 
                 Group__c = 'Restructuring & Recapitalization',
                 First_Name__c = 'FTest' );
       lstEmployee_Profile.add(curBanker);
       Employee_Profile__c curBanker2 = new Employee_Profile__c(
                 Title__c = 'Managing Director',
                 MD_Promotion_Date__c = Date.today() + 1,
                 Start_Date__c = Date.today(),
                 Business_Type__c = 'Advisory',
                 Status__c = 'Active',
                 User_ID__c = UserInfo.getUserId(), 
                 Office_Location__c = 'New York',
                 Last_Name__c = 'LTest2', 
                 Group__c = 'Restructuring & Recapitalization',
                 First_Name__c = 'FTest' );
       lstEmployee_Profile.add(curBanker2);
       
       insert lstEmployee_Profile;
       
       Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Contact cont = new Contact( Title = 'Test', AccountId = acc.Id, FirstName = 'Test',LastName = 'Test' );
        insert cont;
        
        list<Ibanking_Project__c> lstDeals = new list<Ibanking_Project__c>();
       Ibanking_Project__c deal = new Ibanking_Project__c(Requesting_conflict_clearance__c = 'No',
                 Transaction_Type__c='Public', 
                 Status__c='Active', 
                 Expense_Code__c = 'ff',
                 Proposed_Fee_Structure__c = 'test',
                 Referral_Source__c = 'test',
                 Regions__c = 'Americas',
                 Relationship_History__c='test',
                 Transaction_Feature__c = '144A – Common',
                 Transaction_Sub_Type__c = 'Free Fall',
                 Stage__c='NBRC / CMC Request',
                 Competitive_Landscape__c = 'gg', 
                 Region__c='Americas', 
                 Product_Type__c='M&A', 
                 Milestone_DealTeamConflictCheckCleared__c = date.today(),
                 Estimated_Fee_Revenue__c = 200000,
                 Expected_Close_Date__c = '2013 Q1',
                 Moelis_Roles__c = 'Placement Agent',
                 Co_Advisors__c = 'ff',
                 Name='tttest Test Deal', 
                 Industry__c='Other', 
                 Business_Type__c='Advisory',
                 Description__c='test1',
                 Client__c = acc.Id,
                 Est_Transaction_Size__c=100.0,
                 Full_Description_of_Transaction__c='test2',
                 Include_in_Pipeline__c = true,
                 List_of_Owners__c = '123455',
                 Pitch_Date__c = date.today());
       lstDeals.add(deal);
       Ibanking_Project__c deal1 = new Ibanking_Project__c(Requesting_conflict_clearance__c = 'No',
                 Transaction_Type__c='Public', 
                 Status__c='Active', 
                 Stage__c='NBRC / CMC Request',
                 Competitive_Landscape__c = 'gg', 
                 Region__c='Americas', 
                 Product_Type__c='M&A', 
                 Co_Advisors__c = 'ff',
                 Name='tttest Test Deal', 
                 Industry__c='Other', 
                 Business_Type__c='Advisory',
                 Description__c='test1',
                 Client__c = acc.Id,
                 Est_Transaction_Size__c=100.0,
                 Full_Description_of_Transaction__c='test2',
                 Include_in_Pipeline__c = true,
                 List_of_Owners__c = '123455',
                 Pitch_Date__c = date.today());
       lstDeals.add(deal1);
       Ibanking_Project__c deal2 = new Ibanking_Project__c(
       			 Requesting_conflict_clearance__c = 'No',
                 Transaction_Type__c='Public',
                 Status__c='Active', 
                 Expense_Code__c = 'ff1',
                 Proposed_Fee_Structure__c = 'test',
                 Referral_Source__c = 'test',
                 Regions__c = 'Americas',
                 Relationship_History__c='test',
                 Transaction_Feature__c = '144A – Common',
                 Transaction_Sub_Type__c = 'Free Fall',
                 Stage__c='NBRC / CMC Request',
                 Competitive_Landscape__c = 'gg', 
                 Region__c='Americas', 
                 Product_Type__c='M&A', 
                 Milestone_DealTeamConflictCheckCleared__c = date.today(),
                 Engagement_Date__c = date.today(),
                 Estimated_Fee_Revenue__c = 200000,
                 Expected_Close_Date__c = '2013 Q1',
                 Moelis_Roles__c = 'Placement Agent',
                 Co_Advisors__c = 'ff',
                 Name='tttest111 Test Deal', 
                 Industry__c='Other', 
                 Business_Type__c='Advisory',
                 Description__c='test1',
                 Client__c = acc.Id,
                 Est_Transaction_Size__c=100.0,
                 Full_Description_of_Transaction__c='test2',
                 Include_in_Pipeline__c = false,
                 List_of_Owners__c = '123455',
                 Pitch_Date__c = date.today());
       lstDeals.add(deal2);
       
       insert lstDeals;
       
       list<Project_Resource__c> dealTeamMembers = new list<Project_Resource__c>();
       dealTeamMembers.add(new Project_Resource__c (Project__c = deal.Id, Banker__c = curBanker.Id, Status__c = 'Active'));
       dealTeamMembers.add(new Project_Resource__c (Project__c = deal2.Id, Banker__c = curBanker2.Id, Status__c = 'Active'));
       insert dealTeamMembers;
       Project_Resource__c dealTeamMember = new Project_Resource__c (Project__c = deal.Id, Banker__c = curBanker.Id, Status__c = 'Active');
       Project_Resource__c dealTeamMember2 = new Project_Resource__c (Project__c = deal2.Id, Banker__c = curBanker.Id, Status__c = 'Active');
       
       list<Event> lstEvents = new list<Event>();
       Event event = new Event();
      event.StartDateTime = DateTime.now().addHours(-10);
      event.EndDateTime = DateTime.now();
      event.DurationInMinutes = 600;
      event.Subject = 'Other';
      event.Type = 'test';
      event.WhoId = cont.Id;
      event.OwnerId = UserInfo.getUserId();
      lstEvents.add(event);
    Event event1 = new Event();
      event1.StartDateTime = DateTime.now().addMinutes(-90);
      event1.EndDateTime = DateTime.now();
      event1.DurationInMinutes = 90;
      event1.Subject = 'Other';
      event1.Type = 'test';
      event1.OwnerId = UserInfo.getUserId();
      lstEvents.add(event1);
    Event event2 = new Event();
      event2.StartDateTime = DateTime.now();
      event2.EndDateTime = DateTime.now().addHours(100);
      event2.DurationInMinutes = 6000;
      event2.Subject = 'Other';
      event2.Type = 'test';
      event2.WhatId = acc.Id;
      event2.OwnerId = UserInfo.getUserId();
      lstEvents.add(event2);
    insert lstEvents; 
    Call_Log__c cl = new Call_Log__c(Date__c = Date.today());
    insert cl;
    Call_Log_Moelis_Attendee__c clAttendee = new Call_Log_Moelis_Attendee__c(Call_Log__c = cl.Id, Employee__c = curBanker.id);
    insert clAttendee;
    Invoice__c inv = new Invoice__c(Project__c = deal.Id, Invoice_Date__c = Date.today()-1);
    Invoice__c inv2 = new Invoice__c(Project__c = deal2.Id, Invoice_Date__c = Date.today()-1);
    List<Invoice__c> lstInvoice = new List<Invoice__c>();
    lstInvoice.add(inv);
    lstInvoice.add(inv2);
    
    insert lstInvoice;
    
    
    list<Invoice_Detail__c> lstInvoice_Detail = new list<Invoice_Detail__c>();
    Invoice_Detail__c invD1 = new Invoice_Detail__c(Invoice__c = inv.Id, Amount__c = 400000, Transaction_Type__c = 'Fee');
    Invoice_Detail__c invD2 = new Invoice_Detail__c(Invoice__c = inv.Id, Amount__c = 500000, Transaction_Type__c = 'Expense');
    
    Invoice_Detail__c inv2D1 = new Invoice_Detail__c(Invoice__c = inv2.Id, Amount__c = 400, Transaction_Type__c = 'Fee');
    Invoice_Detail__c inv2D2 = new Invoice_Detail__c(Invoice__c = inv2.Id, Amount__c = 500, Transaction_Type__c = 'Expense');
    
    lstInvoice_Detail.add(invD1);
    lstInvoice_Detail.add(invD2);
    lstInvoice_Detail.add(inv2D1);
    lstInvoice_Detail.add(inv2D2);
    
    insert lstInvoice_Detail; 
    
    Company_List__c cmpList = new Company_List__c(Banker_Name__c = curBanker.Id,Status__c = 'Active',Type__c = 'Near-Term Transaction List' );
    insert cmpList;
    Company_List_Member__c clm = new Company_List_Member__c(Company__c = acc.Id, Date__c = Date.today(),Company_List__c = cmpList.Id);
    insert clm;
    
    return curBanker;
  }
  
  static testMethod void SL_SeniorBankerScorecard_Report1_coverage() 
    {
       Employee_Profile__c curBanker = createData();
    Test.startTest();
       ApexPages.currentPage().getParameters().put('filter', 'banker' );
       ApexPages.currentPage().getParameters().put('subfilters', curBanker.Id );
       ApexPages.currentPage().getParameters().put('sdate', String.valueOf(Date.today()-1));
       ApexPages.currentPage().getParameters().put('edate', String.valueOf(Date.today()));
       SL_SeniorBankerScorecard_Report report = new SL_SeniorBankerScorecard_Report();
       Test.stopTest();
    }
    static testMethod void SL_SeniorBankerScorecard_Report2_coverage() 
    {
       Employee_Profile__c curBanker = createData();
    Test.startTest();
    ApexPages.currentPage().getParameters().put('filter', 'group' );
       ApexPages.currentPage().getParameters().put('subfilters', 'Restructuring & Recapitalization');
       ApexPages.currentPage().getParameters().put('sdate', String.valueOf(Date.today()-1));
       ApexPages.currentPage().getParameters().put('edate', String.valueOf(Date.today()));
       SL_SeniorBankerScorecard_Report report = new SL_SeniorBankerScorecard_Report();
       Test.stopTest();
    }
    static testMethod void SL_SeniorBankerScorecard_Report3_coverage() 
    {
       Employee_Profile__c curBanker = createData();
    Test.startTest();
    ApexPages.currentPage().getParameters().put('filter', 'title' );
       ApexPages.currentPage().getParameters().put('subfilters', 'Senior Advisor;');
       ApexPages.currentPage().getParameters().put('sdate', String.valueOf(Date.today()-1));
       ApexPages.currentPage().getParameters().put('edate', String.valueOf(Date.today()));
       SL_SeniorBankerScorecard_Report report = new SL_SeniorBankerScorecard_Report();
       Test.stopTest();
    }
    static testMethod void SL_SeniorBankerScorecard_Report4_coverage() 
    {
       Employee_Profile__c curBanker = createData();
    Test.startTest();
       ApexPages.currentPage().getParameters().put('filter', 'location' );
       ApexPages.currentPage().getParameters().put('subfilters', 'Dubai');
       ApexPages.currentPage().getParameters().put('sdate', String.valueOf(Date.today()-1));
       ApexPages.currentPage().getParameters().put('edate', String.valueOf(Date.today()));
       SL_SeniorBankerScorecard_Report report = new SL_SeniorBankerScorecard_Report();
       Test.stopTest();
    }
}