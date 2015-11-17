/*******************************************************************************
Class Name    : ChatterEmailSchedulerTestClass
Created By    : Suraj Rajoria(Appirio Offshore)
Created Date  : 09 Jan 2013
Description   : Test Class for ChatterEmailScheduler
*******************************************************************************/
@isTest(SeeAllData=true)
public class ChatterEmailSchedulerTestClass {
	public static final String GROUP_NAME = 'TestingGroup';
	public static final String ATTACHMENT_NAME = 'Test Attachment';
	public static final String ATTACHMENT_BODY = 'Test body';
	public static final String EXTERNAL_EMAIL = 'TestExternal';
	public static final String FILE_NAME = 'ChatterFeeds';
	public static final String MAIL = 'test@mail.com';
	public static final String DISPLAY_TEXT = 'test';
	public static final String MESSAGE = 'Hello this is a test message';
	public static final String SUBJECT = 'testSubject';
	public static final String HTML = 'test html';
	public static final String PROFILE_NAME = 'System Administrator';
	public static final String ALIAS = 'standt';
	public static final String USER_EMAIL = 'testFeedItemDelete@testorg.com';
	public static final String EMAIL_ENCODING = 'UTF-8';
	public static final String LAST_NAME = 'Testing';
	public static final String LANGUAGE = 'en_US';
	public static final String LOCALE_SID = 'en_US';
	public static final String TIME_ZONE = 'America/Los_Angeles';
	public static final String USER_NAME = 'testFeedItemDelete@testorg.com';
		
	static testMethod void executeTest(){
	    ChatterEmailScheduler testChatterMail = new ChatterEmailScheduler ();
	    SchedulableContext sc;  
	    GroupMember gm;
	    Group g;
	    User u = new User();
	    u = createUser();  
	    System.runAs(u) {     
		        //Create FeedMailGroup__c object
		        g = new Group();
		        g = createGroup(GROUP_NAME);
		        
		        gm = new GroupMember();
		        gm.GroupId = g.Id;
		        gm.UserOrGroupId = UserInfo.getUserId();
		        insert gm;
	    }
	    FeedMailGroup__c fmg = new FeedMailGroup__c ();
	    fmg = createFeedMailGroup(g);
	    //Assert test if FeedMailGroup__c is inserted or not 
	    System.assert(fmg.id <> null);
	    //Create Attachment object
	    Attachment attachment = new Attachment();
	    attachment = createAttachment(fmg);
	    //Call execute method of ChatterEmailScheduler class
	    testChatterMail.execute(sc);     
	    
	    fmg = [Select Id,IsMailSent__c from FeedMailGroup__c where Id =: fmg.Id];
	    //Assert test for IsMailSent__c field of FeedMailGroup__c
	    System.assert(fmg.IsMailSent__c);
	}
	/*****************************************************************************
	  Method Name : createFeedMailGroup  
	  Description : Contain actions need to create an FeedMailGroup__c
	  *****************************************************************************/
	private static FeedMailGroup__c createFeedMailGroup(Group g){
		  FeedMailGroup__c fmg = new FeedMailGroup__c ();
	    fmg.External_Email_Groups__c = EXTERNAL_EMAIL;
	    fmg.File_Name__c = FILE_NAME;
	    fmg.Internal_Email_Groups__c = g.Id;
	    fmg.IsMailSent__c = false;
	    fmg.Mail_Reply_To__c = MAIL;
	    fmg.Ad_hoc_Emails__c = MAIL;
	    fmg.Include_Custom_Message__c = true;
	    fmg.Display_Text__c = DISPLAY_TEXT;
	    DateTime dt = System.now();
	    dt.addDays(-2);
	    fmg.Mail_Send_On__c = dt;
	    fmg.Message__c = MESSAGE;
	    fmg.Subject__c = SUBJECT;
	    fmg.HtmlBody__c = HTML;
	    insert fmg;
	    return fmg;
	}
	/*****************************************************************************
	  Method Name : createUser  
	  Description : Contain actions need to create an User
	  *****************************************************************************/
	private static User createUser(){
		Profile prof = new Profile();
		for(Profile p : [select id from profile where name =: PROFILE_NAME limit 1]){
			prof = p;
		}
		User user = new User();
		user.alias = ALIAS;
		user.email = USER_EMAIL;
		user.emailencodingkey = EMAIL_ENCODING;
		user.lastname = LAST_NAME;
		user.languagelocalekey = LANGUAGE;
		user.localesidkey = LOCALE_SID;
		user.profileid = prof.Id;
		user.timezonesidkey = TIME_ZONE;
		user.username = USER_NAME;
		return user;
	}
	/*****************************************************************************
	  Method Name : createGroup  
	  Description : Contain actions need to create an Group
	  *****************************************************************************/
	private static Group createGroup(String groupName){
		Group g = new Group();
		g.Name = groupName;
		insert g;
		return g;
	}
	/*****************************************************************************
	  Method Name : createAttachment  
	  Description : Contain actions need to create an Attachment
	  *****************************************************************************/
	private static Attachment createAttachment(FeedMailGroup__c fmg){
		Attachment attachment = new Attachment();
		attachment.ParentId = fmg.Id;
    attachment.Name = ATTACHMENT_NAME;
    attachment.Body = blob.valueOf(ATTACHMENT_BODY);
    insert attachment;
    return attachment;
	}

}