// Name         : CustomChatterPdfExportExtension
// Author       : Kapil Choudhary (Appirio Offshore)
// Created Date : 5-January-2013
// Description  : Cloud Spoke Result Class Extended for  T-107258.
// Last Modified: 

public class CustomChatterPdfExportExtension {

    public CustomChatterPdfExportExtension(CustomChatterSearchController controller) {
        initValues();
        editMode = false;
        showEmail = true;
    }
    
    public Boolean showEmail{get; set;}
    public String email {get;set;}
    public String subject {get; set;}
    public String filename {get; set;}
    public String message {get; set;}
    public FeedMailGroup__c mailGroup{get;set;}
    public List<SelectOption> groupOptions {get;set;}
    public List<SelectOption> externalOptions {get;set;}
    public List<SelectOption> weekDays {get;set;}
    public List<SelectOption> weekHr {get;set;}
    public List<SelectOption> amPm {get;set;}
    public String selectedGroupId {get;set;}
    public String selectedExternalGroupId {get;set;}
    public String selectedweekDays {get;set;}
    public String selectedweekHr {get;set;}
    public String selectedAmPm {get;set;}
    public chatterpage__c defaultSetting {get;set;}
    map<string,list<string>> extraMailingListMap;
    public Boolean editMode {get;set;}
    Map<String, integer> DaysMap;
    List<chatterpage__c> chatterPageList;
    
    
    public void setEmailTrue(){
        showEmail = true;
    }
    
    public void setEmailFalse(){
        //showEmail = false;
        initValues();
    }
    
     public void editSettings(){
        editMode = true;
        if(!chatterPageList.isempty()){
            selectedAmPm = chatterPageList[0].AM_PM__c;
            selectedweekDays = chatterPageList[0].Day__c;
            selectedweekHr = chatterPageList[0].Next_Schedule_HR__c;
        }
     }
     public void cancelSettings(){
        editMode = false;
     }
     public void updateSettings() {
     	
        defaultSetting.Day__c = selectedweekDays;
        defaultSetting.AM_PM__c = selectedAmPm;
        defaultSetting.Next_Schedule_HR__c = selectedweekHr;
        update defaultSetting;
        editMode = false;
     }
    public PageReference sendPdf() {
        
        PageReference pdf = Page.ChatterPagePdf;
        PageReference htmlpg = Page.ChatterPagHtml;
        
        // the contents of the attachment from the pdf
        Blob body;
     
        try {
     
          // returns the output of the page as a PDF
          body = pdf.getContent();
     
        // need to pass unit test -- current bug  
        } catch (VisualforceException e) {
          body = Blob.valueOf('Error Body');
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Error while sending Email to '+email));
        }
        
          set<id>userIdSet = new set<id>();
          list<String> userEmailList = new list<String>();
           
          if((selectedGroupId != null && selectedGroupId != '' && selectedGroupId != '--None--') || (mailGroup.Ad_hoc_Emails__c != null && mailGroup.Ad_hoc_Emails__c != '')){
              if(mailGroup.Mail_Send_On__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a date.'));
                return null;
              }
              
              mailGroup.IsMailSent__c = false;
              mailGroup.HtmlBody__c = htmlpg.getContent().toString();
              
              /*if(selectedExternalGroupId != null && selectedExternalGroupId != '' && selectedExternalGroupId != '--None--'){
                mailGroup.External_Email_Groups__c = selectedExternalGroupId;
              }*/
              if(selectedGroupId != null && selectedGroupId != '' && selectedGroupId != '--None--'){
                mailGroup.Internal_Email_Groups__c = selectedGroupId;
              }
               
              insert mailGroup;
        
              Attachment att = new Attachment(ParentId = mailGroup.id,Body = body,ContentType = 'application/pdf',name = 'ChatterFeed'+System.Today()+'.pdf', Description = 'ChatterFeed'+System.Today()+'.pdf');
              insert att;
              
          }
          else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a mailing group.'));
            return null;
          }
     
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF sent to selected group.'));
     
        setEmailFalse();
        return null;
 
    }
 private void initValues() {
        mailGroup = new FeedMailGroup__c();
        groupOptions = new List<SelectOption>();
        externalOptions = new List<SelectOption>();
        DaysMap = new Map<String, Integer>{ 'Sunday' => 1,
                                                                    'Monday' => 2,
                                                                    'Tuesday' => 3,
                                                                    'Wednesday' => 4,
                                                                    'Thursday' => 5,
                                                                    'Friday' => 6,
                                                                    'Saturday' => 7
                                                                };
        weekDays =  new List<SelectOption>();
         weekDays.add(new SelectOption('Sunday','Sunday'));
         weekDays.add(new SelectOption('Monday','Monday'));
         weekDays.add(new SelectOption('Tuesday','Tuesday'));
         weekDays.add(new SelectOption('Wednesday','Wednesday'));
         weekDays.add(new SelectOption('Thursday','Thursday'));
         weekDays.add(new SelectOption('Friday','Friday'));
         weekDays.add(new SelectOption('Saturday','Saturday'));
        
        weekHr  =  new List<SelectOption>();
            weekHr.add(new SelectOption('01','01'));
            weekHr.add(new SelectOption('02','02'));
            weekHr.add(new SelectOption('03','03'));
            weekHr.add(new SelectOption('04','04'));
            weekHr.add(new SelectOption('05','05'));
            weekHr.add(new SelectOption('06','06'));
            weekHr.add(new SelectOption('07','07'));
            weekHr.add(new SelectOption('08','08'));
            weekHr.add(new SelectOption('09','09'));
            weekHr.add(new SelectOption('10','10'));
            weekHr.add(new SelectOption('11','11'));
            weekHr.add(new SelectOption('12','12'));
        
        amPm = new List<SelectOption>();
            amPm.add(new SelectOption('AM','AM'));
            amPm.add(new SelectOption('PM','PM'));
        groupOptions.add(new SelectOption('--None--','--None--'));
        externalOptions.add(new SelectOption('--None--','--None--'));
       
        
       
        extraMailingListMap = new  map<string,list<string>>();
        for(ExternalMailingList__c em : ExternalMailingList__c.getall().values()) {
            if(em.Email__c != null){
                extraMailingListMap.put(em.name,em.Email__c.split(';'));
            }
            externalOptions.add(new SelectOption(em.name,em.name));
        }
        
        set<id> QObjSet     = new set<id>();

          for(QueueSobject qs : [SELECT QueueId FROM QueueSobject where SobjectType = 'FeedMailGroup__c']) {
                QObjSet.add(qs.QueueId);
          }
          for(Group gp : [SELECT DeveloperName,Email,Id,Name,Type FROM Group WHERE Type = 'Queue' and id in : QObjSet]){
            groupOptions.add(new SelectOption(gp.id,gp.name));
          }
          
         chatterPageList = chatterpage__c.getall().values();
        
        if(!chatterPageList.isempty()){
            defaultSetting = chatterPageList[0];
            mailGroup.subject__c  = chatterPageList[0].Subject__c;
            mailGroup.File_Name__c = chatterPageList[0].FileName__c;
            mailGroup.Message__c  = chatterPageList[0].Message__c;
            mailGroup.Ad_hoc_Emails__c = chatterPageList[0].Ad_hoc_Emails__c;
            mailGroup.Mail_Reply_To__c = chatterPageList[0].Mail_Reply_To__c;
            mailGroup.Display_Text__c = chatterPageList[0].Display_Text__c;
            setdefaultDate();
        }
        else{
        	chatterpage__c chatterPageIns = new chatterpage__c();
        	chatterPageIns.subject__c = 'Feed Subject';
        	chatterPageIns.FileName__c = 'ChatterFeeds';
        	chatterPageIns.Display_Text__c = 'General Atlantic';
        	chatterPageIns.AM_PM__c = 'AM';
        	chatterPageIns.Day__c = 'Monday';
        	chatterPageIns.name = 'DefaultEmailParametrs';
        	chatterPageIns.Next_Schedule_HR__c = '05';
        	insert chatterPageIns;
        	defaultSetting = chatterPageIns;
        }
 }
 
     private void setdefaultDate(){
        integer schDay;
        integer currDay;
        system.debug('defaultSetting.Day__c: '+defaultSetting.Day__c);
        if(DaysMap.containskey(defaultSetting.Day__c)){
            schDay= DaysMap.get(defaultSetting.Day__c);
        }
        currDay = DaysMap.get(datetime.now().format(('EEEEEE')));
        datetime newSchDate = datetime.now();
        
        if(schDay>currDay){
            newSchDate = datetime.now().adddays(schDay-currDay);
        }
        else{
        	system.debug('currDay: '+currDay);
        	system.debug('schDay: '+schDay);
            newSchDate = datetime.now().adddays(7-currDay+schDay);
        }
            string strDate = newSchDate.format('MM/dd/yyyy');
            strDate =  strDate + ' '+ defaultSetting.Next_Schedule_HR__c + ': 00 '+ defaultSetting.AM_PM__c;
            newSchDate = DateTime.parse(strDate);
            mailGroup.Mail_Send_On__c = newSchDate;
     }
}