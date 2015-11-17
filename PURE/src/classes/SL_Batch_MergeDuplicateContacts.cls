/**
* \arg ClassName      : SL_Batch_MergeDuplicateContacts
* \arg JIRATicket     : PURE-64
* \arg CreatedOn      : 6th/Feb/2015
* \arg LastModifiedOn : 18th/Feb/2015
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : Sandeep
* \arg Description    : This batch process is used to merge duplicate contacts.
*/
global class SL_Batch_MergeDuplicateContacts implements Database.Batchable<sObject>
{
	
	/* Start - Constructor */
	global SL_Batch_MergeDuplicateContacts()
	{
		/* Do nothing */
	}
	/* End - Constructor */
   
	/* Start Method */
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		Map<String, SL_BatchContactLastTime__c> mapCustomSetNameTofieldValue = new Map<String, SL_BatchContactLastTime__c>();
		
		/* Getting recordTypeId of Contact of type 'Broker Contact' */ 
		String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Broker Contact').getRecordTypeId();
		
		/* Fetching Custom setting values */
		if(!SL_BatchContactLastTime__c.getAll().isEmpty())
			mapCustomSetNameTofieldValue = SL_BatchContactLastTime__c.getAll();
		
		/* Fetching the AccountId of account names as 'Dummy Broker for Agent View Broker Contacts' */
		List<Account> lstAccount = [SELECT Id FROM Account WHERE Name = 'Broker View Contacts' LIMIT 1];
        
        String strAccountId = (!lstAccount.isEmpty()) ? lstAccount[0].Id : '';
		String strQuery = 'SELECT Id,Email, Name, Description, AccountId, Phone, OtherStreet, OtherState, OtherPostalCode, OtherPhone, OtherCountry, OtherCity, Occupation__c,'+
        				  'MobilePhone, Marital_Status__c, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity, LastName, FirstName, LeadSource,'+
        				  'Department, Contact_Name__c, Contact_External_ID__c, Company_Name__c, Birthdate, AssistantPhone, AssistantName, Title, Fax, Registered_for_Portal__c,'+
        				  'Salutation, ReportsToId, OtherLongitude, OtherLatitude, EmailBouncedReason, EmailBouncedDate, HasAnotherRole__c, CreatedDate,'+
        				  'EDW_Last_Modified_Date__c, Employer_Name__c, Password__c, Primary__c, Role__c, RowHash__c, Suffix__c, Work_Phone__c, HomePhone,' +
        				  'User_Name__c, User_Type__c, Agency_Admin_Role__c, Active__c, OwnerId FROM Contact WHERE Email != null AND recordTypeId =' + '\'' + contactRecordTypeId  + 
        				  '\' AND AccountId != '+ '\'' + strAccountId + '\'';
		
		
		if(!mapCustomSetNameTofieldValue.isEmpty() && mapCustomSetNameTofieldValue.get('BatchTime').Last_Executed__c != null)
		{
			String createdDateFormate = mapCustomSetNameTofieldValue.get('BatchTime').Last_Executed__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
			strQuery += ' AND CreatedDate >= ' + createdDateFormate ;
		}
		
		strQuery += ' Order By CreatedDate ASC'; 
		return Database.getQueryLocator(strQuery); 
	}
	   
	/* Execute Method */
	global void execute(Database.BatchableContext BC, List<Contact> lstNewContact)
	{
		List<Contact> lstContactToDelete = new List<Contact>();
		List<Note> lstNotesToInsert = new List<Note>();
		List<CampaignMember> lstCampaignMemberToInsert = new List<CampaignMember >();
		List<Event> lstEventToInsert = new List<Event>();
		List<Task> lstTaskToInsert = new List<Task>();
		List<Attachment> lstAttachmentToInsert = new List<Attachment>();
		List<FeedItem> lstFeedItemToInsert = new List<FeedItem>();
		Set<Id> setConIdToDelete = new Set<Id>();
		Map<Id, Contact> mapId_Contact = new Map<Id, Contact>();
		Map<Id, Contact> mapContactIdToBroberContact = new Map<Id, Contact>();
		Map<String, List<Contact>> mapEmailAddress_lstContact = new Map<String, List<Contact>>();
		
		Map<String, List<CampaignMember>> mapContactEmailToLstOfCM = new Map<String, List<CampaignMember>>();
		Map<String, List<FeedItem>> mapContactEmailtoListFeedItem = new Map <String, List<FeedItem>> ();
		Map<String, List<Note>> mapContactEmailtoListNote = new Map <String, List<Note>>();
		Map<String, List<Attachment>> mapContactEmailToListAttachment = new Map<String, List<Attachment>>(); 
		Map<String, List<Task>> mapContactEmailToLstOfTask = new Map<String, List<Task>>();
		Map<String, List<Event>> mapContactEmailToLstOfEvent = new Map<String, List<Event>>();
			
		for(Contact objContact : lstNewContact)
		{
			if(!mapEmailAddress_lstContact.containsKey(objContact.Email.toLowerCase()))
				mapEmailAddress_lstContact.put(objContact.Email.toLowerCase(), new List<Contact>{objContact} );
			else
				mapEmailAddress_lstContact.get(objContact.Email.toLowerCase()).add(objContact);
			mapContactIdToBroberContact.put(objContact.Id, objContact);
		}	
		
		for(Attachment objAttachment : [SELECT Id, 
											   Name, 
											   ParentId, 
											   Body 
									      FROM Attachment 
									     WHERE ParentId IN: mapContactIdToBroberContact.keySet()])
		{
			if(!mapContactEmailToListAttachment.containsKey(mapContactIdToBroberContact.get(objAttachment.ParentId).Email.toLowerCase()))
				mapContactEmailToListAttachment.put(mapContactIdToBroberContact.get(objAttachment.ParentId).Email.toLowerCase(),new List <Attachment>{objAttachment});
			else
				mapContactEmailToListAttachment.get(mapContactIdToBroberContact.get(objAttachment.ParentId).Email.toLowerCase()).add(objAttachment);
		}
		
		for(Note objNote : [SELECT Id, 
								   Title, 
								   ParentId, 
								   OwnerId, 
								   Body 
							  FROM Note 
							 WHERE ParentId IN: mapContactIdToBroberContact.keySet()])
		{
			if(!mapContactEmailtoListNote.containsKey(mapContactIdToBroberContact.get(objNote.ParentId).Email.toLowerCase()))
				mapContactEmailtoListNote.put(mapContactIdToBroberContact.get(objNote.ParentId).Email.toLowerCase(), new List<Note>{objNote});
			else
				mapContactEmailtoListNote.get(mapContactIdToBroberContact.get(objNote.ParentId).Email.toLowerCase()).add(objNote);
		}

		for(Task objTask : [SELECT Id, 
								   WhoId,
								   RecurrenceType,
								   RecurrenceTimeZoneSidKey,
								   RecurrenceStartDateOnly,
								   RecurrenceMonthOfYear,
								   RecurrenceInterval,
								   RecurrenceInstance,
								   RecurrenceEndDateOnly,
								   RecurrenceDayOfWeekMask,
								   RecurrenceDayOfMonth,
								   ActivityDate, 
								   ReminderDateTime,
								   IsRecurrence,
								   Priority, 
								   Subject,
								   IsReminderSet, 
								   WhatId, 
								   Type, 
								   Status, 
								   RecordTypeId, 
								   Description__c, 
								   Description 
							  FROM Task 
							 WHERE WhoId IN: mapContactIdToBroberContact.keySet()])
		{
			if(!mapContactEmailToLstOfTask.containsKey(mapContactIdToBroberContact.get(objTask.WhoId).Email.toLowerCase()))
				mapContactEmailToLstOfTask.put((mapContactIdToBroberContact.get(objTask.WhoId).Email.toLowerCase()), new List<Task>{objTask});
			else
				mapContactEmailToLstOfTask.get(mapContactIdToBroberContact.get(objTask.WhoId).Email.toLowerCase()).add(objTask);
		}

		for(Event objEvent : [SELECT Id, 
									 WhoId, 
									 WhatId, 
									 Zone__c, 
									 Location,
									 IsRecurrence,
									 Event_Address__c, 
									 Hosting_Sales_Manager__c, 
									 Estimated_of_Attendees__c, 
									 State__c, Subject, 
									 OwnerId,
									 IsReminderSet ,
									 RecurrenceStartDateTime , 
									 RecurrenceEndDateOnly,
									 Meeting_Type__c, 
									 EndDateTime, 
									 Description__c, 
									 Description, 
									 ActivityDateTime, 
									 ActivityDate, 
									 AccountId,
									 ReminderDateTime,
									 RecurrenceDayOfMonth,
									 RecurrenceTimeZoneSidKey,
									 RecurrenceDayOfWeekMask, 
									 RecurrenceType ,
									 RecurrenceInterval, 
									 RecurrenceInstance 
							    FROM Event 
							   WHERE WhoId IN: mapContactIdToBroberContact.keySet()])
		{
			if(!mapContactEmailToLstOfEvent.containsKey(mapContactIdToBroberContact.get(objEvent.WhoId).Email.toLowerCase()))
				mapContactEmailToLstOfEvent.put(mapContactIdToBroberContact.get(objEvent.WhoId).Email.toLowerCase(), new List<Event>{objEvent});
			else
				mapContactEmailToLstOfEvent.get(mapContactIdToBroberContact.get(objEvent.WhoId).Email.toLowerCase()).add(objEvent);
		}
		
		for(FeedItem objFeedItem : [SELECT Id,
										   Visibility, 
										   Type, 
										   NetworkScope, 
										   LinkUrl, 
										   ContentType, 
										   ContentFileName, 
										   ContentDescription, 
										   ContentData, 
										   ParentId, 
										   Body
									  FROM FeedItem 
									 WHERE ParentId IN: mapContactIdToBroberContact.keySet() AND Type != 'PollPost'])
		{
				if(!mapContactEmailtoListFeedItem.containsKey(mapContactIdToBroberContact.get(objFeedItem.ParentId).Email.toLowerCase()))
					mapContactEmailtoListFeedItem.put(mapContactIdToBroberContact.get(objFeedItem.ParentId).Email.toLowerCase(), new List<FeedItem>{objFeedItem});
				else
					mapContactEmailtoListFeedItem.get(mapContactIdToBroberContact.get(objFeedItem.ParentId).Email.toLowerCase()).add(objFeedItem);
		}
		
		for(CampaignMember objCM : [SELECT Id, 
										   ContactId, 
										   LeadId, 
										   Status, 
										   CampaignId 
									  FROM CampaignMember 
									 WHERE ContactId IN: mapContactIdToBroberContact.keySet()])
		{
			if(!mapContactEmailToLstOfCM.containsKey(mapContactIdToBroberContact.get(objCM.ContactId).Email.toLowerCase()))
				mapContactEmailToLstOfCM.put(mapContactIdToBroberContact.get(objCM.ContactId).Email.toLowerCase(), new List<CampaignMember>{objCM});
			else
				mapContactEmailToLstOfCM.get(mapContactIdToBroberContact.get(objCM.ContactId).Email.toLowerCase()).add(objCM);
		}
		
		for(Contact objContactAgent : [SELECT Id, 
											  Email, 
											  Name, 
											  Description, 
											  AccountId, 
											  Phone, 
											  OtherStreet,
											  OtherState, 
											  OtherPostalCode, 
									     	  OtherPhone, 
									     	  OtherCountry, 
									     	  OtherCity, 
									     	  Occupation__c,
									     	  MobilePhone, 
									     	  Marital_Status__c, 
									     	  MailingStreet, 
									     	  MailingState, 
									     	  MailingPostalCode, 
									     	  MailingCountry, 
									     	  MailingCity, 
									     	  LastName, 
									     	  FirstName, 
									     	  LeadSource,
									     	  Department, 
									     	  Contact_Name__c, 
									     	  Contact_External_ID__c, 
									     	  Company_Name__c, 
									     	  Birthdate, 
									     	  AssistantPhone, 
									     	  AssistantName, 
									     	  Title, 
									     	  Fax, 
									     	  Salutation, 
									     	  ReportsToId, 
									     	  OtherLongitude, 
									     	  OtherLatitude, 
									     	  EmailBouncedReason, 
									     	  EmailBouncedDate, 
									     	  HasAnotherRole__c, 
									     	  EDW_Last_Modified_Date__c, 
									     	  Employer_Name__c, 
									     	  Password__c, 
									     	  Primary__c, 
									     	  Role__c, 
									     	  RowHash__c, 
									     	  Suffix__c, 
									     	  Work_Phone__c, 
									     	  HomePhone, 
									     	  User_Name__c, 
									     	  User_Type__c, 
									     	  Agency_Admin_Role__c, 
									     	  Active__c, 
									     	  Registered_for_Portal__c
		    							 FROM Contact 
		    							WHERE AccountId =: [SELECT Id FROM Account WHERE Name = 'Broker View Contacts'].Id
		    							  AND Email IN:mapEmailAddress_lstContact.keySet()])
		{
			mapId_Contact.put(objContactAgent.Id, objContactAgent);
			
			if(mapEmailAddress_lstContact.containsKey(objContactAgent.Email.toLowerCase()))
			{
				for(Contact objBrokerContact : mapEmailAddress_lstContact.get(objContactAgent.Email.toLowerCase()))
				{
					Contact objContact = mapId_Contact.get(objContactAgent.Id);
					mapId_Contact.put(objContactAgent.Id, new Contact(Id = objContact.Id, FirstName = (objBrokerContact.FirstName != null ? objBrokerContact.FirstName : objContact.FirstName),
					 								   	  LastName = (objBrokerContact.LastName != null ? objBrokerContact.LastName : objContact.LastName),
													      Description = (objBrokerContact.Description != null ? objBrokerContact.Description : objContact.Description),	
													      Department = (objBrokerContact.Department != null ? objBrokerContact.Department : objContact.Department),
													      Role__c = (objBrokerContact.Role__c != null ? objBrokerContact.Role__c : objContact.Role__c),
													   	  Title = (objBrokerContact.Title != null ? objBrokerContact.Title : objContact.Title),
													 	  Suffix__c = (objBrokerContact.Suffix__c != null ? objBrokerContact.Suffix__c : objContact.Suffix__c),
													 	  Birthdate = (objBrokerContact.Birthdate != null ? objBrokerContact.Birthdate : objContact.Birthdate),
													 	  Active__c = (objBrokerContact.Active__c != null ? objBrokerContact.Active__c : objContact.Active__c),
													 	  AssistantName = (objBrokerContact.AssistantName != null ? objBrokerContact.AssistantName : objContact.AssistantName),
												  		  AssistantPhone = (objBrokerContact.AssistantPhone != null ? objBrokerContact.AssistantPhone : objContact.AssistantPhone),
														  Work_Phone__c = (objBrokerContact.Work_Phone__c != null ? objBrokerContact.Work_Phone__c : objContact.Work_Phone__c),
														  MobilePhone = (objBrokerContact.MobilePhone != null ? objBrokerContact.MobilePhone : objContact.MobilePhone),
														  Phone = (objBrokerContact.Phone != null ? objBrokerContact.Phone : objContact.Phone),
														  HomePhone = (objBrokerContact.HomePhone != null ? objBrokerContact.HomePhone : objContact.HomePhone),
														  OtherStreet = (objBrokerContact.OtherStreet != null ? objBrokerContact.OtherStreet : objContact.OtherStreet),
														  OtherState = (objBrokerContact.OtherState != null ? objBrokerContact.OtherState : objContact.OtherState),
														  OtherPostalCode = (objBrokerContact.OtherPostalCode != null ? objBrokerContact.OtherPostalCode : objContact.OtherPostalCode),
														  OtherPhone = (objBrokerContact.OtherPhone != null ? objBrokerContact.OtherPhone : objContact.OtherPhone),
														  Marital_Status__c = (objBrokerContact.Marital_Status__c != null ? objBrokerContact.Marital_Status__c : objContact.Marital_Status__c),
														  MailingStreet = (objBrokerContact.MailingStreet != null ? objBrokerContact.MailingStreet : objContact.MailingStreet),
														  MailingState = (objBrokerContact.MailingState != null ? objBrokerContact.MailingState : objContact.MailingState),
														  MailingPostalCode = (objBrokerContact.MailingPostalCode != null ? objBrokerContact.MailingPostalCode : objContact.MailingPostalCode),
														  MailingCountry = (objBrokerContact.MailingCountry != null ? objBrokerContact.MailingCountry : objContact.MailingCountry),
														  MailingCity = (objBrokerContact.MailingCity != null ? objBrokerContact.MailingCity : objContact.MailingCity),
														  Fax = (objBrokerContact.Fax != null ? objBrokerContact.Fax : objContact.Fax),
														  LeadSource = (objBrokerContact.LeadSource != null ? objBrokerContact.LeadSource : objContact.LeadSource),
														  Agency_Admin_Role__c = (objBrokerContact.Agency_Admin_Role__c != null ? objBrokerContact.Agency_Admin_Role__c : objContact.Agency_Admin_Role__c),
														  HasAnotherRole__c = (objBrokerContact.HasAnotherRole__c != null ? objBrokerContact.HasAnotherRole__c : objContact.HasAnotherRole__c),
													      Contact_External_ID__c = (objBrokerContact.Contact_External_ID__c != null ? objBrokerContact.Contact_External_ID__c : objContact.Contact_External_ID__c), 
													      EDW_Last_Modified_Date__c = (objBrokerContact.EDW_Last_Modified_Date__c != null ? objBrokerContact.EDW_Last_Modified_Date__c : objContact.EDW_Last_Modified_Date__c), 
													      Employer_Name__c = (objBrokerContact.Employer_Name__c != null ? objBrokerContact.Employer_Name__c : objContact.Employer_Name__c), 
													      Occupation__c = (objBrokerContact.Occupation__c != null ? objBrokerContact.Occupation__c : objContact.Occupation__c), 
													      Primary__c = (objBrokerContact.Primary__c != null ? objBrokerContact.Primary__c : objContact.Primary__c), 
													      RowHash__c = (objBrokerContact.RowHash__c != null ? objBrokerContact.RowHash__c : objContact.RowHash__c), 
													      User_Type__c = (objBrokerContact.User_Type__c != null ? objBrokerContact.User_Type__c : objContact.User_Type__c), 
													      User_Name__c = (objBrokerContact.User_Name__c != null ? objBrokerContact.User_Name__c : objContact.User_Name__c), 
														  Password__c = (objBrokerContact.Password__c != null ? objBrokerContact.Password__c : objContact.Password__c), 
													      OwnerId = (objBrokerContact.OwnerId != null ? objBrokerContact.OwnerId : objContact.OwnerId), 
													      Salutation = (objBrokerContact.Salutation != null ? objBrokerContact.Salutation : objContact.Salutation), 
													      ReportsToId =  (objBrokerContact.ReportsToId != null ? objBrokerContact.ReportsToId : objContact.ReportsToId),  
													      OtherLatitude = (objBrokerContact.OtherLatitude != null ? objBrokerContact.OtherLatitude : objContact.OtherLatitude), 
														  EmailBouncedReason = (objBrokerContact.EmailBouncedReason != null ? objBrokerContact.EmailBouncedReason : objContact.EmailBouncedReason), 
													      EmailBouncedDate = (objBrokerContact.EmailBouncedDate != null ? objBrokerContact.EmailBouncedDate : objContact.EmailBouncedDate),
													      Registered_for_Portal__c = (objBrokerContact.Registered_for_Portal__c != null ? objBrokerContact.Registered_for_Portal__c : objContact.Registered_for_Portal__c)));
					
					if(!setConIdToDelete.contains(objBrokerContact.Id))
					{
						setConIdToDelete.add(objBrokerContact.Id);
						lstContactToDelete.add(objBrokerContact);
					}
				}
				
				if(mapContactEmailToListAttachment.containsKey(objContactAgent.Email))
				{
					for(Attachment objAttachment : mapContactEmailToListAttachment.get(objContactAgent.Email))
					{
						lstAttachmentToInsert.add(new Attachment(Name = objAttachment.Name, Body = objAttachment.Body, ParentId =  objContactAgent.Id));
					}
				}
				
				if(mapContactEmailtoListNote.containsKey(objContactAgent.Email))
				{
					for(Note objNote : mapContactEmailtoListNote.get(objContactAgent.Email))
					{
						Note newObj = objNote.clone();
						newObj.ParentId = objContactAgent.Id;
						lstNotesToInsert.add(newObj);
					}
				}
				
				if(mapContactEmailToLstOfTask.containsKey(objContactAgent.Email))
				{
					for(Task objTask : mapContactEmailToLstOfTask.get(objContactAgent.Email))
					{
						Task newObj = objTask.clone();
						newObj.WhoId = objContactAgent.Id;
						lstTaskToInsert.add(newObj);
					}
				}
				
				if(mapContactEmailToLstOfEvent.containsKey(objContactAgent.Email))
				{
					for(Event objEvent : mapContactEmailToLstOfEvent.get(objContactAgent.Email))
					{
						Event newObj = objEvent.clone();
						newObj.WhoId = objContactAgent.Id;
						lstEventToInsert.add(newObj);
					}
				}
				
				if(mapContactEmailToLstOfCM.containsKey(objContactAgent.Email))
				{
					for(CampaignMember objCampaignMember : mapContactEmailToLstOfCM.get(objContactAgent.Email))
					{
							CampaignMember newObj = objCampaignMember.clone();
							newObj.ContactId = objContactAgent.Id;
							lstCampaignMemberToInsert.add(newObj);
					}
				}
				
				if(mapContactEmailtoListFeedItem.containsKey(objContactAgent.Email) )
				{
					for(FeedItem objFeedItem : mapContactEmailtoListFeedItem.get(objContactAgent.Email))
					{
						FeedItem newObj = objFeedItem.clone();
						newObj.ParentId = objContactAgent.Id;
						lstFeedItemToInsert.add(newObj);
						
					}
				}
			}
		}
		
		if(!lstContactToDelete.isEmpty())
			Database.delete(lstContactToDelete, false);
			
		if(!mapId_Contact.isEmpty())
			Database.update(mapId_Contact.values(), false);
		
		if(!lstNotesToInsert.isEmpty())
			Database.insert(lstNotesToInsert, false);
			
		if(!lstCampaignMemberToInsert.isEmpty())
			Database.insert(lstCampaignMemberToInsert, false);
			
		if(!lstEventToInsert.isEmpty())
			Database.insert(lstEventToInsert, false);

		if(!lstTaskToInsert.isEmpty())
			Database.insert(lstTaskToInsert, false);
		
		if(!lstAttachmentToInsert.isEmpty())
			Database.insert(lstAttachmentToInsert, false);
		
		if(!lstFeedItemToInsert.isEmpty())
			Database.insert(lstFeedItemToInsert, false);
		
	}
	
	/* Finish Method */
	global void finish(Database.BatchableContext BC)
	{
		if(SL_BatchContactLastTime__c.getAll().isEmpty())
			insert new SL_BatchContactLastTime__c(Name = 'BatchTime');
		else
		{	
			SL_BatchContactLastTime__c objBatchTime = [SELECT Id, Last_Executed__c FROM SL_BatchContactLastTime__c WHERE Name = 'BatchTime'];  
			objBatchTime.Last_Executed__c = System.now();  
			update objBatchTime;
		}	
	}
}