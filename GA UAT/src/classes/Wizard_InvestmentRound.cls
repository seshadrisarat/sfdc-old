//==============================================================================
// Class Name   : Wizard_InvestmentRound
// Author       : Nikita Jain
// Created Date : 22/11/2012
// Description  : Controller for Wizard_InvestmentRound page
//==============================================================================

public class Wizard_InvestmentRound {
    
    public list<Investment_Round__c> investmentRoundlist{get;set;}
    public List<SelectOption> investMentRounds{get;set;}
    public Investment_Round__c investmentRound{get;set;}
    public String selectedIR{get;set;}
    public list<Commitment_Investment__c> commitmentInvestments{get;set;}
    public String editId{get;set;}
    public integer deleteInvestentRoundIndex{get;set;}
    public string vehicleId{get;set;}
    public Boolean isPreferencePresent{get;set;}
    public Boolean isContactPresent{get;set;}
    public Boolean isInvestorPresent{get;set;}
    public Boolean isCommitmentPresent{get;set;}
    public Integer totalRecords {get;set;}
	public Integer selectedPageNumber {get;set;}
	public string searchByName{get;set;}
	public set<String> IRnames = new set<String>();
    public set<String> commitmentId = new set<String>();
     
	public List<list<Investment_Round__c>> allResults{get;set;}
	static final Integer DEFAULT_NUMBER_OF_LINKS_BEFORE_CURRENT;
    static final Integer DEFAULT_RESULTS_PER_PAGE;
    static final Integer DEFAULT_LINKS_AT_A_TIME;
    
    static {
    	DEFAULT_NUMBER_OF_LINKS_BEFORE_CURRENT = 2;
    	DEFAULT_RESULTS_PER_PAGE = 10;
        DEFAULT_LINKS_AT_A_TIME = 5;    	
    }
            
    public Wizard_InvestmentRound() {
        vehicleId = ApexPages.currentPage().getParameters().get('vehicleId');       
        investmentRoundlist = new list<Investment_Round__c>();
        commitmentInvestments = new list<Commitment_Investment__c>();
        investmentRound = new Investment_Round__c();
        deleteInvestentRoundIndex = 0;
        selectedIR = '';
        searchByName = '';
        selectedPageNumber = 1;	  
        getVehicleInvestmentRound();
        setNavigatorVariables();   
                                                        
    }
    
    public Investment_Round__c inv{get;set;}
    public pagereference SaveIR() { 
        if(editId != null && editId != ''){
            inv = new Investment_Round__c(Id=editId);
            inv.series__c = investmentRound.series__c;
            inv.MPI_Deal_Name__c = investmentRound.MPI_Deal_Name__c;
            inv.Prospecting_Deal__c = investmentRound.Prospecting_Deal__c;
            inv.Investran_ID__c = investmentRound.Investran_ID__c;
            inv.name = investmentRound.name;                
        } else {
            inv = investmentRound;
        }           
        upsert inv;
                                    
        investmentRoundlist = new list<Investment_Round__c>();  
        getVehicleInvestmentRound();        
        return new pagereference('/apex/Wizard_CommitmentInvestments?vehicleId='+vehicleId+'&selectedInvestor='+inv.Id);
    }
    
    public pagereference deleteIR(){
    	if(investmentRoundlist.get(deleteInvestentRoundIndex) != null){
        	delete investmentRoundlist.get(deleteInvestentRoundIndex);     
    	} 
        getVehicleInvestmentRound();
        return null;
    }   
    
    private void setNavigatorVariables() {
    isContactPresent = Wizard_Utility.isContactPresent(vehicleId);
    isInvestorPresent = Wizard_Utility.isInvestorPresent(vehicleId);
    isCommitmentPresent = Wizard_Utility.isCommitmentPresent(vehicleId);
    
    if(isContactPresent == true && isCommitmentPresent == true)
        isPreferencePresent = true;       
    } 
      
    
    //Method to redirect to commitmentInvestments page directly from the link
    public integer CIIndex{get;set;}
    public pagereference redirectToCI() {
    	if(investmentRoundlist.get(CIIndex) != null)
    		return new pagereference('/apex/Wizard_CommitmentInvestments?vehicleId='+vehicleId+'&selectedInvestor='+investmentRoundlist.get(CIIndex).Id);
    	return null;	
    }
    
    
    public void getVehicleInvestmentRound() {
    	 selectedPageNumber = 1;	  
        list<Investment_Round__c> investmentRoundlist1 = new list<Investment_Round__c>();
        investmentRoundlist = new list<Investment_Round__c>();
        allResults = new list<list<Investment_Round__c>>();
        String queryString = 'Select id, name, Series__c, Total_Invested__c, '+
				             'Prospecting_Deal__c, Investran_ID__c, MPI_Deal_Name__c, '+
				             'Prospecting_Deal__r.name '+
		                     ' From Investment_Round__c';
		if(searchByName != ''){
			queryString = queryString + ' WHERE name like \'%' +String.escapeSingleQuotes(searchByName)+ '%\'';
		}                                          
	    for(Investment_Round__c ir : Database.query(queryString)) {
	      	investmentRoundlist1.add(ir);
	    }	
       	setPagination(investmentRoundlist1, DEFAULT_RESULTS_PER_PAGE);
    }
    
    
     //Pagination
    //----------------------------------------------------------------------------------------------------------------------------------------
    // Method to Define Paginator Object for Pagination
    //----------------------------------------------------------------------------------------------------------------------------------------
    private void setPagination(List<Investment_Round__c> investmentRoundlist, integer recordsPerPage){
        allResults = new List<List<Investment_Round__c>>();
        totalRecords = investmentRoundlist.size();
        for(Investment_Round__c ir : investmentRoundlist) {
            if(allResults.size() == 0 || allResults.get(allResults.size() - 1).size() == recordsPerPage) {
                    allResults.add(new List<Investment_Round__c>());
            }
            allResults.get(allResults.size() - 1).add(ir);
        }
        getPage();
    }
    
    //----------------------------------------------------------------------------------------------------------------------------------------
    // Method that is used to get selected page
    //----------------------------------------------------------------------------------------------------------------------------------------
    public PageReference getPage() {
        if(allResults != null && allResults.size() > 0)
                investmentRoundlist = allResults.get(selectedPageNumber - 1);
        return null;
    }
    
    //----------------------------------------------------------------------------------------------------------------------------------------
    // Property that returs the total number of pages
    //----------------------------------------------------------------------------------------------------------------------------------------
    public Integer totalPage {
    	
        get {
            if(allResults != null) {
                    return allResults.size();
            }
            return 0;
        }
        set;
    }
    
    //----------------------------------------------------------------------------------------------------------------------------------------
    // Property which return the list of page links to be display
    //----------------------------------------------------------------------------------------------------------------------------------------
    public List<Integer> listOfLinks {
    	
        get {
            Integer current = selectedPageNumber;
            Integer startFrom = current - DEFAULT_NUMBER_OF_LINKS_BEFORE_CURRENT;
            if(startFrom <= 0) startFrom = 1;
            
            List<Integer> links = new List<Integer>();
            
            for(Integer linkNumber = startFrom; linkNumber <= totalPage; linkNumber++) {
                links.add(linkNumber);
                if(links.size() >= DEFAULT_LINKS_AT_A_TIME) break;
            }
            return links;
        }
        set;
    }
    
    //----------------------------------------------------------------------------------------------------------------------------------------
    // Property that return true if there are more links (in backward direction) to be display
    //----------------------------------------------------------------------------------------------------------------------------------------
    public Boolean isMorePrevious {
    	
        get {
            if(listOfLinks.size() > 0 && Integer.valueOf(listOfLinks.get(0)) != 1) {
                    return true;
            }
            return false;
        }
        set; 
    }
                
                //----------------------------------------------------------------------------------------------------------------------------------------
    // Property that return true if there are more links (in forward direction) to be display 
    //----------------------------------------------------------------------------------------------------------------------------------------
    public Boolean isMoreNext {
    	
        get {
            if(listOfLinks.size() > 0 && Integer.valueOf(listOfLinks.get(listOfLinks.size() - 1)) < totalPage) {
                    return true;
            }
            return false;
        }
        set;
    }
    //----------------------------------------------------------------------------------------------------------------------------------------
    // Property that is used to numbering the record on the page (exa : 1-10 of 100)
    //----------------------------------------------------------------------------------------------------------------------------------------
    public String recordNumbering {
    	
        get {
        if(investmentRoundlist != null ) {
          return '(showing ' + getShowingFrom() + '-' + getShowingTo() + ' of ' + totalRecords + ')';
        }
        return '';
        }
        set;
    }
    
    //----------------------------------------------------------------------------------------------------------------------------------------
    // Method that return the Index number of first record on the page
    //----------------------------------------------------------------------------------------------------------------------------------------
    private Integer getShowingFrom() {
    	
       if(totalRecords != 0) {
            Integer showingFrom = (selectedPageNumber * DEFAULT_RESULTS_PER_PAGE ) - DEFAULT_RESULTS_PER_PAGE + 1;
            return showingFrom;
       }
       return 0;
    }
                
                //----------------------------------------------------------------------------------------------------------------------------------------
    // Method that return the Index number of last record on the page
    //----------------------------------------------------------------------------------------------------------------------------------------
    public Integer getShowingTo() {
      system.debug('in pagination=====getShowingTo');	
      Integer showingTo = selectedPageNumber * DEFAULT_RESULTS_PER_PAGE ;
      if (totalRecords < showingTo) {
        showingTo = totalRecords;
      }
      return showingTo;
    }
    
    //----------------------------------------------------------------------------------------------------------------------------------------
    // Return the String for Page Numbering
    //----------------------------------------------------------------------------------------------------------------------------------------
    public String pageNumbering {
    	
        get {
            if(investmentRoundlist != null ) {
                return 'Page '+ selectedPageNumber + ' of ' + totalPage;  
            }
            return '';
        }
        set;
    }

    
   
}