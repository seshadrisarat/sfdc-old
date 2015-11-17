@isTest
private class Test_Meetings4_Votes_Review_PDF{

    @isTest
    static void Meetings4_Votes_Review_PDF(){
 
        //create test data
    Meeting__c meeting = new Meeting__c(Start_Time__c = System.now(), End_Time__c = System.now(), Location__c = 'Somewhere');
    insert meeting;
    
    Account acc = new Account(Name = 'Test Account Name'+String.valueOf(System.Now()));
    insert acc;
    
    Deal__c deal = new Deal__c(Name = 'Test Account Name'+String.valueOf(System.Now()), Related_Company__c = acc.Id);
        insert deal;
        
    Meeting_Agenda_Item__c agendaItem = new Meeting_Agenda_Item__c(Meeting__c = meeting.Id, Deal__c = deal.Id);
    insert agendaItem;
    
    Meeting_Note__c mtngNote = new Meeting_Note__c(Agenda_Item__c = agendaItem.Id, Is_Post_IC_Vote__c = true, Vote__c = '3', OwnerId= UserInfo.getUserId());
    insert mtngNote;    
    
    Test.setCurrentPage(Page.Meetings4_Votes_Review_PDF);
    ApexPages.currentPage().getParameters().put('meetingId',meeting.Id);
    ApexPages.currentPage().getParameters().put('isMyVotes','true');
    Meetings4_Votes_Review_PDF_Controller mtngCont = new Meetings4_Votes_Review_PDF_Controller();
    
    ApexPages.currentPage().getParameters().put('isMyVotes','false');
    ApexPages.currentPage().getParameters().put('reportType','Full');
    mtngCont = new Meetings4_Votes_Review_PDF_Controller();
    
    ApexPages.currentPage().getParameters().put('reportType','Initial');
    mtngCont = new Meetings4_Votes_Review_PDF_Controller();
    
    ApexPages.currentPage().getParameters().put('reportType','Post');
    mtngCont = new Meetings4_Votes_Review_PDF_Controller();     
    }   
}