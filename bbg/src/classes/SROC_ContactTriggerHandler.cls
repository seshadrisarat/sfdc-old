public with sharing class SROC_ContactTriggerHandler {

    private SROC_System_Settings__c objSS;
    private static final string CUSTOM_SETTING_INSTANCE_NAME = 'SROC'; // Name of the instance from which values are obtain from SROC_System_Settings__c custom setting
    private Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealer').getRecordTypeId(); //To obtain dealer record tyeId  from Contact
    private list<Contact> lstContact;
    private set<Id> setContactId;

    //Contsructor
    public SROC_ContactTriggerHandler() {
        
        //obtaining the values from custom setting
        objSS = SROC_System_Settings__c.getValues(CUSTOM_SETTING_INSTANCE_NAME);
        lstContact = new list<Contact>();
        setContactId = new set<Id>();

    }
 	
 	//method used create a community user on dealer contact insert
    public void onAfterInsert( List<Contact> newList) {

        for(Contact objContact : newList) {

            if(objContact.Create_SROC_Community_User__c && devRecordTypeId == objContact.RecordTypeId) {

                lstContact.add(objContact);
                setContactId.add(objContact.Id);
            }
        }

        if(!lstContact.IsEmpty())
            createCommunityUser(lstContact,setContactId,'Insert');
    }

    //method used create a community user on dealer contact update
    public void onBeforeUpdate( map<Id,Contact> oldMap , map<Id,Contact> newMap) {

        for(Contact objContact : newMap.values()) {

            if(objContact.Create_SROC_Community_User__c && objContact.Create_SROC_Community_User__c != oldMap.get(objContact.Id).Create_SROC_Community_User__c
                && devRecordTypeId == objContact.RecordTypeId ) {
                lstContact.add(objContact);
                setContactId.add(objContact.Id);
            }
        }

        if(!lstContact.IsEmpty())
            createCommunityUser(lstContact,setContactId,'Update');
    }

    //method used create a community user for dealer insert/update cases
    private void createCommunityUser(list<Contact> lstContact,set<Id> setContactId,string strTriggerEvent) {

        map<Id,Id> mapContactIdtoUser = new map<Id,Id>();
        list<User> lstNewCommunityUsertoInsert = new list<User>();
        list<Contact> lstContactCloned = new list<Contact>();
        set<Id> setContactId_ToUncheck_Checkbox = new set<Id>();

        try {	//Iterate through to fetch existing Community user for dealer contacts
            for(User objUser : [Select Id,ContactId 
                                From User 
                                Where (ProfileId =: objSS.Dealer_CCL_Profile_Id__c OR ProfileId =: objSS.Dealer_CCU_Profile_Id__c) AND 
                                ContactId =: setContactId AND ContactId != Null]) {
    
                mapContactIdtoUser.put(objUser.ContactId,objUser.id);
            }
    		
            for(Contact objContact : lstContact) {
    			
    			if(strTriggerEvent == 'Insert')
    					lstContactCloned.add(new Contact(Id= objContact.Id,Create_SROC_Community_User__c = false));
    			else
    				objContact.Create_SROC_Community_User__c = false;
    			
                if(!mapContactIdtoUser.ContainsKey(objContact.Id)) {
    				
    				if(String.isNotEmpty(objContact.Email)) {

    					//Creation of community user
                        User objUser = new User(ContactId = objContact.Id, UserName = objContact.Email, FirstName = (String.IsNotEmpty(objContact.FirstName) ? objContact.FirstName : objContact.LastName),
                                                LastName = objContact.LastName, Email = objContact.Email ,CommunityNickname = 'CommunityNickname_'+Datetime.now().format(),
                                                Alias = String.Valueof(objContact.LastName.Substring(0,1)) + 'CL', 
                                                Profileid = objSS.Dealer_CCL_Profile_Id__c, Emailencodingkey='UTF-8',Languagelocalekey='en_US', 
                                                Localesidkey='en_US', Timezonesidkey='America/New_York',
                                                Street = (String.IsNotEmpty(objContact.MailingStreet) ? objContact.MailingStreet : ''),
                                                City = (String.IsNotEmpty(objContact.MailingCity) ? objContact.MailingCity : ''),
                                                State = (String.IsNotEmpty(objContact.MailingState) ? objContact.MailingState : ''),
                                                Country = (String.IsNotEmpty(objContact.MailingCountry) ? objContact.MailingCountry : ''),
                                                PostalCode = (String.IsNotEmpty(objContact.MailingPostalCode) ? objContact.MailingPostalCode : ''),
                                                MobilePhone = (String.IsNotEmpty(objContact.MobilePhone) ? objContact.MobilePhone : ''),
                                                Phone = (String.IsNotEmpty(objContact.HomePhone) ? objContact.HomePhone : ''),
                                                Birthdate__c = (String.IsNotEmpty(String.valueOf(objContact.Birthday__c)) ? objContact.Birthday__c : NULL) ,
                                                Title = (String.IsNotEmpty(objContact.Title) ? objContact.Title : ''),
                                                CORECONNECT__Classification1__c = 'Dealer');
        
                        lstNewCommunityUsertoInsert.add(objUser);
    				}
    				else {

    					objContact.addError('Email is required inorder to create a Community user for the contact');
    				}	
                }                    
            }
    		
            insert lstNewCommunityUsertoInsert;
            upsert lstContactCloned;
        }
     	catch(Exception ex) {

     		string strCustomError;
			for(Contact objContact : lstContact) {

				if(ex.getMessage().contains('DUPLICATE_USERNAME')){
	                strCustomError = 'Community User cannot be created for Contact as UserName is already taken'; 
	            }
				else if(ex.getMessage().contains('REQUIRED_FIELD_MISSING')) {
	                strCustomError = 'Required field missing ';
	                strCustomError += ex.getMessage().substring(ex.getMessage().lastIndexOf('[') + 1, ex.getMessage().lastIndexOf(']'));
            	}
	            else if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
		              
		            strCustomError = ex.getMessage().split(',')[1].Substring(0,ex.getMessage().split(',')[1].length()-4); 	                
	            }
	            else {

	            	strCustomError = 'An Error occurred while creating a Community user for the contact: ' + ex;
	            }

	            if(String.isNotEmpty(strCustomError))
					objContact.addError(strCustomError);
			}
			system.debug('Exception :'+ex.getMessage());
     	}
    }    
}