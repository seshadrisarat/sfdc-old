//==============================================================================
// Class Name   : Wizard_ContactController
// Author       : Harshit Jain
// Created Date : 23/10/2012
// Description  : Controller for Contact page
//==============================================================================

public class Wizard_ContactController {

  public String vehicleId; 
  public Contact contact{get;set;}
  public list<Contact> contactTable{get;set;}
  public Account companyVehicle{get;set;}
  public boolean notifyAccountingContact{get;set;} 
  public integer editContactIndex {get;set;}
  public integer deleteContactIndex{get;set;}
  public Boolean isCommitmentPresent{get;set;}
  public Boolean isInvestorPresent{get;set;}
  public Boolean isPreferencePresent{get;set;}
  public Account contactLookup{get;set;}
  
  public String selCommitmentId;
  
  //Story # S-105960 Start for Limited Partner Contact record type
  //When Contacts are to be added, add them with "Limited Partner Contact" record type
  private final String CONTACT_RTYPE_LIMITED_PARTNER_CONTACT= 'Limited Partner Contact';
  private Id contRcrdTypeId_LPC;
  //Story # S-105960 End
	
  //Constructor
  public Wizard_ContactController() {
  	contactLookup = new Account();
  	notifyAccountingContact = false;
		vehicleId = ApexPages.currentPage().getParameters().get('Id');
		selCommitmentId = ApexPages.currentPage().getParameters().get('commitmentId');
		
		//setting the record Type Id
		contRcrdTypeId_LPC = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONTACT_RTYPE_LIMITED_PARTNER_CONTACT).getRecordTypeId();
	
	//contact = new Contact();
	contact = new Contact(RecordTYpeId = contRcrdTypeId_LPC);
	
	contactTable = new list<Contact>();
	populateContactList();
	if(vehicleId != null && vehicleId != '') {
		list<Account> acclist = [Select Id, name,isPersonAccount from Account where id =:vehicleId];
		if(acclist != null && acclist.size() > 0) {
			companyVehicle = acclist.get(0);	
			setNavigatorVariables();		
		}     		
	}
	editContactIndex = 0;
	deleteContactIndex = 0;
  }
	
   //Method to pupulate the contactList
   public pageReference populateContactList() {
	    if(selCommitmentId != '' && selCommitmentId != null){
	    	
	    	Set<Id> contactIdSet = new Set<Id>();
	    	for(Investor_Correspondence_Preference__c correspondencePreference : [Select i.Investor_Commitment_Agreement__c, i.Id, i.Contact__c 
  																	      From Investor_Correspondence_Preference__c i 
  																		  where Investor_Commitment_Agreement__c =:selCommitmentId]) {
  				contactIdSet.add(correspondencePreference.Contact__c);	
  			}
  			if(contactIdSet.size() > 0){ 
  				//Story # S-105960
  				//contactTable = [Select Id, firstname, lastname, MailingState, MailingCity, Name, fax, phone, MailingStreet, MailingCountry
  				contactTable = [Select Id, firstname, lastname, MailingState, MailingCity, Name, fax, phone, MailingStreet, MailingCountry, Email
  				//Story # S-105960 End 
	    	                		from contact 
	    	                		where Id = :contactIdSet
	    	                		order by lastmodifiedDate desc];
  			}
	    	
	    }else{
	    	if(vehicleId != null){
	    		//Story # S-105960
	    		//contactTable = [Select Id, firstname, lastname, MailingState, MailingCity,
	    		contactTable = [Select Id, firstname, lastname, MailingState, MailingCity, Email,
	    		//Story # S-105960 End
	    	    	     	Name, fax, phone, MailingStreet, MailingCountry 
	    	                from contact 
	    	                where AccountId = :vehicleId
	    	                order by lastmodifiedDate desc];
	    	}
	    }
	    return null;
   }
  
  //edit existing contact
  public pagereference editContact() {
  	contact = contactTable.get(editContactIndex);
  	return null;
  }
 
  //delete existing contact
  public pagereference deleteContact() {
  	delete contactTable.get(deleteContactIndex);
  	populateContactList();
  	return null;
  }
  
  //Method to save a contact and move to next page  
  public pagereference saveContact() {
   	if(contact.lastname == null || contact.lastname == ''){
   		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Last name required'));         
        return null;
   	}
    if(vehicleId != null && (contact.lastname != null && contact.lastname != '' )) {
        contact.AccountId = vehicleId;
        upsert contact;
    }
    
    setNavigatorVariables();
    //Done for Story # S-102359 [Passing contact in the Wizard_ContactPreference so that preference tab should start with contact from previous tab selected]   
    //return new pagereference('/apex/Wizard_ContactPreference?vehicleId='+vehicleId);
    return new pagereference('/apex/Wizard_ContactPreference?vehicleId='+vehicleId + '&contactId=' + contact.Id);
   }
   
  //Method to save and add new contact
  public pagereference addContact(){
   	if(contact.lastname == null || contact.lastname == ''){
   		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Last name required'));         
        return null;
   	}
     if(vehicleId != null && (contact.lastname != null && contact.lastname != '' )) {
        contact.AccountId = vehicleId;
        upsert contact;
    }
    
    populateContactList();
    setNavigatorVariables();
	  //contact = new Contact();
	  contact = new Contact(RecordTYpeId = contRcrdTypeId_LPC);
    return null;       
  }
  
  //Method to set fields of exiating contacts
  public pagereference setContactField() {
  	contact = new Contact();
  	contact = new Contact(RecordTYpeId = contRcrdTypeId_LPC);
  	//Story # S-105960 Start
  	//contact = [Select Id, firstname, lastname, MailingState, MailingCity,
  	contact = [Select Id, firstname, lastname, MailingState, MailingCity, Email,
  	//Story # S-105960 End
    	     	Name, fax, phone, MailingStreet, MailingCountry 
                from contact where id =: contactLookup.Source_Contact__c];
  	return null;     
  }
  
  //Method to clear contact fields
  public pagereference clearContactFields() {
   	contact = new Contact();
   	contact = new Contact(RecordTYpeId = contRcrdTypeId_LPC);
   	return null;
   }
   
  //Method invoked to clicking next button 
  public pageReference redirectToContactPreferencePage(){
  	//Done for Story # S-102359 [Passing contact in the Wizard_ContactPreference so that preference tab should start with contact from previous tab selected]   
  	//return new pagereference('/apex/Wizard_ContactPreference?vehicleId='+vehicleId);
  	if(contact.Id != null){
  		return new pagereference('/apex/Wizard_ContactPreference?vehicleId='+vehicleId + '&contactId=' + contact.Id);
  	}else{
  		return new pagereference('/apex/Wizard_ContactPreference?vehicleId='+vehicleId);
  	}
  	
   } 
   
  //Method to set setNavigatorVariables
  private void setNavigatorVariables() {
  	isInvestorPresent = Wizard_Utility.isInvestorPresent(companyVehicle.Id);
  	isCommitmentPresent = Wizard_Utility.isCommitmentPresent(companyVehicle.Id);
  	if(isCommitmentPresent == true && Wizard_Utility.isContactPresent(companyVehicle.Id)) {
  		isPreferencePresent = true;
  	}
  }     
}