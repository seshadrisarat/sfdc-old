/**************************************************************************************************
Name : MeetingsController4
Related VF Page: Meetings4
Modified : Added the following Pages for Story # S-123652 [7/9/2013] Hemant
                        1. Post IC Voting (only visible for IC members (Public Group"Committe:Investment" Users) + Frank Brown + Steve Dening)
                        2. Final IC Review (only visible to "Mark Dzialgaand and Drew Pearson" users)
                        3. Added the functionality to email the Vote review as PDF [Story # 132864]
**************************************************************************************************/                     
global with sharing class MeetingsController4 
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
    
    public MeetingsController4()
    {
    }
    
    public static String getBaseURL()
    {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    @RemoteAction
    global static List<Meeting__c> queryActiveMeetings(Boolean isShowMore)
    {
        if(isShowMore)
            return [SELECT Id,Name,Start_Time__c,End_Time__c,Location__c, RecordType.Name FROM Meeting__c ORDER BY Start_Time__c DESC];
        else 
            return [SELECT Id,Name,Start_Time__c,End_Time__c,Location__c, RecordType.Name FROM Meeting__c ORDER BY Start_Time__c DESC Limit 2];
    }
    
    @RemoteAction
    global static List<Meeting__c> queryActiveMeetingsByType(String strType,Boolean isShowMore)
    {   
        if(isShowMore)
            return [SELECT Id,Name,Start_Time__c,End_Time__c,Location__c, RecordType.Name FROM Meeting__c WHERE RecordType.Name=:strType ORDER BY Start_Time__c DESC];
        else
            return [SELECT Id,Name,Start_Time__c,End_Time__c,Location__c, RecordType.Name FROM Meeting__c WHERE RecordType.Name=:strType ORDER BY Start_Time__c DESC Limit 2];  
    }    
    
    @RemoteAction
    global static List<Meeting_Agenda_Item__c> queryAgenda(String strMeetingID)
    {
        return [SELECT Id,Name,RecordType.Name,Meeting__c, Start_Time__c, End_Time__c ,Deal__c, Deal__r.Name, Deal__r.Deal_Size_MM__c,Deal__r.MD_Principal_Members__c, Deal__r.Deal_Team_Members__c,Portfolio_Company__c,Deal__r.Related_Company__r.Name,Deal__r.Related_Company__r.RKCB__Logo__c,Related_Topic__c, Materials_submitted_on_time__c FROM Meeting_Agenda_Item__c WHERE Meeting__c=:strMeetingID ORDER BY Start_Time__c ASC]; 
    } 
    
    @RemoteAction
    global static Meeting_Note__c getNoteForAgendaItem(String strAID, Boolean isPostICVote)
    {
        //Story # S-123652
        //List<Meeting_Note__c > l=[SELECT Id, Name, Vote__c,Would_Invest__c, Materials_submitted_on_time__c, Quality_of_Materials__c, Note__c, Agenda_Item__c FROM Meeting_Note__c WHERE CreatedById=:UserInfo.getUserId() AND Agenda_Item__c=:strAID];
        //List<Meeting_Note__c > l=[SELECT Id, Name, OwnerId,Vote__c,Would_Invest__c, Materials_submitted_on_time__c, Quality_of_Materials__c, Note__c, Agenda_Item__c FROM Meeting_Note__c WHERE CreatedById=:UserInfo.getUserId() AND ownerId=:UserInfo.getUserId()  AND Agenda_Item__c=:strAID AND Is_Post_IC_Vote__c =: isPostICVote order BY LastModifiedDate Desc];
        List<Meeting_Note__c > l=[SELECT Id, Name, OwnerId,Vote__c,Would_Invest__c, Materials_submitted_on_time__c, Quality_of_Materials__c, Note__c, Agenda_Item__c FROM Meeting_Note__c WHERE ownerId=:UserInfo.getUserId()  AND Agenda_Item__c=:strAID AND Is_Post_IC_Vote__c =: isPostICVote order BY LastModifiedDate Desc];
        
        if(l.size()>0) return l.get(0);
            
        return null;
    }
    
    @RemoteAction
    global static Meeting_Note__c getNoteForAgendaItemForOwner(String strAID, Boolean isPostICVote, String ownId)
    {
        //Story # S-135394
        
        if(ownId == 'none'){
            ownId = UserInfo.getUserId();
        }
        
        //List<Meeting_Note__c > l=[SELECT Id, Name, OwnerId,Vote__c,Would_Invest__c, Materials_submitted_on_time__c, Quality_of_Materials__c, Note__c, Agenda_Item__c FROM Meeting_Note__c WHERE CreatedById=:UserInfo.getUserId() AND ownerId=: ownId  AND Agenda_Item__c=:strAID AND Is_Post_IC_Vote__c =: isPostICVote order BY LastModifiedDate Desc];
        List<Meeting_Note__c > l=[SELECT Id, Name, OwnerId,Vote__c,Would_Invest__c, Materials_submitted_on_time__c, Quality_of_Materials__c, Note__c, Agenda_Item__c FROM Meeting_Note__c WHERE ownerId=: ownId  AND Agenda_Item__c=:strAID AND Is_Post_IC_Vote__c =: isPostICVote order BY LastModifiedDate Desc];
        
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
    // Added by Jyoti Singh for S-132864
    @RemoteAction
    global static List<String> getUserValues()
    {
        Set<Id> userIds = new Set<Id>();     
        GAPS_Settings__c settings1=GAPS_Settings__c.getInstance();        
        List<GroupMember> lGm=[select Id, GroupId,Group.Name, UserOrGroupId,SystemModstamp from GroupMember WHERE Group.Name=:settings1.Vote_On_User_Behalf_Group__c] ;
         
        for(GroupMember gm: lGm){
            userIds.add(gm.UserOrGroupId);
        }   
        List<User> userList = [Select Id, Name from User where Id in : userIds];
        
        List<String> lVals=new List<String>();
        
        for(User u: userList)
        {
            if(u.ID != UserInfo.getUserId()){
                lVals.add(u.ID+';'+u.Name);
            }
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
    global static List<Material> getHistoricalItemMaterialsURLs(String strAID)
    {
        List<Material> lMaterials=new List<Material>();
        Id orgMid = strAID;
        Id dealId;
        Set<Id> mIds = new Set<Id>();

        Meeting_Agenda_Item__c m = [Select Id,Deal__c From Meeting_Agenda_Item__c WHERE Id =: strAID];

        dealId = m.Deal__c;

        Deal__c deal = [Select Id,(Select Id From Meeting_Agenda_Items__r) From Deal__c WHERE Id =: dealId];

        if(deal.Meeting_Agenda_Items__r != null && !deal.Meeting_Agenda_Items__r.isEmpty())
        {
            for(Meeting_Agenda_Item__c ma : deal.Meeting_Agenda_Items__r)
            {
                if(ma.Id != orgMid)
                {
                    mIds.add(ma.Id);
                }
            }
        }


        List<Meeting_Agenda_Item__Feed> lAttachments=[SELECT Id, RelatedRecordId, ParentId, Title, ContentType FROM Meeting_Agenda_Item__Feed WHERE Type='ContentPost' AND ParentId IN: mIds ORDER BY Title];
        
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
        //Story # S-123652
        //return [select COUNT(Id) NumVotes, AVG(Numeric_Vote_Value__c) AvgVote, AVG(Numeric_Quality_of_Materials_Value__c) AvgQoM,AVG(Numeric_Would_Invest_Value__c) AVGWI from Meeting_Note__c WHERE Agenda_Item__c=:strAID];
        return [select COUNT(Id) NumVotes, AVG(Numeric_Vote_Value__c) AvgVote, AVG(Numeric_Quality_of_Materials_Value__c) AvgQoM,AVG(Numeric_Would_Invest_Value__c) AVGWI from Meeting_Note__c WHERE Agenda_Item__c=:strAID AND Is_Post_IC_Vote__c = false];
    }

    @RemoteAction 
    global static List<Meeting_Note__c> getMeetingNotesEntered(String strAID)
    {
        //Story # S-123652
        //return [SELECT Id, Owner.Name, Name, Note__c, Quality_of_Materials__c, Vote__c, Materials_submitted_on_time__c, Agenda_Item__c, Would_Invest__c FROM Meeting_Note__c WHERE Agenda_Item__c=:strAID ORDER BY Owner.LastName ASC];
        return [SELECT Id, Owner.Name, Name, Note__c, Quality_of_Materials__c, Vote__c, Materials_submitted_on_time__c, Agenda_Item__c, Would_Invest__c FROM Meeting_Note__c WHERE Agenda_Item__c=:strAID AND Is_Post_IC_Vote__c = false ORDER BY Owner.LastName ASC];
    }
    
    @RemoteAction 
    global static List<Account> getCompanyDetails(String strAID)
    {
        return [SELECT Id, Name, RKCB__Logo__c,RKCB__Founded_Date__c, Incorporation_Date__c, Last_Activity_Date__c, Next_Steps__c, Latest_Status_Note__c, Latest_Status_Note_Subject__c, Owner__r.Name, SecondaryOwner__r.Name, Industry, Sector__c, Sub_Sector__c, Themes__c, Status__c, IC_Prospect_Phase__c, Code_Name__c, Website, Description, Latest_Financials_Year__c, Latest_Revenue__c,Projected_Financials_Year__c, Projected_Revenue__c FROM Account WHERE Id=:strAID ];
    }
    
    //Story # S-123652 Start
    // Save the meeting notes list
    @RemoteAction
    global static List<Meeting_Note__c> saveMeetingNotes(List<Meeting_Note__c> notesLst)
    {        
      if(notesLst != null && notesLst.size() > 0){
        upsert notesLst;
      }
      return notesLst;
    }
    
    //method to return the listof Wrapper class - MeetingNotePhotoURL for the Meeting Notes along with Small Photo of the owner
    @RemoteAction 
    global static List<MeetingNotePhotoURL> getMeetingNotesWithPhotoURL(String strAID, String voteOwnerId)
    {
        List<MeetingNotePhotoURL> mnUrlLst = new List<MeetingNotePhotoURL>();
        List<Meeting_Note__c> mtngNoteLst = new List<Meeting_Note__c>();
        if(voteOwnerId != null && voteOwnerId != ''){
            mtngNoteLst = [SELECT Id, OwnerId, Is_Post_IC_Vote__c, Owner.Name, Name, Note__c, Quality_of_Materials__c, Vote__c, Materials_submitted_on_time__c, Agenda_Item__c, Would_Invest__c 
                            FROM Meeting_Note__c
                            WHERE Agenda_Item__c=:strAID AND OwnerId = :voteOwnerId 
                            order BY Owner.FirstName Asc, Is_Post_IC_Vote__c Asc, LastModifiedDate Desc];
        }else{
            mtngNoteLst = [SELECT Id, OwnerId, Is_Post_IC_Vote__c, Owner.Name, Name, Note__c, Quality_of_Materials__c, Vote__c, Materials_submitted_on_time__c, Agenda_Item__c, Would_Invest__c FROM Meeting_Note__c WHERE Agenda_Item__c=:strAID order BY Owner.FirstName Asc, Is_Post_IC_Vote__c Asc, LastModifiedDate Desc];
        }
        //List<Meeting_Note__c> 
        List<Meeting_Note__c> mtngNoteLstToAdd = new List<Meeting_Note__c>();

        if(mtngNoteLst.size() > 0){
            Set<Id> userIdSet = new Set<Id>();
            //
            Set<Id> initialVoteOwnerIdSet = new Set<Id>();
            Set<Id> postVoteOwnerIdSet = new Set<Id>(); 
            
            for(Meeting_Note__c m : mtngNoteLst){
                if(m.OwnerId != null && String.valueOf(m.OwnerId).startsWith('005')){
                    userIdSet.add(m.OwnerId);
                }
                
                if(m.Is_Post_IC_Vote__c){
                     if(!postVoteOwnerIdSet.contains(m.OwnerId)){
                        postVoteOwnerIdSet.add(m.OwnerId);
                        mtngNoteLstToAdd.add(m);
                     }
                }else{
                    if(!initialVoteOwnerIdSet.contains(m.OwnerId)){
                        initialVoteOwnerIdSet.add(m.OwnerId);
                        mtngNoteLstToAdd.add(m);
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
            List<MeetingNotePhotoURL> ICMembermnUrlLst = new List<MeetingNotePhotoURL>();
            List<MeetingNotePhotoURL> NonICMembermnUrlLst = new List<MeetingNotePhotoURL>();
            
            for(Meeting_Note__c m : mtngNoteLstToAdd){
                MeetingNotePhotoURL mnp;
                if(userMap.containsKey(m.OwnerId)){
                    mnp = new MeetingNotePhotoURL(m,userMap.get(m.OwnerId).SmallPhotoUrl);
                }else{
                    String genUrl = URL.getSalesforceBaseUrl().toExternalForm()+ '/img/social/unknown_profile_pic.png';
                    mnp = new MeetingNotePhotoURL(m,genUrl);
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
        }
        return mnUrlLst;
    }
    
    //Wrapper class - MeetingNotePhotoURL to hold the Meeting Notes along with Small Photo URL of the owner
    global class MeetingNotePhotoURL
    {
        public Meeting_Note__c mtngNote{get;set;}
        public String userUrl{get;set;}
        
        public MeetingNotePhotoURL(Meeting_Note__c m, String u)
        {
            mtngNote = m;
            userUrl = u;
        }
    }
    
    //method to return boolean value if the User is allowed to see the Final IC Review link
    //Final IC Review (only visible to "Mark Dzialgaand and Drew Pearson" users)
    // hemant [8/19/2013]- created new public group "Meetings App: IC Final Review" such that users of thsi group will be able to see Final IC Review Link
    @RemoteAction 
    global static boolean IsFinalICReview()
    {
      final string FINAL_IC_REVIEW_PUBLIC_GROUP = 'Meetings App: IC Final Review';
        Id currUser = UserInfo.getUserId();
        
        List<GroupMember> lGm = [select Id, GroupId,Group.Name, UserOrGroupId, SystemModstamp from GroupMember WHERE Group.Name =: FINAL_IC_REVIEW_PUBLIC_GROUP AND UserOrGroupId=:currUser];
      return (lGm.size()>0);
    }
    
    //method to return boolean value if the User is allowed to see the Post IC Voting link
    //Post IC Voting (only visible for IC members (Public Group"Committe:Investment" Users) + Frank Brown + Steve Dening)
    @RemoteAction 
    global static boolean IsPostICVoting()
    {
        final string POST_IC_VOTING = 'Post IC voting';
        boolean isTrue = false ;
        Id currUser = UserInfo.getUserId();
        EnablePermissionForUser__c settings=EnablePermissionForUser__c.getInstance(currUser);
        if(settings != null && settings.Type__c != null && settings.Type__c.contains(POST_IC_VOTING)) {
                isTrue = true ;
        } else {
                GAPS_Settings__c settings1=GAPS_Settings__c.getInstance();        
                List<GroupMember> lGm=[select Id, GroupId,Group.Name, UserOrGroupId, SystemModstamp from GroupMember WHERE Group.Name=:settings1.Post_IC_Voting_Group__c AND UserOrGroupId=:currUser];
                isTrue = (lGm.size()>0);
        }
        return isTrue ;
    }
    // Added by Jyoti Singh for S-132864
    //method to return boolean value if the User is allowed to vote on others behalf
    //VoteOnOthersBehalf (only visible for IC members (Public Group"Commitee:Vote On Others Behalf" Users))
    @RemoteAction 
    global static boolean IsVoteOnOthersBehalf()
    {
        boolean isTrue = false ;
        Id currUser = UserInfo.getUserId();
        GAPS_Settings__c settings1=GAPS_Settings__c.getInstance();        
        List<GroupMember> lGm=[select Id, GroupId,Group.Name, UserOrGroupId, SystemModstamp from GroupMember WHERE Group.Name=:settings1.Vote_On_Others_Behalf_Group__c AND UserOrGroupId=:currUser];
        isTrue = (lGm.size()>0);
        return isTrue ;
    }
    
    /****************************************************************************************************************
        Functionality to email the Vote review screen as PDF attachment using the VF Page "Meetings4_Votes_Review_PDF"
    ****************************************************************************************************************/
    @RemoteAction
    global static String sendEMailWithPDF(String mtngId, String PDFReportType, Boolean isNYO, Boolean isEmailMyVotes){
        
        if(mtngId == '' || mtngId == null){
            return null;
        }
    
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>(); 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        
        String[] toAddress = new String[]{};
        String[] ccAddress = new String[]{};
        String emailSubject = '';
        String emailBody = '';
        
        if(isEmailMyVotes){
          toAddress = new String[]{UserInfo.getUserEmail()};
          emailSubject = 'Post IC Review (full report).';
          emailBody = UserInfo.getFirstName() + ',\n\n' + 'Please find attached a summary of your votes.' + '\n\n' + 'GAPS Team';
        }
        
        else{
            //set to address to Drew and Mark using the custom setting "Post_IC_Review_Email_Settings__c"
            for(Post_IC_Review_Email_Settings__c postICEmail : Post_IC_Review_Email_Settings__c.getall().values()){
                
                //For NYO
                if(isNYO){
                    
                    //set to address
                    if(postICEmail.NYO_To_Address__c != null && postICEmail.NYO_To_Address__c != ''){
                    toAddress.addAll(postICEmail.NYO_To_Address__c.split(';')); 
                  }
                  
                  //set cc address
                  if(postICEmail.NYO_CC_Address__c != null && postICEmail.NYO_CC_Address__c != ''){
                    ccAddress.addAll(postICEmail.NYO_CC_Address__c.split(';')); 
                  }
                  
                    //get email body for full
                    if(postICEmail.NYO_Body__c != null && postICEmail.NYO_Body__c != '' && PDFReportType == 'Full'){
                        emailBody = postICEmail.NYO_Body__c;    
                    }
                    
                  //get email body for Initial
                  if(postICEmail.NYO_Initial_Body__c != null && postICEmail.NYO_Initial_Body__c != '' && PDFReportType == 'Initial'){
                      emailBody = postICEmail.NYO_Initial_Body__c;    
                  }
                    
                    //get email body for Post
                  if(postICEmail.NYO_Post_Body__c != null && postICEmail.NYO_Post_Body__c != '' && PDFReportType == 'Post'){
                      emailBody = postICEmail.NYO_Post_Body__c;    
                  }
                    
                }else{
                    // for email as pdf
                    
                    //get to addresses
                    if(postICEmail.To_Address__c != null && postICEmail.To_Address__c != ''){
                        toAddress.addAll(postICEmail.To_Address__c.split(';')); 
                    }
    
                    //get cc addressed
                    if(postICEmail.CC_Address__c != null && postICEmail.CC_Address__c != ''){
                        ccAddress.addAll(postICEmail.CC_Address__c.split(';')); 
                    }
                    
                    //get email body for full
                  if(postICEmail.Body__c != null && postICEmail.Body__c != '' && PDFReportType == 'Full'){
                      emailBody = postICEmail.Body__c;    
                  }
                  
                  //get email body for Initial
                  if(postICEmail.Initial_Body__c != null && postICEmail.Initial_Body__c != '' && PDFReportType == 'Initial'){
                      emailBody = postICEmail.Initial_Body__c;    
                  }
                  
                  //get email body for Post
                  if(postICEmail.Post_Body__c != null && postICEmail.Post_Body__c != '' && PDFReportType == 'Post'){
                      emailBody = postICEmail.Post_Body__c;    
                  }
                }
                
                //get subject for Full 
                  if(postICEmail.Subject__c != null && postICEmail.Subject__c != '' && PDFReportType == 'Full'){
                      emailSubject += postICEmail.Subject__c; 
                  }
                  //get subject for Initial 
                  if(postICEmail.Initial_Subject__c!= null && postICEmail.Initial_Subject__c!= '' && PDFReportType == 'Initial'){
                      emailSubject += postICEmail.Initial_Subject__c; 
                  }
                  //get subject for Post 
                  if(postICEmail.Post_Subject__c!= null && postICEmail.Post_Subject__c!= '' && PDFReportType == 'Post'){
                      emailSubject += postICEmail.Post_Subject__c; 
                  }
            }
        }
        
        //set to addresses
        mail.SetToAddresses(toAddress);         
    
        //set cc addresses
        if(ccAddress.size() > 0){
          mail.SetCcAddresses(ccAddress);
        }  
        
        //set email body
        mail.SetPlainTextBody(emailBody);
        
        //set email subject
        mail.setSubject(emailSubject);

        mail.saveAsActivity = false;
         
        // Set Sender name
        mail.setSenderDisplayName(UserInfo.getName());
        
        // Reference the attachment page and pass in the account ID
      PageReference pdf =  Page.Meetings4_Votes_Review_PDF;
      pdf.getParameters().put('meetingId',mtngId);
      pdf.getParameters().put('reportType',PDFReportType);
      
      if(isEmailMyVotes){
          pdf.getParameters().put('isMyVotes','true');
      }
        
      pdf.setRedirect(true);

      // Take the PDF content
      Blob b;
      if(Test.isRunningTest()){
        b = Blob.valueOf('Test blob data');
      }else{
        b = pdf.getContentAsPDF();  
      }

      // Create the email attachment
      Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
      if(isEmailMyVotes){
      //LSLEVIN Case 56574 11.4.2013 START
      //efa.setFileName(UserInfo.getFirstName() + ' ' + UserInfo.getFirstName() + ' ' + String.valueOf(Date.today()) + '.pdf'); 
        efa.setFileName((UserInfo.getFirstName() == null ? '' : UserInfo.getFirstName()+ ' ') + UserInfo.getLastName() + ' ' + String.valueOf(Date.today()) + '.pdf');
      //LSLEVIN Case 56574 11.4.2013 END
      }else{
        //set file name for Full 
          if(PDFReportType == 'Full'){
            efa.setFileName('Final IC Review ' + String.valueOf(Date.today()) + '.pdf'); 
          }
          //set file name for Initial 
          if(PDFReportType == 'Initial'){
            efa.setFileName('Initial Votes IC Review ' + String.valueOf(Date.today()) + '.pdf'); 
          }
          //set file name for Post 
          if(PDFReportType == 'Post'){
            efa.setFileName('Post IC Votes Review ' + String.valueOf(Date.today()) + '.pdf'); 
          }
      }
      
      efa.setBody(b);
      
      //attaching the attachment to email
      mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
       
      if(toAddress.size() > 0){                  
        mailList.Add(mail);
      }
        
        //Send Email    
        if(mailList.size()>0){        
                Messaging.SendEmailResult [] r = Messaging.sendEmail(mailList);
                
                if(isNYO){
                  return 'Sent to NYO printer.';
                }else{
                  return 'Report sent by email.';
                }
        }
        return null;
    }

    @RemoteAction 
    global static List<MeetingNotePhotoURL> getMeetingNotesWithPhotoURL_Agenda(String strAID)
    {
        MeetingNotePhotoURL[] mNoteList = new MeetingNotePhotoURL[]{};

        Id orgMid = strAID;

        Id dealId;
        Id acctId;

        Set<Id> dealIds = new Set<Id>();
        Set<Id> mIds = new Set<Id>();

        Meeting_Agenda_Item__c m = [Select Id,Deal__c From Meeting_Agenda_Item__c WHERE Id =: orgMid];

        dealId = m.Deal__c;

        Deal__c deal = [Select Id,Related_Company__c From Deal__c WHERE Id =: dealId];

        acctId = deal.Related_Company__c;

        Account a = [Select Id,(Select Id From Investments__r)
                     From Account
                     WHERE Id =: acctId];

        if(a.Investments__r != null && !a.Investments__r.isEmpty())
        {
            for(Deal__c d : a.Investments__r)
            {
                dealIds.add(d.Id);
            }
        }

        Meeting_Agenda_Item__c[] mList = [Select Id,(Select Agenda_Item__r.Name,Agenda_Item__r.Deal__r.Related_Company__r.Name,
                                           Id,
                                           Note__c,
                                           Quality_of_Materials__c,
                                           Would_Invest__c,
                                           CreatedDate,
                                           Vote__c From Meeting_Notes__r
                                           WHERE OwnerId =: UserInfo.getUserId())
                                          From Meeting_Agenda_Item__c
                                          WHERE Deal__c IN: dealIds];

        for(Meeting_Agenda_Item__c ma : mList)
        {
            if(ma.Meeting_Notes__r != null && !ma.Meeting_Notes__r.isEmpty())
            {
                for(Meeting_Note__c mn : ma.Meeting_Notes__r)
                {
                    mNoteList.add(new MeetingNotePhotoURL(mn,''));
                }
            }
        }

        return mNoteList;
    }


    /****************************************************************************************************************/
    
    /*************************************************************************************
    //DashboardStory # S-146191 Start - Graphs / Dashboard section
    *************************************************************************************/
    
    //method to return the listof Wrapper class - MeetingNotePhotoURL for the Meeting Notes along with Small Photo of the owner
    // 10/23/2013
    //All the Post IC votes of (IC Members + Non IC members Post IC votes)
    @RemoteAction 
    global static List<MeetingNotePhotoURL> getMeetingNotesWithPhotoURL_Dashboard(String strAID)
    {
        List<MeetingNotePhotoURL> mnUrlLst = new List<MeetingNotePhotoURL>();
        List<Meeting_Note__c> mtngNoteLst = [SELECT Id, OwnerId, Is_Post_IC_Vote__c, Owner.Name, Name, Note__c, Quality_of_Materials__c, Vote__c, Materials_submitted_on_time__c, Agenda_Item__c, Would_Invest__c
                                              FROM Meeting_Note__c 
                                              WHERE Agenda_Item__c=:strAID 
                                              AND Is_Post_IC_Vote__c = true
                                              //START Story # S-183841 [hemant 1/24/2014]
                                              //AND (Vote__c like 'N/A%' OR Vote__c like '1%' OR Vote__c like '2%' OR Vote__c like '3%')
                                              //END Story # S-183841 
                                              order BY Owner.FirstName Asc, Is_Post_IC_Vote__c Asc, LastModifiedDate Desc];
        List<Meeting_Note__c> mtngNoteLstToAdd = new List<Meeting_Note__c>();

        if(mtngNoteLst.size() > 0){
            Set<Id> userIdSet = new Set<Id>();
            Set<Id> postVoteOwnerIdSet = new Set<Id>(); 
            
            for(Meeting_Note__c m : mtngNoteLst){
              if(m.OwnerId != null && String.valueOf(m.OwnerId).startsWith('005')){
                userIdSet.add(m.OwnerId);
              }
                
                if(!postVoteOwnerIdSet.contains(m.OwnerId)){
                  postVoteOwnerIdSet.add(m.OwnerId);
                  mtngNoteLstToAdd.add(m);
                }
            }
            
            //Committee: Investment group for IC Member list
            Set<Id> ICMemberIdSet = new Set<Id>();
            GAPS_Settings__c settings1=GAPS_Settings__c.getInstance();        
            for(GroupMember gm : [select Id, GroupId,Group.Name, UserOrGroupId, SystemModstamp from GroupMember WHERE Group.Name=:settings1.Post_IC_Voting_Group__c AND UserOrGroupId IN : userIdSet]){
                ICMemberIdSet.add(gm.UserOrGroupId);
            }
            
            Map<Id, User> userMap = new Map<Id, User>([SELECT Id, SmallPhotoUrl from User where Id IN: userIdSet]);
            List<MeetingNotePhotoURL> ICMembermnUrlLst = new List<MeetingNotePhotoURL>();
            List<MeetingNotePhotoURL> NonICMembermnUrlLst = new List<MeetingNotePhotoURL>();
            
            for(Meeting_Note__c m : mtngNoteLstToAdd){
                MeetingNotePhotoURL mnp;
                if(userMap.containsKey(m.OwnerId)){
                    mnp = new MeetingNotePhotoURL(m,userMap.get(m.OwnerId).SmallPhotoUrl);
                }else{
                    String genUrl = URL.getSalesforceBaseUrl().toExternalForm()+ '/img/social/unknown_profile_pic.png';
                    mnp = new MeetingNotePhotoURL(m,genUrl);
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
        }
        return mnUrlLst;
    }
    
    /*************************************************************************************
    //DashboardStory # S-146191 End Graphs / Dashboard section
    *************************************************************************************/
    
    
    static testMethod void test()
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
    }
}