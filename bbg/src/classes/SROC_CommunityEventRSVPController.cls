public with sharing class SROC_CommunityEventRSVPController {
	
	public String eventId {get;set;}
	public CORECONNECT__CC_ScheduledContent_Registration__c currentSCRSVPRegistration {get;set;}
	public List<User> attendingUsers {get;private set;}
	public Integer showNumRSVPUsers {get;set;}
	public List<CORECONNECT__CC_ScheduledContent_Registration__c> lstSCReg {get;set;}
    
    public Integer defaultRSVPShowNumUsers {get;private set;}

	public SROC_CommunityEventRSVPController() {
		this.currentSCRSVPRegistration = new CORECONNECT__CC_ScheduledContent_Registration__c();
		this.attendingUsers = new List<User>();
		this.lstSCReg = new List<CORECONNECT__CC_ScheduledContent_Registration__c>();
		this.defaultRSVPShowNumUsers = 16;
        this.showNumRSVPUsers = this.defaultRSVPShowNumUsers;
		
		system.debug('---ApexPages::'+ApexPages.currentPage().getParameters().get('id'));	
		eventId = ApexPages.currentPage().getParameters().get('id');

		if(String.isNotBlank(eventId)){
			currentSCRegistration();
			queryAttendingUsers();
		}
		system.debug('-SROC_CommunityEventRSVPController-currentSCRSVPRegistration--'+this.currentSCRSVPRegistration);
		system.debug('-SROC_CommunityEventRSVPController-lstSCReg--'+this.lstSCReg);
	}

	private void currentSCRegistration(){

		List<CORECONNECT__CC_ScheduledContent_Registration__c> scrList = [	SELECT Id, Name, CORECONNECT__Responded__c, CORECONNECT__Response__c, CORECONNECT__CC_Community_Content__c,
						   										CORECONNECT__User__c, Number_of_Guests_Under_21__c, Number_of_Guests_Total__c, Custom_Message__c 
						   										FROM CORECONNECT__CC_ScheduledContent_Registration__c 
						   										WHERE CORECONNECT__User__c =: UserInfo.getUserId() AND CORECONNECT__CC_Community_Content__c =: eventId];
   			
		if(scrList != null && scrList.size() > 0)
			this.currentSCRSVPRegistration = scrList[0];
		else{
			this.currentSCRSVPRegistration.CORECONNECT__CC_Community_Content__c = eventId;
   			this.currentSCRSVPRegistration.CORECONNECT__User__c = UserInfo.getUserId();
	
		}
		this.lstSCReg.add(currentSCRSVPRegistration);
		system.debug('--currentSCRSVPRegistration--'+this.currentSCRSVPRegistration);
		system.debug('--lstSCReg--'+this.lstSCReg);
	}
	
	private void queryAttendingUsers() {
   		
   		this.attendingUsers = new List<User>();
   		
   	
   		Set<Id> userIdSet = new Set<Id>();
   		for(CORECONNECT__CC_ScheduledContent_Registration__c scr : [ SELECT CORECONNECT__User__c 
                       									FROM CORECONNECT__CC_ScheduledContent_Registration__c 
                       									WHERE CORECONNECT__CC_Community_Content__c = :eventId AND CORECONNECT__Response__c = 'YES'])
   		{
   			userIdSet.add(scr.CORECONNECT__User__c);
   		}
   		
   		this.attendingUsers = [SELECT Id, Name, SmallPhotoUrl FROM User WHERE Id IN :userIdSet];
   			
   		
   		
   }
   
   public void notAttendingRSVPSC() {
   		
   		if(this.currentSCRSVPRegistration != null)
   		{
   			this.currentSCRSVPRegistration.CORECONNECT__Response__c = 'NO';
   			upsertSCRSVPRegistration();
   		}
   		
   }
   
   public void attendingSC() {
   		
   		if(this.currentSCRSVPRegistration != null)
   		{
   			this.currentSCRSVPRegistration.CORECONNECT__Response__c = 'YES';
   			upsertSCRSVPRegistration();
   		}
   		
   }
   
   public void cancelSC(){
       this.currentSCRSVPRegistration = new CORECONNECT__CC_ScheduledContent_Registration__c();
   }
   
   private void upsertSCRSVPRegistration() {
   		
   		if(this.currentSCRSVPRegistration != null && this.currentSCRSVPRegistration.CORECONNECT__Response__c != null)
   		{
   			
   			this.currentSCRSVPRegistration.CORECONNECT__Responded__c = true;
   			
   			if(this.currentSCRSVPRegistration.Id != null)
   			{
				update this.currentSCRSVPRegistration;
   			}
   			else
   			{
   				insert this.currentSCRSVPRegistration;
   			}
   			queryAttendingUsers();
   		}
   		
   }
   
   public void viewAllMembers() {
   		this.showNumRSVPUsers = 0;
   }
   
   public void viewLessMembers() {
   		this.showNumRSVPUsers = this.defaultRSVPShowNumUsers;
   }
}