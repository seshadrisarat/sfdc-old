/**
* Test methods are in Test_Companies_DSummary.cls
**/
public without sharing class Companies_DSummary_CSearch_filter {
	
	private String companyId_p = null;
	public String companyId {
		get {
			if (companyId_p == null) {
				companyId_p = ApexPages.currentPage().getParameters().get('compId');
			}
			if (companyId_p == null) {
				companyId_p = '';
			}
			return companyId_p;
		}
	}
	
	/*********************************
	 * Names filter methods & fields *
	 *********************************/
	public Multifilter_filter user_filters { get; set; } 
	
	public Companies_DSummary_CSearch_filter() { // Constructor
		user_filters  = new Multifilter_filter();
		if (companyId != '') {
			user_filters.filters[0].value = Companies_DSummary_CSearch_logic.getCompanyName(companyId);
			//user_filters.filters[0].fieldName = 'Client__r.Name';
			user_filters.filters[0].operator = 'contains';
			addFilter();
		}
	}
	
	public Pagereference removeFilter() {
		String fidx = ApexPages.currentPage().getParameters().get('fidx');
		try {
			user_filters.remove( fidx );
		} catch(Exception e) {
			system.debug(e.getMessage());
		}
		searchResult_p = null;
		return null;
	}
	
	public Pagereference addFilter() {
		searchResult_p = null;
		user_filters.add();
		return null;	
	}
	
	public String filter {get;set;}
		
	/****************************************
	 * Creating Picklist options to objects *
	 ****************************************/
	
	/* Product Type picklist items */
	private List<SelectOption> productTypeSO_p = null;
	public List<SelectOption> productTypeSO {
		get {
			if (productTypeSO_p == null) {
				Schema.DescribeFieldResult obj = Ibanking_Project__c.Product_Type__c.getDescribe(); //Get object describe
				List<Schema.PicklistEntry> vals = obj.getPicklistValues(); //Get PickList values
				productTypeSO_p = new List<SelectOption>();
				for (Schema.PicklistEntry val: vals) { //Add values to result array
					productTypeSO_p.add(new SelectOption(val.getLabel(),val.getValue()));
				}
			}
			return productTypeSO_p;
		}
	}
	/* Expected Timing picklist items */
	private List<SelectOption> expectedTimingSO_p = null;
	public List<SelectOption> expectedTimingSO {
		get {
			if (expectedTimingSO_p == null) {
				Schema.DescribeFieldResult obj = Ibanking_Project__c.Expected_Close_Date__c.getDescribe(); //Get object describe
				List<Schema.PicklistEntry> vals = obj.getPicklistValues(); //Get PickList values
				expectedTimingSO_p = new List<SelectOption>();
				for (Schema.PicklistEntry val: vals) { //Add values to result array
					expectedTimingSO_p.add(new SelectOption(val.getLabel(),val.getValue()));
				}
			}
			return expectedTimingSO_p;
		}
	}
	/* Deal Region picklist items */
	private List<SelectOption> dealRegionSO_p = null;
	public List<SelectOption> dealRegionSO {
		get {
			if (dealRegionSO_p == null) {
				Schema.DescribeFieldResult obj = Ibanking_Project__c.Regions__c.getDescribe(); //Get object describe
				List<Schema.PicklistEntry> vals = obj.getPicklistValues(); //Get PickList values
				dealRegionSO_p = new List<SelectOption>();
				for (Schema.PicklistEntry val: vals) { //Add values to result array
					dealRegionSO_p.add(new SelectOption(val.getLabel(),val.getValue()));
				}
			}
			return dealRegionSO_p;
		}
	}
	/* Deal Industry picklist items */
	private List<SelectOption> dealIndustrySO_p = null;
	public List<SelectOption> dealIndustrySO {
		get {
			if (dealIndustrySO_p == null) {
				Schema.DescribeFieldResult obj = Ibanking_Project__c.Industry__c.getDescribe(); //Get object describe
				List<Schema.PicklistEntry> vals = obj.getPicklistValues(); //Get PickList values
				dealIndustrySO_p = new List<SelectOption>();
				for (Schema.PicklistEntry val: vals) { //Add values to result array
					dealIndustrySO_p.add(new SelectOption(val.getLabel(),val.getValue()));
				}
			}
			return dealIndustrySO_p;
		}
	}
	/* Deal Sub-Sector picklist items */
	private List<SelectOption> dealSubSectorSO_p = null;
	public List<SelectOption> dealSubSectorSO {
		get {
			if (dealSubSectorSO_p == null) {
				Schema.DescribeFieldResult obj = Ibanking_Project__c.Sector__c.getDescribe(); //Get object describe
				List<Schema.PicklistEntry> vals = obj.getPicklistValues(); //Get PickList values
				dealSubSectorSO_p = new List<SelectOption>();
				for (Schema.PicklistEntry val: vals) { //Add values to result array
					dealSubSectorSO_p.add(new SelectOption(val.getLabel(),val.getValue()));
				}
			}
			return dealSubSectorSO_p;
		}
	}
	/* Deal Status picklist items */
	private List<SelectOption> dealStatusSO_p = null;
	public List<SelectOption> dealStatusSO {
		get {
			if (dealStatusSO_p == null) {
				Schema.DescribeFieldResult obj = Ibanking_Project__c.Status__c.getDescribe(); //Get object describe
				List<Schema.PicklistEntry> vals = obj.getPicklistValues(); //Get PickList values
				dealStatusSO_p = new List<SelectOption>();
				for (Schema.PicklistEntry val: vals) { //Add values to result array
					dealStatusSO_p.add(new SelectOption(val.getLabel(),val.getValue()));
				}
			}
			return dealStatusSO_p;
		}
	}
	
	/*************************
	 * Getting search result *
	 *************************/
	 
	private List<List<sObject>> searchResult_p {get;set;}
	public List<List<sObject>> searchResult {
		get {
			//Function is in the Companies_DSummary_CSearch_logic class
			if (searchResult_p == null) {
			searchResult_p = Companies_DSummary_CSearch_logic.getSearchResult(
								user_filters.dealResultFilter, 
								user_filters.drpResultFilter, 
								user_filters.pbiResultFilter, 
								productTypeSelected, 
								expectedTimingSelected, 
								dealRegionSelected, 
								dealIndustrySelected, 
								dealSubSectorSelected, 
								dealStatusSelected);
			}
			return searchResult_p;
		}
	}
	
	public List<Ibanking_Project__c> dealTable { //Data to display in the page
		get {
			List<Ibanking_Project__c> res = new List<Ibanking_Project__c>();
			if (searchResult.size() > 0) {
				if (searchResult[0] != null && searchResult[0].size() > 0) {
					res = (List<Ibanking_Project__c>)searchResult[0];
				}
			}
			//system.debug('****** res = '+res);
			return res;
		}
	}
	
	public List<Ibanking_Project__c> drpTable { //Data to display in the page
		get {
			List<Ibanking_Project__c> res = new List<Ibanking_Project__c>();
			if (searchResult.size() > 0) {
				if (searchResult[1] != null && searchResult[1].size() > 0) {
					res = (List<Ibanking_Project__c>)searchResult[1];
				}
			}
			//system.debug('****** res = '+res);
			return res;
		}
	}
	
	public List<Companies_DSummary_CSearch_logic.DealRelatedParties_cls> getDRPlist() { // New results for DRP
		List<Companies_DSummary_CSearch_logic.DealRelatedParties_cls> res = Companies_DSummary_CSearch_logic.getDRPlist(
																	user_filters.drpResultFilter,
																	productTypeSelected, 
																	expectedTimingSelected, 
																	dealRegionSelected, 
																	dealIndustrySelected, 
																	dealSubSectorSelected, 
																	dealStatusSelected);
		
		//system.debug('****** RESULT >>>> '+res);
		
		return res;
	}
	
	public List<Ibanking_Project__c> pbiTable { //Data to display in the page
		get {
			List<Ibanking_Project__c> res = new List<Ibanking_Project__c>();
			if (searchResult.size() > 0) {
				if (searchResult[2] != null && searchResult[2].size() > 0) {
					res = (List<Ibanking_Project__c>)searchResult[2];
				}
			}
			//system.debug('****** res = '+res);
			return res;
		}
	}
	public String dealTableSize {
		get {
			Integer res = 0;
			return dealTable.size()+'';
		}
	}
	public String drpTableSize {
		get {
			Integer res = 0;
			for (Ibanking_Project__c item: drpTable) {
				for (Deal_Related_Parties__c el:item.Deal_Related_Parties__r) {
					res ++;
				}
			}
			//return drpTable.size()+'';
			return res+'';
		}
	}
	public String pbiTableSize {
		get {
			Integer res = 0;
			for (Ibanking_Project__c item: pbiTable) {
				for (Potential_Buyer_Investor__c el:item.Target_Buyers__r) {
					res ++;
				}
			}
			//return pbiTable.size()+'';
			return res+'';
		}
	}
	
	/*************************************
	 * Getting lists of selected options *
	 *************************************/
	
	/* Selected items of Product Type */
	private List<String> productTypeSelected_p = null;
	public List<String> productTypeSelected {
		get {
			if (productTypeSelected_p == null) {
				productTypeSelected_p = new List<String>();
			}
			return productTypeSelected_p;
		}
		set {
			productTypeSelected_p = value;
		}
	}
	/* Selected items of Expected Timing */
	private List<String> expectedTimingSelected_p = null;
	public List<String> expectedTimingSelected {
		get {
			if (expectedTimingSelected_p == null) {
				expectedTimingSelected_p = new List<String>();
			}
			return expectedTimingSelected_p;
		}
		set {
			expectedTimingSelected_p = value;
		}
	}
	/* Selected items of Deal Region */
	private List<String> dealRegionSelected_p = null;
	public List<String> dealRegionSelected {
		get {
			if (dealRegionSelected_p == null) {
				dealRegionSelected_p = new List<String>();
			}
			return dealRegionSelected_p;
		}
		set {
			dealRegionSelected_p = value;
		}
	}
	/* Selected items of Deal Industry */
	private List<String> dealIndustrySelected_p = null;
	public List<String> dealIndustrySelected {
		get {
			if (dealIndustrySelected_p == null) {
				dealIndustrySelected_p = new List<String>();
			}
			return dealIndustrySelected_p;
		}
		set {
			dealIndustrySelected_p = value;
		}
	}
	/* Selected items of Deal Sub-Sector */
	private List<String> dealSubSectorSelected_p = null;
	public List<String> dealSubSectorSelected {
		get {
			if (dealSubSectorSelected_p == null) {
				dealSubSectorSelected_p = new List<String>();
			}
			return dealSubSectorSelected_p;
		}
		set {
			dealSubSectorSelected_p = value;
		}
	}
	/* Selected items of Deal Status */
	private List<String> dealStatusSelected_p = null;
	public List<String> dealStatusSelected {
		get {
			if (dealStatusSelected_p == null) {
				dealStatusSelected_p = new List<String>();
			}
			return dealStatusSelected_p;
		}
		set {
			dealStatusSelected_p = value;
		}
	}
	
	/***************************************
	 *              METHODS                *
	 ***************************************/
	
	public PageReference startSearch() { //Only refresh a page & all search data
		user_filters.getConditions();
		searchResult_p = Companies_DSummary_CSearch_logic.getSearchResult(
								user_filters.dealResultFilter, 
								user_filters.drpResultFilter, 
								user_filters.pbiResultFilter, 
								productTypeSelected, 
								expectedTimingSelected, 
								dealRegionSelected, 
								dealIndustrySelected, 
								dealSubSectorSelected, 
								dealStatusSelected);
		return null;
	}
	
	public PageReference clearFilter() {
		user_filters.getConditions();
		PageReference pg = new PageReference('/apex/Companies_DSummary_CSearch_filter');
		user_filters  = new Multifilter_filter();
		pg.setRedirect(true);
		return pg;
	} 
	
}