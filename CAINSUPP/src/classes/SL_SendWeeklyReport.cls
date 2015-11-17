/**
* \arg ClassName      : SL_SendWeeklyReport
* \arg JIRATicket     : CAINSUPP-14
* \arg CreatedOn      : 11/03/2015
* \arg CreatededBy    : Sanath
* \arg ModifiedBy     : -
* \arg Description    : -
*/
global with sharing class SL_SendWeeklyReport implements Database.Batchable<Sobject>
{
	private static Id softReminderId;
	private static Id weeklyReminderId;
	
	static
	{
		for(EmailTemplate objEmailTemplate : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN ('Send_Soft_Reminder', 'Send_Weekly_Reminder')])
		{
			if(objEmailTemplate.DeveloperName == 'Send_Soft_Reminder')
				softReminderId = objEmailTemplate.Id;
			else
				weeklyReminderId = objEmailTemplate.Id;
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext bc)
	{
		return Database.getQueryLocator('SELECT Id, Proj_Closing_Date__c, (SELECT Team_Member__c, Team_Member__r.Email FROM Cain_Deal_Teams__r WHERE Team_Member__r.Email!=NULL) FROM Deal__c WHERE Due_Diligence_Complete__c = FALSE AND Status__c = \'In Progress\' AND (Proj_Closing_Date__c = NEXT_N_DAYS:60 OR (Proj_Closing_Date__c > TODAY AND Proj_Closing_Date__c <= NEXT_N_DAYS:30))');
	}
	
	global void execute(Database.BatchableContext BC, List<Deal__c> lstDeal)
	{
		List<Messaging.Singleemailmessage> lstMails = new List<Messaging.Singleemailmessage>();
		
		for(Deal__c objDeal : lstDeal)
		{
			if(objDeal.Proj_Closing_Date__c >= Date.today() && objDeal.Proj_Closing_Date__c <= Date.today().addDays(30) && DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('EEEE') == 'Tuesday')
			{
				lstMails.addAll(prepareList(objDeal.Cain_Deal_Teams__r, weeklyReminderId));
			}
			else
			{
				lstMails.addAll(prepareList(objDeal.Cain_Deal_Teams__r, softReminderId));
			}
		}
		if(!lstMails.isEmpty())
			Messaging.sendEmail(lstMails);
	}
	
	global void finish(Database.BatchableContext BC)
	{
		//Do Nothing
	}
	
	private static List<Messaging.Singleemailmessage> prepareList(List<Cain_Deal_Team__c> lstDealTeam, String emailTemplateId)
	{
		List<Messaging.Singleemailmessage> lstMails = new List<Messaging.Singleemailmessage>();
		
		for(Cain_Deal_Team__c objDealTeam : lstDealTeam)
		{
			Messaging.Singleemailmessage objEmail = new Messaging.Singleemailmessage();
			objEmail.setTemplateId(emailTemplateId);
			objEmail.setTargetObjectId(objDealTeam.Team_Member__c);
			lstMails.add(objEmail);
		}		
		return lstMails;
	}
}