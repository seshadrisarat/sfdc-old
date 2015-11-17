/*
*  ClassName  	  : SL_SubmitClaimController
*  JIRATicket     : PURE-11
*  CreatedOn      : 3/2/2014
*  ModifiedBy     : Hemant
*  Description    : Submit all input to claimcenter through Email.  
*/
	
public with sharing class SL_SubmitClaimController 
{
	/* Start of variables */
	public string memberName 					{get; set;}
	public string memberNumber 					{get; set;}
	/* Upload File fields */
	public String strFileName					{get;set;}
	public Blob attachmentBody 					{get;set;} 
    public Integer imageSize					{get;set;}
    
	public list<Account> objAccount 			{get; set;}
	public list<Sl_VehicleWrapper> objVehicles 	{get; set;}
	public list<Sl_CoveredVesselsWrapper> objCoveredVessels {get; set;}
	
	public string selectedClaimType				{get; set;}
	/* common fields for all*/
	/* Primary Contact Fields */
	public string memName						{get; set;}
	public string relationToInsured				{get; set;}
	public string memPhone						{get; set;}
	public string memEmail						{get; set;}
	/* Date of incident/accident fields*/
	public string incDate						{get; set;}
	public string incTime						{get; set;}
	/* Incident or Accident location*/
	public string incAddr1						{get; set;}
	public string incAddr2						{get; set;}
	public string incCity						{get; set;}
	public string incState						{get; set;}
	public string incZipcode					{get; set;}
	/* Incident or Accident Description*/
	public string incDesc						{get; set;}
	public string strDefltClmUsrMailAddr        {get; set;}
	/* End common fields for all*/
	
	/* Auto*/
	public string autoWasInjured 				{get; set;}
	public string autoVehicalInvolved 			{get; set;}
	public string autoMake						{get; set;}
	public string autoModel						{get; set;}
	public string autoYear						{get; set;}
	/* Homeowners*/
	public string homeWasDamage 				{get; set;}
	/* Collections*/
	/* Watercraft*/
	public string WCWasInjured	 				{get; set;}
	public string WCVehicalInvolved 			{get; set;}
	public string WCMake						{get; set;}
	public string WCModel						{get; set;}
	public string WCYear						{get; set;}
	/* Flood*/

	public string ClaimUserEmail				{get; set;}
	public String isSuccess 					{get; set;}	
	
	/* Worker's compensation*/
	public string strEmployeeName               {get; set;}
	public string strEmployeeRole               {get; set;}
	/* End of Variables */
	
	public String autoGlassLink					{get;set;}
	/*
		Constructor
	*/
	public SL_SubmitClaimController()
	{
		selectedClaimType = '';
		objVehicles = new list<Sl_VehicleWrapper>();
		objCoveredVessels = new list<Sl_CoveredVesselsWrapper>();
		isSuccess = ApexPages.currentPage().getParameters().get('isSuccess');
		autoGlassLink = '';
		incDesc = '';
		PortalURLMap__c oAutoGlassLink = PortalURLMap__c.getInstance('SubmitClaim');
		if(oAutoGlassLink != null)
			autoGlassLink = oAutoGlassLink.URL__c;
	}
	
	/*
		Name: pageAction
		Param: None
		Description: This page action method will ensure that non authenicated user can't see the page content
	*/
	public pageReference pageAction()
	{
		String strBrocker = ''; 
		String strContactId = '';
		Set<Id> setAgencyContactId = new Set<Id>();		
		String strProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;
		String strQuery = 'SELECT Name, Member_Key_EDW__c, Phone, Primary_Email__c ';
		String strMember = 'Member';
		
		//If user is not authenticated then redirect to login page else proceed with further logic
		if(Userinfo.getUserType() == 'Guest') 
			return new Pagereference('/LoginPage');
		
		String userAccountId;										//This is to store logged in user account id.
		
		/* If it is accessed from AgentHomepage // Added regarding PURE-63   */
		if(Apexpages.currentPage().getParameters().containsKey('mId') && strProfileName != 'Pure Customer Community Login User')
		{
			// Member Id
			userAccountId = Apexpages.currentPage().getParameters().get('mId');
			
			for(User objUser : [SELECT Id, Contact.AccountId, ContactId FROM User WHERE Id =: Userinfo.getUserId() LIMIT 1])
				strContactId = objUser.ContactId;
			
			for(Agency_Contact__c obj : [SELECT Agency__c 
										 FROM Agency_Contact__c 
										 WHERE Contact__c =: strContactId 
										   AND User_Status__c = 'Active'
										   AND (Agency__r.Broker_Status__c = 'Active' 
										    OR Agency__r.Broker_Status__c = 'Suspended with Access')])
				setAgencyContactId.add(obj.Agency__c);
			
			if(!setAgencyContactId.isEmpty() && setAgencyContactId != null)
				strBrocker =  'Broker__c IN: setAgencyContactId';
			else {
				PageReference pageRef = new PageReference('/Exception');
				return pageRef;
			}
		}
		else
		{
			/* This is to query logged in user account id.*/
			for(User objUser : [Select Id, Contact.AccountId from User where Id=: Userinfo.getUserId() limit 1])
			{
				userAccountId = objUser.Contact.AccountId;
			}	
		}
		
		if(!String.isEmpty(strBrocker) && strBrocker != '')
		{
			strQuery += ' FROM Account WHERE Id=' + '\'' + userAccountId +'\' AND ' + strBrocker + ' AND RecordType.Name =: strMember LIMIT 1';
			objAccount = Database.query(strQuery);
			
			if(objAccount.isEmpty() )
				return (new PageReference('/Exception'));
		}
		else
		{
			strQuery +=	' FROM Account WHERE Id=' + '\'' + userAccountId +'\' LIMIT 1';
			objAccount = Database.query(strQuery);
		}
		
		list<User> objDefaultClaimUser = [Select Id,Email,User_s_Email__c,Contact.AccountId from User where IsActive = true and Default_Claims_User__c = true limit 1];
		if(!objDefaultClaimUser.isEmpty())
			strDefltClmUsrMailAddr = objDefaultClaimUser[0].User_s_Email__c;
		
		list<User> objClaimUser = [SELECT Id,Email,ContactId FROM User WHERE IsActive = true AND Default_Member_Advocate_User__c = true limit 1];
		if(!objClaimUser.isEmpty())
			ClaimUserEmail = objClaimUser[0].Email;
		
		set<string> policyNumber = new set<string>();
		for(Policy__c objPolicy : [SELECT Id, Policy_Number__c, Policy_Status__c, Policy_Term_Dates__c, Effective_Date__c, Expiration_Date__c, Description__c, Line_of_Business__c 
									FROM Policy__c 
									WHERE Member__c = :userAccountId])
		{
			policyNumber.add(objPolicy.Id);
		}	
		
		for(Vehicle__c objVehical : [SELECT id, IDCardId__c, Make__c, Model__c, Policy__c, VIN__c, Year__c FROM Vehicle__c WHERE Policy__c IN: policyNumber])
		{
			objVehicles.add(new Sl_VehicleWrapper(objVehical.Make__c,objVehical.Model__c,objVehical.VIN__c,objVehical.Year__c) );
		}
		for(Covered_Vessels__c objCoveredVes : [select id,Horsepower__c, Hull_Value__c, Length__c, make__c,	Model__c,Policy__c,Year__c from Covered_Vessels__c WHERE Policy__c IN: policyNumber])
		{
			objCoveredVessels.add(new Sl_CoveredVesselsWrapper(objCoveredVes.Horsepower__c,objCoveredVes.Hull_Value__c,objCoveredVes.Length__c, objCoveredVes.Make__c,objCoveredVes.Model__c,objCoveredVes.Year__c));
		}
		
		return null;
	}
	public pageReference emailSend()
	{
	 	try {  
	 		
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
			String[] toAddresses = new String[] {strDefltClmUsrMailAddr}; //{ClaimUserEmail}; 
			mail.setToAddresses(toAddresses); 
			
			if(!objAccount.isEmpty()) 
				mail.setSubject('New Claim from '+objAccount[0].Name+ ', ' + objAccount[0].Member_Key_EDW__c);  
			
			mail.setPlainTextBody('Test Data');  
		 	mail.setHtmlBody(emailHTMLBody());  
	        mail.setSenderDisplayName('Member Portal');
	        if( strFileName != null)
	        {
		        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		        efa.setFileName(strFileName);
		        efa.setBody(attachmentBody);
		        
		        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
	        }
	        
	 		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
	 	} catch(Exception e) {
	 		system.debug('--exception-->'+e.getMessage());
	 	}  
		//varaibleDeclare();
		isSuccess = 'true';
		PageReference submitClaim = new PageReference('/SubmitClaim?isSuccess=true');
		submitClaim.setRedirect(false);
		return submitClaim; 
	}
	public string emailHTMLBody()
	{
		string strEmailBody = '';
		strEmailBody += '<b>SELECTED CLAIM TYPE </b> <br/>'+ (selectedClaimType == 'workers_compensation' ? 'Workers Compensation' : selectedClaimType) + '<br/><br />';
		strEmailBody += '<b>INSURED MEMBER DETAILS: </b> <br/>';
		if(!objAccount.isEmpty())
		{
			strEmailBody += ' Name - '+ objAccount[0].Name + '<br/>';
			strEmailBody += ' Phone - '+ objAccount[0].Phone + '<br/>';
			strEmailBody += ' Email - '+ objAccount[0].Primary_Email__c + '<br/>';
			strEmailBody += ' ID - '+ objAccount[0].Member_Key_EDW__c + '<br/>';
		}
		strEmailBody += ' Loss Reported Date - '+ date.today().format() + '<br/><br/>';
		
		strEmailBody += '<b>PRIMARY CONTACT FOR CLAIM:</b> <br/>';
		strEmailBody += ' Name - '+ this.memName + '<br/>';
		strEmailBody += ' Relationship To Insured - '+ this.relationToInsured + '<br/>';
		strEmailBody += ' Phone - '+ this.memPhone + '<br/>';
		strEmailBody += ' Email - '+ this.memEmail + '<br/><br/>';
		
		strEmailBody += '<b>DATE OF INCIDENT / ACCIDENT:</b> <br/>';
		strEmailBody += ' Date - '+ incDate + '<br/>';
		strEmailBody += ' Time - '+ incTime + '<br/><br/>';
		
		strEmailBody += '<b>INCIDENT DESCRIPTION:</b> <br/>';
		strEmailBody += ' Description - '+ incDesc + '<br/><br/>';
		
		strEmailBody += '<b>INCIDENT / ACCIDENT LOCATION:</b> <br/>';
		strEmailBody += ' Address Line 1 - '+ incAddr1 + '<br/>';
		strEmailBody += ' Address Line 2 - '+ incAddr2 + '<br/>';
		strEmailBody += ' City - '+ incCity + '<br/>';
		strEmailBody += ' State - '+ incState + '<br/>';
		strEmailBody += ' Zip Code - '+ incZipcode + '<br/><br/>';
		
		if(selectedClaimType == 'auto')
		{
			strEmailBody += '<b>WAS ANYONE INJURED:  </b> '+ autoWasInjured + '<br/>';
			strEmailBody += '<b>ARE THERE OTHER VEHICLES INVOLVED:  </b> '+ autoVehicalInvolved + '<br/><br/>';
			
			strEmailBody += '<b>INSURED VEHICLE DETAILS:  </b><br/>';
			strEmailBody += '<b>MAKE -  </b> '+ autoMake + '<br/>';
			strEmailBody += '<b>MODEL -  </b> '+ autoModel + '<br/>';
			strEmailBody += '<b>YEAR -  </b> '+ autoYear + '<br/><br/>';
		}
		else if(selectedClaimType == 'autoglass')
		{
			//// nothing todo;
		}
		else if(selectedClaimType == 'homeowners')
		{
			strEmailBody += '<b>IS THERE DAMAGE TO THE HOME:  </b> '+ homeWasDamage + '<br/>'; 
		}
		else if(selectedClaimType == 'collections')
		{
			/// nothing to add;
		}
		else if(selectedClaimType == 'watercraft')
		{
			strEmailBody += '<b>WAS ANYONE INJURED:  </b> '+ WCWasInjured + '<br/>';
			strEmailBody += '<b>ARE THERE OTHER WATERCRAFT INVOLVED:  </b> '+ WCVehicalInvolved + '<br/><br/>';
			
			strEmailBody += '<b>INSURED WATERCRAFT DETAILS:  </b><br/>';
			strEmailBody += '<b>MAKE -  </b> '+ WCMake + '<br/>';
			strEmailBody += '<b>MODEL -  </b> '+ WCModel + '<br/>';
			strEmailBody += '<b>YEAR -  </b> '+ WCYear + '<br/><br/>';
		}
		else if(selectedClaimType == 'flood')
		{
			/// nothing to add; 
		}
		else if(selectedClaimType == 'workers_compensation')
		{
		    strEmailBody += '<b> EMPLOYEE NAME: </b>'+strEmployeeName+'<br/>';
		    strEmailBody += '<b> EMPLOYEE ROLE: </b>'+strEmployeeRole+'<br/>';
		}
		
		return strEmailBody;
		
	}
	/* Wrapper Class*/
	public class Sl_VehicleWrapper
	{
		public String Make 			{	get;set;	}
		public String Model   		{	get;set;	}
		public String VIN			{	get;set;	}
		public Decimal Year 		{	get;set;	}
		
		public Sl_VehicleWrapper(String Make,String Model,String VIN,Decimal Year)
		{
			this.Make		= 	Make;
			this.Model		= 	Model;
			this.VIN		= 	VIN;
			this.Year 		= 	Year;
		}
	}
	public class Sl_CoveredVesselsWrapper
	{
		public Decimal Horsepower 	{	get;set;	}
		public Decimal HullValue  	{	get;set;	}
		public String VLength		{	get;set;	}
		public String Make 			{	get;set;	}
		public String Model   		{	get;set;	}
		public Decimal Year 		{	get;set;	}
		
		public Sl_CoveredVesselsWrapper(Decimal Horsepower, Decimal HullValue, String VLength, String Make, String Model,Decimal Year)
		{
			this.Make		= 	Make;
			this.Model		= 	Model;
			this.Horsepower	= 	Horsepower;
			this.HullValue 	= 	HullValue;
			this.VLength	=	Vlength;
			this.Year 		= 	Year;
		}
	}
	
	public void dummyfunction()
	{
		system.debug('=========incDesc========' + incDesc);
	}
}