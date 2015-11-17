/**************************************************************************************************
Name : Meetings4_Votes_Review_PDF_Controller
Related VF Page: Meetings4_Votes_Review_PDF
Created Date : 7/25/2013 [Hemant]
Desc : Functionality to email the Vote review screen as PDF attachment using the VF Page "Meetings4_Votes_Review_PDF"
**************************************************************************************************/     
global with sharing class Meetings4_Votes_Review_PDF_Controller {

  private static final String PDF_HEADER_FULL = 'Final IC Review (all votes)';
  private static final String PDF_HEADER_INITIAL = 'Initial Votes IC Review';
  private static final String PDF_HEADER_POST = 'Post IC Votes Review';
  //LSLEVIN Case 56574 11.4.2013 START
 // private static final String PDF_HEADER_MY_VOTES = 'Votes for ' + UserInfo.getFirstName() + ' ' + UserInfo.getFirstName() + ' on ' + String.valueOf(Date.today());
    private static final String PDF_HEADER_MY_VOTES = 'Votes for ' + (UserInfo.getFirstName() == null ? '': UserInfo.getFirstName()+ ' ')  + UserInfo.getLastName() + ' on ' + String.valueOf(Date.today());
  //LSLEVIN Case 56574 11.4.2013 END 
  
  public static List<Meeting_Agenda_Item__c> meetingAgendaLst{get;set;}
  public static Map<Id,List<MeetingsController4.MeetingNotePhotoURL>> mtngAIMNotesPhotoURLMap{get;set;}
  String meetingId;
  String reportType;
  String isMyVotes;
  public static String pdfHeader{get;set;}  
    
  //constructor
  public Meetings4_Votes_Review_PDF_Controller(){
    isMyVotes = '';
    meetingAgendaLst = new List<Meeting_Agenda_Item__c>();
    mtngAIMNotesPhotoURLMap = new Map<Id,List<MeetingsController4.MeetingNotePhotoURL>>();
    meetingId = ApexPages.currentPage().getParameters().get('meetingId');
    reportType = ApexPages.currentPage().getParameters().get('reportType');
    isMyVotes = ApexPages.currentPage().getParameters().get('isMyVotes');
    
    pdfHeader = 'Final IC Review';
    
    if(meetingId != null && meetingId != ''){
        initPDFPgData(meetingId, reportType, isMyVotes);
    }
  }
  
  //method to populate the pdf page data from the meeting
    public static void initPDFPgData(String strMeetingID, String strReportType, String isMyVotesStr){
        
         //For my votes
          if(isMyVotesStr == 'true'){
            //get agenda items for the meeting
            meetingAgendaLst = [SELECT Id,Name,RecordType.Name,Meeting__c, Start_Time__c, End_Time__c ,Deal__c, Deal__r.Name, Deal__r.Deal_Size_MM__c,Deal__r.MD_Principal_Members__c, Deal__r.Deal_Team_Members__c,Portfolio_Company__c,Deal__r.Related_Company__r.Name,Deal__r.Related_Company__r.RKCB__Logo__c,Related_Topic__c, Materials_submitted_on_time__c,
                                                                                                            (SELECT Id, OwnerId, Is_Post_IC_Vote__c, Owner.Name, Name, Note__c, Quality_of_Materials__c, Vote__c, Materials_submitted_on_time__c, Agenda_Item__c, Would_Invest__c 
                                                                                                                FROM Meeting_Notes__r
                                                                                                                where OwnerId =: UserInfo.getUserId()
                                                                                                                order BY Is_Post_IC_Vote__c ASC , Owner.FirstName ASC)            
                                                                                                            FROM Meeting_Agenda_Item__c 
                                                                                                            WHERE Meeting__c=:strMeetingID AND Deal__c != null AND Deal__r.Related_Company__c != null 
                                                                                                            order BY Start_Time__c ASC];
          pdfHeader = PDF_HEADER_MY_VOTES;
          }
        else if(strReportType == 'Full'){
            //get agenda items for the meeting
            meetingAgendaLst = [SELECT Id,Name,RecordType.Name,Meeting__c, Start_Time__c, End_Time__c ,Deal__c, Deal__r.Name, Deal__r.Deal_Size_MM__c,Deal__r.MD_Principal_Members__c, Deal__r.Deal_Team_Members__c,Portfolio_Company__c,Deal__r.Related_Company__r.Name,Deal__r.Related_Company__r.RKCB__Logo__c,Related_Topic__c, Materials_submitted_on_time__c,
                                                                                                                (SELECT Id, OwnerId, Is_Post_IC_Vote__c, Owner.Name, Name, Note__c, Quality_of_Materials__c, Vote__c, Materials_submitted_on_time__c, Agenda_Item__c, Would_Invest__c FROM Meeting_Notes__r order BY Is_Post_IC_Vote__c ASC , Owner.FirstName ASC)            
                                                                                                            FROM Meeting_Agenda_Item__c 
                                                                                                            WHERE Meeting__c=:strMeetingID AND Deal__c != null AND Deal__r.Related_Company__c != null 
                                                                                                            order BY Start_Time__c ASC];
          pdfHeader = PDF_HEADER_FULL;
        }
        else if(strReportType == 'Initial'){
            //get agenda items for the meeting
            meetingAgendaLst = [SELECT Id,Name,RecordType.Name,Meeting__c, Start_Time__c, End_Time__c ,Deal__c, Deal__r.Name, Deal__r.Deal_Size_MM__c,Deal__r.MD_Principal_Members__c, Deal__r.Deal_Team_Members__c,Portfolio_Company__c,Deal__r.Related_Company__r.Name,Deal__r.Related_Company__r.RKCB__Logo__c,Related_Topic__c, Materials_submitted_on_time__c,
                                                                                                                (SELECT Id, OwnerId, Is_Post_IC_Vote__c, Owner.Name, Name, Note__c, Quality_of_Materials__c, Vote__c, Materials_submitted_on_time__c, Agenda_Item__c, Would_Invest__c FROM Meeting_Notes__r where Is_Post_IC_Vote__c = false 
                                                                                                                order BY Owner.FirstName ASC)            
                                                                                                            FROM Meeting_Agenda_Item__c 
                                                                                                            WHERE Meeting__c=:strMeetingID AND Deal__c != null AND Deal__r.Related_Company__c != null 
                                                                                                            order BY Start_Time__c ASC];
          pdfHeader = PDF_HEADER_INITIAL;
        }
        else if(strReportType == 'Post'){
            //get agenda items for the meeting
            meetingAgendaLst = [SELECT Id,Name,RecordType.Name,Meeting__c, Start_Time__c, End_Time__c ,Deal__c, Deal__r.Name, Deal__r.Deal_Size_MM__c,Deal__r.MD_Principal_Members__c, Deal__r.Deal_Team_Members__c,Portfolio_Company__c,Deal__r.Related_Company__r.Name,Deal__r.Related_Company__r.RKCB__Logo__c,Related_Topic__c, Materials_submitted_on_time__c,
                                                                                                                (SELECT Id, OwnerId, Is_Post_IC_Vote__c, Owner.Name, Name, Note__c, Quality_of_Materials__c, Vote__c, Materials_submitted_on_time__c, Agenda_Item__c, Would_Invest__c FROM Meeting_Notes__r where Is_Post_IC_Vote__c = true 
                                                                                                                order BY Owner.FirstName ASC)            
                                                                                                            FROM Meeting_Agenda_Item__c 
                                                                                                            WHERE Meeting__c=:strMeetingID AND Deal__c != null AND Deal__r.Related_Company__c != null 
                                                                                                            order BY Start_Time__c ASC];
          pdfHeader = PDF_HEADER_POST;
        }
        mtngAIMNotesPhotoURLMap = new Map<Id,List<MeetingsController4.MeetingNotePhotoURL>>();
        Set<Id> userIdSet = new Set<Id>();
        for(Meeting_Agenda_Item__c mai : meetingAgendaLst){                                                                                                 
            for(Meeting_Note__c m : mai.Meeting_Notes__r){
            if(m.OwnerId != null && String.valueOf(m.OwnerId).startsWith('005')){
                userIdSet.add(m.OwnerId);
            }
        }
        }
      
      //Committee: Investment group for IC Member list
      Set<Id> ICMemberIdSet = new Set<Id>();
      GAPS_Settings__c settings1=GAPS_Settings__c.getInstance();        
      for(GroupMember gm : [select Id, GroupId,Group.Name, UserOrGroupId, SystemModstamp from GroupMember WHERE Group.Name=:settings1.Post_IC_Voting_Group__c AND UserOrGroupId IN : userIdSet]){
        ICMemberIdSet.add(gm.UserOrGroupId);
      }
      
      Map<Id, User> userMap = new Map<Id, User>([SELECT Id, SmallPhotoUrl from User where Id IN: userIdSet]);
        
        for(Meeting_Agenda_Item__c mai : meetingAgendaLst){
            List<MeetingsController4.MeetingNotePhotoURL> mnUrlLst = new List<MeetingsController4.MeetingNotePhotoURL>();
            List<MeetingsController4.MeetingNotePhotoURL> ICMembermnUrlLst = new List<MeetingsController4.MeetingNotePhotoURL>();
            List<MeetingsController4.MeetingNotePhotoURL> NonICMembermnUrlLst = new List<MeetingsController4.MeetingNotePhotoURL>();
        
            for(Meeting_Note__c m : mai.Meeting_Notes__r){
                MeetingsController4.MeetingNotePhotoURL mnp;
                if(userMap.containsKey(m.OwnerId)){
                    mnp = new MeetingsController4.MeetingNotePhotoURL(m,userMap.get(m.OwnerId).SmallPhotoUrl);
                }else{
                    String genUrl = URL.getSalesforceBaseUrl().toExternalForm()+ '/img/social/unknown_profile_pic.png';
                    mnp = new MeetingsController4.MeetingNotePhotoURL(m,genUrl);
                }
                
                //IC member users notes
                if(ICMemberIdSet.contains(m.OwnerId)){
                    ICMembermnUrlLst.add(mnp);
                }
                //Non IC member users notes
                else{
                    NonICMembermnUrlLst.add(mnp);
                }
            }
            //adding first IC member users notes and then Non-IC member users notes
        mnUrlLst.addAll(ICMembermnUrlLst);
        mnUrlLst.addAll(NonICMembermnUrlLst);
            mtngAIMNotesPhotoURLMap.put(mai.Id, mnUrlLst);
        }                                                                                                    
    }
}