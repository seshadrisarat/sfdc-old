@isTest
private class Companies_DSummary_CSearch_test {
	public static testMethod void firstTest() {
		
		/* Creating a test data */
		//Accounts
		List<Account> accounts = new List<Account>();
		accounts.add(new Account(Name='Account 1'));
		accounts.add(new Account(Name='Account 2'));
		accounts.add(new Account(Name='Account 3'));
		insert accounts;
		//Deals
		List<Ibanking_Project__c> deals = new List<Ibanking_Project__c>();
		deals.add(new Ibanking_Project__c(Client__c=accounts[0].Id));
		deals.add(new Ibanking_Project__c(Client__c=accounts[1].Id));
		deals.add(new Ibanking_Project__c(Client__c=accounts[2].Id));
		insert deals;
		//Deal Related Parties
		List<Deal_Related_Parties__c> drp = new List<Deal_Related_Parties__c>();
		drp.add(new Deal_Related_Parties__c(Deal__c=deals[0].Id,Company__c=accounts[1].Id));
		drp.add(new Deal_Related_Parties__c(Deal__c=deals[1].Id,Company__c=accounts[2].Id));
		drp.add(new Deal_Related_Parties__c(Deal__c=deals[2].Id,Company__c=accounts[0].Id));
		insert drp;
		//Potential Buyer / Investor
		List<Potential_Buyer_Investor__c> pbi = new List<Potential_Buyer_Investor__c>();
		pbi.add(new Potential_Buyer_Investor__c(Project__c=deals[0].Id,TargetBuyer__c=accounts[2].Id));
		pbi.add(new Potential_Buyer_Investor__c(Project__c=deals[1].Id,TargetBuyer__c=accounts[0].Id));
		pbi.add(new Potential_Buyer_Investor__c(Project__c=deals[2].Id,TargetBuyer__c=accounts[1].Id));
		insert pbi;
		
		/* Search result for current company */
		Account currCompany = [SELECT Id,Name FROM Account Limit 1];
		ApexPages.currentPage().getParameters().put('compId',currCompany.Id);
		
		Companies_DSummary_CSearch_filter filter = new Companies_DSummary_CSearch_filter();
		List<List<sObject>> searchResult = filter.searchResult;
		system.debug('==== Search Result for Current Company ======== >>>> '+searchResult);
		
		/* Modelling search process for user */
		ApexPages.currentPage().getParameters().put('compId','');
		filter = new Companies_DSummary_CSearch_filter();
		
		//Add new filters
		filter.user_filters.filters[0].value = 'Account 1';
		filter.user_filters.filters[0].operator = 'contains';
		filter.user_filters.filters[0].condition = ' OR ';
		filter.addFilter();
		filter.user_filters.filters[1].value = 'Account 2';
		filter.user_filters.filters[1].operator = 'startsWith';
		filter.user_filters.filters[1].condition = ' AND ';
		filter.addFilter();
		filter.user_filters.filters[2].value = 'Account 1';
		filter.user_filters.filters[2].operator = 'notContain';
		filter.user_filters.filters[2].condition = ' OR ';
		filter.addFilter();
		filter.user_filters.filters[3].value = 'Account 2';
		filter.user_filters.filters[3].operator = 'equals';
		filter.user_filters.filters[3].condition = ' AND ';
		filter.addFilter();
		filter.user_filters.filters[3].value = 'Account 1';
		filter.user_filters.filters[3].operator = 'notEqual';
		filter.addFilter();
		system.debug('==== Filters after adding ======== >>>> '+filter.user_filters.filters);
		//Remove filters
		ApexPages.currentPage().getParameters().put('fidx','1');
		filter.removeFilter();
		ApexPages.currentPage().getParameters().put('fidx','1');
		filter.removeFilter();
		ApexPages.currentPage().getParameters().put('fidx','1');
		filter.removeFilter();
		ApexPages.currentPage().getParameters().put('fidx','1');
		filter.removeFilter();
		system.debug('==== Filters after removing ======== >>>> '+filter.user_filters.filters);
		//Start other functions in Multi_Filter.cls
		filter.user_filters.filters[0].getOperators();
		String err = filter.user_filters.errMsg;
		
		//Reading multiselect records from schema
		List<String> selectedProductTypeOpts = new List<String>();
		if (filter.productTypeSO.size() > 0)
			selectedProductTypeOpts.add(filter.productTypeSO[0].getValue());
		List<String> selectedexpectedTimingSOOpts = new List<String>();
		if (filter.expectedTimingSO.size() > 0)
			selectedexpectedTimingSOOpts.add(filter.expectedTimingSO[0].getValue());
		List<String> selecteddealRegionSOOpts = new List<String>();
		if (filter.dealRegionSO.size() > 0)
			selecteddealRegionSOOpts.add(filter.dealRegionSO[0].getValue());
		List<String> selecteddealIndustrySOOpts = new List<String>();
		if (filter.dealIndustrySO.size() > 0)
			selecteddealIndustrySOOpts.add(filter.dealIndustrySO[0].getValue());
		List<String> selecteddealSubSectorSOOpts = new List<String>();
		if (filter.dealSubSectorSO.size() > 0)
			selecteddealSubSectorSOOpts.add(filter.dealSubSectorSO[0].getValue());
		List<String> selecteddealStatusSOOpts = new List<String>();
		if (filter.dealStatusSO.size() > 0)
			selecteddealStatusSOOpts.add(filter.dealStatusSO[0].getValue());
		
		filter.startSearch();
		
		//Results of search
		system.debug('==== Deal table size ======== >>>> '+filter.dealTableSize);
		system.debug('==== Search result for Deal object ======== >>>> '+filter.dealTable);
		system.debug('==== DRP table size ======== >>>> '+filter.drpTableSize);
		system.debug('==== Search result for old Deal Related Party object ======== >>>> '+filter.drpTable);
		system.debug('==== PBI table size ======== >>>> '+filter.pbiTableSize);
		system.debug('==== Search result for Potential Buyer/Investor object ======== >>>> '+filter.pbiTable);
		system.debug('==== Search result for new Deal Related Party object ======== >>>> '+filter.getDRPlist());
		
		//Run clearFilter method
		filter.clearFilter();
	}
	
	public static testMethod void testTwo() {
		//Reading multiselect records from schema with empty Find values
		Companies_DSummary_CSearch_filter filter = new Companies_DSummary_CSearch_filter();
		
		if (filter.productTypeSO.size() > 0) {
			filter.productTypeSelected.add(filter.productTypeSO[0].getValue());
			filter.productTypeSelected.add(filter.productTypeSO[1].getValue());
		}
		if (filter.expectedTimingSO.size() > 0) {
			filter.expectedTimingSelected.add(filter.expectedTimingSO[0].getValue());
			filter.expectedTimingSelected.add(filter.expectedTimingSO[1].getValue());
		}
		if (filter.dealRegionSO.size() > 0) {
			filter.dealRegionSelected.add(filter.dealRegionSO[0].getValue());
			filter.dealRegionSelected.add(filter.dealRegionSO[1].getValue());
		}
		if (filter.dealIndustrySO.size() > 0) {
			filter.dealIndustrySelected.add(filter.dealIndustrySO[0].getValue());
			filter.dealIndustrySelected.add(filter.dealIndustrySO[1].getValue());
		}
		if (filter.dealSubSectorSO.size() > 0) {
			filter.dealSubSectorSelected.add(filter.dealSubSectorSO[0].getValue());
			filter.dealSubSectorSelected.add(filter.dealSubSectorSO[1].getValue());
		}
		if (filter.dealStatusSO.size() > 0) {
			filter.dealStatusSelected.add(filter.dealStatusSO[0].getValue());
			filter.dealStatusSelected.add(filter.dealStatusSO[1].getValue());
		}
		
		filter.startSearch();
		
	}
}