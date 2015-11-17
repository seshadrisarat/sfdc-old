/**
* Test methods are in Test_Companies_DSummary.cls
**/
public without sharing class Companies_DSummary_CSearch {
	
	public Companies_DSummary_CSearch(Companies_DSummary_CSearch_filter controller) {
		
	}
	
	public String errMsg {get;set;}
	
	/****************************************
	 *        Collecting search data        *
	 ****************************************/
	
	/* Name filters */
	private String dealFilter_p = null;
	public String dealFilter {
		get {
			if (dealFilter_p == null) {
				dealFilter_p = ApexPages.currentPage().getParameters().get('dealFilter');
				if (dealfilter_p == null) {
					dealFilter_p = '';
					errMsg = 'You cannot view data in this page.';
				}
			}
			return dealFilter_p;
		}
	}
	private String drpFilter_p = null;
	public String drpFilter {
		get {
			if (drpFilter_p == null) {
				drpFilter_p = ApexPages.currentPage().getParameters().get('drpFilter');
				if (drpFilter_p == null) {
					drpFilter_p = '';
					errMsg = 'You cannot view data in this page.';
				}
			}
			return drpFilter_p;
		}
	}
	private String pbiFilter_p = null;
	public String pbiFilter {
		get {
			if (pbiFilter_p == null) {
				pbiFilter_p = ApexPages.currentPage().getParameters().get('pbiFilter');
				if (pbiFilter_p == null) {
					pbiFilter_p = '';
					errMsg = 'You cannot view data in this page.';
				}
			}
			return pbiFilter_p;
		}
	}
	
	/* Fields filters */
	private List<String> productTypeList_p = null;
	public List<String> productTypeList {
		get {
			if (productTypeList_p == null) {
				productTypeList_p = getSerchParamsList('productType');
			}
			return productTypeList_p;
		}
	}
	private List<String> expectedTimingList_p = null;
	public List<String> expectedTimingList {
		get {
			if (expectedTimingList_p == null) {
				expectedTimingList_p = getSerchParamsList('expectedTiming');
			}
			return expectedTimingList_p;
		}
	}
	private List<String> dealRegionList_p = null;
	public List<String> dealRegionList {
		get {
			if (dealRegionList_p == null) {
				dealRegionList_p = getSerchParamsList('dealRegion');
			}
			return dealRegionList_p;
		}
	}
	private List<String> dealIndustryList_p = null;
	public List<String> dealIndustryList {
		get {
			if (dealIndustryList_p == null) {
				dealIndustryList_p = getSerchParamsList('dealIndustry');
			}
			return dealIndustryList_p;
		}
	}
	private List<String> dealSubSectorList_p = null;
	public List<String> dealSubSectorList {
		get {
			if (dealSubSectorList_p == null) {
				dealSubSectorList_p = getSerchParamsList('dealSubSector');
			}
			return dealSubSectorList_p;
		}
	}
	private List<String> dealStatusList_p = null;
	public List<String> dealStatusList {
		get {
			if (dealStatusList_p == null) {
				dealStatusList_p = getSerchParamsList('dealStatus');
			}
			return dealStatusList_p;
		}
	}
	
	private List<List<sObject>> searchResult_p = null;
	public List<List<sObject>> searchResult {
		get {
			if (searchResult_p == null) {
				searchResult_p = Companies_DSummary_CSearch_logic.getSearchResult(dealFilter, drpFilter, pbiFilter, productTypeList, expectedTimingList, dealRegionList, dealIndustryList, dealSubSectorList, dealStatusList);
			}
			return searchResult_p;
		}
	}
	
	public List<Ibanking_Project__c> dealTable {
		get {
			List<Ibanking_Project__c> res = new List<Ibanking_Project__c>();
			if (searchResult.size() > 0) {
				if (searchResult[0] != null && searchResult[0].size() > 0) {
					res = (List<Ibanking_Project__c>)searchResult[0];
				}
			}
			return res;
		}
	}
	
	public List<Deal_Related_Parties__c> drpTable {
		get {
			List<Deal_Related_Parties__c> res = new List<Deal_Related_Parties__c>();
			if (searchResult.size() > 0) {
				if (searchResult[1] != null && searchResult[1].size() > 0) {
					res = (List<Deal_Related_Parties__c>)searchResult[1];
				}
			}
			return res;
		}
	}
	
	public List<Potential_Buyer_Investor__c> pbiTable {
		get {
			List<Potential_Buyer_Investor__c> res = new List<Potential_Buyer_Investor__c>();
			if (searchResult.size() > 0) {
				if (searchResult[2] != null && searchResult[2].size() > 0) {
					res = (List<Potential_Buyer_Investor__c>)searchResult[2];
				}
			}
			return res;
		}
	}
	public String dealTableSize {
		get {
			return dealTable.size()+'';
		}
	}
	public String drpTableSize {
		get {
			return drpTable.size()+'';
		}
	}
	public String pbiTableSize {
		get {
			return pbiTable.size()+'';
		}
	}
	
	/*************************
	 *        METHODS        *
	 *************************/
	
	/* Transforming search String parameters to List of params */
	private List<String> getSerchParamsList(String paramType) {
		String params = ApexPages.currentPage().getParameters().get(paramType);
		List<String> res = new List<String>();
		if (params != null) {
			res = params.split(';',0);
		}
		return res;
	}
}