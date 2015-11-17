//==============================================================================
// Class Name   : Wizard_Commitment
// Author       : Nikita Jain
// Created Date : 23/10/2012
// Description  : Controller for Commitment page
// Modified date : April 3, 2013 [Story # S-105960 Changes the look and feel of the Commitment Info section]
//==============================================================================

public class Wizard_CommitmentController {
    
    public Investor_Commitment_Agreement__c commitment{get;set;}
    public boolean notifyAccountingCommitment{get;set;}
    public List<SelectOption> selectCommitmentType{get; set;}
    public List<SelectOption> selectInvestorType{get; set;}
    public String selectedCommitment{get;set;}
    public String selectedInvestor{get;set;}
    public list<Investor_Commitment_Agreement__c> commitmentList{get;set;}
    public String companyInvestorId;
    public String vehicleId{get;set;}
    public integer editCommitmentIndex {get;set;}
    public integer deleteCommitmentIndex{get;set;}
    public Account companyInvestor{get;set;}    
    private Set<Id> setOfInvestorIds{get; set;}     
    public Boolean isContactPresent{get;set;}   
    public Boolean isPreferencePresent{get;set;}
    public map<Id, list<Commitment_Investment__c>> commitmentInvestmentMap{get;set;}
    public string mapCommitmentInvestmentIdString{get;set;}
    public integer editCommitmentInvestmentIndex {get;set;}
    public integer deleteCommitmentInvestmentIndex{get;set;}
    public integer commitmentIndex{get;set;}
    public string deleteCommitmentIdCIdelete{get;set;}
    public string editCommitmentIdCIedit{get;set;}
    public Commitment_Investment__c commitmentInvestment{get;set;}
    public string selectedCommitmentId {get;set;}
    public Account vehicle{get;set;}
    //Constructor
    public Wizard_CommitmentController () {  
    	vehicle = new Account(); 
        selectInvestorType = new list<selectOption>();     
        companyInvestorId = ApexPages.currentPage().getParameters().get('Id');
        vehicleId = ApexPages.currentPage().getParameters().get('vehicleId'); 
        if(vehicleId != null && vehicleId != ''){             
            setNavigatorVariables();
        } 
				// Done for Story # S-105960               
        //commitment = new Investor_Commitment_Agreement__c();
        commitment = new Investor_Commitment_Agreement__c(Year__c = Date.today().year());
        commitmentList = new list<Investor_Commitment_Agreement__c>();        
        notifyAccountingCommitment = false; 
        setOfInvestorIds = new Set<Id>();
        commitmentInvestment = new Commitment_Investment__c();
        // Done for Story # S-105960
        //selectedInvestor = 'All';
        populateInvestorList();
        populateCommitmentList();   
        editCommitmentIndex = 0;
        deleteCommitmentIndex = 0;
        editCommitmentInvestmentIndex = 0;
        deleteCommitmentInvestmentIndex = 0;
        commitmentIndex = 0;
        commitmentInvestmentMap = new map<Id, list<Commitment_Investment__c>>();
        mapCommitmentInvestmentIdString = '';
        
    }
    
    public pagereference printSelected(){
        system.debug('====selectedInvestor==='+selectedInvestor);
        return null;
    } 
        
    //Method to pupulate the commitmentList
    public pageReference populateCommitmentList() {
				// Done for Story # S-105960 start    	
        //commitment = new Investor_Commitment_Agreement__c();  
        commitment = new Investor_Commitment_Agreement__c(Year__c = Date.today().year());
        system.debug('========='+selectedInvestor);  
        /*
        if(selectedInvestor == 'All') {
            for(Account account : [Select a.Parent.FirstName, a.Parent.LastName, a.ParentId, a.Id 
                                   From Account a 
                                   where ParentId =: vehicleId]) {
                setOfInvestorIds.add(account.Id);
            }
            // Done for Story # S-105960
            //commitmentList = [Select name, id, Investor__r.name, Year__c, Size__c,
            commitmentList = [Select name, id, Investor__r.name, Year__c, Size__c, Effective_Date__c,
                              Status__c, Type_of_Account__c, Investran_ID__c,CurrencyIsoCode
                              from Investor_Commitment_Agreement__c
                              where Investor__c = :setOfInvestorIds
                              order by lastModifiedDate desc];
        } else {
        */
        		// Done for Story # S-105960
            //commitmentList = [Select name, id, Investor__r.name, Year__c, Size__c,
            commitmentList = [Select name, id, Investor__r.name, Year__c, Size__c, Effective_Date__c,
                              Status__c, Type_of_Account__c, Investran_ID__c, CurrencyIsoCode
                              from Investor_Commitment_Agreement__c
                              where Investor__c = :selectedInvestor
                              order by lastModifiedDate desc];
            commitment.Investor__c = selectedInvestor;
        //}
      //  populateInvestmentCommitmentMap();
        return null;
    }
    
   //Save method from Commitment page 
   public pageReference saveCommitment() {
        if(selectedInvestor == 'All' ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select Investor'));         
            return null;
        }
        if(commitment.Investor__c != null && (commitment.Name != null && commitment.Name != '') ) {
            upsert commitment;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Name Required'));         
            return null;
        }            
        return new pagereference('/apex/Wizard_Contact?id='+vehicleId);
   }
   
   //Method when an existing commitement is edited 
   public pagereference editCommitment() {
    commitment = commitmentList.get(editCommitmentIndex);
    selectedInvestor = commitment.Investor__c;
    return null;
   }
  
  //Method when an existing commitement is deleted 
  public pagereference deleteCommitment() {
    delete commitmentList.get(deleteCommitmentIndex);
    populateCommitmentList();
    return null;
  }
  
   //Method to clear commitment fields
   public pagereference clearCommitmentFields() {
        // Done for Story # S-105960
        //commitment = new Investor_Commitment_Agreement__c();
        commitment = new Investor_Commitment_Agreement__c(Year__c = Date.today().year());
        return null;
   }
   
   //Method to redirect to Contact page from indivisual commitment
	 public pagereference pickInvestorIndex() {
	   if(commitmentList.get(commitmentIndex) != null)
	     return new pagereference('/apex/Wizard_Contact?commitmentId='+commitmentList.get(commitmentIndex).Id+'&Id='+vehicleId);       
	     return null;  
	 }  
 
   //Method to save and add more commitment   
   public pageReference saveAddCommitment() {
        
        if(commitment.Investor__c != null && commitment.name != null && commitment.name != '') {        
            upsert commitment;       
        }else if(selectedInvestor == 'All' ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select Investor'));         
            return null;
        }else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Name Required'));         
            return null;
        }              
        populateCommitmentList();
        return null;
   }
  
   //Method invoked on clickinf next button 
   public pageReference redirectToContactPage() {       
        //return new pagereference('/apex/Wizard_Contact?id='+vehicleId);
      if(commitment == null ||commitment.Id == null){
      	commitment = commitmentList.get(0);
    	}   
    	return new pagereference('/apex/Wizard_Contact?commitmentId='+commitment.Id+'&Id='+vehicleId);
   }
   
  //Method to populate Investor name select list related to selected vehicle
   public void populateInvestorList() {
   	    vehicle = [Select id, name from Account where id = :vehicleId];
        selectInvestorType = new list<selectOption>();
        // Done for Story # S-105960 
        //selectInvestorType.add(new selectOption('All', 'All'));
        list<Account> investorList = [Select a.Name, a.Id From Account a where ParentId =:vehicleId];
        for(Account investor :investorList) {
            if(investor.Id == companyInvestorId) {
                selectedInvestor = investor.Id;
                commitment.Investor__c = investor.Id;   
            }
          SelectOption option = new selectOption(investor.Id, investor.Name);
          selectInvestorType.add(option);  
        }
        // Done for Story # S-105960
        if(selectedInvestor == null && investorList.size() > 0){
        	selectedInvestor = investorList[0].Id;
          commitment.Investor__c = selectedInvestor; 
        }
        
  } 
   
   //Method to set setNavigatorVariables
   public void setNavigatorVariables() {
    isContactPresent = Wizard_Utility.isContactPresent(vehicleId);
    if(isContactPresent == true )
        isPreferencePresent = true;       
   }
   
   
}