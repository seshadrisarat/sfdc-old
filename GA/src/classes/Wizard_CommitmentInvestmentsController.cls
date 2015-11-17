//==============================================================================
// Class Name   : Wizard_CommitmentInvestmentsController
// Author       : Nikita Jain
// Created Date : 20/11/2012
// Description  : Controller for Wizard_CommitmentInvestments page
//==============================================================================
public class Wizard_CommitmentInvestmentsController {
     
    public list<Commitment_Investment__c> commitmentInvestments{get;set;}
    public List<SelectOption> investMentRounds{get;set;}
    public String selectedIR{get;set;}
    public list<Investment_Round__c> investmentRoundlist{get;set;}
    public string vehicleId{get;set;}
    public string selectedInvestor;
    public Investment_Round__c investorRound{get;set;}
    public list<commitmentWrapper> listCommitmentWrapper{get;set;}
    public integer deleteCIIndex{get;set;}
    public string searchName{get;set;}
    public Integer searchYear{get;set;}
    public Integer searchStatus{get;set;}    
    public String selectedInvestorRC{get;set;}
    public Investor_Commitment_Agreement__c commitment{get;set;}
    public list<SelectOption> selectRecordTypeInvestor{get;set;}
    public list<partnerShipCompanyWrapper> listPartnerShipCompany{get;set;}
    public boolean isContactPresent{get;set;}
    public boolean isInvestorPresent{get;set;}
    public boolean isCommitmentPresent{get;set;}
    public boolean isPreferencePresent{get;set;}
    
    
    public Wizard_CommitmentInvestmentsController() {    	
    	listPartnerShipCompany = new list<partnerShipCompanyWrapper>();
    	commitment = new Investor_Commitment_Agreement__c();
    	commitment.Status__c = 'Active';
    	selectedInvestorRC = 'All';
		populateInvestorSelectList();
    	investorRound = new Investment_Round__c();
    	listCommitmentWrapper = new list<commitmentWrapper>();
        vehicleId = ApexPages.currentPage().getParameters().get('vehicleId'); 
        selectedInvestor = ApexPages.currentPage().getParameters().get('selectedInvestor');
        investmentRoundlist = new list<Investment_Round__c>();
        selectedIR = selectedInvestor;
        extractRelatedInvestor();
        commitmentInvestments = new list<Commitment_Investment__c>();
        populateInvestmentRoundSelectList();    
        extractRelatedCommitmentInvestments();   
        populateCommitmentWrapper();
        populateListPartnerShipCompany();
		deleteCIIndex = 0;	
		setNavigatorVariables();	
		
    }
    
    
    public void extractRelatedInvestor() {
    	if(selectedIR != null){
	    	investorRound = [Select name, id from Investment_Round__c where
	    					 id = :selectedIR];
    	}    	
    }
    
    public set <Id> commitmentIdExcluded;
    public pagereference extractRelatedCommitmentInvestments() {
    	/*list<Commitment_Investment__c>*/ commitmentInvestments = new list<Commitment_Investment__c>();
    	commitmentIdExcluded = new set<Id>();
    	if(selectedIR != null){
	        for(Commitment_Investment__c ci : [Select id, name, size__c, Date__c, Investor_Commitment_Agreement__c,
				                                 Investment_Round__c, Investor_Commitment_Agreement__r.name,
				                                 Partnership_Company__c, Partnership_Company__r.name, 
				                                 Investor_Commitment_Agreement__r.size__c
				                                 from Commitment_Investment__c where Investment_Round__c = :selectedIR]){
				commitmentInvestments.add(ci);
				commitmentIdExcluded.add(ci.Investor_Commitment_Agreement__c);                                 	
			}	                         
    	}
    	populateCommitmentWrapper();
        return null;
    }   
    
    public void populateCommitmentWrapper() {
    	commitmentWrapper cmntWrap;
    	system.debug('==selectedInvestorRC==='+selectedInvestorRC);
    	String recordTypeId = Wizard_Utility.fetchRecordTypeIdFromName(selectedInvestorRC);
    	    	
    	set<Id> recordTypeIdset = new set<Id>();    	
    	String investorLPRecordType = Wizard_Utility.fetchRecordTypeIdFromName('Investor-LP');
    	if(investorLPRecordType != null && investorLPRecordType != ''){
    		 recordTypeIdset.add(investorLPRecordType);
    	}
    	investorLPRecordType = Wizard_Utility.fetchRecordTypeIdFromName('Investor-CoInvestor');
    	if(investorLPRecordType != null && investorLPRecordType != ''){
    		 recordTypeIdset.add(investorLPRecordType);
    	}
    	investorLPRecordType = Wizard_Utility.fetchRecordTypeIdFromName('Investor-Feeder Fund');
    	if(investorLPRecordType != null && investorLPRecordType != ''){
    		 recordTypeIdset.add(investorLPRecordType);
    	}
    	    	
    	String queryString = 'Select id, name, Year__c, Type_of_Account__c, Status__c,'+
    															'Investor__r.name, Investor__c,' + 
    															'Investor__r.recordTypeId, Size__c' +
    												 ' from Investor_Commitment_Agreement__c'+ 
    												 ' WHERE id not in :commitmentIdExcluded' ;    												     	
    	if(selectedInvestorRC == 'All') {
    		queryString += ' AND Investor__r.recordTypeId in :recordTypeIdset';
    	}    										
        if(selectedInvestorRC != 'All') {
        	queryString += ' AND Investor__r.recordTypeId = :recordTypeId';
        }
        if(searchName != null && searchName != '') {        	
        	queryString += ' AND name like \'%' +String.escapeSingleQuotes(searchName)+ '%\'';
        }
        if(searchYear != null && searchYear != 0) {
        	queryString += ' AND year__c = '+searchYear;
        }  
        if(commitment.Status__c != null) {
        	queryString += ' AND status__c = \''+commitment.Status__c+'\'';
        } 
       	
       	system.debug('==queryString==='+queryString);
    	listCommitmentWrapper.clear();
    	for(Investor_Commitment_Agreement__c comm : Database.query(queryString) ) {
    		cmntWrap = new commitmentWrapper(comm);									 	
    		listCommitmentWrapper.add(cmntWrap);
    	}
    	system.debug(listCommitmentWrapper);
    }
    
        
    private void populateInvestmentRoundSelectList() {
    	if(investmentRoundlist != null) {
	        investMentRounds = new list<SelectOption>();
	        SelectOption option;
	        for(Investment_Round__c ir :investmentRoundlist) {
	            option = new selectOption(ir.Id, ir.name);  
	            investMentRounds.add(option);
	        }
    	}
    }
    
    public pagereference saveRecord(){
        upsert commitmentInvestments;
        extractRelatedCommitmentInvestments();
        return null;
    }
    
    //wrapper for commitment list
    public class commitmentWrapper {
    	public boolean isSelected{get;set;}
    	public Investor_Commitment_Agreement__c commitment{get;set;}
    	
    	public commitmentWrapper(Investor_Commitment_Agreement__c cmnt) {
    		isSelected = false;
    		commitment = cmnt;
    	}
    }
    
    public pagereference deleteCI() {
    	delete commitmentInvestments.get(deleteCIIndex);      
        extractRelatedCommitmentInvestments();
        return null;    	
    }
    
    public pagereference addCommitmentInvestment() {
    	list<Commitment_Investment__c> ciInsertList = new list<Commitment_Investment__c>();
    	Commitment_Investment__c ci;
    	boolean isInserted;
    	for(commitmentWrapper wrap :listCommitmentWrapper) {
    		if(wrap.isSelected == true){
    			for(partnerShipCompanyWrapper pc : listPartnerShipCompany) {
    				if(pc.isSelected == true) {
		    			ci = new Commitment_Investment__c();
		    			ci.Investment_Round__c = investorRound.Id;
		    			ci.Investor_Commitment_Agreement__c = wrap.commitment.Id;    			    			    				
    					ci.Partnership_Company__c = pc.partnershipCompany.Id;
    					ciInsertList.add(ci);
    				}    				
    			}    			    		
    		}
    	}
    	if(ciInsertList.size() == 0) {
    			apexpages.addmessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one Partnership Company'));
    			return null;
    	}
    	if(ciInsertList.size() > 0){
    		insert ciInsertList;
    	}
    	system.debug('ciInsertList====='+ciInsertList);
    	populateCommitmentWrapper();
    	extractRelatedCommitmentInvestments();
    	return null;
    }
   
    //Method to fetch all accounts filter by rec type: GA Partnership Company.  
    private void populateListPartnerShipCompany(){
   		partnerShipCompanyWrapper wrap;
   		for(Account acc : [Select id, name 
   						   from Account
   						   where recordTypeId = :Wizard_Utility.fetchRecordTypeIdFromName('GA Partnership Company')]) {
   			wrap = new partnerShipCompanyWrapper(acc);
   			listPartnerShipCompany.add(wrap);				   	
   	    }
   								  
    }
     
    //wrapper for Partnership Company
    public class partnerShipCompanyWrapper {
    	public boolean isSelected{get;set;}
    	public Account partnershipCompany{get;set;}
    	
    	public partnerShipCompanyWrapper(Account acc) {
    		isSelected = false;
    		partnershipCompany = acc;
    	}
    }
               
    //Method to set navigator variables 
    private void setNavigatorVariables() {
    	isContactPresent = Wizard_Utility.isContactPresent(vehicleId);
    	isInvestorPresent = Wizard_Utility.isInvestorPresent(vehicleId);
    	isCommitmentPresent = Wizard_Utility.isCommitmentPresent(vehicleId);
    
    	if(isContactPresent == true && isCommitmentPresent == true)
        isPreferencePresent = true;       
    } 
        
    //Method to populate Investor record type select list
    private void populateInvestorSelectList() {      
      selectRecordTypeInvestor = new list<selectOption>();
      SelectOption option = new selectOption('All', 'All');
      selectRecordTypeInvestor.add(option);
      option = new selectOption('Investor-LP', 'Investor-LP');
      selectRecordTypeInvestor.add(option);
      option = new selectOption('Investor-CoInvestor', 'Investor-CoInvestor');
      selectRecordTypeInvestor.add(option);
      option = new selectOption('Investor-Feeder Fund', 'Investor-Feeder Fund');
      selectRecordTypeInvestor.add(option);
   }
}