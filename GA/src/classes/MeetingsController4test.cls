@isTest(seeAllData=true)
private class MeetingsController4test {
static testMethod void MeetingsController4_test()
    {
        RecordType r=[SELECT Id FROM RecordType WHERE DeveloperName='General' LIMIT 1];
        MeetingsController4 m=new MeetingsController4();
        MeetingsController4.getBaseUrl();
        MeetingsController4.queryActiveMeetings(false);
        
        Meeting__c meeting = new Meeting__c(Start_Time__c = System.now(), End_Time__c = System.now(), Location__c = 'Somewhere', RecordTypeId=r.Id);
        insert meeting;
        MeetingsController4.queryAgenda(meeting.Id);
        MeetingsController4.queryActiveMeetingsByType(r.Id, false);
        
        Meeting_Agenda_Item__c agendaItem = new Meeting_Agenda_Item__c(Meeting__c = meeting.Id);
        insert agendaItem;
        
        Meeting_Note__c mtngNote = new Meeting_Note__c(Agenda_Item__c = agendaItem.Id, Is_Post_IC_Vote__c = true, Vote__c = '3', OwnerId= UserInfo.getUserId());
        insert mtngNote; 
        MeetingsController4.getNoteForAgendaItem(agendaItem.Id,false);
        
        FeedItem f=new FeedItem(ParentId = agendaItem.Id, Type='ContentPost', ContentFileName = 'a file',ContentData = blob.valueOf('my attachment text'));
        insert f;
        f=new FeedItem(ParentId = meeting.Id, Type='ContentPost', ContentFileName = 'another file',ContentData = blob.valueOf('my attachment text'));
        insert f;
        
        Account acc = new Account(Name = 'Test Account Name'+String.valueOf(System.Now()));
        insert acc;
        
        //insert CS Post_IC_Review_Email_Settings__c
        Post_IC_Review_Email_Settings__c postICEmail = new Post_IC_Review_Email_Settings__c(
                                                                                Name = 'test PIRES1', To_Address__c = 'test1@testing.com;test2@testing.com;',
                                                                                CC_Address__c = 'test3@testing.com;test4@testing.com;',
                                                                                Subject__c = 'test subject', Body__c = 'test body');
        insert postICEmail;                                                                     
        
        MeetingsController4.Material material=new MeetingsController4.Material('string','string');
        
        Meeting_Note__c note = new Meeting_Note__c(Agenda_Item__c = agendaItem.Id, Is_Post_IC_Vote__c = true, Vote__c = '3', OwnerId= UserInfo.getUserId());
        
        MeetingsController4.saveNote(note);
        MeetingsController4.getVoteValues();
        MeetingsController4.getWouldInvestValues();
        MeetingsController4.getQualityOfMaterialsValues();
        MeetingsController4.getMeetingTypes();
        MeetingsController4.getItemMaterialsURLs(agendaItem.Id);
        MeetingsController4.getAgendaMaterialsURLs(agendaItem.Id);
        MeetingsController4.isICAdmin();
        MeetingsController4.getMeetingNotesEnteredStats(agendaItem.Id);
        MeetingsController4.getMeetingNotesEntered(agendaItem.Id);
        
        MeetingsController4.getCompanyDetails(acc.Id);
        MeetingsController4.saveMeetingNotes(new List<Meeting_Note__c>{mtngNote});
        MeetingsController4.getMeetingNotesWithPhotoURL(agendaItem.Id,'');
        MeetingsController4.getMeetingNotesWithPhotoURL(agendaItem.Id,UserInfo.getUserId());
        MeetingsController4.IsFinalICReview();
        MeetingsController4.IsPostICVoting();
        MeetingsController4.sendEMailWithPDF(meeting.Id, 'Full', false, false);
        
        MeetingsController4.getNoteForAgendaItemForOwner(agendaItem.Id, true, 'none');
        MeetingsController4.getUserValues();
        MeetingsController4.IsVoteOnOthersBehalf();
        MeetingsController4.getMeetingNotesWithPhotoURL_Dashboard(agendaItem.Id);
    }
}