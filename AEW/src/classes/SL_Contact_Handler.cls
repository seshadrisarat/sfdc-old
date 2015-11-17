/*
    *  ClassName    : SL_Contact_Handler
    *  JIRATicket   : AEW-12 
    *  CreatedOn    : 07/02/2015
    *  ModifiedBy   : Harsh
    *  Description  : Handler for trigger on Contact Records to send email, create Affiliations and update the Fundraising communication to Inactive. when the AccountId or status is got changed
*/
public class SL_Contact_Handler
{ 
    public static final string str_RETIRED_STATUS = 'Retired';
    public static final string str_Inactive_STATUS = 'Inactive';
    public static final string strEmailTemNameFor_STATUSChange = 'AEW_12_Status_Change';
    public static final string strEmailTemNameFor_ORGChange = 'AEW_12_Organization_Change';
    public static final string strEmailTemNameFor_STATUSANDORGChange = 'AEW_12_Status_and_Organization_Change';
    
    public Map<Id, Account> MapOfAccIdToName;       // Map to keep the OLD and New Account Id to their Name for showing on the Note field while creating Affliations
    /* start - constructor */ 
    public SL_Contact_Handler()
    {
        //Initialize your method those you want to load on the class load...
    }
    
    /*
        * MethodName : onAfterInsert
        * Param      : Map<Id, Contact> mapOfOldContactRecords, Map<Id, Contact> mapOfNewContactRecords
        * Description: method to Before Update of Contact Records
    */
    public void onBeforeUpdate(Map<Id, Contact> mapOfOldContactRecords, Map<Id, Contact> mapOfNewContactRecords)
    {
        filteringContacts(mapOfOldContactRecords, mapOfNewContactRecords);        
    }
    
    /*
        * MethodName : filteringContacts
        * Param      : Map<Id, Contact> mapOfOldContactRecords, Map<Id, Contact> mapOfNewContactRecords
        * Description: method to Filter the contacts whether the Account is updated or the STATUS and then doing the functionalities accordingly
    */
    private void filteringContacts(Map<Id, Contact> mapOfOldContactRecords, Map<Id, Contact> mapOfNewContactRecords){
        Set<Id> setofAllAccIds = new Set<Id>();               // Set to the all OLD and New Account Ids
        Set<Contact> setofContactsChangedAccountId = new Set<Contact>();            // Set to keep those contacts where the AccountId got changed
        Set<Contact> setofContactsChangedStatus = new Set<Contact>();               // Set to keep those contacts where the Status got changed to 'Retired'
        
        // map to keep those contact where both STATUS AND Organisation is updated...
        Map<Id, Contact> mapOfIdToContact = new Map<Id, Contact>();
        
        // Iterating over new Contacts
        for(Contact objCon : mapOfNewContactRecords.values()){
            // getting th oldContact
            Contact objOldContact = mapOfOldContactRecords.get(objCon.Id);
            
            /*** Adding the Old and New AccountIds **/
            setofAllAccIds.add(objCon.AccountId);
            setofAllAccIds.add(objOldContact.AccountId);
            /** ENDS ****/  

			// checking if both changed..
			if(objCon.AccountId != NULL && objCon.AccountId != objOldContact.AccountId && 
					objCon.Status__c != NULL &&  (objCon.Status__c == str_RETIRED_STATUS || objCon.Status__c == str_Inactive_STATUS) && objCon.Status__c != objOldContact.Status__c)
				mapOfIdToContact.put(objCon.Id, objCon);
			                
            // Checking if the AccountId got changed
            if(objCon.AccountId != NULL && objCon.AccountId != objOldContact.AccountId)
                setofContactsChangedAccountId.add(objCon);
            
            // Checking if the STATUS got changed and the same contact should not present in the previous SET
            if(objCon.Status__c != NULL &&  (objCon.Status__c == str_RETIRED_STATUS || objCon.Status__c == str_Inactive_STATUS) && objCon.Status__c != objOldContact.Status__c && !setofContactsChangedAccountId.contains(objCon))
                setofContactsChangedStatus.add(objCon);
        }
        
        // If no contcats found with either accoundId updated OR Status changed then returning 
        if(setofContactsChangedAccountId.isEmpty() && setofContactsChangedStatus.isEmpty())
            return;
        
        if(!setofAllAccIds.isEmpty()){
            // Removing NUll from the set before que
            setofAllAccIds.remove(NULL); 
            MapOfAccIdToName = new Map<Id, Account>([Select Id, Name From Account Where Id IN : setofAllAccIds]);
        }
        
        // calling this fucntion for AccountId OR Status is changes for the contacts
        if(!setofContactsChangedAccountId.isEmpty())
        {
            // calling this method to update the What Id of the Activities
            updateActivityWhatIds(setofContactsChangedAccountId, mapOfOldContactRecords);
            
            // calling this to create Affiliation records
            createAffiliationRecords(setofContactsChangedAccountId, mapOfOldContactRecords);
            
            // Calling this to send the email to the FundRaising Opportunity Contact's owners....ONCE TEMPLATE IS GOT CREATE WE WILL UNCOMENT THIS Method
            sendEmailToTheFundraisingOppConOwners(setofContactsChangedAccountId, mapOfOldContactRecords, false, mapOfIdToContact);
            
            // Calling this to make the Campaign Member and Fund Communication Status to INACTIVE...
            makeInactiveTheFundCommunicationAndCampMember(setofContactsChangedAccountId);
            
            
        }
        // calling this fucntion for only STATUS is changes for the contacts
        if(!setofContactsChangedStatus.isEmpty()){
             // Calling this to send the email to the FundRaising Opportunity Contact's owners...ONCE TEMPLATE IS GOT CREATE WE WILL UNCOMENT THIS Method
            sendEmailToTheFundraisingOppConOwners(setofContactsChangedStatus, mapOfOldContactRecords, true, mapOfIdToContact);
        }
    }
    
    /*
        * MethodName : updateActivityWhatIds
        * Param      : Set<Contact> setofContactsChangedAccountId, Map<Id, Contact> mapOfOldContactRecords
        * Description: method to Update the Old Account of the Contact to the WhatId field on the relate Activities
    */
    private void updateActivityWhatIds(Set<Contact> setofContactsChangedAccountId, Map<Id, Contact> mapOfOldContactRecords)
    {
        List<Task> lstTasksToUpdateWhatId = new List<Task>();
        List<Event> lstEventsToUpdateWhatId = new List<Event>();
        
        // Collecting the Task records whose WHoId is BLANK and WhoId is the contacts whose AccId is changed
        for(Task objTask : [Select Id, WhoId, WhatId From Task Where WhatId = NULL AND WhoId IN : setofContactsChangedAccountId])
        {
            if(mapOfOldContactRecords.containsKey(objTask.WhoId))
            {
                objTask.WhatId = mapOfOldContactRecords.get(objTask.WhoId).AccountId;
                lstTasksToUpdateWhatId.add(objTask);
            }
        }
        
        // Collecting the Event records whose WHoId is BLANK and WhoId is the contacts whose AccId is changed
        for(Event objEvent : [Select Id, WhoId, WhatId From Event Where WhatId = NULL AND WhoId IN : setofContactsChangedAccountId])
        {
            if(mapOfOldContactRecords.containsKey(objEvent.WhoId))
            {
                objEvent.WhatId = mapOfOldContactRecords.get(objEvent.WhoId).AccountId;
                lstEventsToUpdateWhatId.add(objEvent);
            }
        }
        
        // Updating the Activities
        Database.update(lstTasksToUpdateWhatId, false);
		Database.update(lstEventsToUpdateWhatId, false);
    }
    
    /*
        * MethodName : createAffiliationRecords
        * Param      : Set<Contact> setofContactsChangedAccountId, Map<Id, Contact> mapOfOldContactRecords
        * Description: method to Create Affiliation records where the Contact's Account is changed
    */
    private void createAffiliationRecords(Set<Contact> setofUpdateContacts, Map<Id, Contact> mapOfOldContactRecords)
    {
        List<Affiliation__c> lstAffiliationsToInsert = new List<Affiliation__c>();
        // Iterating on Contact for inserting the Affiliation records 
        for(Contact objCon : setofUpdateContacts)
        {
            Affiliation__c objAffiliation = new Affiliation__c(Organization__c = mapOfOldContactRecords.get(objCon.Id).AccountId, 
                                                                Role__c = 'Previous Employee', 
                                                                Contact__c  = objCon.Id, 
                                                                Note__c  = 'Contact was moved to New Organization(' +MapOfAccIdToName.get(objCon.AccountId).Name+ ') on [' +DateTime.Now().format('MM/dd/YYYY')+ '].');
            lstAffiliationsToInsert.add(objAffiliation);
        }
        
        Database.insert(lstAffiliationsToInsert, false);
    }
    
    /*
        * MethodName : sendEmailToTheFundraisingOppConOwners
        * Param      : Set<Contact> setofContactsChangedAccountId
        * Description: method for Sending email the Open Fundraising Opportunity owners
    */
    private void sendEmailToTheFundraisingOppConOwners(Set<Contact> setOfupdateContacts, Map<Id, Contact> mapOfOldContactRecords, boolean IsOnlyStatusChanged, Map<Id, Contact> mapOfbothStatusAndOrganisationChanged)
    {
        /***** Getting the email Templated ****/
        EmailTemplate objEmailForStatus; 
        EmailTemplate objEmailForOrganisation;
        EmailTemplate objEmailForBothStatusAndOrg;
        
        //Fetch email Template id for STATUS
		for (EmailTemplate objEmailTemplate : [SELECT Body,HtmlValue, Subject,id FROM EmailTemplate WHERE DeveloperName =: strEmailTemNameFor_STATUSChange])
		{
			objEmailForStatus = objEmailTemplate;
		}
        
        //Fetch email Template id for Orgainsation
		for (EmailTemplate objEmailTemplate : [SELECT Body,HtmlValue, Subject, id FROM EmailTemplate WHERE DeveloperName =: strEmailTemNameFor_ORGChange])
		{
			objEmailForOrganisation = objEmailTemplate;
		}
		
		//Fetch email Template id for STATUS AND ORGNISATION
		for (EmailTemplate objEmailTemplate : [SELECT Body, HtmlValue, Subject, id FROM EmailTemplate WHERE DeveloperName =: strEmailTemNameFor_STATUSANDORGChange])
		{
			objEmailForBothStatusAndOrg = objEmailTemplate;
		}
        
        // If no email template found retruning from here only...
        if(objEmailForStatus == NULL && objEmailForOrganisation == NULL && objEmailForBothStatusAndOrg == NULL)
        	return;
        /**** ENDS ***/
        
        List<Messaging.SingleEmailMessage> lstmails = new List<Messaging.SingleEmailMessage>();
        String strBaseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        Map<Id, List<Fundraising_Opportunity_Contact__c>> mapOfContactIdTolistOfFundOppCon = new Map<Id, List<Fundraising_Opportunity_Contact__c>>();
        Set<Id> setOfFundOpportunityIds = new Set<Id>();            // Set to keep the FunRaising OpportuntiyIds
        
        for(Fundraising_Opportunity_Contact__c objFundOppContact : [Select Id, Contact__c, Fundraising_Opportunity__c, Fundraising_Opportunity__r.AEW_Point_Person__c, 
                                                                            Fundraising_Opportunity__r.AEW_Point_Person__r.Name, Fundraising_Opportunity__r.AEW_Point_Person__r.email, Fundraising_Opportunity__r.View__c
                                                                    From Fundraising_Opportunity_Contact__c
                                                                    Where Fundraising_Opportunity__r.IsOpen__c = TRUE 
                                                                            AND Fundraising_Opportunity__r.AEW_Point_Person__c != NULL
                                                                            AND Contact__c IN : setOfupdateContacts 
                                                                    ])
        {
            setOfFundOpportunityIds.add(objFundOppContact.Fundraising_Opportunity__c);
            
            if(!mapOfContactIdTolistOfFundOppCon.containsKey(objFundOppContact.Contact__c))
                mapOfContactIdTolistOfFundOppCon.put(objFundOppContact.Contact__c, new List<Fundraising_Opportunity_Contact__c>());
            
            mapOfContactIdTolistOfFundOppCon.get(objFundOppContact.Contact__c).add(objFundOppContact);
        }
        
        // if no Fundraising Opp Contact is there related to this Contact then no need to send any email and returning from here.
        if(setOfFundOpportunityIds.isEmpty())
           return;
        
        // Getting the FundRaising Values
        Map<Id, Fundraising_Opportunity__c> mapOfFundOpenOpprtunities = new Map<Id, Fundraising_Opportunity__c>([Select Id, View__c, Name From Fundraising_Opportunity__c Where Id IN : setOfFundOpportunityIds]);
        
        // Iterating over the Contact records to prepare the email
        for(Contact objContact : setOfupdateContacts)
        {
        	Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
            Set<String> setOfToAddresses = new Set<String>();
            List<String> lstUniqueToAddress = new List<String>();
            Set<String> setOfUniquesFundRaiseOppNames = new Set<String>();
        	String strBody = '';
        	EmailTemplate objEmailTemp;	// Assigning the Email Template......
        	String strbodyForOpps = '<br/> <br/>'; 		// String taken to add the Open Fundraising Opportunities in the email
        	
        	String strOLDStatus = mapOfOldContactRecords.get(objContact.Id).Status__c != NULL ? mapOfOldContactRecords.get(objContact.Id).Status__c : '--NONE--';
        	// getting old ACC Id and name
        	String strOldAccId = MapOfAccIdToName.get(mapOfOldContactRecords.get(objContact.Id).AccountId).Id;
        	String strOldAccName = MapOfAccIdToName.get(mapOfOldContactRecords.get(objContact.Id).AccountId).Name;
        	
			// New Acc Name and Id...            	
        	String strNewAccId = MapOfAccIdToName.get(objContact.AccountId).Id;
        	String strNewAccName = MapOfAccIdToName.get(objContact.AccountId).Name;
        	
        	String strContactName = objContact.FirstName != NULL ? (objContact.FirstName + ' ' +objContact.LastName) : objContact.LastName;
        	
        	// Checking and initializing the value to the emailTemplate based n mapOfbothStatusAndOrganisationChanged
            if(!mapOfbothStatusAndOrganisationChanged.isEmpty() && mapOfbothStatusAndOrganisationChanged.containsKey(objContact.Id))
            {
            	objEmailTemp = objEmailForBothStatusAndOrg;
            	strBody = getEmailTemplateBody(objEmailTemp.Id);		// Calling this method to get the email HTML body...
				
				//Replacing the Contact Name
				strBody = strBody.replace('NAME', '<a href = "'  +strBaseURL+ '/' + objContact.Id + '">' + strContactName + '</a>');
				// Replacing the "PREVIOUS_STATUS" and "New_STATUS" values..
            	strBody = strBody.replace('PREVIOUS_STATUS', strOLDStatus);
            	strBody = strBody.replace('NEW_STATUS', objContact.Status__c);
            	strBody = strBody.replace('PREVIOUS_ORGANIZATION', '<a href = "'  +strBaseURL+ '/' + strOldAccId + '">' + strOldAccName + '</a>');
            	strBody = strBody.replace('NEW_ORGANIZATION', '<a href = "'  +strBaseURL+ '/' + strNewAccId + '">' + strNewAccName + '</a>');
            }
            else if(IsOnlyStatusChanged)
            {
            	objEmailTemp = objEmailForStatus;
            	strBody = getEmailTemplateBody(objEmailTemp.Id);		// Calling this method to get the email HTML body...
            	
            	//Replacing the Contact Name
				strBody = strBody.replace('NAME', '<a href = "'  +strBaseURL+ '/' + objContact.Id + '">' + strContactName + '</a>');
            	strBody = strBody.replace('PREVIOUS_STATUS', strOLDStatus);
            	strBody = strBody.replace('NEW_STATUS', objContact.Status__c);
            }
            else
            {
            	objEmailTemp = objEmailForOrganisation;
            	strBody = getEmailTemplateBody(objEmailTemp.Id);		// Calling this method to get the email HTML body...
            	
            	//Replacing the Contact Name
				strBody = strBody.replace('NAME', '<a href = "'  +strBaseURL+ '/' + objContact.Id + '">' + strContactName + '</a>');
            	strBody = strBody.replace('PREVIOUS_ORGANIZATION', '<a href = "'  +strBaseURL+ '/' + strOldAccId + '">' +strOldAccName+ '</a>');
            	strBody = strBody.replace('NEW_ORGANIZATION', '<a href = "'  +strBaseURL+ '/' + strNewAccId + '">' + strNewAccName + '</a>');
            }
            
			// If we have any child FundRaising Opportunity Contact records
            if(mapOfContactIdTolistOfFundOppCon.containsKey(objContact.id))
            {
                // Iterating the Fundraising Opp Contact records
                for(Fundraising_Opportunity_Contact__c objFundOppCon : mapOfContactIdTolistOfFundOppCon.get(objContact.id))
                {
                    setOfToAddresses.add(objFundOppCon.Fundraising_Opportunity__r.AEW_Point_Person__r.email);
                    
                    
                    if(mapOfFundOpenOpprtunities.containsKey(objFundOppCon.Fundraising_Opportunity__c))
                    {
                        String strName = mapOfFundOpenOpprtunities.get(objFundOppCon.Fundraising_Opportunity__c).Name;      // Keeping the FundRaising Opportunity Name
                        if(!setOfUniquesFundRaiseOppNames.contains(strName))
                        {
                            setOfUniquesFundRaiseOppNames.add(strName);
                            strbodyForOpps += strName + ' - <a href = "' +strBaseURL+ '/' +objFundOppCon.Fundraising_Opportunity__c+ '"> ' +strName+ ' </a><br/><br/>';
                        }
                    }
                }
                
                // Adding the Thanks at the End of the content..
                strbodyForOpps += 'Thanks';
                
                // Adding all the unique emails address from the FundRaising Opportunities
                lstUniqueToAddress.addAll(setOfToAddresses);
				
				String strSubject = objEmailTemp.Subject;
				strSubject = strSubject.replace('NAME', '"'+ strContactName+ '"');
				objEmailTemp.Subject = strSubject;
				
				objMail.setSubject(objEmailTemp.Subject);
				// setting the toAddresses
                objMail.setToAddresses(lstUniqueToAddress);
                
                objMail.setSaveAsActivity(false);
                
                // Adding the Fundraising Opportunities.....as link 
                strBody = strBody.replace('Contact:', 'Contact:'+strbodyForOpps);
                objMail.setHtmlBody(strBody);
            }
            lstmails.add(objMail);
        }
        
        // Sending the email
        if(!lstmails.isEmpty())
            If(!Test.isRunningTest()) Messaging.sendEmail(lstmails);
                                                                        
    }
    
    /*
        * MethodName : getEmailTemplateBody
        * Param      : Id objEmailTemplateId
        * Description: method to get the Email HTML body.
    */
    private String getEmailTemplateBody(Id objEmailTemplateId)
    {
		String mailHtmlBody = '';
		try
		{
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setSaveAsActivity(false);
			mail.setTargetObjectId(UserInfo.getUserId());
			mail.setTemplateId(objEmailTemplateId);
		   
			Savepoint sp = Database.setSavepoint();
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
			Database.rollback(sp);
		   
			mailHtmlBody = mail.getHTMLBody();
		}
		catch(Exception ex) {
			system.debug('## Exception in getting Email Template body : ' + ex);
		}
		 
		return mailHtmlBody;
    } 
    
    /*
        * MethodName : makeInactiveTheFundCommunicationAndCampMember
        * Param      : Set<Contact> setofContactsChangedAccountId
        * Description: method to update the Contact Stataus to INACTIVE of both relate "Fund Communication and" and "Campaign Members" 
    */
    private void makeInactiveTheFundCommunicationAndCampMember(Set<Contact> setOfUpdateContacts)
    {
        List<Fund_Communication_Recipient__c> lstFundCommunicationsReciptentToMakeInactive = new List<Fund_Communication_Recipient__c>();
        List<CampaignMember> lstCampignMembersToMakeInactive = new List<CampaignMember>();
        
        // Collecting all the realted Fund Communication records..changed to Fund_Communication_Recipient__c from Fund_Communication__c as per AEW-12 latest requirement...
        for(Fund_Communication_Recipient__c objFundCommunicationReciptent : [Select Id, Contact__c, Contact_Status__c From Fund_Communication_Recipient__c Where Contact__c IN : setOfUpdateContacts AND Contact_Status__c  != 'InActive'])
        {
            objFundCommunicationReciptent.Contact_Status__c = 'Inactive';
            lstFundCommunicationsReciptentToMakeInactive.add(objFundCommunicationReciptent);
        }
        // Coleecting all the realted CampaignMember records
        for(CampaignMember objCampaignMember : [Select Id, ContactId, Contact_Status__c From CampaignMember Where ContactId IN : setOfUpdateContacts AND Contact_Status__c != 'InActive'])
        {
            objCampaignMember.Contact_Status__c = 'Inactive';
            lstCampignMembersToMakeInactive.add(objCampaignMember);
        }
        
        // Updating the Fund commission Contact Status
		Database.update(lstFundCommunicationsReciptentToMakeInactive , false);
        // Updating the campaignMember commission Contact Status    
		Database.update(lstCampignMembersToMakeInactive, false);
    }
}