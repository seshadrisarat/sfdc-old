global with sharing class MeetingsController3 
{
    global class Material
    {
        public String URL;
        public String Title;
        
        public Material(String u, String t)
        {
            URL=u;
            Title=t;
        }
    }
    
    
    public MeetingsController3()
    {
 
    }
    
    public static String getBaseURL()
    {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }

    @RemoteAction
    global static List<Meeting__c> queryActiveMeetings()
    {
        return [SELECT Id,Name,Start_Time__c,End_Time__c,Location__c, RecordType.Name FROM Meeting__c ORDER BY Start_Time__c DESC];
    }
    
    @RemoteAction
    global static List<Meeting__c> queryActiveMeetingsByType(String strType)
    {
        return [SELECT Id,Name,Start_Time__c,End_Time__c,Location__c, RecordType.Name FROM Meeting__c WHERE RecordType.Name=:strType ORDER BY Start_Time__c DESC];
    }    
    
    @RemoteAction
    global static List<Meeting_Agenda_Item__c> queryAgenda(String strMeetingID)
    {
        return [SELECT Id,Name,RecordType.Name,Meeting__c, Start_Time__c, End_Time__c ,Deal__c, Deal__r.Name, Deal__r.Deal_Size_MM__c,Deal__r.MD_Principal_Members__c, Deal__r.Deal_Team_Members__c,Portfolio_Company__c,Deal__r.Related_Company__r.Name,Deal__r.Related_Company__r.RKCB__Logo__c,Related_Topic__c, Materials_submitted_on_time__c FROM Meeting_Agenda_Item__c WHERE Meeting__c=:strMeetingID ORDER BY Start_Time__c ASC]; 
    } 
    
    @RemoteAction
    global static Meeting_Note__c getNoteForAgendaItem(String strAID)
    {
        List<Meeting_Note__c > l=[SELECT Id, Name, Vote__c,Would_Invest__c, Materials_submitted_on_time__c, Quality_of_Materials__c, Note__c, Agenda_Item__c FROM Meeting_Note__c WHERE CreatedById=:UserInfo.getUserId() AND Agenda_Item__c=:strAID];
        
        if(l.size()>0) return l.get(0);
            
        return null;
    }
    
    @RemoteAction
    global static String saveNote(Meeting_Note__c note)
    {        
      if(note.Id==null)
        insert note;
      else
        update note;
        
      return note.Id; //(note.Id!=null);//note.Id+'/'+note.Meeting_Agenda_Item__c+'/'+note.Vote__c+'/'+note.Quality_of_Materials__c+'/'+note.Note__c;
    }
     
    @RemoteAction
    global static List<String> getVoteValues()
    {
        Schema.DescribeFieldResult fieldResult=Meeting_Note__c.Vote__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> lVals=new List<String>();
        
        for(Schema.PicklistEntry f : ple)
        {
          lVals.add(f.getValue());
        }
        
        return lVals;
    }
    
    
    @RemoteAction
    global static List<String> getWouldInvestValues()
    {
        Schema.DescribeFieldResult fieldResult=Meeting_Note__c.Would_Invest__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> lVals=new List<String>();
        
        for(Schema.PicklistEntry f : ple)
        {
          lVals.add(f.getValue());
        }
        
        return lVals;
    }    
    @RemoteAction
    global static List<String> getQualityOfMaterialsValues()
    {
        Schema.DescribeFieldResult fieldResult=Meeting_Note__c.Quality_of_Materials__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> lVals=new List<String>();
        
        for(Schema.PicklistEntry f : ple)
        {
          lVals.add(f.getValue());
        }
        
        return lVals;
    }   

    @RemoteAction
    global static List<RecordType> getMeetingTypes()
    {
      return [SELECT Id,Name,DeveloperName FROM RecordType WHERE isActive=true AND SobjectType='Meeting__c'];
    }

    @RemoteAction
    global static List<Material> getItemMaterialsURLs(String strAID)
    {
        List<Material> lMaterials=new List<Material>();
        List<Meeting_Agenda_Item__Feed> lAttachments=[SELECT Id, RelatedRecordId, ParentId, Title, ContentType FROM Meeting_Agenda_Item__Feed WHERE Type='ContentPost' AND ParentId=:strAID ORDER BY Title];
        
        for(Meeting_Agenda_Item__Feed a : lAttachments)
        {
            lMaterials.add(new Material(URL.getSalesforceBaseUrl().toExternalForm()+'/sfc/servlet.shepherd/version/download/'+a.RelatedRecordId ,a.Title));
        }  
          
        return lMaterials;
    }

    @RemoteAction
    global static List<Material> getAgendaMaterialsURLs(String strAID)
    {
        List<Material> lMaterials=new List<Material>();
        List<Meeting__Feed> lAttachments=[SELECT Id, RelatedRecordId, ParentId, Title, ContentType FROM Meeting__Feed WHERE Type='ContentPost' AND ParentId=:strAID ORDER BY Title];
        
        for(Meeting__Feed a : lAttachments)
        {
            lMaterials.add(new Material(URL.getSalesforceBaseUrl().toExternalForm()+'/sfc/servlet.shepherd/version/download/'+a.RelatedRecordId ,a.Title));
        }
          
        return lMaterials;
    }
    
    @RemoteAction 
    global static boolean isICAdmin()
    {
        GAPS_Settings__c settings=GAPS_Settings__c.getInstance();
        List<GroupMember> lGm=[select Id, GroupId,Group.Name, UserOrGroupId, SystemModstamp from GroupMember WHERE Group.Name=:settings.IC_Group__c AND UserOrGroupId=:UserInfo.getUserId()];
        return (lGm.size()>0);
    }
 
    @RemoteAction 
    global static List<AggregateResult> getMeetingNotesEnteredStats(String strAID)
    {
        return [select COUNT(Id) NumVotes, AVG(Numeric_Vote_Value__c) AvgVote, AVG(Numeric_Quality_of_Materials_Value__c) AvgQoM,AVG(Numeric_Would_Invest_Value__c) AVGWI from Meeting_Note__c WHERE Agenda_Item__c=:strAID];
    }

    @RemoteAction 
    global static List<Meeting_Note__c> getMeetingNotesEntered(String strAID)
    {
        return [SELECT Id, Owner.Name, Name, Note__c, Quality_of_Materials__c, Vote__c, Materials_submitted_on_time__c, Agenda_Item__c, Would_Invest__c FROM Meeting_Note__c WHERE Agenda_Item__c=:strAID ORDER BY Owner.LastName ASC];
    }
    
    @RemoteAction 
    global static List<Account> getCompanyDetails(String strAID)
    {
        return [SELECT Id, Name, RKCB__Logo__c,RKCB__Founded_Date__c, Incorporation_Date__c, Last_Activity_Date__c, Next_Steps__c, Latest_Status_Note__c, Latest_Status_Note_Subject__c, Owner__r.Name, SecondaryOwner__r.Name, Industry, Sector__c, Sub_Sector__c, Themes__c, Status__c, IC_Prospect_Phase__c, Code_Name__c, Website, Description, Latest_Financials_Year__c, Latest_Revenue__c,Projected_Financials_Year__c, Projected_Revenue__c FROM Account WHERE Id=:strAID ];
    }    
       
    static testMethod void test()
    {
        RecordType r=[SELECT Id FROM RecordType WHERE DeveloperName='General' LIMIT 1];
        MeetingsController m=new MeetingsController();
        MeetingsController.getBaseUrl();
        MeetingsController.queryActiveMeetings();
        
        Meeting__c meeting = new Meeting__c(Start_Time__c = System.now(), End_Time__c = System.now(), Location__c = 'Somewhere', RecordTypeId=r.Id);
        insert meeting;
        MeetingsController.queryAgenda(meeting.Id);
        MeetingsController.queryActiveMeetingsByType(r.Id);
        
        Meeting_Agenda_Item__c agendaItem = new Meeting_Agenda_Item__c(Meeting__c = meeting.Id);
        insert agendaItem;
        MeetingsController.getNoteForAgendaItem(agendaItem.Id);
        
        FeedItem f=new FeedItem(ParentId = agendaItem.Id, Type='ContentPost', ContentFileName = 'a file',ContentData = blob.valueOf('my attachment text'));
        insert f;
        f=new FeedItem(ParentId = meeting.Id, Type='ContentPost', ContentFileName = 'another file',ContentData = blob.valueOf('my attachment text'));
        insert f;
        
        MeetingsController.Material material=new MeetingsController.Material('string','string');
        
        Meeting_Note__c note = new Meeting_Note__c(Agenda_Item__c=agendaItem.Id);
        MeetingsController.saveNote(note);
        MeetingsController.saveNote(note);
        MeetingsController.getVoteValues();
        MeetingsController.getWouldInvestValues();
        MeetingsController.getQualityOfMaterialsValues();
        MeetingsController.getMeetingTypes();
        MeetingsController.getItemMaterialsURLs(agendaItem.Id);
        MeetingsController.getAgendaMaterialsURLs(agendaItem.Id);
        MeetingsController.isICAdmin();
        MeetingsController.getMeetingNotesEnteredStats(agendaItem.Id);
        MeetingsController.getMeetingNotesEntered(agendaItem.Id);
    }
}