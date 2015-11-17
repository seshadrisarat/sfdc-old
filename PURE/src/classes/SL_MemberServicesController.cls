public with sharing class SL_MemberServicesController {

	public string strEmailSubject {get;set;} 
	public string strMemberPhoneNum {get;set;}
	
	public SL_MemberServicesController()
	{
		strEmailSubject = '';
		memberDetails();
	}
	
	public void memberDetails()
	{
		string strAccountId = [Select accountId from User where id =: userInfo.getUserId()].accountId;
		try{
			Account objAccount = [SELECT Name,Phone,Member_Key_EDW__c FROM Account WHERE Id =: strAccountId];
			strEmailSubject = 'Member Portal:'+objAccount.Name +','+ objAccount.Member_Key_EDW__c ;
			strMemberPhoneNum = objAccount.Phone;
		}
		catch(Exception e)
		{
			system.debug('#####Exception####->'+e.getMessage());
		}
	}
}