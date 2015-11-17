/*

Modified: Privlad 02/23/2010 - task: 956

*/
trigger sendEmailsTrigger on Ibanking_Project__c (after insert, after update) {
	
	List<OrgWideEmailAddress> oweaList = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName='Salesforce Admin' limit 1];
	List<Structure> structureList = new List<Structure>();

    Map<Id,List<Project_Resource__c>> projectResourcesMap = getProjectResourcesMap();
    List<EmailTemplate> emailTemplateList = [select Id, developerName from EmailTemplate];
	
	
	string tmpParam;
    for(integer i=0; i<trigger.new.size(); i++)
    {
        // fetching the new & old deals
        final Ibanking_Project__c oldDeal = (Trigger.isInsert)?null:((Ibanking_Project__c) Trigger.old[i]); 
        final Ibanking_Project__c newDeal = (Ibanking_Project__c) Trigger.new[i];
        
        system.debug('newDeal.EmailTriggerParamsFlag__c===' + newDeal.EmailTriggerParamsFlag__c);
		tmpParam = newDeal.EmailTriggerParamsFlag__c;
		system.debug('UserInfo.getUserId()------------------------------->'+UserInfo.getUserId());
		//if (UserInfo.getUserId()=='00530000003YdqjAAC')tmpParam = 'MOELIS_TEAM, ProjectClosedWon';
        if (tmpParam != null && tmpParam != '' ) {
                
            // splitting emailTriggerParams data
            String [] emailTriggerParamsArr = tmpParam.split(',', 2);
            emailTriggerParamsArr[0] = emailTriggerParamsArr[0].trim();
            emailTriggerParamsArr[1] = emailTriggerParamsArr[1].trim();
                
            Id templateId = null;
            List<String> emailList = new List<String>();
            if (emailTriggerParamsArr[0] == 'STAFFER') {
                system.debug('=== STAFFER ===');
                templateId = getTemplateIdByName(emailTriggerParamsArr[1]);
                if (templateId != null) {
                    //emailList.add(newDeal.Staffer_Email__c);//_r.User_ID__r.Email);
                    //sendMassEmails(newDeal.Id, templateId, emailList);
                    
                    // DELETE FIELD: Staffer_Email__c!!!!!!!!!!!!!!!!!!!!
                    //Was Comment!!!   sendSingleEmails(newDeal.Id, templateId, newDeal.Staffer_Email__c); 
                }
            } else if (emailTriggerParamsArr[0] == 'MOELIS_TEAM') {
                system.debug('=== MOELIS_TEAM ===');
                templateId = getTemplateIdByName(emailTriggerParamsArr[1]);
                if (templateId != null) 
                { 
			        
			        String[] ccAddresses = new String[]{};   
			        Emails__c Emails = Emails__c.getOrgDefaults();
			        system.debug(Emails);
			        if(Emails != null)
			        {
			        	String Moelis_CompanyAccountingEmail = Emails.MoelisCompanyEmail__c;
			        	if(Moelis_CompanyAccountingEmail != null  && Moelis_CompanyAccountingEmail != '')ccAddresses.add(Moelis_CompanyAccountingEmail);
			        	String Moelis_PublicGroup = Emails.Group_Name__c;
			        	if (Moelis_PublicGroup != null && Moelis_PublicGroup != '')
			        	{
			        		List<Id> UserIds = new List<Id>();
			        		for(GroupMember item : 
			        						[Select UserOrGroupId, SystemModstamp, Id, Group.Name, GroupId From GroupMember  where Group.Name =: Moelis_PublicGroup])
			        				UserIds.add(item.UserOrGroupId);
			        		if(UserIds.size() > 0)
			        		{
			        			for(User item : [Select Email From User Where Id IN: UserIds]) 
			        			{
			        				if (item.Email != null && item.Email != '')ccAddresses.add(item.Email);
			        			}
			        		}
			        	}
			        }
			        
			        String[] toAddresses = new String[]{}; 
			        Set<String> toAddressesSet = new Set<String>(); 
			        String newTargetObjectId;
					Boolean isFirst = true;
					Lead objLead;
					for(Project_Resource__c item: projectResourcesMap.get(newDeal.Id)) 
					{
			          if (item.Banker__r.User_ID__r.Email != null) 
			          {
						if(isFirst)
						{
							objLead = new Lead( LastName='TestLastNameNeedDelete', CurrencyIsoCode = 'USD', Company = 'TestCompany',  Email = item.Banker__r.User_ID__r.Email);
							insert objLead;
							newTargetObjectId = objLead.Id; 
							toAddressesSet.add(item.Banker__r.User_ID__r.Email); 
							isFirst = false;
						}
						else 
						{ 
							if(!toAddressesSet.contains(item.Banker__r.User_ID__r.Email))
							{
								toAddresses.add(item.Banker__r.User_ID__r.Email);
								toAddressesSet.add(item.Banker__r.User_ID__r.Email); 
							}
							system.debug(toAddresses.size()+' ---1- '+toAddresses);
						}
			          }
			          if(item.Banker__r.Asst_Email__c != null) 
			          {
			          	if(!toAddressesSet.contains(item.Banker__r.Asst_Email__c))
						{
							toAddresses.add(item.Banker__r.Asst_Email__c);
							toAddressesSet.add(item.Banker__r.Asst_Email__c); 
						}
			          	system.debug(toAddresses.size()+' ---2- '+toAddresses);
			          }
					}
                
		            system.debug('objLead------------------>'+objLead);
					system.debug('newTargetObjectId------------------>'+newTargetObjectId);  
		            system.debug('toAddresses------------------>'+toAddresses);    
		            system.debug('ccAddresses------------------>'+ccAddresses); 
		            if(newTargetObjectId != null && newTargetObjectId != '')
		            {        
			            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				        mail.setSaveAsActivity(false);
				        mail.setWhatId(newDeal.Id);               // which object
				        mail.setTemplateId(templateId);       // which template
				        mail.setTargetObjectId(newTargetObjectId);     // which recipient (must be user or contact or like those)
				        system.debug('newTargetObjectId----------------'+newTargetObjectId);
				       
				        if(toAddresses.size() > 0)	mail.setToAddresses(toAddresses);
				        if(ccAddresses.size() > 0)	mail.setCcAddresses(ccAddresses);
				        if (oweaList.size() > 0)   	mail.setOrgWideEmailAddressId(oweaList[0].Id); 
				        
				        List<Messaging.SendEmailResult> result;
				        try {
				            result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				            system.debug('=== EMAIL SENT SUCCESSFULLY ========');
				        } catch (EmailException e){
				            system.debug('=== EMAIL EXCEPTION ======== sendEmail.result===' + result + ' - e.mess===' + e.getMessage());
				        } catch (Exception e){
				        	system.debug('=== ANOTHER EXCEPTION ======== ' + result + ' - e.mess===' + e.getMessage());
				        }
		            }
		           if (objLead != null )  delete objLead;
                    
                } // if
            } // if-else
        } // if
    }
     
    
    
 	//sendSingleEmails();
    
    
    // sending mass emails
    private void sendSingleEmails() {
        system.debug('==== sendSingleEmail =====');
        /*
        
        
		List<Lead> contactList = new List<Lead>();
		for(Structure item : structureList) 
			contactList.add(new Lead( LastName='TestLastNameNeedDelete', CurrencyIsoCode = 'USD', Company = 'TestCompany',  Email = item.emailStr));
		insert contactList;
        
		 
       // system.debug('contactList----------------'+contactList); 
        Structure curStructure;
       // system.debug('structureList----------------'+structureList); 
		for(Integer i = 0; i < structureList.size(); i++) {
			curStructure = structureList.get(i);
	        // sending emails
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        mail.setSaveAsActivity(false);
	        mail.setWhatId(curStructure.dealId);               // which object
	        mail.setTemplateId(curStructure.templateId);       // which template
	        mail.setTargetObjectId(contactList.get(i).Id);     // which recipient (must be user or contact or like those)
	        system.debug(' mail.setTargetObjectId(contactList.get(i).Id)----------------'+mail.setTargetObjectId(contactList.get(i).Id));
	        if (oweaList.size() > 0) 
	        	mail.setOrgWideEmailAddressId(oweaList[0].Id); 
	        
	        List<Messaging.SendEmailResult> result;
	        try {
	            result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	            system.debug('=== EMAIL SENT SUCCESSFULLY ========');
	        } catch (EmailException e){
	            system.debug('=== EMAIL EXCEPTION ======== sendEmail.result===' + result + ' - e.mess===' + e.getMessage());
	        } catch (Exception e){
	        	system.debug('=== ANOTHER EXCEPTION ======== ' + result + ' - e.mess===' + e.getMessage());
	        }
		}
        
        
        //delete contactList;
        delete contactList;
        */
    }
    
    // getting a template id by its name
    private Id getTemplateIdByName(String templateName) {
        Id resultId = null;
        for(EmailTemplate item: emailTemplateList) {
            if (item.developerName == templateName) {
                resultId = item.Id;
                break;
            }
        }
        system.debug('getTemplateIdByName(String templateName)===' + resultId);
        return resultId;
    }
    
    // preparing a map dealId<->list<Project_Resource__c> 
    private Map<Id,List<Project_Resource__c>> getProjectResourcesMap() {
        // fetching a new deal id list
        List<Id> newDealIdList = new List<Id>();
        for (Ibanking_Project__c ip : Trigger.new) newDealIdList.add(ip.Id);
        
        // fetching all project resources
        List<Project_Resource__c> projectResourceList = [select pr.Banker__r.User_ID__r.Email, pr.Banker__r.User_ID__c, pr.Project__c, pr.Banker__r.Asst_Email__c from Project_Resource__c pr where pr.Project__c in :newDealIdList];
        
        Map<Id,List<Project_Resource__c>> projResourcesMap = new Map<Id,List<Project_Resource__c>>();
        for(Id idItem: newDealIdList) {
            List<Project_Resource__c> prList = new List<Project_Resource__c>();
            for(Project_Resource__c prItem: projectResourceList) {
                if (prItem.Project__c == idItem) {
                    prList.add(prItem);
                }
            }
            projResourcesMap.put(idItem,prList);
        }
        return projResourcesMap;
    }
    
	public class Structure {
    	public String templateId {get;set;}
    	public String dealId     {get;set;}
    	public String emailStr   {get;set;}
    	public Structure(String p_templateId, String p_dealId, String p_emailStr) {
    		templateId = p_templateId;
    		dealId     = p_dealId;
    		emailStr   = p_emailStr;
    	}
    }
    
}