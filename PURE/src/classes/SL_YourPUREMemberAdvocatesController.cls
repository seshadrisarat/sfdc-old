public with sharing class SL_YourPUREMemberAdvocatesController {
	public string strEmailSubject {get;set;} 
	public String strMemberPhoneNum {get;set;}
	public String learMoreLink		{get;set;}
	
	public SL_YourPUREMemberAdvocatesController()
	{
		strEmailSubject = learMoreLink = '';
		memberDetails();
		PortalURLMap__c oLearMore = new PortalURLMap__c();
		oLearMore = PortalURLMap__c.getInstance('MemberAdvocateLearnMore');
		learMoreLink = (oLearMore != null) ? oLearMore.URL__c : '#';
	}
	
	public void memberDetails()
	{
		string strAccountId = [Select accountId from User where id =: userInfo.getUserId()].accountId;
		try{
			Account objAccount = [SELECT Name,Phone,Member_Key_EDW__c FROM Account WHERE Id =: strAccountId ];
			strEmailSubject = 'Member Portal:'+objAccount.Name +','+ objAccount.Member_Key_EDW__c ;
			strMemberPhoneNum = objAccount.Phone;
		}
		catch(Exception e)
		{
			system.debug('#####Exception####->'+e.getMessage());
		}
	}
}