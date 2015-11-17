/**
*  ClassName      : SL_LeadHandler
*  JIRATicket     : THOR-17
*  CreatedOn      : 5/AUG/2014
*  ModifiedBy     : Rahul Majumder
*  Description    : This is the handler class to create Contact role records when a lead is converted
*/
public without sharing class SL_LeadHandler  
{
	Map<String,Id> mapAdditionalApplicantDetails_PersonAccountId = new Map<String,Id>();
	
	/*
    	* MethodName   : onAfterUpdate
        * param        : trigger.newMap
        * Description  : This method is called after Lead record is updated
    */
	public void onAfterUpdate(Map<Id,Lead> mapLeadId_LeadNew)
	{
		///Call createContactRole method to create a Contact role record when a lead is converted
		createContactRole(mapLeadId_LeadNew);
	}
	
	/*
    	* MethodName   : createContactRole
        * param        : Lead New Map values
        * Description  : Creates a new Contact Role for all the Converted Leads. 
    */
	private void createContactRole(Map<Id,Lead> mapLeadId_LeadNew)
	{
		List<Contact_Role__c> lstNewContactRoles = new List<Contact_Role__c>();///List to store Contact role records to be inserted
		List<Account> lstPersonAccount = new List<Account>();///List to store person account records that need to be created from Lead fields
		List<Opportunity> lstOpportunity = new List<Opportunity>();///List to store Opportunity records to be updated
		Map<Id,Id> mapAccountId_RecordTypeId = new Map<Id,Id>();
		Map<Id,Id> mapLeadId_ConvertedOpportunityId = new Map<Id,Id>();
		List<Unit_to_Opportunity_Connector__c> lstOldApartmentConnectors = new List<Unit_to_Opportunity_Connector__c>();
		List<Unit_to_Opportunity_Connector__c> lstApartmentConnectorsToUpdate = new List<Unit_to_Opportunity_Connector__c>();
		Id personAccountRecordTypeId = [SELECT Id FROM RecordType WHERE ispersontype = true AND sobjectType = 'Account'].Id;///Query person account record type id
		
		///Create a map of account id to recordtype by querying since we donot get ConvertedAccount.RecordTypeId directly from trigger.newMap values
		for(Lead objLead :[SELECT Id, ConvertedAccount.RecordTypeId,ConvertedAccountId,IsConverted,ConvertedOpportunityId,CreatedDate
		                   FROM Lead
		                   WHERE ID IN:mapLeadId_LeadNew.keyset()])
		{
			if(objLead.IsConverted && objLead.ConvertedOpportunityId != null)
			{
				mapAccountId_RecordTypeId.put(objLead.ConvertedAccountId,objLead.ConvertedAccount.RecordTypeId);
			}
		}
		
		///Create a list of apartment connector records related to the lead which is converted
		for(Unit_to_Opportunity_Connector__c objUnitToOpportunityConnector:[SELECT Lead__c,Opportunity__c
		                                                                    FROM Unit_to_Opportunity_Connector__c
		                                                                    WHERE Lead__c IN:mapLeadId_LeadNew.keyset()])
		{
			lstOldApartmentConnectors.add(objUnitToOpportunityConnector);
		}
		
		
		///Create data for person account records to be inserted
		for(Lead objLead :mapLeadId_LeadNew.values())
		{
			///Check if lead is converted and an Opportunity is created upon lead conversion
			if(objLead.IsConverted && objLead.ConvertedOpportunityId != null)
			{
				///Create a contact role record with role as tenant
				lstNewContactRoles.add(new Contact_Role__c(Opportunity__c = objLead.ConvertedOpportunityId,Person_Account__c = objLead.ConvertedAccountId,Role__c = 'Tenant',
				                                           FirstName__c = objLead.FirstName, LastName__c = objLead.LastName, 
				                                           Middle_Name__c = objLead.MiddleName , Suffix__c = objLead.Suffix,
				                                           Email__c = objLead.Email, 
				                                           Employer__c = objLead.Employer__c, Current_Address_ZIP__c = objLead.PostalCode, 
				                                           Current_Address_Street__c = objLead.Street, Current_Address_State__c = objLead.State,
				                                           Current_Address_City__c = objLead.City, Current_Address_Country__c = objLead.Country,
				                                           Cell__c  = objLead.Phone));
				///Update the fields on person account created as  a part of lead conversion
				if(mapAccountId_RecordTypeId.get(objLead.ConvertedAccountId) == personAccountRecordTypeId)
					lstPersonAccount.add(new Account(Id =  objLead.ConvertedAccountId, FirstName = objLead.FirstName, LastName = objLead.LastName ,
					                             MiddleName = objLead.MiddleName , Suffix = objLead.Suffix,
					                             PersonEmail = objLead.Email, Employer__c = objLead.Employer__c,
				                                 PersonLeadSource = objLead.LeadSource,
				                                 Broker__c = objLead.Broker__c, ShippingStreet = objLead.Street, ShippingState = objLead.State, 
				                                 ShippingPostalCode = objLead.PostalCode, ShippingCountry = objLead.Country, ShippingCity = objLead.City,
				                                 University__c = objLead.University__c,
				                                 University_Program__c = objLead.University_Program__c,
				                                 Phone  = objLead.Phone,
				                                 Resident_Referral_Apartment__c =    objLead.Resident_Referral_Apartment__c,
				                                 Resident_Referral_Building__c = objLead.Resident_Referral_Building__c,
				                                 Resident_Referral_Email__c = objLead.Resident_Referral_Email__c,
				                                 Resident_Referral_First_Name__c = objLead.Resident_Referral_First_Name__c,
				                                 Resident_Referral_Last_Name__c = objLead.Resident_Referral_Last_Name__c,
				                                 Resident_Referral_Phone__c = objLead.Resident_Referral_Phone__c
				                                 ));
				
				///Update the fields on opportunity created as  a part of lead conversion
				lstOpportunity.add(new Opportunity(Id = objLead.ConvertedOpportunityId, LeadSource = objLead.LeadSource, First_Call_Date__c = objLead.First_Call_Date__c,
				                                    First_Email_Date__c = objLead.First_Email_Date__c, First_Appointment_Date__c = objLead.First_Appointment_Date__c,
				                                    Last_Appointment_Date__c = objLead.Last_Appointment_Date__c, 
				                                    Move_In_Date__c = objLead.Move_In_Date__c,
				                                    Budget__c = objLead.Budget__c, Budget_Max__c = objLead.Budget_Max__c,
				                                    Preferred_New_York_Location__c = objLead.New_York_Location__c,
				                                    Lead_Created_Date__c = Date.ValueOf(objLead.CreatedDate),
				                                    Preferred_Apartment_Type__c = objLead.Apartment_Type__c,
				                                    Preferred_Submarket__c = objLead.Submarket__c,
				                                    Comments_from_Website__c = objLead.Comments_from_Website__c,
					                                Resident_Referral_Apartment__c =    objLead.Resident_Referral_Apartment__c,
					                                Resident_Referral_Building__c = objLead.Resident_Referral_Building__c,
					                                Resident_Referral_Email__c = objLead.Resident_Referral_Email__c,
					                                Resident_Referral_First_Name__c = objLead.Resident_Referral_First_Name__c,
					                                Resident_Referral_Last_Name__c = objLead.Resident_Referral_Last_Name__c,
					                                Resident_Referral_Phone__c = objLead.Resident_Referral_Phone__c,
				                                    Lead_Converted_Date__c = system.date.today()));
				
				/***************** Start- Records created from additonal applicant fields on lead ****************/
				
				///Check if last name is present  on Lead since it is a mandatory field on person account
				if(objLead.Applicant_1_Last_Name__c != null)
					lstPersonAccount.add(createPersonAccountRecords(objLead.Applicant_1_First_Name__c,objLead.Applicant_1_Last_Name__c,objLead.Applicant_1_Phone__c,
					                           objLead.Applicant_1_Email__c,personAccountRecordTypeId));
				
				///Check if last name is present  on Lead since it is a mandatory field on person account
				if(objLead.Applicant_2_Last_Name__c != null)
					lstPersonAccount.add(createPersonAccountRecords(objLead.Applicant_2_First_Name__c,objLead.Applicant_2_Last_Name__c,objLead.Applicant_2_Phone__c,
					                           objLead.Applicant_2_Email__c,personAccountRecordTypeId));
				
				///Check if last name is present  on Lead since it is a mandatory field on person account
				if(objLead.Applicant_3_Last_Name__c != null)
					lstPersonAccount.add(createPersonAccountRecords(objLead.Applicant_3_First_Name__c,objLead.Applicant_3_Last_Name__c,objLead.Applicant_3_Phone__c,
					                           objLead.Applicant_3_Email__c,personAccountRecordTypeId));
				
				///Check if last name is present  on Lead since it is a mandatory field on person account
				if(objLead.Applicant_4_Last_Name__c != null)
					lstPersonAccount.add(createPersonAccountRecords(objLead.Applicant_4_First_Name__c,objLead.Applicant_4_Last_Name__c,objLead.Applicant_4_Phone__c,
					                           objLead.Applicant_4_Email__c,personAccountRecordTypeId));
					                           
				/***************** End - Records created from additonal applicant fields on lead ****************/
				
				mapLeadId_ConvertedOpportunityId.put(objLead.Id,objLead.ConvertedOpportunityId);
			}
		}
		
		///Upsert person account records	
		if(!lstPersonAccount.isEmpty())
			upsert lstPersonAccount;
			
		///Update Opportunity records	
		if(!lstOpportunity.isEmpty())
			update lstOpportunity;
		
		///Create a map of Additional applicant details to person account id
		for(Account objAccount:[SELECT Id,FirstName,LastName,Phone,PersonEmail
		                        FROM Account
		                        WHERE ID IN:lstPersonAccount])
		{
			String strAdditionalApplicantDetails = objAccount.FirstName + '-' + objAccount.LastName + '-' + objAccount.Phone + '-' + objAccount.PersonEmail;
			mapAdditionalApplicantDetails_PersonAccountId.put(strAdditionalApplicantDetails,objAccount.Id);
		}
			
		///Create data for person account records to be inserted
		for(Lead objLead :mapLeadId_LeadNew.values())
		{
			///Check if lead is converted and an Opportunity is created upon lead conversion
			if(objLead.IsConverted && objLead.ConvertedOpportunityId != null)
			{	
				
				///Check if any one of the related fields on lead has value
				///If yes, create a contact role from those values
				if(objLead.Applicant_1_Role__c != null || objLead.Applicant_1_Phone__c != null || objLead.Applicant_1_Last_Name__c != null ||
				   		objLead.Applicant_1_First_Name__c != null ||  objLead.Applicant_1_Email__c != null)
					lstNewContactRoles.add(createContactRoleRecords(objLead.ConvertedOpportunityId, objLead.Applicant_1_First_Name__c,
					                       objLead.Applicant_1_Last_Name__c,objLead.Applicant_1_Phone__c,objLead.Applicant_1_Role__c,objLead.Applicant_1_Email__c));
				
				///Check if any one of the related fields on lead has value
				///If yes, create a contact role from those values
				if(objLead.Applicant_2_Role__c != null || objLead.Applicant_2_Phone__c != null || objLead.Applicant_2_Last_Name__c != null ||
				   		objLead.Applicant_2_First_Name__c != null ||  objLead.Applicant_2_Email__c != null)
			   		lstNewContactRoles.add(createContactRoleRecords(objLead.ConvertedOpportunityId,objLead.Applicant_2_First_Name__c,
					                       objLead.Applicant_2_Last_Name__c,objLead.Applicant_2_Phone__c,objLead.Applicant_2_Role__c,objLead.Applicant_2_Email__c));
				
				///Check if any one of the related fields on lead has value
				///If yes, create a contact role from those values
				if(objLead.Applicant_3_Role__c != null || objLead.Applicant_3_Phone__c != null || objLead.Applicant_3_Last_Name__c != null ||
				   		objLead.Applicant_3_First_Name__c != null || objLead.Applicant_3_Email__c != null)
			   		lstNewContactRoles.add(createContactRoleRecords(objLead.ConvertedOpportunityId,objLead.Applicant_3_First_Name__c,
					                       objLead.Applicant_3_Last_Name__c,objLead.Applicant_3_Phone__c,objLead.Applicant_3_Role__c,objLead.Applicant_3_Email__c));
				
				///Check if any one of the related fields on lead has value
				///If yes, create a contact role from those values
				if(objLead.Applicant_4_Role__c != null || objLead.Applicant_4_Phone__c != null || objLead.Applicant_4_Last_Name__c != null ||
				   		objLead.Applicant_4_First_Name__c != null ||  objLead.Applicant_4_Email__c != null)
			   		lstNewContactRoles.add(createContactRoleRecords(objLead.ConvertedOpportunityId,objLead.Applicant_4_First_Name__c,
					                       objLead.Applicant_4_Last_Name__c,objLead.Applicant_4_Phone__c,objLead.Applicant_4_Role__c,objLead.Applicant_4_Email__c));
			
			}
		}
		
		///Insert contact role record
		if(!lstNewContactRoles.isEmpty())
			insert lstNewContactRoles;
		
		///Move aprtment connector records from lead to opportunity	
		for(Unit_to_Opportunity_Connector__c objApartmentConnector:lstOldApartmentConnectors)
		{
			if(objApartmentConnector.Lead__c != null &&  mapLeadId_ConvertedOpportunityId.containskey(objApartmentConnector.Lead__c) && 
			          mapLeadId_ConvertedOpportunityId.get(objApartmentConnector.Lead__c) != null)
			{
				objApartmentConnector.Opportunity__c = mapLeadId_ConvertedOpportunityId.get(objApartmentConnector.Lead__c);
				lstApartmentConnectorsToUpdate.add(objApartmentConnector);
			}
		}
		
		if(!lstApartmentConnectorsToUpdate.isEmpty())
			update lstApartmentConnectorsToUpdate;
	}
	
	/*
    	* MethodName   : createPersonAccountRecords
        * param        : Lead fields
        * Description  : Creates a new Person account record
    */
	private Account createPersonAccountRecords(String strFirstName, String strLastName, String strPhone, String strEmail, Id recordTypeId)
	{
		Account objPersonAccount = new Account
		(
			FirstName = strFirstName,
			LastName = strLastName, 
			Phone = strPhone, 
			PersonEmail = strEmail,
			RecordTypeId = recordTypeId
		);
		return objPersonAccount;
	}
	
	
	/*
    	* MethodName   : createContactRoleRecords
        * param        : Lead additional applicant fields
        * Description  : Creates a new Contact role record
    */
	private Contact_Role__c createContactRoleRecords(Id opportunityId, String strFirstName, String strLastName, String strPhone, String strRole, String strEmail)
	{
		Contact_Role__c objAdditionalContactRole = new Contact_Role__c
		(
			Opportunity__c = opportunityId,
			Person_Account__c = mapAdditionalApplicantDetails_PersonAccountId.get(strFirstName + '-' + strLastName + '-' + strPhone + '-' + strEmail),
			FirstName__c =  strFirstName,
			LastName__c =  strLastName,
			Cell__c =  strPhone,
			Role__c = strRole,
			Email__c = strEmail					
		);
		
		return objAdditionalContactRole;
	}
}