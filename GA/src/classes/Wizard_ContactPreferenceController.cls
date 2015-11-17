/***************************************************************************************
Class           : Wizard_ContactPreferenceController 
Description     : This class is used to create contact commitment preference.
Developed by    : Harshit Jain (Appirio)
Created Date    : Oct 26, 2012
Modified date : April 1, 2013 [Story # S-105960 Changed the look and feel of the Preferences Detail section and also added the Fax column in it.]
***************************************************************************************/
public class Wizard_ContactPreferenceController {
  public List<SelectOption> selectCommitmentType{get; set;}
  public List<SelectOption> selectContactType{get; set;}    
  public List<SelectOption> selectRecipientType{get; set;}
  public list<Contact> conts{get;set;}
  public String selectedCommitment{get;set;}
  public String commName {get;set;}
  public String invEntName {get;set;}
  public String selectedContact{get;set;}
  public String vehicleId;  
  public String contactId;
  public map<Id,String> contEmailMap;
  public map<Id,String> contFaxMap;
  private Set<Id> setOfInvestorIds{get; set;}
  public Account companyVehicle{get;set;}
  public list<PreferenceWrapper> PreferenceWrapperList{get;set;} 
  //public static final list<String> recordTypeList = new list<String>{'Capital Calls','Quarterly Capital Statements','Tax Statements/K-1s'};
  public list<String> recordTypeList;
  public Boolean isInvestorPresent{get;set;}
  public String defaultEmail{get;set;}
  public String defaultFax{get;set;}
  //Added for Story S-102359
  public List<SelectOption> selectInvestorType{get; set;}
  public String selectedInvestor{get;set;}
  list<Investor_Commitment_Agreement__c> commitmentList;
  Set<ID> commitmentSet = new Set<ID>();
  //Constructor
  public Wizard_ContactPreferenceController() {
        contEmailMap = new map<Id,String>();
        contFaxMap = new map<Id,String>();
        vehicleId = ApexPages.currentPage().getParameters().get('vehicleId');   
        contactId = ApexPages.currentPage().getParameters().get('contactId');
        String commId = ApexPages.currentPage().getParameters().get('commId');
        recordTypeList = new list<String>();
        Commitment__c c = [Select Id,Name,Investor_Entity__r.Name,Investor_Entity__r.Account__c From Commitment__c WHERE Id =: commId];
        selectedCommitment = c.Id;          
        commName = c.Name;
        invEntName = c.Investor_Entity__r.Name;
        vehicleId = c.Investor_Entity__r.Account__c;      
        if(vehicleId != null && vehicleId != ''){
            setOfInvestorIds = new Set<Id>();
            companyVehicle = [Select Id, name,  PersonEmail from Account where id =:vehicleId];
            for(Account account : [Select a.Parent.FirstName, a.Parent.LastName, a.ParentId, a.Id From Account a where ParentId =: vehicleId]) {
                setOfInvestorIds.add(account.Id);
            }
            //Wizard_Utility.isInvestorAndContactPresent(companyVehicle.Id);    
            setNavigatorVariables();
        }
        list<RecordType> ICPrecordTypeList = new list<RecordType>();
        ICPrecordTypeList = [Select r.SobjectType, r.Name
                             From RecordType r 
                             where SobjectType = 'Correspondence_Preference__c'];
        if(ICPrecordTypeList.size() > 0) {                                 
            for(RecordType rc : ICPrecordTypeList){
                recordTypeList.add(rc.Name);
            }
             recordTypeList.sort();                     
        }       
        populateCommitmentSelectList(setOfInvestorIds);
        populateContactList(vehicleId);
        populateRecipientSelectList();
        fetchCorrespondenceRecord();
        
        //Added for S-102359
        populateInvestorList();
        
  } 

  
  //Method to fetch InvestorCorrespondencePreference list 
  public void fetchCorrespondenceRecord() {
    PreferenceWrapperList = new list<PreferenceWrapper>();
    String methodType;
    map<String ,Correspondence_Preference__c> recordTypeCorrespondenceMap = new map<String ,Correspondence_Preference__c>();
    Set<ID> selectedCom = new Set<ID>();
    //saveCorrespondencePreference();
    //Added for handling ALL selection of Commitments.
    system.debug('===TESTING Top Fetch==='+selectedCom);
    if(selectedCommitment == 'All'){
        selectedCom = commitmentSet ;
    }
    else{    
        selectedCom.Add(selectedCommitment);
    }

    System.debug(selectedCommitment);
    System.debug(selectedContact);
    
    for(Correspondence_Preference__c correspondencePreference : [Select i.RecordTypeId, i.RecordType.Name,
                                                                          i.Id, i.Contact__c, i.Communication_Method__c,Recipient_Type__c,Email__c, Fax__c
                                                                          From Correspondence_Preference__c i 
                                                                          where Commitment__c =:selectedCommitment
                                                                          and Contact__c =:selectedContact
                                                                          and RecordType.Name In: recordTypeList]) {
        
        //cariss Story S-146915 START - commented out                                                                
        //if(selectedCommitment == 'All'){
          //  correspondencePreference.Communication_Method__c = '';
            //correspondencePreference.Email__c = '';
            //correspondencePreference.Fax__c = '';
        //} 
        // Added lookup to email on contact record if they don't already have a preference email saved
        if(correspondencePreference.Email__c == '' || correspondencePreference.Email__c == null){
        	//correspondencePreference.Email__c = contEmailMap.get(selectedContact);
        }
        // Added lookup to fax on contact record if they don't already have a preference fax saved
        if(correspondencePreference.Fax__c == '' || correspondencePreference.Fax__c == null){
        	//correspondencePreference.Fax__c = contFaxMap.get(selectedContact);
        }
        //cariss Story S-146915 END  
                                                                       
        recordTypeCorrespondenceMap.put(correspondencePreference.RecordType.Name, correspondencePreference);    
    }
    
    
    for(String recordTypeName : recordTypeList)
    {
        if(recordTypeCorrespondenceMap.get(recordTypeName) != null)
        {
            methodType = recordTypeCorrespondenceMap.get(recordTypeName).Communication_Method__c != null ? recordTypeCorrespondenceMap.get(recordTypeName).Communication_Method__c : '';
            //Done for Story # S-105960
            //PreferenceWrapperList.add(new PreferenceWrapper(recordTypeName, fetchRecordTypeIdFromName(recordTypeName), methodType.contains('Fax'), methodType.contains('Print'), methodType.contains('Filesharing'),recordTypeCorrespondenceMap.get(recordTypeName).Id, recordTypeCorrespondenceMap.get(recordTypeName).Recipient_Type__c, recordTypeCorrespondenceMap.get(recordTypeName).Email__c, methodType.contains('Email')));
            PreferenceWrapperList.add(new PreferenceWrapper(recordTypeName,
                                                            fetchRecordTypeIdFromName(recordTypeName),
                                                            methodType.contains('Fax'),
                                                            methodType.contains('Print'),
                                                            methodType.contains('Filesharing'),
                                                            recordTypeCorrespondenceMap.get(recordTypeName).Id, 
                                                            recordTypeCorrespondenceMap.get(recordTypeName).Recipient_Type__c,
                                                            recordTypeCorrespondenceMap.get(recordTypeName).Email__c, methodType.contains('Email'),
                                                            recordTypeCorrespondenceMap.get(recordTypeName).Fax__c));

            system.debug('==PreferenceWrapperList FOR==='+PreferenceWrapperList);
        }else
        {
            //PreferenceWrapperList.add(new PreferenceWrapper(recordTypeName, fetchRecordTypeIdFromName(recordTypeName),false,false,false,null,'Primary','',false));
            //defaultEmail = [SELECT Email FROM Contact where Id =: selectedContact].Email;
            //defaultFax = [SELECT Fax FROM Contact where Id =: selectedContact].Fax;
            PreferenceWrapperList.add(new PreferenceWrapper(recordTypeName,
                                                            fetchRecordTypeIdFromName(recordTypeName),
                                                            false,
                                                            false,
                                                            false,
                                                            null,'Primary',
                                                            defaultEmail,
                                                            false,
                                                            defaultFax));
            system.debug('==PreferenceWrapperList ELSE==='+PreferenceWrapperList);
        }
    }

    System.debug(PreferenceWrapperList);    
  }
    
  //Method to save commitment preference for each contact
  public void saveCorrespondencePreference() {
    list<Correspondence_Preference__c> correspondencePreferenceList = new list<Correspondence_Preference__c>();
    list<Correspondence_Preference__c> delCorPrefList = new list<Correspondence_Preference__c>();
    Correspondence_Preference__c commitPreference;
    String communicationMethod;
    Set<ID> idUpdates = new Set<ID>();
    Set<String> commMethods = new Set<String>();

    for(PreferenceWrapper correspondencePreference : PreferenceWrapperList)
    {
        commMethods.clear();

        if(correspondencePreference.IsFax == true)
        {
          commMethods.add('Fax');
        }

        if(correspondencePreference.IsPrint == true)
        {
          commMethods.add('Print');
        }

        if(correspondencePreference.IsEmail == true)
        {
          commMethods.add('Email');
        }

        if(correspondencePreference.IsFileSharing == true)
        {
          commMethods.add('Filesharing');
        }        

        //communicationMethod += (correspondencePreference.IsPrint == true ? 'Print' : '');
        //communicationMethod += (correspondencePreference.IsEmail == true ? 'Email' : '');
        //communicationMethod += (correspondencePreference.IsFileSharing == true ? 'Filesharing' : '');
        
        //Done for Issue # I-58202 [6/24/2013] hemant Start - set email and fax to null if not checked
        //if(!correspondencePreference.IsEmail && (correspondencePreference.email != '' || correspondencePreference.email != null)){
          //  correspondencePreference.email = '';
        //}
        //if(!correspondencePreference.IsFax && correspondencePreference.fax != '' || correspondencePreference.fax != null){
            //correspondencePreference.fax = '';
        //}
        //Done for Issue # I-58202 [6/24/2013] hemant end
        
        //Added IF condition by Reena for All commitments.

        if(selectedCommitment == 'All'){
            List<Correspondence_Preference__c> prefs = new List<Correspondence_Preference__c>(
                                                                [Select id from Correspondence_Preference__c 
                                                                where Contact__c   =: selectedContact and Commitment__c =: selectedCommitment]);
            delete prefs;
                                                               
            for(Investor_Commitment_Agreement__c comAgree : commitmentList){
                commitPreference = new Correspondence_Preference__c(Contact__c   = selectedContact,
                                                                     Commitment__c = selectedCommitment,
                                                                     RecordTypeId = correspondencePreference.recordTypeId, 
                                                                     Communication_Method__c = communicationMethod,
                                                                     Recipient_Type__c = correspondencePreference.RecipientType,
                                                                     Email__c = correspondencePreference.email,
                                                                     //Done for Story # S-105960
                                                                     Fax__c = correspondencePreference.fax);
                //if(!idUpdates.Contains(commitPreference.ID)){
     
                if(communicationMethod != ''){    
                    correspondencePreferenceList.add(commitPreference);
                    idUpdates.Add(commitPreference.ID);
                }
                //}
            }
        }
        else{
          System.debug(communicationMethod);
          System.debug(correspondencePreference.RecordId);
          System.debug(commMethods);
          if(!commMethods.isEmpty())
          {
            commitPreference = new Correspondence_Preference__c(id = correspondencePreference.RecordId,
                                                                           Contact__c   = selectedContact,
                                                                           Commitment__c = selectedCommitment,
                                                                           RecordTypeId = correspondencePreference.recordTypeId, 
                                                                           Communication_Method__c = String.join(new List<String>(commMethods),';'),
                                                                           Recipient_Type__c = correspondencePreference.RecipientType,
                                                                           Email__c = correspondencePreference.email != '' ? correspondencePreference.email : contEmailMap.get(selectedContact),
                                                                           //Done for Story # S-105960
                                                                           Fax__c = correspondencePreference.fax != '' ? correspondencePreference.fax : contFaxMap.get(selectedContact));
             //cariss Appirio Story S-146915 START - comment out IF statment                                                              
             //if(!idUpdates.Contains(commitPreference.ID)){
              correspondencePreferenceList.add(commitPreference);
              idUpdates.Add(commitPreference.ID);
          }else if(commMethods.isEmpty() && correspondencePreference.RecordId != null)
          {
            delCorPrefList.add(new Correspondence_Preference__c(Id = correspondencePreference.RecordId));
          }
           //} 
           //cariss Appirio Story S-146915 END
        }                                                                                                  
    }

    if(correspondencePreferenceList.size() > 0)
    {
      System.debug(correspondencePreferenceList);
      upsert correspondencePreferenceList;
        //for(Integer index = 0; index < PreferenceWrapperList.size(); index++) {
          //  PreferenceWrapperList.get(index).RecordId = correspondencePreferenceList.get(index).Id;
        //}
        PreferenceWrapperList.clear();
      fetchCorrespondenceRecord();
    }

    if(delCorPrefList.size() > 0)
    {
      System.debug(delCorPrefList);
      delete delCorPrefList;
        //for(Integer index = 0; index < PreferenceWrapperList.size(); index++) {
          //  PreferenceWrapperList.get(index).RecordId = correspondencePreferenceList.get(index).Id;
        //}
        PreferenceWrapperList.clear();
      fetchCorrespondenceRecord();
    }
    //return new PageReference('/apex/Wizard_Contactpreference?vehicleId='+vehicleId);                                                                                                        
  }

  	

  //Method to populate commitment name select list related to selected vehicle
  public void populateCommitmentSelectList(Set<Id> setOfInvestorIds) {
    selectCommitmentType = new list<selectOption>();
    commitmentList = [Select i.Name, i.Investor__c, i.Id From Investor_Commitment_Agreement__c i where  Investor__c in: setOfInvestorIds];
    //Added All option for commitmenttype by Reena
    SelectOption option = new selectOption('All', 'All');
    selectCommitmentType.add(option);
    for(Investor_Commitment_Agreement__c commitment :commitmentList) {
      commitmentSet.Add(commitment.Id);
      option = new selectOption(commitment.Id, commitment.Name);
      selectCommitmentType.add(option);  
    }
    if(commitmentList.size() > 0) {
        //selectedCommitment = 'All';// commitmentList.get(0).Id; 
    }
  }
    
  //Method to set setNavigatorVariables
  private void setNavigatorVariables() {
    isInvestorPresent = Wizard_Utility.isInvestorPresent(companyVehicle.Id);    
  } 
  
  public PageReference redirectToInvestorRound() {
    return new pagereference('/apex/Wizard_InvestmentRound?vehicleId='+companyVehicle.Id);
  }
  
  //Method to populate contact name select list related to selected vehicle
  public void populateContactList(Id vehicleId) {
    selectContactType = new list<selectOption>();
    list<Contact> contactList = [Select c.Name, c.Id, c.Email, c.Fax From Contact c where AccountId =: vehicleId ORDER BY FirstName ASC];
    for(Contact contact :contactList) {
      contEmailMap.put(contact.Id,contact.Email);
      contFaxMap.put(contact.Id,contact.Fax);
      SelectOption option = new selectOption(contact.Id, contact.Name);
      if(((contactId != null && contactId != '') && contact.Id == contactId)){
                selectedContact = contact.Id;   
      }
      selectContactType.add(option);  
    }
    if(((selectedContact == null || selectedContact == '') && contactList.size() > 0)) {
        selectedContact = contactList.get(0).Id; 
    }
  }
  

  
  
  //Method to populate Investor Correspondence Preference record type select list
  private void populateRecipientSelectList() {      
      selectRecipientType = new list<selectOption>();
      //Done for Story # S-105960
      //SelectOption option = new selectOption('Primary', 'Primary');
      SelectOption option = new selectOption('Primary', '');
      selectRecipientType.add(option);
      //option = new selectOption('CC', 'CC');
      option = new selectOption('CC', '');
      selectRecipientType.add(option);
      //option = new selectOption('BCC', 'BCC');
      option = new selectOption('BCC', '');
      selectRecipientType.add(option);
  }
  
  //Done for Story S-102359 
  

  //Method to pupulate the commitmentList
  public pageReference populateCommitmentList() {
        setOfInvestorIds = new Set<Id>();
        if(selectedInvestor == 'All') {
            for(Account account : [Select a.Parent.FirstName, a.Parent.LastName, a.ParentId, a.Id 
                                   From Account a 
                                   where ParentId =: vehicleId]) {
                setOfInvestorIds.add(account.Id);
            }
      }else{
        setOfInvestorIds.add(selectedInvestor);
      }
        
        populateCommitmentSelectList(setOfInvestorIds);
        return null;
    }
    
  
  //Method to populate Investor name select list related to selected vehicle
   public void populateInvestorList() {
        selectInvestorType = new list<selectOption>();
        selectInvestorType.add(new selectOption('All', 'All')); 
        list<Account> investorList = [Select a.Name, a.Id From Account a where ParentId =:vehicleId];
        for(Account investor :investorList) {
          SelectOption option = new selectOption(investor.Id, investor.Name);
          selectInvestorType.add(option);  
        }
  }
  //End Story S-102359 
    
  //Wrapper class used to maintain communication method related data.
  public class PreferenceWrapper {
    public String recordTypeName{get;set;}
    public String recordTypeId{get;set;}
    public Boolean IsFax{get;set;}
    public Boolean IsPrint{get;set;}
    public Boolean IsEmail{get;set;}
    public Boolean IsFileSharing{get;set;}      
    public Id RecordId;
    public String RecipientType{get;set;}
    public String email{get;set;}
    //Done for Story # S-105960
    public String fax{get;set;}
    public String selectedContact{get;set;}
    
    //public PreferenceWrapper(String recordTypeName, Id recordTypeId, Boolean IsFax, Boolean IsPrint, Boolean IsFileSharing,Id RecordId, String RecipientType, String email, Boolean IsEmail) {
    public PreferenceWrapper(String recordTypeName, Id recordTypeId, Boolean IsFax, Boolean IsPrint, Boolean IsFileSharing,Id RecordId, String RecipientType, String email, Boolean IsEmail, String fax) {
                            this.recordTypeName = recordTypeName;
                            this.recordTypeId = recordTypeId;
                            this.IsFax = IsFax;
                            this.IsPrint = IsPrint;
                            this.IsFileSharing = IsFileSharing;
                            this.RecordId = RecordId;
                            this.RecipientType = RecipientType;
                            this.IsEmail = IsEmail;
                            this.Email = email;
                            //Done for Story # S-105960
                            this.fax = fax;
    }   
  }
  
  //Method to extract recordTypeId from name
  private String fetchRecordTypeIdFromName(String recordTypeName) {
     String recordTypeId ;
     Schema.DescribeSObjectResult tskResult = Schema.SObjectType.Correspondence_Preference__c;
     Map<String,Schema.RecordTypeInfo> rtMapByName = tskResult.getRecordTypeInfosByName();
     if(rtMapByName.containsKey(recordTypeName))
     recordTypeId = rtMapByName.get(recordTypeName).getRecordTypeId(); 
     
     return recordTypeId;
  }
}