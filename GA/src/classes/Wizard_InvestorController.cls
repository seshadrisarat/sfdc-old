//==============================================================================
// Class Name   : Wizard_Investor
// Author       : Nikita Jain
// Created Date : 23/10/2012
// Description  : Controller for Investor page
//==============================================================================

public class Wizard_InvestorController {
    
  public string companyVehicleId{get;set;}
  public Contact cnt{get;set;}
  public Account companyInvestor{get;set;}
  public List<SelectOption> selectRecordTypeInvestor{get;set;}
  public String selectedInvestorRC{get;set;}
  public boolean notifyAccountingInvestor{get;set;}
  public integer editInvestorIndex {get;set;}
  public integer deleteInvestorIndex{get;set;}
  public integer investorIndex{get;set;}  
  public list<Account> companyInvestorList{get;set;}
  public Account oldcompanyInvestor{get;set;}
  public Account companyVehicle{get;set;}
  public Boolean isContactPresent{get;set;}
  public Boolean isCommitmentPresent{get;set;}
  public Boolean isPreferencePresent{get;set;}
   
  //constructor   
  public Wizard_InvestorController () {
    cnt = new Contact();
    companyVehicleId = ApexPages.currentPage().getParameters().get('Id');
    if(companyVehicleId != null && companyVehicleId != '') {
        companyVehicle = [Select name from account where id = :companyVehicleId];
        //Wizard_Utility.isInvestorAndContactPresent(companyVehicleId);    
        setNavigatorVariables();
    }
    notifyAccountingInvestor = false;
    companyInvestor = new Account();
    selectedInvestorRC = 'Investor-LP';    
    populateInvestorSelectList();
    editInvestorIndex = 0;
    deleteInvestorIndex = 0;
    companyInvestorList = new List<Account>();
    companyInvestor.ParentId = companyVehicleId;
    cnt.accountId = companyVehicleId;
    populateInvestorList();    
  }
    
  //save method from Investor page
  public pageReference saveInvestor(){
    Id recordTypeId = Wizard_Utility.fetchRecordTypeIdFromName(selectedInvestorRC);
    if(recordTypeId != null)
        companyInvestor.RecordTypeId = recordTypeId;    
    if(companyVehicleId != null)
        companyInvestor.ParentId = companyVehicleId;    
    if(companyInvestor.name != null && companyInvestor.name != '')    
    	upsert companyInvestor;
              
    return new pagereference('/apex/Wizard_Commitment?Id='+companyInvestor.Id+'&vehicleId='+companyVehicleId);
  }
  
  //Method invoked on editing an existing investor
  public pagereference editInvestor() {
    companyInvestor = companyInvestorList.get(editInvestorIndex);
    selectedInvestorRC = companyInvestor.RecordType.name;
    return null;
  }
  
  //Method to delete an existing investor
  public pagereference deleteInvestor() {  	
    delete companyInvestorList.get(deleteInvestorIndex);
    populateInvestorList();
    selectedInvestorRC = 'Investor-LP';   
    return null;
  }
  
  public pagereference clearInvestorFields() {
    companyInvestor = new Account();
    companyInvestor.ParentId = companyVehicleId;
    return null;
  }
  
  //Method to save and add new investor
  public pageReference saveAddInvestor() {      
    Id recordTypeId = Wizard_Utility.fetchRecordTypeIdFromName(selectedInvestorRC);
    if(recordTypeId != null)
        companyInvestor.RecordTypeId = recordTypeId;    
    if(companyVehicleId != null)
        companyInvestor.ParentId = companyVehicleId;        
    upsert companyInvestor;
         
    oldcompanyInvestor = companyInvestor;
    populateInvestorList();
    companyInvestor = new Account();
    companyInvestor.parentId = companyVehicleId;
    selectedInvestorRC = 'Investor-LP';  
    companyInvestor.RecordTypeId = Wizard_Utility.fetchRecordTypeIdFromName(selectedInvestorRC);
    return null;
  }
  
  //Method to populate existing investor list  
  public void populateInvestorList() {
    if(companyVehicleId != null){
        companyInvestorList = [Select name, id, IsPersonAccount, Parent.name, phone, fax, BillingStreet, BillingCity, BillingState, 
                               BillingCountry, 
                               recordType.Name from Account where ParentId = :companyVehicleId
                               order by lastModifiedDate desc];
    }
    if(oldcompanyInvestor == null && companyInvestorList.size() != 0)
    oldcompanyInvestor = companyInvestorList.get(0);   
  }
  
  //Method to redirect to commitment page from indivisual investor
  public pagereference pickInvestorIndex() {
    if(companyInvestorList.get(investorIndex) != null)
      return new pagereference('/apex/Wizard_Commitment?id='+companyInvestorList.get(investorIndex).Id+'&vehicleId='+companyVehicleId);       
      return null;  
  }
    
  //Method invoked on 'next' button click
  public pageReference redirectToCommitmentPage(){
   if(companyInvestor == null ||companyInvestor.Id == null){
        companyInvestor = companyInvestorList.get(0);
    }   
    return new pagereference('/apex/Wizard_Commitment?Id='+companyInvestor.Id+'&vehicleId='+companyVehicleId);
  } 
  
  //Method to set setNavigatorVariables
  private void setNavigatorVariables() {
    isContactPresent = Wizard_Utility.isContactPresent(companyVehicleId);
    isCommitmentPresent = Wizard_Utility.isCommitmentPresent(companyVehicleId);    
    if(isContactPresent == true && isCommitmentPresent == true ) {
        isPreferencePresent = true;
    }
  }
   
  //Method to populate Investor record type select list
  private void populateInvestorSelectList() {      
      selectRecordTypeInvestor = new list<selectOption>();
      SelectOption option = new selectOption('Investor-LP', 'Investor-LP');
      selectRecordTypeInvestor.add(option);
      option = new selectOption('Investor-CoInvestor', 'Investor-CoInvestor');
      selectRecordTypeInvestor.add(option);
      option = new selectOption('Investor-Feeder Fund', 'Investor-Feeder Fund');
      selectRecordTypeInvestor.add(option);
  }
  
  
}