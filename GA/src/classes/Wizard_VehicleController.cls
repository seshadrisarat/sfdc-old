//==============================================================================
// Class Name   : Wizard_Vehicle
// Author       : Nikita Jain
// Created Date : 23/10/2012
// Description  : Controller for Vehicle page
// Modified date : April 5, 2013 [Story # S-105960 Changes the Vehicle Type to Multiselect Picklist]
//==============================================================================

public class Wizard_VehicleController {
 
  public Account companyVehicle{get;set;}
  //Story # S-105960
  //public List<SelectOption> selectRecordTypeVehicle{get;set;} 
  public String selectedVehicleRC{get;set;}
  //public Contact vehicleLookup{get;set;}
  public Account vehicleLookup{get;set;}
  public Boolean isInvestorPresent{get;set;} 
  public Boolean isContactPresent{get;set;}
  public Boolean isCommitmentPresent{get;set;}
  public Boolean isPreferencePresent{get;set;}
 
  //Constructor   
  public Wizard_VehicleController() { 
     companyVehicle = new Account();
    if(ApexPages.currentPage().getParameters().get('Id') == null 
       || ApexPages.currentPage().getParameters().get('Id') == '' ) {       
        //Story # S-105960
        //selectedVehicleRC = 'Vehicle-LP';
        selectedVehicleRC = 'Vehicle';
        //vehicleLookup = new Contact();
        vehicleLookup = new Account();        
        //Story # S-105960 End
    } else {
        list<Account> accList = [Select id, phone, fax, name, BillingStreet, BillingCity, BillingState,
                                  //Story # S-105960
                                  //recordType.Name, isPersonAccount, LP_Site_ID__c,
                                  recordType.Name, isPersonAccount, LP_Site_ID__c, Vehicle_Type__c,
                                  Website,  Investran_ID__c, Description, BillingCountry                  
                                  from Account
                                  Where id = :ApexPages.currentPage().getParameters().get('Id')];
        if(accList != null && accList.size() > 0) {
            companyVehicle = accList.get(0);        
            //vehicleLookup = new Contact();
            vehicleLookup = new Account(); 
            //vehicleLookup.AccountId = companyVehicle.id;
            vehicleLookup.Vehicle_Account__c = companyVehicle.id;
            
            if(accList.get(0).recordType != null)
                selectedVehicleRC = accList.get(0).recordType.Name;          
            setNavigatorVariables();
        }                                                        
    }   
    //Story # S-105960
    //populateVehicleSelectList();     
  }
  
  //Save method from Vehicle page (fires on save and next button click)
  public pageReference saveVehicle() {      
    if(companyVehicle.name == null || companyVehicle.name == '') {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company name required !!'));         
        return null;
    }      
    system.debug('====selectedVehicleRC===='+selectedVehicleRC);
    Id recordTypeId = Wizard_Utility.fetchRecordTypeIdFromName(selectedVehicleRC);
    if(recordTypeId != null){
        companyVehicle.RecordTypeId = recordTypeId;
    }
    upsert companyVehicle;    
    return new pagereference('/apex/Wizard_Investor?id='+companyVehicle.Id);
  }
  
  //Populate vehicle fields (on selecting an existing vehicle )
  public pagereference setVehicleField() {
    //if(vehicleLookup.AccountId != null) {
    if(vehicleLookup.Vehicle_Account__c != null) {           
        companyVehicle = [Select id, phone, fax, name, BillingStreet, BillingCity, BillingState,
                          //Story # S-105960
                          //recordType.Name, isPersonAccount, LP_Site_ID__c, BillingCountry,
                          recordType.Name, isPersonAccount, LP_Site_ID__c, BillingCountry, Vehicle_Type__c,
                          Website,  Investran_ID__c, Description        
                          from Account
                          //Where id = :vehicleLookup.AccountId];
                          Where id = :vehicleLookup.Vehicle_Account__c];
        selectedVehicleRC = companyVehicle.RecordType.Name;
        setNavigatorVariables();
    }
    //Wizard_Utility.isInvestorAndContactPresent(companyVehicle.Id);    
     
    return null;
  }
     
  //Method to set setNavigatorVariables
  private void setNavigatorVariables() {    
    isInvestorPresent = Wizard_Utility.isInvestorPresent(companyVehicle.Id);
    isContactPresent = Wizard_Utility.isContactPresent(companyVehicle.Id);
    isCommitmentPresent = Wizard_Utility.isCommitmentPresent(companyVehicle.Id);    
    if(isContactPresent == true && isCommitmentPresent == true ) {
        isPreferencePresent = true;
    }
  }
  
  //Story # S-105960
  /*      
  //Method to populate Vehicle record type select list
  private void populateVehicleSelectList() {      
      selectRecordTypeVehicle = new list<selectOption>();
      SelectOption option = new selectOption('Vehicle-LP', 'Vehicle-LP');
      selectRecordTypeVehicle.add(option);
      option = new selectOption('Vehicle-CoInvestor', 'Vehicle-CoInvestor');
      selectRecordTypeVehicle.add(option);
      option = new selectOption('Vehicle-Feeder Fund', 'Vehicle-Feeder Fund');
      selectRecordTypeVehicle.add(option);
  }
  */    
}