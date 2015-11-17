@isTest(seeAllData=True)
private class Meetings4_DashboardControllertest {
    static testMethod void testMeetings4_DashboardController() {    
    Account a = new Account(name='Test Deal Company');
    insert a;
    Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
    insert c;
    Deal__c d = new Deal__c(Related_Company__c=a.Id,Source_Name__c=c.id,Source_Company__c=a.id,Deal_Size_MM__c=5,Status__c='Early Investigation');
    insert d;
    Meeting__c m=new Meeting__c(End_Time__c=datetime.now(), Start_Time__c=datetime.now(), Location__c='nyo');
    insert m;
    Meeting_Agenda_Item__c meetobj=new Meeting_Agenda_Item__c(Deal__c=d.id,Meeting__c=m.Id, Name='test item',End_Time__c=datetime.now(), Start_Time__c=datetime.now());
    insert meetobj;    
    Meeting_Note__c n=new Meeting_Note__c(Agenda_Item__c=meetobj.Id, Vote__c='2', Quality_of_Materials__c='2', Would_Invest__c='yes', Note__c='test note', Is_Post_IC_Vote__c = true);
    insert n;          
    Meetings4_DashboardController controller = new Meetings4_DashboardController();  
    //controller.getCompanyVotes();    
    //***********************************
    Meetings4_DashboardController.getBaseURL(); //static method call
    //For wrapper class
    ApexPages.currentPage().getParameters().put('meetingId',m.id);
    
    Meetings4_DashboardController.CompanyVoteData compVote = new Meetings4_DashboardController.CompanyVoteData(a.Id, 1, 1);
    Meetings4_DashboardController.tableData tableDataObj = new Meetings4_DashboardController.tableData('Test', 1);
    
    Meetings4_DashboardController controllerObj = new Meetings4_DashboardController();   
    }
}