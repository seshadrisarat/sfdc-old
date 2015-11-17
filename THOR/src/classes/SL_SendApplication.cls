/**
* \arg \b ClassName      : SL_SendApplicationController
* \arg \b JIRATicket     : THOR-16
* \arg \b CreatedOn      : 5/08/2014
* \arg \b ModifiedBy     : -
* \arg \b Description    : Controller used to send Apllication Link via Email to Selected Contact Roles from Opportunity Detail Page 'Send Application' button.
                            
*/


public with sharing class SL_SendApplication extends SL_Paginator
{
    public Opportunity objOpportunity                                                       {get;set;}  // Used to store the Opportunity from where page is launched.
    public list<WrapperClassToBindCheckBox> lstWrapperClass                                 {get;set;}  //This list is use to store inner class objects.
    public list<WrapperClassToBindApartmentFieldsWithCheckBox> lstApartmentWrapperClass     {get;set;}  //This list is use to store inner class objects.
    public Boolean isRecipientSelected                                                      {get;set;}
    public Boolean isValidStageToSendApplication                                            {get;set;}
    public String strRedirectUrl                                                            {get;set;}
    public Boolean isMulitpleApartmentSelected                                              {get;set;}
     
   //Constructor
   public SL_SendApplication( ApexPages.StandardController sc)
   {
       lstWrapperClass = new list<WrapperClassToBindCheckBox>();
       lstApartmentWrapperClass = new list<WrapperClassToBindApartmentFieldsWithCheckBox>();
       isRecipientSelected = false;
       isMulitpleApartmentSelected = false;
       isValidStageToSendApplication = true;
       strRedirectUrl = '';
       set<String> setOpportunityStageNames = new set<String>{'Lease Sent', 'Lease Signed by Tenants', 'Lease Signed by Thor', 'Closed Lost'};
       objOpportunity = new Opportunity();
       	try
       	{
       		if(Apexpages.currentPage().getParameters().containsKey('id'))
   			{
	            objOpportunity = [select Name,OwnerId,StageName
	                             from Opportunity
	                             where Id=:Apexpages.currentPage().getParameters().get('id')];
	            strRedirectUrl = '/' + objOpportunity.Id;
	            
	            if(setOpportunityStageNames.contains(objOpportunity.StageName))
	            {
	             	isValidStageToSendApplication = false;
	             	return;
	            }
	            else
	            {
	            	queryContactRoleRelToOpp();
	            	queryApartmentRelToOpp();
	            }
   			}
   			else
	     	{
	     		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Insufficient Parameters.'));
				return;
	     	}
       	}
       	catch(Exception e)	
     	{
     		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Invalid Parameters.'));
			return;
     	}
   		
   } 
   
   /*!
      *  @ClassName: WrapperClassToBindCheckBox
      *  @Description: Inner class to bind contact id's with checkbox
    */
    public class WrapperClassToBindCheckBox 
    {
        public Contact_Role__c objContactRole   {get;set;}  //This object is use to bind values of company_List with checkbox.
        public Boolean isChecked                {get;set;}  //This variable is use to store all rows checkbox status
                      
        /*Innerclass parametric constructor*/
        public WrapperClassToBindCheckBox(Contact_Role__c objContactRole, Boolean isChecked)
        {
            this.objContactRole = objContactRole;
            this.isChecked = isChecked;
        }
    }
   
   /*!
      *  @ClassName: WrapperClassToBindApartmentFieldsWithCheckBox
      *  @Description: Inner class to bind Apartment fields with checkbox
    */
    public class WrapperClassToBindApartmentFieldsWithCheckBox 
    {
        public Apartment__c objApartment        {get;set;}  //This object is use to bind values of apartment fields with checkbox.
        public Boolean isChecked                {get;set;}  //This variable is use to store all rows checkbox status
                      
        /*Innerclass parametric constructor*/
        public WrapperClassToBindApartmentFieldsWithCheckBox(Apartment__c objApartment, Boolean isChecked)
        {
            this.objApartment = objApartment;
            this.isChecked = isChecked;
        }
    }
    
    
    /*!
      *  @MethodName: initPaginationForRecipient
      *  @param None: None.
      *  @Description: This method will initalize the variables which is required in pagination.
    */
    private void initPaginationForRecipient() 
    {
        pageForRecipient=1;//initally page is 1. 
        FirstPageForRecipient = 0; //first page index is initially 0
        TotalRowsForRecipient = lstWrapperClass.size();// total rows to be spanned across pages
        PageSizeForRecipient = 5;// no. of rows you want to show per page
        LastPageForRecipient = Math.mod(TotalRowsForRecipient, PageSizeForRecipient) == 0 ? TotalRowsForRecipient / PageSizeForRecipient : TotalRowsForRecipient / PageSizeForRecipient + 1;// calculate the index of last page
        noOfPagesForRecipient = Math.mod(TotalRowsForRecipient, PageSizeForRecipient) > 0 ? TotalRowsForRecipient / PageSizeForRecipient + 1 : TotalRowsForRecipient / PageSizeForRecipient;
    }
    
    /*!
      *  @MethodName: initPaginationForApartment
      *  @param None: None.
      *  @Description: This method will initalize the variables which is required in pagination.
    */
    private void initPaginationForApartment() 
    {
        pageForApartment=1;//initally page is 1. 
        FirstPageForApartment = 0; //first page index is initially 0
        TotalRowsForApartment = lstApartmentWrapperClass.size();// total rows to be spanned across pages
        PageSizeForApartment = 5;// no. of rows you want to show per page
        LastPageForApartment = Math.mod(TotalRowsForApartment, PageSizeForApartment) == 0 ? TotalRowsForApartment / PageSizeForApartment : TotalRowsForApartment / PageSizeForApartment + 1;// calculate the index of last page
        noOfPagesForApartment = Math.mod(TotalRowsForApartment, PageSizeForApartment) > 0 ? TotalRowsForApartment / PageSizeForApartment + 1 : TotalRowsForApartment / PageSizeForApartment;
    }
    
    /*!
      *  @MethodName: queryContactRoleRelToOpp
      *  @param None: None.
      *  @Description: This method is used to get all ContactRoles of type Role__c = 'Tenant' related to Opportunity from where Page is Launched.
    */
    
    public void queryContactRoleRelToOpp()
    {
    	String OPPORTUNITY_ID = Apexpages.currentPage().getParameters().get('id');
    	
    	// THOR-31: Getting the Contact Role's Role which are eligible to be recipient. 
    	Set<String> setContactRolesAddedForRecipient = new Set<String>(); 
		
		// Getting the custom settign record with Name as Role which is maintaining Contact Role's Role which are eligible to be recipient 
		for(SL_ContactRoleAddedForRecipient__c objCS : SL_ContactRoleAddedForRecipient__c.getAll().values())
		{
			setContactRolesAddedForRecipient.add(objCS.Name);
		}
		
		if(setContactRolesAddedForRecipient.isEmpty())
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Roles defined for sending email. Please contact your administrator.'));
			return;
		}
		
    	/* Contact__c,Contact__r.Name Contact__r.Email,*/
        for(Contact_Role__c objContactRole : [SELECT Role__c,Email__c,Name,Opportunity__c,Id,FirstName__c,LastName__c,Person_Account__r.PersonContactId,Status__c
                                              from Contact_Role__c 
                                              where Opportunity__c=: OPPORTUNITY_ID and (Role__c IN : setContactRolesAddedForRecipient)])    
        {
            WrapperClassToBindCheckBox objWrapper = new  WrapperClassToBindCheckBox(objContactRole , false); 
            lstWrapperClass.add(objWrapper);
        }
        // Initializing the variables required for Pagination.
        initPaginationForRecipient();
    }
    
    /*!
      *  @MethodName: queryApartmentRelToOpp
      *  @param None: None.
      *  @Description: This method is used to get all Apartment records related to Opportunity from where Page is Launched.
    */
    public void queryApartmentRelToOpp()
    {
    	String OPPORTUNITY_ID = Apexpages.currentPage().getParameters().get('id');
    	Set<Id> setApartmentId = new Set<Id>();///Set to store apartment ids of apartment connector records
        Set<String> setInvalidApartmentStatus = new Set<String>{'Leased - Not Available','Leased - On Hold',
                                                        'Available - On Hold'};
		
		///Create a set of apartment ids
        for(Unit_to_Opportunity_Connector__c objApartmentConnector : [SELECT Unit__c
                                                                      FROM Unit_to_Opportunity_Connector__c 
                                                                      WHERE Opportunity__c=: OPPORTUNITY_ID])    
        {
            setApartmentId.add(objApartmentConnector.Unit__c);
        }
        
        ///create a list of apartment wrapper class
        for(Apartment__c objApartment:[SELECT Name,Apartment_Type__c,Availability_Date__c,Asking_Rent__c,Apartment_Status__c
                                       FROM Apartment__c
                                       WHERE Id IN:setApartmentId])
        {
        	if(!setInvalidApartmentStatus.contains(objApartment.Apartment_Status__c))
        	{
	        	WrapperClassToBindApartmentFieldsWithCheckBox objWrapper = new  WrapperClassToBindApartmentFieldsWithCheckBox(objApartment , false); 
	            lstApartmentWrapperClass.add(objWrapper);
        	}
        }
        
        // Initializing the variables required for Pagination.
        initPaginationForApartment();
        
    }
    
    
     /*!
      *  @MethodName: sendApplication
      *  @param None: None.
      *  @Description: This method is used to send an Email to Selected Contact Roles with custom URL that redirects to Application Form of THOR Apartments.
    */
    public void sendApplication()
    {
        list<Contact_Role__c> lstCRToSendAF = new list<Contact_Role__c>();
        String OPPORTUNITY_ID = Apexpages.currentPage().getParameters().get('id');
        Id selectedApartmentId;
        Integer intNumberOfApartmentsSelected = 0;
        isMulitpleApartmentSelected = false;
        
        for(WrapperClassToBindCheckBox objWrapperClass : lstWrapperClass)
        {
            /* Creating Contact list member Where checkbox is true*/
            if(objWrapperClass.isChecked)
            {
                 if(!string.isEmpty(objWrapperClass.objContactRole.Email__c) )   
                 {
                 	isRecipientSelected = true;
             		lstCRToSendAF.add(objWrapperClass.objContactRole);
                 }
            }
        }  
        
        ///Get the id of selected apartment
        for(WrapperClassToBindApartmentFieldsWithCheckBox objWrapperClass : lstApartmentWrapperClass)
        {
            /* Creating Contact list member Where checkbox is true*/
            if(objWrapperClass.isChecked)
            {
            	++intNumberOfApartmentsSelected;
            	selectedApartmentId = objWrapperClass.objApartment.Id;
            }
        }  
        
        if(intNumberOfApartmentsSelected != 1)
        {
        	isMulitpleApartmentSelected = true;
        	isRecipientSelected = false;
        }
        	
        if(!lstCRToSendAF.isEmpty() && !isMulitpleApartmentSelected && isRecipientSelected)
        {
        	try
         	{
         		List<Contact_Role__c> lstContactRoleToUpdate = new List<Contact_Role__c>();
         		
         		///Update Apartment field on Opportunity
         		if(selectedApartmentId != null)
         		{
			        //Opportunity objopportunity = [SELECT Id,Apartment__c FROM Opportunity WHERE Id=:OPPORTUNITY_ID];
			        //objopportunity.Apartment__c = Id.ValueOf(selectedApartmentId);
                    //objopportunity.StageName='Application Sent'; // Added for THOR-69
			        update new Opportunity(Id = OPPORTUNITY_ID, Apartment__c = Id.ValueOf(selectedApartmentId), StageName = 'Application Sent');
         		}
        
	             List<Messaging.SingleEmailMessage> lstMail = new List<Messaging.SingleEmailMessage>();
	             EmailTemplate objEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Send_Application'];
	             //User objUser = [SELECT Id, Name, Email FROM User WHERE Id =:UserInfo.getUserId()];
	             ///Send email and create a task 
	             for(Contact_Role__c objContRole : lstCRToSendAF)
	             {
	             	Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
      				 	objEmail.setWhatId(objContRole.ID);
      				 	objEmail.setTargetObjectId(objContRole.Person_Account__r.PersonContactId);
      				 	objEmail.setTemplateId(objEmailTemplate.Id);
      				 	objEmail.setSenderDisplayName(UserInfo.getName()); 
      					objEmail.setReplyTo(UserInfo.getUserEmail());
      					objEmail.setSaveAsActivity(true);
      					lstMail.add(objEmail);
      					objContRole.Status__c = 'Application Sent';
      					lstContactRoleToUpdate.add(objContRole);
	             }	 
				 system.debug('==>>>' + lstMail);
				 if(!lstMail.isEmpty()) 
	           		 Messaging.sendEmail(lstMail);
	           	
	           	 if(!lstContactRoleToUpdate.isEmpty())
	           	 	update lstContactRoleToUpdate;
     		}
         		             	
         	catch(Exception mailException)	
         	{
         		system.debug('=========mailException=====>>>>>>>>>>>>>>'+mailException);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,mailException.getmessage()));	
				return;
         	}
        }
    }  
    
     /*!
      *  @MethodName: cancel
      *  @param None: None.
      *  @Description: This method is used to redirect to Opportunity Detail Page onClick of Cancel buton.
    */
    public pagereference cancel()
    {
        return new pagereference('/' + objOpportunity.Id);
    }
   
}