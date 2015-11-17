/**
* \arg ClassName      : SL_GenerateEmail
* \arg JIRATicket     : PWP-3
* \arg CreatedOn      : 1/DEC/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class is used to send an email to coverage team members corresponding to selected Call Report.
*/
public with sharing class SL_GenerateEmail 
{
	static final String strCREmailTemplate = 'Call_Report_Email';//constant variable to hold value of call report email template
	
	/* Start - Page Variables */
	public Call_Report__c objCallReport {get;set;}//call report object to contain information related to current call report object
	public String strSubject			{get;set;}//variable to hold value of subject that will be displayed in sent email
	public String strBody				{get;set;}//variable to hold value of email body
	public String strSelectedUserName	{get;set;}//variable to hold selected recipient name
	public String strSelectedUserId     {get;set;} // 
	public Boolean noError				{get;set;}//variable to hold the value which shows that whether we need to display page or not
	public MultiSelectOptionWrapper mutiselectCoverageTeamMember    {get;set;}//wrapper class variable to hold the values of multiselect picklist
	public List<String> lstString {get;set;}
	/* End - Page Variables */
	
	/* Start - Class Variables */
	private SObjectType objSobjectType;
	private Map<String,Schema.SObjectField> mapStringToAPINames; 
	private Map<String, String> mapFieldToType;
	/* End - Class Variables */
	
	//This wrapper class is used to hold the values of picklist which will contain all the coverage team members.
	public class MultiSelectOptionWrapper
    {
       public List<SelectOption> selected  {get;set;}

       public MultiSelectOptionWrapper(List<SelectOption> selected)
       {
           this.selected = selected;
       }
    }
	
	/* Start - Constructor */
	public SL_GenerateEmail(Apexpages.standardController stdController)
	{
		lstString = new List<String>();
		objCallReport = (Call_Report__c)stdController.getRecord();
		initialize();
	}
	/* End - Constructor */
	
	/*
    * MethodName        : initialize
    * param             : NA
    * Description       : This function will initialize the page variables.
    */
	void initialize()
	{
		mapFieldToType = new Map<String, String>();
		strSubject = strBody = '';
		noError = true;
		objSobjectType = Schema.getGlobalDescribe().get('Call_Report__c');
		mapStringToAPINames = objSobjectType.getDescribe().fields.getMap();
		//collecting all parameters of page in a page
		Map<String,String> mapPageParameters = Apexpages.currentPage().getParameters();
		try
		{
			//checking if id of call report record contained in url or not
			if(!mapPageParameters.containskey('id') || String.isEmpty(mapPageParameters.get('id')))
			{
				Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, Label.Insufficient_Parameters));
				noError = false;
				return;
			}
			//fetching coverage team members
			fetchCoverageTeamMembers();
			//calling method to populate subject and body of email that needs to be sent
			fetchEmailTemplate();
		}
		catch(Exception ex)
		{
			System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
		}
	}
	
	/*
    * MethodName        : fetchCoverageTeamMembers
    * param             : NA
    * Description       : This function will fetch the emails of coverage team members and form a string
    */
	void fetchCoverageTeamMembers()
	{
		Set<String> setCoverageTeamMember = new Set<String>();// set to hold combination of both coverage team member and its corresponding email address. 
		List<Selectoption> lstCoverageTeamMember = new List<Selectoption>();// list to hold values of coverage team member names and their email addresses
		String strFields = '';
		
		//Iterating over all the fields of call report for querying 
		for(String strField : mapStringToAPINames.keySet())
		{
			strFields += ', ' + strField;
			mapFieldToType.put(strField, String.valueOf(mapStringToAPINames.get(strField).getDescribe().getType()));
		}
		strFields = strFields.replaceFirst(',', '');
		
		List<Call_Report__c> lstCallReport = Database.query('SELECT ' + strFields + ', Owner.Name, Owner.Email , (SELECT Call_Report_Attendee__r.Name, Call_Report_Attendee__r.Email, Call_Report_Attendee__r.User__r.Name, Call_Report_Attendee__r.RecordTypeId, Call_Report_Attendee__r.User__r.Email FROM Meeting_Attendees__r) FROM Call_Report__c WHERE Id = ' + '\'' +objCallReport.Id + '\'');
		
		if(!lstCallReport.isEmpty())
		{
			objCallReport = lstCallReport[0];
			setCoverageTeamMember.add(String.format('{0} : {1}', new List<String>{objCallReport.Owner.Name,objCallReport.Owner.Email}));
		}
		
		if(!objCallReport.Meeting_Attendees__r.isEmpty())
		{
			RecordType objRecordType = [SELECT Id  FROM RecordType WHERE DeveloperName=:'PWP_Employee' AND SobjectType =: 'Contact' LIMIT 1];
			//fetching contact attendees correponding to current call report
			for(Call_Report_Attendees__c objCRA : objCallReport.Meeting_Attendees__r)
			{
				if(objCRA.Call_Report_Attendee__r.RecordTypeId == objRecordType.id && String.isNotEmpty(objCRA.Call_Report_Attendee__r.User__r.Email) && String.isNotEmpty(objCRA.Call_Report_Attendee__r.User__r.Name))
					setCoverageTeamMember.add(String.format('{0} : {1}', new List<String>{objCRA.Call_Report_Attendee__r.User__r.Name, objCRA.Call_Report_Attendee__r.User__r.Email}));
			}
		}
		
		//fetching Coverage team members corresponding to Primary client/company of current call report
		for(Coverage_Team_Members__c objCTM : [SELECT PWP_Employee__r.Name, PWP_Employee__r.Email FROM Coverage_Team_Members__c WHERE Company__c =:objCallReport.Reference_Account__c])
		{
			if(String.isNotEmpty(objCTM.PWP_Employee__r.Email))
			{
				setCoverageTeamMember.add(String.format('{0} : {1}', new List<String>{objCTM.PWP_Employee__r.Name, objCTM.PWP_Employee__r.Email}));
			}
		}
		
		//storing the set in picklist to display on a page.
		for(String strCoverageTeamMember : setCoverageTeamMember)
		{
			lstCoverageTeamMember.add(new Selectoption(strCoverageTeamMember.split(':')[1],strCoverageTeamMember));
		}
		mutiselectCoverageTeamMember = new MultiSelectOptionWrapper(lstCoverageTeamMember);//Filling the component with list of coverage team members
	}
	
	/*
    * MethodName        : fetchEmailTemplate
    * param             : NA
    * Description       : This function will fetch the body of email template.
    */
	void fetchEmailTemplate()
	{
		List<EmailTemplate> lstEmailTemplate = [SELECT Body, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName =: strCREmailTemplate];
		
		//checking if list is empty
		if(!lstEmailTemplate.isEmpty())
		{
			EmailTemplate objEmailTemplate = lstEmailTemplate[0];
			//fetching body without merge fields containing
			strBody = replaceMergeFields(objEmailTemplate.HtmlValue,objCallReport);
			//fetching subject without merge fields containing
			strSubject = replaceMergeFields(objEmailTemplate.Subject,objCallReport).replaceAll('</br>', '');
			
		}
		else
		{
			//setting default value of subject and body if there is no email template found.
			strSubject = String.format('Call Report: {0}',new List<String>{objCallReport.Name});
			strBody = String.join(new List<String>{'<b>'+objCallReport.Name+'</b></br>' ,String.valueOf(objCallReport.Call_Report_Date__c)!=null ? '<b>'+(String.valueOf(objCallReport.Call_Report_Date__c)+'</b></br>'): '', '<b>'+objCallReport.Interaction_Type__c+'</b></br></br>', objCallReport.Notes__c+'</br></br>'},'\r\n\r\n');
		}
	}
	
	/*
    * MethodName        : replaceMergeFields
    * param             : string containing merge fields and call report object
    * Description       : This function is used to replace all the merge fields from the passed string and replace its contents with object field values
    */
	String replaceMergeFields(String strMergeFieldString, Call_Report__c objCallReport)
	{
		if(strMergeFieldString.contains('{!Call_Report__c.'))
		{
			while(strMergeFieldString.indexOf('{!Call_Report__c.') != -1)
			{
				String strReplace = '';
				String strField = String.valueOf(strMergeFieldString.subStringBetween('{!Call_Report__c.', '}')).trim().toLowerCase();
				String strFieldValue = String.valueOf(objCallReport.get(strMergeFieldString.subStringBetween('{!Call_Report__c.', '}')));
				if(strFieldValue != null)
				{
					
					if(mapFieldToType.get(strField) == 'DATE')
						strReplace += (Date.valueOf(strFieldValue).day() +'-'+ 
									   Date.valueOf(strFieldValue).month() +'-'+
									   Date.valueOf(strFieldValue).year())+'</br>';
					else 
						strReplace += strFieldValue+'</br>';
				}
					String strTemp = '{!Call_Report__c.' + strMergeFieldString.subStringBetween('{!Call_Report__c.', '}') + '}';
					strMergeFieldString = strMergeFieldString.replace(strTemp, strReplace);
			}
		}
		return strMergeFieldString;
	} 
	
	/*
    * MethodName        : getSelectedEmailAddresses
    * param             : NA
    * Description       : This function is used to form collect email addresses of all selected coverage team members.
    */
	List<String> getSelectedEmailAddresses()
	{
		List<String> lstCoverageTeamEmail = new List<String>();
		//Iterating over selected values of picklist
		for(Selectoption objSelectOptionValue : mutiselectCoverageTeamMember.selected)
		{
			lstCoverageTeamEmail.add(objSelectOptionValue.getValue());
		}
		return lstCoverageTeamEmail;
	}
	
	/*
    * MethodName        : sendEmail
    * param             : NA
    * Description       : This function is used to email to coverage team members related to current call report record.
    */
	public void sendEmail()
	{
		Messaging.Singleemailmessage mailHandler=new Messaging.Singleemailmessage();//creating instance of single email message class
        try
        {
	        List<String> lstCoverageTeamEmail = getSelectedEmailAddresses();
	        if(!lstCoverageTeamEmail.isEmpty())
	        	mailHandler.setToAddresses(lstCoverageTeamEmail);
	        
	        mailHandler.setSubject(strSubject);
	        mailHandler.setHtmlBody(strBody);
	        try
	        {
		        Messaging.sendEmail(new Messaging.Singleemailmessage[]{mailHandler});
		        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,Label.Email_Confirmation_Message));
	        }
	        catch(EmailException ex)
	        {
	        	Apexpages.addMessage(ex.getMessage().contains('INVALID_EMAIL_ADDRESS') ? new Apexpages.Message(ApexPages.Severity.INFO,Label.Email_address_not_valid) : new Apexpages.Message(ApexPages.Severity.INFO,Label.Email_Failed_Message));
	        }
        }
        catch(Exception ex)
        {
        	Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,Label.Email_Failed_Message));
        }
	}
	
	/*
    * MethodName        : cancel
    * param             : NA
    * Description       : This function is used redirect the user on detail page of call report record.
    */
	public Pagereference cancel()
	{
		return new Pagereference('/'+objCallReport.Id);
	}
	
	public List<String> getSelectedUserEmail(){
  	 	return lstString;
 	}

 	public void setSelectedUserEmail(List<String> lstString) {
 	 	this.lstString = lstString;
 	}
 	
 	// Method used to remove Selected Emails from 'To' box.
	public void removeUserEmail()
	{
		set<String> setUserEmail = new set<String>();
		setUserEmail.addAll(lstString);
		
		List<SelectOption> lstStringTemp = new List<SelectOption>();
		if(!setUserEmail.isEmpty())
		{
			for(Selectoption objSelectOptionValue : mutiselectCoverageTeamMember.selected)
			{
				// Checking if the removed Email matches with select option then removing it from select option.
				if(!setUserEmail.contains(objSelectOptionValue.getValue()))
					lstStringTemp.add(objSelectOptionValue);
			}
			mutiselectCoverageTeamMember = new MultiSelectOptionWrapper(lstStringTemp);
		}
	}
	
	// Method used to add selected user Email to select options in To box.
	public void addSelectedUserEmail()
	{
		try
		{
			if(!String.isEmpty(strSelectedUserId))
			{
				// Querying selected user
				User objAddedRecipient = [Select Name,Email
										  from User
										  where Id=:strSelectedUserId];
			    
			    //Creating format to display in To box							  
				String strDisplayFormat = String.format('{0} : {1}', new List<String>{objAddedRecipient.Name, objAddedRecipient.Email});
											  
				list<Selectoption> lstSelectOptions = new list<Selectoption>();
				
				Boolean isUserAlreadyAdded = false; // Used to check whether selected user is already added in 'To' box
				
				// Iterating through select options in 'To' box
				for(Selectoption objSelectOptionValue : mutiselectCoverageTeamMember.selected)
			    {
			    	lstSelectOptions.add(objSelectOptionValue);
			    	
			    	list<String> lstString = objSelectOptionValue.getLabel().split(':');
			    	
			    	// Checking if selected user is already added in 'To' box..
					if(lstString[0].trim() == objAddedRecipient.Name)
						isUserAlreadyAdded = true;
			    }
			    
			    // If user is not present then adding it in select option
			    if(!isUserAlreadyAdded)
			    {
					// Adding new Selectoption for selected user.
					lstSelectOptions.add(new Selectoption(strDisplayFormat.split(':')[1],strDisplayFormat));
					mutiselectCoverageTeamMember = new MultiSelectOptionWrapper(lstSelectOptions);	
			    }			  
			}
		}
		catch(exception ex)
		{
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}
}