/**
    * \arg ClassName      : SL_Test_TimeTracking_Ctrl
    * \arg JIRATicket     : PWP-188
    * \arg CreatedOn      : 21/August/2015
    * \arg LastModifiedOn : 03/Sep/2015
    * \arg CreatededBy    : Sandeep
    * \arg ModifiedBy     : Lodhi
    * \arg Description    : Test class for the SL_TimeTracking_Ctrl.
*/
@isTest
private class SL_Test_TimeTracking_Ctrl 
{
    static List<User> lstUser;
    // static List<Group> lstGroup;
    static List<GroupMember> lstGroupMember;
    static List<Project_Coverage_Team_Member__c> lstPCTM;
    static List<Opportunity> lstOpportunity;
    static List<Time_Card__c> lstTimeCard;
    
    private static void createData()
    {
        Id profileId  = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id;
		lstUser = new List<User>{
            new User(Alias = 'User1', Email='user1@user.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userTTTC-01@user.com'),
            new User(Alias = 'User2', Email='user2@user.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userTTTC-02@user.com'),
            new User(Alias = 'User3', Email='user3@user.com', EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userTTTC-03@user.com'),
            new User(Alias = 'User4', Email='user4@user.com', EmailEncodingKey='UTF-8', LastName='Testing4', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userTTTC-04@user.com'),
            new User(Alias = 'User5', Email='user5@user.com', EmailEncodingKey='UTF-8', LastName='Testing5', LanguageLocaleKey='en_US', 
			         LocaleSidKey='en_US', ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', UserName='userTTTC-05@user.com',
			         Coverage_Team_Role__c = 'Managing Director')
		};
    	insert lstUser;
        
        lstOpportunity = new List<Opportunity>{
            new Opportunity(Name = 'Opportunity-01', StageName = 'Prospective Mandate', CloseDate = Date.today().addDays(5)),
            new Opportunity(Name = 'Opportunity-01', StageName = 'Prospective Mandate', CloseDate = Date.today().addDays(5))
        };
        insert lstOpportunity;
        
        lstPCTM = new List<Project_Coverage_Team_Member__c>{
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[0].Id, User__c = UserInfo.getUserId()),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[0].Id, User__c = lstUser[0].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[0].Id, User__c = lstUser[4].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[1].Id, User__c = UserInfo.getUserId()),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[1].Id, User__c = lstUser[2].Id),
            new Project_Coverage_Team_Member__c(Project__c = lstOpportunity[1].Id, User__c = lstUser[4].Id)
        };
        insert lstPCTM;
        Date dtStart = Date.today().toStartofWeek();
        Date dtEnd = dtStart.addDays(6);
        lstTimeCard = new List<Time_Card__c>{
            new Time_Card__c(End_Date__c = dtEnd, Start_Date__c = dtStart, Worked_Hours__c = 5, 
                             Resource__c = UserInfo.getUserId(), Project__c = lstOpportunity[0].Id),
            new Time_Card__c(End_Date__c = dtEnd.addDays(-7), Start_Date__c = dtStart.addDays(-7), Worked_Hours__c = 5, 
                             Resource__c = lstUser[0].Id, Project__c = lstOpportunity[0].Id),
            new Time_Card__c(End_Date__c = dtEnd.addDays(-7), Start_Date__c = dtStart.addDays(-7), Worked_Hours__c = 5, 
                             Resource__c = lstUser[0].Id, Project__c = lstOpportunity[1].Id),                 
            new Time_Card__c(End_Date__c = dtEnd.addDays(-14), Start_Date__c = dtStart.addDays(-14), Worked_Hours__c = 5, 
                             Resource__c = lstUser[0].Id, Project__c = lstOpportunity[0].Id),
            new Time_Card__c(End_Date__c = dtEnd.addDays(-14), Start_Date__c = dtStart.addDays(-14), Worked_Hours__c = 5, 
                             Resource__c = lstUser[0].Id, Project__c = lstOpportunity[1].Id)                 
        };
        insert lstTimeCard;
    }
    
    private static testMethod void testTimeTracking() 
    {
        createData();
        SL_TimeTracking_Ctrl objTimeTracking = new SL_TimeTracking_Ctrl();
        objTimeTracking.addTimeEntryForCurrentWeek();
        system.assertEquals(objTimeTracking.lstWrapperTimeCard.size(), 2);//check list contain only one row
        
        objTimeTracking.idSelectedTimeCardId = lstTimeCard[0].Id;
        objTimeTracking.editTimeCardEntry();
        system.assertEquals(objTimeTracking.lstWrapperTimeCard[0].isEditable, true); // checking the row in editable mode
        
        objTimeTracking.idSelectedProject = lstOpportunity[0].Id;
        objTimeTracking.newTimeCardEntry();
        system.assertEquals(objTimeTracking.lstWrapperTimeCard.size(), 3); //check new row is added into wrapper list
        
        objTimeTracking.lstWrapperTimeCard[0].objTimeCard.Worked_Hours__c = 2;
        objTimeTracking.intIndexNo = 2;
        objTimeTracking.saveTimeCard();
        system.assert(objTimeTracking.lstWrapperTimeCard[1].objTimeCard.Id != null);//check newly created Time card
        
        objTimeTracking.nxtWeekTimeCard();
        objTimeTracking.prevWeekTimeCard();
        objTimeTracking.changeTimeIn();
    }
}