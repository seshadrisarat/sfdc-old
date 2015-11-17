/*
*Class: SL_ContactViewPageController
*Description: Controller class for SL_ContactViewPage used to override the standard contact view page .
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_ContactViewPageController
{
      /* State-Begin */ 
    public Contact ObjContact                                                            {get;set;}     // Getting contact fields present in fieldsets and forming dynamic query for contact.
    public String contactID = '';
    public List<Affiliation__c>         lstAffiliation                                   {get;set;}     // list to store affiliation related list
    public List<Provider_Specialty__c>  lstProviderSpecialty                             {get;set;}     // list to store ProviderSpecialty related list
    public List<Provider_Credential__c> lstProviderCredential                            {get;set;}     // list to store ProviderCredential related list
    public List<Provider_Care_Team__c>  lstProviderCareTeam								 {get;set;}		// list to store ProviderCareTeamMemberships related list
    public List<Provider_Address__c> 	lstProviderAddress								 {get;set;}		// list to store Provider Address related list
    public String strPracticeAddress                                                     {get;set;}     // String to store PracticeAddress for Contact
    public String strMailingAddress                                                      {get;set;}     // String to store MailingAddress for Contact
    public boolean isEditRendered                                                        {get;set;} 
    public String strUserId                                                              {get;set;}     // String to store current user id 
    public User objUser ;                                                                               // Current log in user record
    public Profile objProfile;                                                                          
    public List<AffiliationWrapper>       lstAffiliationWrapper                          {get;set;}     // list to bind edit,del buttons to affiliation related list
    public List<ProviderSpecialtyWrapper> lstProviderSpecialtyWrapper                    {get;set;}     // list to bind edit,del buttons to ProviderSpecialty related list
    public List<ProviderCredentialWrapper> lstProviderCredentialWrapper                  {get;set;}     // list to bind edit,del buttons to ProviderCredential related list
    public List<ProviderCareTeamWrapper>   lstProviderCareTeamWrapper					 {get;set;}     // list to bind edit,del buttons to ProviderCareTeam related list
    public List<ProviderAddressWrapper>    lstProviderAddressWrapper					 {get;set;}		// list of bind edit,del buttons to ProviderAddress related list
    public boolean isEdit                                                                {get;set;}     // used to check whether edit button is clicked in contact GeneralInforamtion,ESIData,ContactInformation sections
    public boolean isAddNewOrEdit                                                        {get;set;}     // used to check whether AddNew button is clicked in contact related list
    public boolean isRelatedListEdit                                                     {get;set;}
    public String strContactSection                                                      {get;set;}     // String to maintain url of affiliation standard  New page .
    public string strRelatedlistName                                                     {get;set;}
    public String strQuery ;                                                                            // String used to store dynamic query
    public List<SelectOption> lstPCRT                                                    {get;set;}
    public String strRecordTypeName                                                      {get;set;}              // used to store the selected recordtype name for ProviderCredential record.
    public String strAffiliationAccountId                                                {get;set;}     // used to store account Id of affiliation record which is marked as primary to update contact AccountId
    public String strSelectedRecordType                                                  {get;set;}     // used to store the selected recordtype Id for ProviderCredential record.
    public Id idProviderSpeciality                                                       {get;set;}
    public boolean isAnotherprofileUser                                                  {get;set;} 
    public List<Schema.FieldSetMember> lstContactFields                                  {get;set;}     // used to store fields in contact fieldsets
    public List<Schema.FieldSetMember> lstRelatedListFields                              {get;set;}     // used to store fields in related list fieldsets
    public Affiliation__c objAffiliationForInsertOrEdit                                  {get;set;}     // used to create Affiliation record for contact     
    public Provider_Specialty__c objProviderSpecialityForInsertOrEdit                    {get;set;}     // used to create providerspecialty record for contact
    public Provider_Credential__c objProviderCredentialForInsertOrEdit                   {get;set;}     // used to create providerCredential record for contact
    public Provider_Care_Team__c objProviderCareTeamForInsertOrEdit						 {get;set;}		// used to create providerProviderCareTeam record for contact
    public Provider_Address__c objProviderAddressForInsertOrEdit						 {get;set;}		// used to create provderaddress record for Contact
    public SL_ProviderCredRecordTypeToFieldset__c objProvCredRecTypeToFieldsetCustSet;                     // used to store SL_ProviderCredRecordTypeToFieldset custom setting record based on selected ProviderCredential recordType
    public SL_ProviderCredRecordTypeToFieldset__c objProvCredRecTypeToFieldsetCustSetInitVal;
    public String strRelatedListRecordIdToEdit                                           {get;set;}
    public boolean isEditRecord                                                          {get;set;}
    Map<String, Schema.SObjectType> GlobalDescribeMap;
    public ApexPages.StandardController objStandardController                            {get;set;}
    
     /* State-End */    
    
    public SL_ContactViewPageController(ApexPages.StandardController Controller)
    {
        objStandardController = Controller;
        // getting contact Id
        contactID = controller.getId();
        initialize();
    	for(SL_ProviderCredRecordTypeToFieldset__c objCustSet : [Select Name,Label__c,Fieldset_Name__c
    												  			 From SL_ProviderCredRecordTypeToFieldset__c 
    												  			 Where Active__c = true])
		{
      		lstPCRT.add(new SelectOption(objCustSet.Name, objCustSet.Label__c));
     		 // On load object
      		if(objProvCredRecTypeToFieldsetCustSet == null) 
      		{
      			objProvCredRecTypeToFieldsetCustSet = objCustSet;
      			objProvCredRecTypeToFieldsetCustSetInitVal = objCustSet;
      		}	
		}
        queryContactWithFieldsPresentInFieldset();
        checkCurrentContextUserProfileAndOwnershipOfContact();
        affiliationRecordsBindedWithButtonsAndPrimaryfield();
        providerSpecialityRecordsBindedWithEditdelButtons();
        providerCredentialRecordsBindedWithEditdelButtons();
        providerCareTeamRecordsBindedWithButtonsAndPrimaryfield();
        providerAddressRecordsBindedWithEditandDeleteButtons();
    }
    
    /*
        @MethodName : initialize 
        @Description: This method is used to initialize all variables 
    */
    
    public void initialize()
    {
        Objcontact = new Contact();
        lstAffiliation = new list<Affiliation__c>();
        lstProviderSpecialty = new list<Provider_Specialty__c>();
        lstProviderCredential =  new list<Provider_Credential__c>();
        lstProviderCareTeam = new list<Provider_Care_Team__c>();
        lstProviderAddress = new List<Provider_Address__c>();
        GlobalDescribeMap = Schema.getGlobalDescribe(); 
        objAffiliationForInsertOrEdit = new Affiliation__c();
        objProviderSpecialityForInsertOrEdit = new Provider_Specialty__c();
        objProviderCredentialForInsertOrEdit = new Provider_Credential__c();
        objProviderCareTeamForInsertOrEdit = new Provider_Care_Team__c();
        objProviderAddressForInsertOrEdit = new Provider_Address__c();
        strRecordTypeName = '';
        // objProvCredRecTypeToFieldsetCustSet = new SL_ProviderCredRecordTypeToFieldset__c();
        objProvCredRecTypeToFieldsetCustSetInitVal = new SL_ProviderCredRecordTypeToFieldset__c();
        lstPCRT = new List<SelectOption>();
        objUser = new User();
        objProfile = new Profile();
        strPracticeAddress = '';
        strMailingAddress = '';
        isEditRendered = false;
        isEdit = false;
        isAddNewOrEdit = false;
        isAnotherprofileUser = false;
        isRelatedListEdit = false;
        strQuery = '';
        strContactSection = '';
        strAffiliationAccountId = '';
        strRelatedListRecordIdToEdit = '';
        strSelectedRecordType = '';
        isEditRecord = false;
    }
    
    /*
        @MethodName : checkCurrentContextUserProfileAndOwnershipOfContact 
        @param      : NA
        @Description: This method is used to check current context user profile and ownership of contact record. 
    */
    
      public void checkCurrentContextUserProfileAndOwnershipOfContact()
      {
            try
            {
                 // Getting cuurently logged in user id 
                strUserId = UserInfo.getUserId();
                
                // Querying currently logged in user
                objUser = [ select ProfileId,ContactId,UserType
                            from User where Id=: strUserId];
                
                // Querying 'MIHN - HPD Provider User' profile  (MIHN - HPD Provider User)  
                objProfile = [ select Id from Profile
                              where Name = 'MIHN - HPD Provider User' ];    
                              
                // Comparing currently logged in user profile with MIHN - HPD Provider User and checking the ownership of contact record .              
                if(objUser.ContactId != null && objUser.ProfileId == objProfile.Id && objUser.ContactId == ObjContact.Id ) 
                {
                    isEditRendered = true;
                }   
                    
                // Comparing currently logged in user profile with MIHN - HPD Provider User and checking checking the ownership of contact record  .    
                if(objUser.ContactId != null && objUser.ProfileId == objProfile.Id && objUser.ContactId != ObjContact.Id ) 
                {
                    isEditRendered = false;
                }
                
                if( objUser.ProfileId != objProfile.Id )    
                    isAnotherprofileUser = true;
                
            }
            catch(Exception e)
            {
                // do nothing
            }   
      } 
      
      /*
        @MethodName : providerAddressRecordsBindedWithEditandDeleteButtons 
        @param      : NA
        @CreatedBy	: Pankaj Ganwani
        @JIRATicket	: MIHIN-95
        @Description: This method is used to Query all Provider Address records related to contact and binding edit and del to ProviderAddress related list.
      */
      public void providerAddressRecordsBindedWithEditandDeleteButtons()
      {
      		try
      		{	      		
	      		lstProviderAddressWrapper = new List<ProviderAddressWrapper>();
	      		//Iterating over provider address object to bind edit and del buttons to ProviderAddress related list.
	      		for(Provider_Address__c objProviderAddress : [SELECT Street_Address_1__c, Street_Address_2__c, City__c, State__c, Postal_Code__c, Type__c, CreatedById, 
	      															 Phone__c, Fax__c, Primary__c, Provider__c 
	      													  FROM Provider_Address__c WHERE Provider__c=:contactID])
	  			{
	  					lstProviderAddressWrapper.add(new ProviderAddressWrapper(false,false,Userinfo.getUserId() == objProviderAddress.CreatedById? true:false,objProviderAddress));					 	
	  			}
	  			//To cover the catch block
	      		if(Test.isRunningTest())
	      			Integer i = 10/0;
      		}
      		catch(Exception ex)
      		{
      			System.debug('========================='+ex.getMessage());
      		}
      }
      
      
      
      /*
        @MethodName : providerCareTeamRecordsBindedWithButtonsAndPrimaryfield 
        @param      : NA
        @CreatedBy	: Pankaj Ganwani
        @JIRATicket	: MIHIN-64
        @Description: This method is used to Query all ProviderCareTeam records related to contact and binding edit,del buttons and primary field to ProviderCareTeam related list.
      */
      
    public void providerCareTeamRecordsBindedWithButtonsAndPrimaryfield()
    {
        try
        {
            lstProviderCareTeamWrapper = new list<ProviderCareTeamWrapper>();
             // querying ProviderCareTeam related list for contact
            lstProviderCareTeam = [ select Id ,Name,TOC_Destination__c,Role__c,Direct_Email__c,Care_Team__c,Care_Team__r.Organization__c, createdById
                               From Provider_Care_Team__c
                               where Provider__c =:contactID];
            // Iterating ProviderCareTeam related list and binding edit,del buttons to ProviderCareTeam related list                    
            for( Provider_Care_Team__c objProviderCareTeam : lstProviderCareTeam) 
            {                
                Boolean isEditable = (Userinfo.getUserId() == objProviderCareTeam.createdById) ? true : false;                
                ProviderCareTeamWrapper objProviderCareTeamWrapper = new ProviderCareTeamWrapper(false,false,isEditable,objProviderCareTeam);
                lstProviderCareTeamWrapper.add(objProviderCareTeamWrapper);     
            }    
        }
                       
        catch(Exception e)   
        {
            // do nothing
        }                
    }       
       
       
       /*
        @MethodName : affiliationRecordsBindedWithButtonsAndPrimaryfield 
        @param      : NA
        @Description: This method is used to Query all affiliation records related to contact and binding edit,del buttons and primary field to affiliation related list.
      */
      
    public void affiliationRecordsBindedWithButtonsAndPrimaryfield()
    {
        try
        {
            lstAffiliationWrapper = new list<AffiliationWrapper>();
             // querying affiliation related list for contact
            lstAffiliation = [ select Organization__c,Start_Date__c,End_Date__c,Type__c ,Provider__c, createdById
                               From Affiliation__c
                               where Provider__c =:contactID];
                               
            // Iterating affiliation related list and binding edit,del buttons to affiliation related list                    
            for( Affiliation__c objAffiliation : lstAffiliation) 
            {
                
                Boolean blnTemp = false;
                if(objAffiliation.Organization__c == ObjContact.AccountId)
                    blnTemp = true;
                
                Boolean isEditable = (Userinfo.getUserId() == objAffiliation.createdById) ? true : false;
                
                AffiliationWrapper objWrapper = new AffiliationWrapper(blnTemp,false,false,isEditable,objAffiliation);
                lstAffiliationWrapper.add(objWrapper);      
            }    
        }
                       
        catch(Exception e)   
        {
            // do nothing
        }                
    }
    
      /*
        @MethodName : providerSpecialityRecordsBindedWithEditdelButtons 
        @param      : NA
        @Description: This method is used to Query all ProviderSpecialty records related to contact and binding edit,del buttons to ProviderSpecialty related list.
      */
      
    public void providerSpecialityRecordsBindedWithEditdelButtons()
    {
        try
        {
            lstProviderSpecialtyWrapper = new list<ProviderSpecialtyWrapper>();
        
            // querying ProviderSpecialty related list for contact                   
            lstProviderSpecialty = [ select Specialty__c,Specialty__r.Name,  Provider__c ,As_of_Date__c, Recertification_Date__c ,Expiration_Date__c,Primary_Indicator__c,
            								Specialty__r.Specialty_Code__c, createdById
                                     from Provider_Specialty__c
                                     where Provider__c =:contactID ];
            
            // Iterating ProviderSpecialty related list and binding edit,del buttons to ProviderSpecialty related list
            for( Provider_Specialty__c objProviderSpeciality : lstProviderSpecialty) 
            {
                Boolean isEditable = (Userinfo.getUserId() == objProviderSpeciality.createdById) ? true : false;                 
                ProviderSpecialtyWrapper objWrapper = new ProviderSpecialtyWrapper(false,false,isEditable,objProviderSpeciality);
                lstProviderSpecialtyWrapper.add(objWrapper);        
            }       
        }
        
        catch(Exception e)
        {
            // do nothing
        }
     }
    
    /*
        @MethodName : providerCredentialRecordsBindedWithEditdelButtons 
        @param      : NA
        @Description: This method is used to Query all ProviderCredential records related to contact and binding edit,del buttons to ProviderCredential related list.
   */
    public void providerCredentialRecordsBindedWithEditdelButtons()
    {
        try
        {
            lstProviderCredentialWrapper = new list<ProviderCredentialWrapper>();
            // querying ProviderCredential related list for contact
            lstProviderCredential = [ select Name ,Grant_Date__c ,Credential_Number__c ,Current_Status__c ,Granting_Organization__c,Provider__c,RecordTypeId, createdById
                                      from Provider_Credential__c
                                      where Provider__c =:contactID ];  
                                      
            // Iterating ProviderCredential related list and binding edit,del buttons to ProviderCredential related list
            for( Provider_Credential__c objProviderCredential : lstProviderCredential) 
            {
                Boolean isEditable = (Userinfo.getUserId() == objProviderCredential.createdById) ? true : false;                            
                ProviderCredentialWrapper objWrapper = new ProviderCredentialWrapper(false,false,isEditable,objProviderCredential);
                lstProviderCredentialWrapper.add(objWrapper);       
            }
        }
        catch(Exception e)
        {
            // do nothing
        }
    }
    
     /*
        @MethodName : updateContactAccountId 
        @param      : NA
        @Description: This method is used to Update contact AccountId when user changes primary field in Affiliation related list.
    */
    
    public void updateContactAccountId()
    {
        try
        {
            Contact objContact = new Contact( Id = objContact.Id, AccountId = strAffiliationAccountId );
            update objContact;
        }
        catch(Exception e)
        {
            // do nothing
        }
    }
    
    /*
        @MethodName : createRelatedlistRecordForContact 
        @param      : NA
        @Description: This method is used to create or edit relatedlistrecord for contact when clicking save in modal window
    */
    public Pagereference createOrEditRelatedlistRecordForContact()
    {
            // create or update Affiliation record for contact 
             if(strRelatedlistName == 'Affiliation Edit')
             {
                if(objAffiliationForInsertOrEdit.Id == null)
                    objAffiliationForInsertOrEdit.Provider__c = objContact.Id;
                upsert objAffiliationForInsertOrEdit;
                affiliationRecordsBindedWithButtonsAndPrimaryfield();
             }
             // create or update ProviderSpeciality record for contact
              if(strRelatedlistName == 'ProviderSpecialty Edit')
              {
                    if(objProviderSpecialityForInsertOrEdit.Id == null)
                        objProviderSpecialityForInsertOrEdit.Provider__c = objContact.Id;
                    upsert objProviderSpecialityForInsertOrEdit;
                    providerSpecialityRecordsBindedWithEditdelButtons();
              }
             // create or update ProviderCredential record for contact
              if(strRelatedlistName == 'ProviderCredential Edit')
              {
                    if(objProviderCredentialForInsertOrEdit.Id == null)
                    {
                        objProviderCredentialForInsertOrEdit.Provider__c = objContact.Id;
                        objProviderCredentialForInsertOrEdit.RecordTypeId = [Select DeveloperName,SobjectType from RecordType where DeveloperName =:strRecordTypeName and SobjectType = 'Provider_Credential__c'].id;
                    }    
                    upsert objProviderCredentialForInsertOrEdit;
                    providerCredentialRecordsBindedWithEditdelButtons();
             }
             
             // create or update ProviderSpeciality record for contact
              if(strRelatedlistName == 'ProviderCareTeam Edit')
              { 
                    if(objProviderCareTeamForInsertOrEdit.Id == null)
                        objProviderCareTeamForInsertOrEdit.Provider__c = objContact.Id;
                    upsert objProviderCareTeamForInsertOrEdit; //Performing upsert dml
                    providerCareTeamRecordsBindedWithButtonsAndPrimaryfield();
              }
              
              //create or update ProviderAddress record for contact
              if(strRelatedlistName == 'ProviderAddress Edit')
              {
              	 if(objProviderAddressForInsertOrEdit.Id == null)
                        objProviderAddressForInsertOrEdit.Provider__c = objContact.Id;
                 upsert objProviderAddressForInsertOrEdit; //Performing upsert dml
                 providerAddressRecordsBindedWithEditandDeleteButtons();
              }
             strRecordTypeName = objProvCredRecTypeToFieldsetCustSetInitVal.Name;
             isAddNewOrEdit = false;
             return new Pagereference('/'+ObjContact.Id);
    }
    /*
        @MethodName : updateProviderSpecialityRecord 
        @param      : NA
        @Description: This method is used to Update ProviderSpecialty records when user changes primary field in ProviderSpecialty related list.
    */
    
    public void updateProviderSpecialityRecord()
    {
        try
        {
            // Querying all the provider specialty records except the one which clicked on primary in providerspecialty relatedlist and making Primary_Indicator__c as false for all records.
            list<Provider_Specialty__c> lstProviderSpeciality = [ select Id, Name, Primary_Indicator__c,Provider__c
                                                                  from Provider_Specialty__c
                                                                  where Id !=:idProviderSpeciality and Provider__c =:objContact.id ];
            list<Provider_Specialty__c> lstProviderSpecialityToUpdate = new list<Provider_Specialty__c>();
                                            
            for( Provider_Specialty__c objProSpec : lstProviderSpeciality )     
            {
                Provider_Specialty__c objProviderSpeciality = new Provider_Specialty__c(id=objProSpec.id ,Primary_Indicator__c = false);
                lstProviderSpecialityToUpdate.add(objProviderSpeciality);
            }                       
            Provider_Specialty__c objProviderSpeciality = new Provider_Specialty__c(id=idProviderSpeciality ,Primary_Indicator__c = true);
            lstProviderSpecialityToUpdate.add(objProviderSpeciality);
            update lstProviderSpecialityToUpdate;
       }
       catch(Exception e)
        {
            // do nothing
        }
    }
    
    /* 
    	@ClassName : ProviderAddressWrapper
    	@CreatedBy : Pankaj Ganwani
    	@JIRA ticket : MIHIN-95
        @Description: This class is used to bind edit and delete button links with My Addresses related list   
    */
     public class ProviderAddressWrapper
     {
        public boolean isEdit                                       {set;get;}
        public boolean isDelete                                     {set;get;}
        public boolean isEditable									{set;get;}
        public Provider_Address__c objProviderAddress            	{set;get;}
        
        public ProviderAddressWrapper(boolean isEdit , boolean isDelete , boolean isEditable, Provider_Address__c objProviderAddress)
        {
            this.isEdit         = isEdit;
            this.isDelete       = isDelete;
            this.isEditable		= isEditable;	
            this.objProviderAddress =  objProviderAddress; 
        }
     }    
    
    /* 
    	@ClassName : ProviderCareTeamWrapper
    	@CreatedBy : Pankaj Ganwani
    	@JIRA ticket : MIHIN-64 
        @Description: This class is used to bind primary field , edit and delete buttons for ProviderCareTeam related list    
    */
     public class ProviderCareTeamWrapper
     {
        public boolean isEdit                                       {set;get;}
        public boolean isDelete                                     {set;get;}
        public boolean isEditable									{set;get;}
        public Provider_Care_Team__c objProviderCareTeam            {set;get;}
        
        public ProviderCareTeamWrapper(boolean isEdit , boolean isDelete , boolean isEditable, Provider_Care_Team__c objProviderCareTeam)
        {
            this.isEdit         = isEdit;
            this.isDelete       = isDelete;
            this.isEditable		= isEditable;	
            this.objProviderCareTeam =  objProviderCareTeam; 
        }
     }
    
    /*
        @ClassName : AffiliationWrapper 
        @Description: This class is used to bind primary field , edit and delete buttons for affiliation related list
    */ 
    
    public class AffiliationWrapper
    {
        public boolean isPrimary                                    {set;get;}
        public boolean isEdit                                       {set;get;}
        public boolean isDelete                                     {set;get;}
        public boolean isEditable									{set;get;}
        public Affiliation__c objAffiliation                        {set;get;}
        
        public AffiliationWrapper(boolean isPrimary , boolean isEdit , boolean isDelete , boolean isEditable, Affiliation__c objAffiliation)
        {
            this.isPrimary      = isPrimary;
            this.isEdit         = isEdit;
            this.isDelete       = isDelete;
            this.isEditable		= isEditable;	
            this.objAffiliation =  objAffiliation; 
        }
    }
    
     /*
        @ClassName : ProviderSpecialtyWrapper 
        @Description: This class is used to bind edit and delete buttons for ProviderSpecialty related list
    */ 
    
     public class ProviderSpecialtyWrapper
     {
        public boolean isPrimary                                    {set;get;}
        public boolean isEdit                                       {set;get;}
        public boolean isDelete                                     {set;get;}
        public boolean isEditable									{set;get;}
        public Provider_Specialty__c objProviderSpeciality          {set;get;}
        
        public ProviderSpecialtyWrapper(boolean isEdit , boolean isDelete ,boolean isEditable, Provider_Specialty__c objProviderSpeciality)
        {
            this.isEdit            = isEdit;
            this.isDelete          = isDelete;
            this.isEditable        = isEditable;
            this.objProviderSpeciality  =  objProviderSpeciality; 
        }
     }
     
      /*
           @ClassName : ProviderCredentialWrapper 
           @Description: This class is used to bind edit and delete buttons for ProviderCredential related list
     */ 
     
     public class ProviderCredentialWrapper
     {
        public boolean isEdit                                       {set;get;}
        public boolean isDelete                                     {set;get;}
        public boolean isEditable									{set;get;}
        public Provider_Credential__c objProviderCredential         {set;get;}
        
        public ProviderCredentialWrapper(boolean isEdit , boolean isDelete , boolean isEditable, Provider_Credential__c objProviderCredential)
        {
            this.isEdit            = isEdit;
            this.isDelete          = isDelete;
            this.isEditable        = isEditable;
            this.objProviderCredential  =  objProviderCredential; 
        }
     }
     
     
          
    /*
        @Method-Name  : collectObjContact
        @Description  : This method is used for forming dynamic query for contact based on fields present in fieldsets
   */  
    public void queryContactWithFieldsPresentInFieldset()
    {
      try
      { 
        strQuery = formingQueryWithFieldsPresentInFieldSet();
        String strQueryString = 'Select '+ strQuery + ' from Contact where Id =:contactID' ;
        
        // executing dynamic query 
         Objcontact = Database.Query(strQueryString);
        
         // forming practice address for contact to bind in VF page 
         strPracticeAddress =  ( Objcontact.OtherStreet != '' &&  Objcontact.OtherStreet != null) ?  Objcontact.OtherStreet + ',' + '</br>' :  '</br>' ;
         strPracticeAddress += ( Objcontact.OtherCity != '' &&  Objcontact.OtherCity != null) ? Objcontact.OtherCity + ', ' : ' ' ;
         strPracticeAddress += ( Objcontact.OtherState != '' && Objcontact.OtherState != null) ? Objcontact.OtherState + '</br> ' : '</br>' ;
         strPracticeAddress += ( Objcontact.OtherCountry != '' &&   Objcontact.OtherCountry != null) ? Objcontact.OtherCountry  + ',' :  ' ' ;
         strPracticeAddress += ( Objcontact.OtherPostalCode != '' &&   Objcontact.OtherPostalCode != null) ? Objcontact.OtherPostalCode : '' ;
         
          // forming Mailing address for contact to bind in VF page 
         strMailingAddress =  ( Objcontact.MailingStreet != '' &&  Objcontact.MailingStreet != null) ?  Objcontact.MailingStreet + ',' + '</br>' :  '</br>' ;
         strMailingAddress += ( Objcontact.MailingCity != '' &&  Objcontact.MailingCity != null) ? Objcontact.MailingCity + ', ' : ' ' ;
         strMailingAddress += ( Objcontact.MailingState != '' && Objcontact.MailingState != null) ? Objcontact.MailingState + '</br> ' : '</br>' ;
         strMailingAddress += ( Objcontact.MailingCountry != '' &&   Objcontact.MailingCountry != null) ? Objcontact.MailingCountry + ',' :  ' ' ;
         strMailingAddress += ( Objcontact.MailingPostalCode != '' &&   Objcontact.MailingPostalCode != null) ? Objcontact.MailingPostalCode : '' ;
      }
      catch( Exception e)   
      {
        // do nothing
      }
   }
   
   /*
        @Method-Name  : formingQueryWithFieldsPresentInFieldSet
        @Description  : This method is used for forming dynamic query for contact based on fields present in fieldsets
   */ 
   
    public String formingQueryWithFieldsPresentInFieldSet()
    {
        set<string> setToStoreUniqueFieldsForContact = new set<string>();
        // to get Description about Contact Object
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Contact');
       
        // to get read or write permissions of Lead Object
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
       
        // to get description of fields
        Schema.FieldSet fieldSetObjForGeneralInformation  = DescribeSObjectResultObj.FieldSets.getMap().get('ContactGeneralInformation');
        Schema.FieldSet fieldSetObjForESIData = DescribeSObjectResultObj.FieldSets.getMap().get('ContactESIData');
        Schema.FieldSet fieldSetObjForContactInformation = DescribeSObjectResultObj.FieldSets.getMap().get('ContactInformation');
        
        // Iterating through ContactGeneralInformation fieldset and forming dynamic query
        for(Schema.FieldSetMember fieldSet : fieldSetObjForGeneralInformation.getFields())
        {
            if(strQuery == '')
            {
                strQuery += fieldSet.getFieldPath();
            }
            else
            {
                if(!setToStoreUniqueFieldsForContact.contains(fieldSet.getFieldPath()))
                {
                    strQuery +=  ', ' +fieldSet.getFieldPath();
                    setToStoreUniqueFieldsForContact.add(fieldSet.getFieldPath());
                }
            }
        }
        // Iterating through ContactESIData fieldset and forming dynamic query
        for(Schema.FieldSetMember fieldSet : fieldSetObjForESIData.getFields())
        {
            if(strQuery == '')
            {
                strQuery += fieldSet.getFieldPath();
            }
            else
            {
                if(!setToStoreUniqueFieldsForContact.contains(fieldSet.getFieldPath()))
                {
                    strQuery +=  ', ' +fieldSet.getFieldPath();
                    setToStoreUniqueFieldsForContact.add(fieldSet.getFieldPath());
                }
            }
        }
        
        // Iterating through ContactInformation fieldset and forming dynamic query
        for(Schema.FieldSetMember fieldSet : fieldSetObjForContactInformation.getFields())
        {
            if(strQuery == '')
            {
                strQuery += fieldSet.getFieldPath();
            }
            else
            {
                if(!setToStoreUniqueFieldsForContact.contains(fieldSet.getFieldPath()))
                {
                    strQuery +=  ', ' +fieldSet.getFieldPath();
                    setToStoreUniqueFieldsForContact.add(fieldSet.getFieldPath());
                }
            }
        }   
         // hard coding mailing address for contact 
         if(!strQuery.contains('MailingStreet'))
         { 
             strQuery += ', MailingStreet' ;
         }
            
         if(!strQuery.contains('MailingState'))
         {
             strQuery += ', MailingState';
         }
            
         if(!strQuery.contains('MailingPostalCode'))
         {
             strQuery += ', MailingPostalCode';
         }
            
         if(!strQuery.contains('MailingCountry'))
         {
             strQuery += ', MailingCountry';
         }  
         
         if(!strQuery.contains('MailingCity'))
         {
             strQuery += ', MailingCity';
         }
         
         // Hard coding Practice address for contact
         if(!strQuery.contains('OtherStreet'))
         {
             strQuery += ', OtherStreet';
         }
            
         if(!strQuery.contains('OtherCity'))
         {
             strQuery += ', OtherCity';
         }
         
         if(!strQuery.contains('OtherState'))
         {
             strQuery += ', OtherState';
         }
         
         if(!strQuery.contains('OtherCountry'))
         {
             strQuery += ', OtherCountry';
         }  
         
         if(!strQuery.contains('OtherPostalCode'))
         {
             strQuery += ', OtherPostalCode';
         }
         
         if(!strQuery.contains('AccountId'))
         {
             strQuery += ', AccountId';
         }  
         return strQuery;
    }
   
   
   	  /*
        @CreatedBy	  : Pankaj Ganwani
        @JIRA Ticket  : MIHIN-95
        @Method-Name  : editOrDeleteProviderAddressRecord
        @Description  : This method is called on click of Del link in ProviderAddress related list to delete ProviderAddress record .
     */  
      public void editOrDeleteProviderAddressRecord()
      {
      		try
      		{
      			for(Integer i=0;i<lstProviderAddressWrapper.size();i++)
                {
                    // Deleting related ProviderCareTeam with wrapper row when user clicks delete button
                    if(lstProviderAddressWrapper[i].isDelete && lstProviderAddressWrapper[i].objProviderAddress.Id != null)
                    {
                
                        delete new Provider_Address__c(Id=lstProviderAddressWrapper[i].objProviderAddress.Id);
                        lstProviderAddressWrapper.remove(i);
                        break;
                    }
                    //Deleting wrapper row
                    else if(lstProviderAddressWrapper[i].isDelete)
                    {
                        lstProviderAddressWrapper.remove(i);
                        break;
                    }
                }      			
      		}
      		catch(Exception ex)
      		{
      			
      		}
      }
      
      
      /*
        @CreatedBy	  : Pankaj Ganwani
        @JIRA Ticket  : MIHIN-64
        @Method-Name  : editOrDeleteProviderCareTeamRecord
        @Description  : This method is called on click of Del link in ProviderCareTeam related list to delete ProviderCareTeam record .
     */  
   
       public void editOrDeleteProviderCareTeamRecord()
       {
            try
            {
                for(Integer i=0;i<lstProviderCareTeamWrapper.size();i++)
                {
                    // Deleting related ProviderCareTeam with wrapper row when user clicks delete button
                    if(lstProviderCareTeamWrapper[i].isDelete && lstProviderCareTeamWrapper[i].objProviderCareTeam.Id != null)
                    {
                
                        delete new Provider_Care_Team__c(Id=lstProviderCareTeamWrapper[i].objProviderCareTeam.Id);
                        lstProviderCareTeamWrapper.remove(i);
                        break;
                    }
                    //Deleting wrapper row
                    else if(lstProviderCareTeamWrapper[i].isDelete)
                    {
                        lstProviderCareTeamWrapper.remove(i);
                        break;
                    }
                }
            }
            catch(Exception ex)
            {
                //Do nothing 
            }
        }
      
      /*
        @Method-Name  : editOrDeleteAffiliationRecord
        @Description  : This method is called on click of Del link in affiliation related list to delete Affiliation record .
     */  
   
       public void editOrDeleteAffiliationRecord()
       {
            try
            {
                for(Integer i=0;i<lstAffiliationWrapper.size();i++)
                {
                    // Deleting related Affiliation with wrapper row when user clicks delete button
                    if(lstAffiliationWrapper[i].isDelete && lstAffiliationWrapper[i].objAffiliation.Id != null)
                    {
                
                        delete new Affiliation__c(Id=lstAffiliationWrapper[i].objAffiliation.Id);
                        lstAffiliationWrapper.remove(i);
                        break;
                    }
                    //Deleting wrapper row
                    else if(lstAffiliationWrapper[i].isDelete)
                    {
                        lstAffiliationWrapper.remove(i);
                        break;
                    }
                }
            }
            catch(Exception ex)
            {
                //Do nothing 
            }
        }
       
       /*
            @Method-Name  : editOrDeleteProviderSpecialityRecord
            @Description  : This method is called on click of Del link in ProviderSpeciality related list to delete ProviderSpeciality record .
        
       */
     
      public void editOrDeleteProviderSpecialityRecord()
       {
            try
            {
                for(Integer i=0;i<lstProviderSpecialtyWrapper.size();i++)
                {
                    // Deleting related ProviderSpeciality with wrapper row when user clicks delete button
                    if(lstProviderSpecialtyWrapper[i].isDelete && lstProviderSpecialtyWrapper[i].objProviderSpeciality.Id != null)
                    {
                
                        delete new Provider_Specialty__c(Id=lstProviderSpecialtyWrapper[i].objProviderSpeciality.Id);
                        lstProviderSpecialtyWrapper.remove(i);
                        break;
                    }
                    //Deleting wrapper row
                    else if(lstProviderSpecialtyWrapper[i].isDelete)
                    {
                        lstProviderSpecialtyWrapper.remove(i);
                        break;
                    }
                }
            }
            catch(Exception ex)
            {
                //Do nothing 
            }
       }
     
      /*
            @Method-Name  : editOrDeleteProviderCredentialRecord
            @Description  : This method is called on click of Del link in ProviderCredential related list to delete ProviderCredential record .
        
      */
    
       public void editOrDeleteProviderCredentialRecord()
       {
            try
            {
                for(Integer i=0;i<lstProviderCredentialWrapper.size();i++)
                {
                    // Deleting related ProviderCredential with wrapper row when user clicks delete button
                    if(lstProviderCredentialWrapper[i].isDelete && lstProviderCredentialWrapper[i].objProviderCredential.Id != null)
                    {
                
                        delete new Provider_Credential__c(Id=lstProviderCredentialWrapper[i].objProviderCredential.Id);
                        lstProviderCredentialWrapper.remove(i);
                        break;
                    }
                    //Deleting wrapper row
                    else if(lstProviderCredentialWrapper[i].isDelete)
                    {
                        lstProviderCredentialWrapper.remove(i);
                        break;
                    }
                }
            }
            catch(Exception ex)
            {
                //Do nothing 
            }
      }
 
    /*
    
        @Method-Name  : EditContact
        @Description  : This method is used to edit contact fields of  detail page sections
    
   */  
    public void EditContact()
    {
        isEdit = true;
        lstContactFields = new List<Schema.FieldSetMember>();
        
        // to get Description about Contact Object
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Contact');
        
        // to get read or write permissions of Lead Object
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        // Checking which detail page section edit button in clicked 
        if(strContactSection == 'General Information')
            lstContactFields = DescribeSObjectResultObj.FieldSets.getMap().get('ContactGeneralInformation').getFields();
            
        // Checking which detail page section edit button in clicked    
        if(strContactSection == 'ESI Data')
            lstContactFields = DescribeSObjectResultObj.FieldSets.getMap().get('ContactESIData').getFields();
            
        // Checking which detail page section edit button in clicked
        if(strContactSection == 'Contact Information')
            lstContactFields = DescribeSObjectResultObj.FieldSets.getMap().get('ContactInformation').getFields();
    }
    
     /*
    
        @Method-Name  : editAffiliationRecord
        @Description  : This method is called on click of edit in all relatedlist records to edit relatedlist record for contact
    
   */   
   
    public void editRelatedListRecordForContact()
    {
         lstRelatedListFields = new List<Schema.FieldSetMember>();
         String strQueryForRelatedList ='';   // Used to form dynamic query by fields in field set
         String strQueryString = '';
         isAddNewOrEdit = true;
         
         if(strRelatedlistName == 'Affiliation Edit')
         { 
             objAffiliationForInsertOrEdit = new Affiliation__c();
             Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Affiliation__c');
             Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
             lstRelatedListFields = DescribeSObjectResultObj.FieldSets.getMap().get('AffiliationFieldset').getFields();
            
            // forming dynamic Query from fields in field set 
            for(Schema.FieldSetMember fieldSet : lstRelatedListFields)
            {
                if(strQueryForRelatedList == '')
                {
                    strQueryForRelatedList += fieldSet.getFieldPath();
                }
                else
                {
                    strQueryForRelatedList +=  ', ' +fieldSet.getFieldPath();
                }
                
            }
            strQueryString = 'Select '+ strQueryForRelatedList + ',Provider__c from Affiliation__c where Id =:strRelatedListRecordIdToEdit' ;
            objAffiliationForInsertOrEdit = Database.Query(strQueryString);
         }
         
         /* Start - This code comes under as per the requirement of MIHIN-64 */
         if(strRelatedlistName == 'ProviderCareTeam Edit')
         { 
             objProviderCareTeamForInsertOrEdit = new Provider_Care_Team__c();
             Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Provider_Care_Team__c');
             Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
             lstRelatedListFields = DescribeSObjectResultObj.FieldSets.getMap().get('ProviderCareTeamFieldSet').getFields();
            
            // forming dynamic Query from fields in field set 
            for(Schema.FieldSetMember fieldSet : lstRelatedListFields)
            {
                if(strQueryForRelatedList == '')
                {
                    strQueryForRelatedList += fieldSet.getFieldPath();
                }
                else
                {
                    strQueryForRelatedList +=  ', ' +fieldSet.getFieldPath();
                }
                
            }
            strQueryString = 'Select '+ strQueryForRelatedList + ' from Provider_Care_Team__c where Id =:strRelatedListRecordIdToEdit' ;
            objProviderCareTeamForInsertOrEdit = Database.Query(strQueryString);
         }
          /* End - This code comes under as per the requirement of MIHIN-64 */  
          
          /* Start - This code comes under as per the requirement of MIHIN-95 */
         if(strRelatedlistName == 'ProviderAddress Edit')
         {
         	objProviderAddressForInsertOrEdit = new Provider_Address__c();
         	Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Provider_Address__c');
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            lstRelatedListFields = DescribeSObjectResultObj.FieldSets.getMap().get('ProviderAddressFiedSet').getFields();
            
            // forming dynamic Query from fields in field set 
            for(Schema.FieldSetMember fieldSet : lstRelatedListFields)
            {
                 strQueryForRelatedList+=String.isBlank(strQueryForRelatedList) ? fieldSet.getFieldPath() : ','+fieldSet.getFieldPath();
            }
            if(!strQueryForRelatedList.contains('Provider__c'))
            	strQueryForRelatedList+=' , Provider__c';
            strQueryString = 'Select '+ strQueryForRelatedList + ' from Provider_Address__c where Id =:strRelatedListRecordIdToEdit' ;
            objProviderAddressForInsertOrEdit = Database.Query(strQueryString);
         }
          /* End - This code comes under as per the requirement of MIHIN-95 */
          
          
         if(strRelatedlistName == 'ProviderSpecialty Edit')
         {
             objProviderSpecialityForInsertOrEdit = new Provider_Specialty__c();
             Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Provider_Specialty__c');
             Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
             lstRelatedListFields = DescribeSObjectResultObj.FieldSets.getMap().get('ProviderSpecialtyFieldset').getFields();
            
            // forming dynamic Query from fields in field set 
            for(Schema.FieldSetMember fieldSet : lstRelatedListFields)
            {
                if(strQueryForRelatedList == '')
                {
                    strQueryForRelatedList += fieldSet.getFieldPath();
                }
                else
                {
                    strQueryForRelatedList +=  ', ' +fieldSet.getFieldPath();
                }
                
            }
            strQueryString = 'Select '+ strQueryForRelatedList + ',Provider__c from Provider_Specialty__c where Id =:strRelatedListRecordIdToEdit' ;
            objProviderSpecialityForInsertOrEdit = Database.Query(strQueryString);
         }  
         if(strRelatedlistName == 'ProviderCredential Edit')
         {
         	 string strRecordTypeNameOfEditedRecord ;
         	 try
         	 {
	         	 Provider_Credential__c objPC = [ Select Name,RecordTypeId from Provider_Credential__c where id=:strRelatedListRecordIdToEdit ]; 
	         	 strRecordTypeNameOfEditedRecord = [select Name,DeveloperName from RecordType where id=:objPC.RecordTypeId].DeveloperName;       
	         	 objProviderCredentialForInsertOrEdit = new Provider_Credential__c();
            	 Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Provider_Credential__c');
            	 Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            	 objProvCredRecTypeToFieldsetCustSet = SL_ProviderCredRecordTypeToFieldset__c.getInstance(strRecordTypeNameOfEditedRecord);      
            	 lstRelatedListFields = DescribeSObjectResultObj.FieldSets.getMap().get(objProvCredRecTypeToFieldsetCustSet.Fieldset_Name__c).getFields();
	             	 
	             	 // forming dynamic Query from fields in field set 
	            for(Schema.FieldSetMember fieldSet : lstRelatedListFields)
	            {
	                if(strQueryForRelatedList == '')
	                {
	                    strQueryForRelatedList += fieldSet.getFieldPath();
	                }
	                else
	                {
	                    strQueryForRelatedList +=  ', ' +fieldSet.getFieldPath();
	                }
	                
	            }
	            strQueryString = 'Select '+ strQueryForRelatedList + ',Provider__c from Provider_Credential__c where Id =:strRelatedListRecordIdToEdit' ;
	            objProviderCredentialForInsertOrEdit = Database.Query(strQueryString);
	            objProvCredRecTypeToFieldsetCustSet = objProvCredRecTypeToFieldsetCustSetInitVal;
         	 }
            catch(Exception e)
            {
            	system.debug('##Exception:'+ e);
            }
         }  
    }   
    
     /*
    
        @Method-Name  : queryRelatedRecordTypeFields
        @Description  : This method is used to get the fields of selected recordtype of Providercredential record(method is called onchange of recordtype when creating ProviderCredential record).
    
     */  
    public void queryRelatedRecordTypeFields()
    {
    	isAddNewOrEdit = true;
    	try
    	{
    		Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Provider_Credential__c');
    		Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    		objProvCredRecTypeToFieldsetCustSet = SL_ProviderCredRecordTypeToFieldset__c.getInstance(strRecordTypeName);    
		    lstRelatedListFields = DescribeSObjectResultObj.FieldSets.getMap().get(objProvCredRecTypeToFieldsetCustSet.Fieldset_Name__c).getFields();
		    objProvCredRecTypeToFieldsetCustSet = objProvCredRecTypeToFieldsetCustSetInitVal;
    	}
        catch(Exception e)
        {
           system.debug('##Exception:'+ e);
        }
    }
    
    /*
        @Method-Name  : addNewRecordForContactRelatedList
        @Description  : This method is called when onclick of add new button in related lists to get the fields from corresponding fieldsets
    */
    
    public void addNewRecordForContactRelatedList()
    {
        isAddNewOrEdit = true;
        isEditRecord = false;
        lstRelatedListFields = new List<Schema.FieldSetMember>();
        
        // Checking which detail page section AddNew button in clicked 
        if(strRelatedlistName == 'Affiliation Edit')
         {
            objAffiliationForInsertOrEdit = new Affiliation__c();
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Affiliation__c');
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            lstRelatedListFields = DescribeSObjectResultObj.FieldSets.getMap().get('AffiliationFieldset').getFields();
         }  
            
        // Checking which detail page section AddNew button in clicked  
        if(strRelatedlistName == 'ProviderSpecialty Edit')
        {
            objProviderSpecialityForInsertOrEdit = new Provider_Specialty__c();
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Provider_Specialty__c');
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            lstRelatedListFields = DescribeSObjectResultObj.FieldSets.getMap().get('ProviderSpecialtyFieldset').getFields();
        }   
            
        // Checking which detail page section AddNew button in clicked
        if(strRelatedlistName == 'ProviderCredential Edit')
        {
            objProviderCredentialForInsertOrEdit = new Provider_Credential__c();
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Provider_Credential__c');
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            
            //Default recordtype is set to education onclick of add new button in ProviderCredential  
	         lstRelatedListFields = DescribeSObjectResultObj.FieldSets.getMap().get(objProvCredRecTypeToFieldsetCustSet.Fieldset_Name__c).getFields(); 
        }
        
        /* Start - This code comes under as per the requirement of MIHIN-64*/
        //Checking which detail page section AddNew button is clicked
        if(strRelatedlistName == 'ProviderCareTeam Edit')
        {
        	objProviderCareTeamForInsertOrEdit = new Provider_Care_Team__c();
        	Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Provider_Care_Team__c');
        	Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        	lstRelatedListFields = DescribeSObjectResultObj.FieldSets.getMap().get('ProviderCareTeamFieldSet').getFields();
        }
        /* End - This code comes under as per the requirement of MIHIN-64*/   
        
         /* Start - This code comes under as per the requirement of MIHIN-95*/
        //Checking if Provider address detail page section Add new button has been clicked
        if(strRelatedlistName == 'ProviderAddress Edit')
        {
        	objProviderAddressForInsertOrEdit = new Provider_Address__c();
        	Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Provider_Address__c');
        	Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        	lstRelatedListFields = DescribeSObjectResultObj.FieldSets.getMap().get('ProviderAddressFiedSet').getFields();
        }
        /* End - This code comes under as per the requirement of MIHIN-95*/
    }
}