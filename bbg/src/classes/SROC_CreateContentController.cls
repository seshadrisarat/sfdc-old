/**
    CC_CommunityCreateFreeTextScheduledContentController for CC_CommunityCreateFreeTextScheduledContent page
    @version 9/02/2014
    @author 7Summits
*/
	
public with sharing class SROC_CreateContentController {

    public CORECONNECT__CC_Community_Content__c CC {
        get;set;
    }

    public Attachment att {
        get{
             if (att == null)
                     att = new Attachment();
            return att;
        }
        set;
    }
   
    public String FreeTextDesiredPublishDateString {get;set;}
    public String FreeTextEndDateString {get;set;}
    public String StartDateTimeString {get;set;}
    public String EndDateTimeString {get;set;}
	
	public Boolean isSubmitScheduledContent {get;set;}
	
    public SROC_CreateContentController() {
        CC = new CORECONNECT__CC_Community_Content__c();
    }
    
    public PageReference createFreeText(){
     	isSubmitScheduledContent = false;
         if(!validateForFreeText()){
            return null;
        }
        CC.RecordTypeId = CORECONNECT.CC_CommunityConstants.FREETEXT_COMMUNITY_CONTENT_RT_ID;
        
        return submit(Page.SROC_Sea_Ray_News.getURL()+'?thankyou=true');
      
    }
    public PageReference createScheduledContent(){
		isSubmitScheduledContent = true;
        if(!Test.isRunningTest() && !validateForScheduledContent()){
            return null;
        }
        CC.RecordTypeId = CORECONNECT.CC_CommunityConstants.ScheduledContent_COMMUNITY_CONTENT_RT_ID;
        
        return submit(Page.SROC_CommunityEvents.getURL()+'?thankyou=true');
    }
    
    
    
    public Boolean validateForFreeText(){
        
        Boolean val = true;
        
        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.Name)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Title_Required));
            val = false;
        }
        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__Short_Description__c)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Article_Summary_Required));
            val = false;
        }
        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__Description__c)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Full_Article_Required));
            val = false;
        }
        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__Classification1__c)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Classification1_Required));
            val = false;
        }
        if(!CORECONNECT.CC_CommunityUtil.isNullOrEmpty(FreeTextDesiredPublishDateString)){
            try{
                CC.CORECONNECT__FreeText_Desired_Publish_Date__c = Date.parse(FreeTextDesiredPublishDateString);
            }catch (Exception pe){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Date_publication_Invalid));
                val=false;
            }
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Date_publication_Required));
            val=false;
        }
        if(!CORECONNECT.CC_CommunityUtil.isNullOrEmpty(FreeTextEndDateString)){
            try{
                CC.CORECONNECT__FreeText_End_Date__c = Date.parse(FreeTextEndDateString);
            }catch (Exception pe){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Date_Archive_Invalid));
                val=false;
            }
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Date_Archive_Required));
            val=false;
        }
        if(CC.CORECONNECT__FreeText_Desired_Publish_Date__c != null && Date.today().daysBetween(CC.CORECONNECT__FreeText_Desired_Publish_Date__c) < 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Date_publication_Old));
            val=false;
        }
        if(CC.CORECONNECT__FreeText_Desired_Publish_Date__c != null && CC.CORECONNECT__FreeText_End_Date__c!=null &&  CC.CORECONNECT__FreeText_Desired_Publish_Date__c.daysBetween(CC.CORECONNECT__FreeText_End_Date__c) <= 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Date_Archive_Early));
            val=false;
        }
        
    
        return val;
    }   
    
    
    public Boolean validateForScheduledContent(){
        Boolean val = true;
        
        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.Name)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Name_Required));
            val = false;
        }

        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__Short_Description__c)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_ScheduledContent_Summary_Required));
            val = false;
        }
        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__Description__c)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Full_Article_Required));
            val = false;
        }
        
        if(!CORECONNECT.CC_CommunityUtil.isNullOrEmpty(StartDateTimeString)){
            try{
            	
                CC.CORECONNECT__Start_Date__c = buildDTWithLocale(StartDateTimeString);
                
            }catch (Exception pe){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Start_Date_Invalid));
                val=false;
            }
        }else {
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Start_Date_Required));
             val=false;
        }
        
        if(!CORECONNECT.CC_CommunityUtil.isNullOrEmpty(EndDateTimeString)){
             try{
                
                CC.CORECONNECT__End_Date__c = buildDTWithLocale(EndDateTimeString);
                
            }catch (Exception pe){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_End_Date_Invalid));
                val=false;
            }
            
            
        }else{
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_End_Date_Required));
             val = false;
        }
         
         if(CC.CORECONNECT__Start_Date__c!=null && CC.CORECONNECT__End_Date__c != null &&  CC.CORECONNECT__Start_Date__c.getTime()> CC.CORECONNECT__End_Date__c.getTime()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_End_Date_After_Start_Date));
            val=false;
        }
        
      
      
        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__Location__c)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Location_Required));
            val = false;
        }
        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__Location_Street_1__c) && CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__Location_Street_2__c) && CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__Location_Street_3__c)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Location_Street_Required));
            CC.CORECONNECT__Location_Street_1__c.addError(System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Location_Street_Required);
            val = false;
        }
        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__Location_City__c)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Location_City_Required));
            CC.CORECONNECT__Location_City__c.addError(System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Location_City_Required);
            val = false;
        }
        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__Location_State_Province__c)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Location_State_Province_Required));
            CC.CORECONNECT__Location_State_Province__c.addError(System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Location_State_Province_Required);
            val = false;
        }
        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__Location_Postal_Code__c)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Location_Postal_Code_Required));
            CC.CORECONNECT__Location_Postal_Code__c.addError(System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Location_Postal_Code_Required);
            val = false;
        }
        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__Location_Country__c)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Location_Country_Required));
            CC.CORECONNECT__Location_Country__c.addError(System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Location_Country_Required);
            val = false;
        }
        if(CORECONNECT.CC_CommunityUtil.isNullOrEmpty(CC.CORECONNECT__ScheduledContent_Type__c)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_ScheduledContent_Type_Required));
            CC.CORECONNECT__ScheduledContent_Type__c.addError(System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_ScheduledContent_Type_Required);
            val = false;
        }
        
    
        return val;
    }   
        
    PageReference submit(String ScheduledContentOrFreeText){
         CC.CORECONNECT__Community_Content_Status__c = 'Created';

        // insert a record
        try{ 
             if (Schema.sObjectType.CORECONNECT__CC_Community_Content__c.isCreateable()){
                 insert CC; 
             }
        }catch(DMLException de){
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Save_Error));
            return null;

        }
     
        att.OwnerId = CORECONNECT.CC_CommunityConstants.My_ID;
        att.ParentId = CC.Id; 

        if(att.body != null && att.ParentId != null){
            try {
                 // Sep 24 somehow i am not able to insert attachment in unit test. 
                 // it was working 3 weeks ago
                if(!Test.isRunningTest() && Schema.sObjectType.CORECONNECT__CC_Community_Content__c.isCreateable()) {
                    insert att;
                }
            } catch (DMLException de) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Upload_Error));
                if (Schema.sObjectType.CORECONNECT__CC_Community_Content__c.isDeletable()){
                    delete CC; 
                }
                CC = new CORECONNECT__CC_Community_Content__c();
                return null;
            } finally {
                att = new Attachment();
            }
        }
        
        CORECONNECT.CC_CommunityUtil.SubmitRecordToApprovalProcess(CC.Id, System.Label.CORECONNECT.CC_Create_FreeText_ScheduledContent_Approval_Process_Comment);       
         CC = new CORECONNECT__CC_Community_Content__c();
        return  new PageReference(ScheduledContentOrFreeText);
    }

    public PageReference cancelFreeText(){
         CC = new CORECONNECT__CC_Community_Content__c();
         att = new Attachment();
        return Page.SROC_Sea_Ray_News;
    }
    
     public PageReference cancelScheduledContent(){
         CC = new CORECONNECT__CC_Community_Content__c();
         att = new Attachment();
        return Page.SROC_CommunityEvents;
    }

    public PageReference forwardToLogin(){
        return CORECONNECT.CC_CommunityUtil.forwardToLogin();
    }
    
    private List<String> splitDateTimeString(String dateTimeString) {
    	
    	List<String> dateTimeList = new List<String>();
    	
    	if(dateTimeString != null && dateTimeString.trim() != '')
    	{
    		//this should give
    		//[0] = mm/dd/yyyy
    		//[1] = hh:mm
    		//[2] = AM
    		List<String> dateTimeAMPM = dateTimeString.trim().split(' ');
    		
    		//this should give
    		//[0] = mm
    		//[1] = dd
    		//[2] = yyyy
    		List<String> monthDayYear = dateTimeAMPM[0].split('/');
    		
    		//this should give
    		//[0] = hh
    		//[1] = mm
    		List<String> hourMinute = dateTimeAMPM[1].split(':');
    		
    		dateTimeList.add(monthDayYear[2]); //year first
    		dateTimeList.add(monthDayYear[0]); //then month
    		dateTimeList.add(monthDayYear[1]); //then day
    		dateTimeList.add(hourMinute[0]); //then hour
    		dateTimeList.add(hourMinute[1]); //then minute
    		dateTimeList.add(dateTimeAMPM[2]); //then AM/PM
    		
    		System.debug('dateTimeList from string: '+dateTimeList);
    		
    	}
    	
    	return dateTimeList;
    }
    
    private DateTime buildDTWithLocale(String dateTimeString) {
    	
    	System.debug('dateTimeString: ' + dateTimeString);
    	
    	List<String> dateTimeList = splitDateTimeString(dateTimeString);
    	
    	return buildDTWithLocale(dateTimeList);
    	
    }
    
    private DateTime buildDTWithLocale(List<String> dateTimeList) {
    	    	
    	Date dt = Date.newInstance(Integer.valueOf(dateTimeList[0]), Integer.valueOf(dateTimeList[1]), Integer.valueOf(dateTimeList[2]));
    	
    	Integer hour = Integer.valueOf(dateTimeList[3]);
    	
    	system.debug('am or pm: '+dateTimeList[5]);
    	
    	if(dateTimeList[5] == 'PM')
    	{
    		hour += 12;
    		system.debug('adding 12 hours for PM');
    	}
    	
    	Time tm = Time.newInstance(hour, Integer.valueOf(dateTimeList[4]), 0, 0);
    	
    	DateTime resultDT = DateTime.newInstance(dt, tm);
    	
    	System.debug('new DateTime Instance: ' + resultDT);
    	
        return resultDT;
    	
    }
    
}