@isTest
public class MeetingsController3Test
{
    static testMethod void test()
    {
        RecordType r=[SELECT Id FROM RecordType WHERE DeveloperName='General' LIMIT 1];
        MeetingsController3 m=new MeetingsController3();
        MeetingsController3.getBaseUrl();
        MeetingsController3.queryActiveMeetings();
        
        Meeting__c meeting = new Meeting__c(Start_Time__c = System.now(), End_Time__c = System.now(), Location__c = 'Somewhere', RecordTypeId=r.Id);
        insert meeting;
        MeetingsController3.queryAgenda(meeting.Id);
        MeetingsController3.queryActiveMeetingsByType(r.Id);
        
        Meeting_Agenda_Item__c agendaItem = new Meeting_Agenda_Item__c(Meeting__c = meeting.Id);
        insert agendaItem;
        MeetingsController3.getNoteForAgendaItem(agendaItem.Id);
        
        FeedItem f=new FeedItem(ParentId = agendaItem.Id, Type='ContentPost', ContentFileName = 'a file',ContentData = blob.valueOf('my attachment text'));
        insert f;
        f=new FeedItem(ParentId = meeting.Id, Type='ContentPost', ContentFileName = 'another file',ContentData = blob.valueOf('my attachment text'));
        insert f;
        
        MeetingsController3.Material material=new MeetingsController3.Material('string','string');
        
        Meeting_Note__c note = new Meeting_Note__c(Agenda_Item__c=agendaItem.Id);
        MeetingsController3.saveNote(note);
        MeetingsController3.saveNote(note);
        MeetingsController3.getVoteValues();
        MeetingsController3.getWouldInvestValues();
        MeetingsController3.getQualityOfMaterialsValues();
        MeetingsController3.getMeetingTypes();
        MeetingsController3.getItemMaterialsURLs(agendaItem.Id);
        MeetingsController3.getAgendaMaterialsURLs(agendaItem.Id);
        MeetingsController3.isICAdmin();
        MeetingsController3.getMeetingNotesEnteredStats(agendaItem.Id);
        MeetingsController3.getMeetingNotesEntered(agendaItem.Id);
    }
}