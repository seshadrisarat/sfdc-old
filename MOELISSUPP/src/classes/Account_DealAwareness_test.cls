@isTest
private class Account_DealAwareness_test {
	
	public static testMethod void test1() {
		// Insert Account data & data of related objects
		Account acc = new Account(Name = 'Test Company');
		insert acc;
		
		// Insert Deals
		List<Ibanking_Project__c> deals = new List<Ibanking_Project__c>();
		deals.add(new Ibanking_Project__c(Name = 'Test Deal 1',Client__c = acc.Id));
		deals.add(new Ibanking_Project__c(Name = 'Test Deal 2',Client__c = acc.Id));
		deals.add(new Ibanking_Project__c(Name = 'Test Deal 3',Client__c = acc.Id));
		insert deals;
		
		// Insert Deal Related Parties
		List<Deal_Related_Parties__c> drpList = new List<Deal_Related_Parties__c>();
		drpList.add(new Deal_Related_Parties__c(Company__c = acc.Id,Deal__c = deals[0].Id));
		drpList.add(new Deal_Related_Parties__c(Company__c = acc.Id,Deal__c = deals[1].Id));
		drpList.add(new Deal_Related_Parties__c(Company__c = acc.Id,Deal__c = deals[2].Id));
		drpList.add(new Deal_Related_Parties__c(Company__c = acc.Id,Deal__c = deals[0].Id));
		insert drpList;
		
		// Insert Potential Buyer Investors
		List<Potential_Buyer_Investor__c> pbiList = new List<Potential_Buyer_Investor__c>();
		pbiList.add(new Potential_Buyer_Investor__c(Name = 'Test PBI 1',TargetBuyer__c = acc.Id,Project__c = deals[0].Id));
		pbiList.add(new Potential_Buyer_Investor__c(Name = 'Test PBI 2',TargetBuyer__c = acc.Id,Project__c = deals[1].Id));
		pbiList.add(new Potential_Buyer_Investor__c(Name = 'Test PBI 3',TargetBuyer__c = acc.Id,Project__c = deals[2].Id));
		pbiList.add(new Potential_Buyer_Investor__c(Name = 'Test PBI 4',TargetBuyer__c = acc.Id,Project__c = deals[0].Id));
		pbiList.add(new Potential_Buyer_Investor__c(Name = 'Test PBI 5',TargetBuyer__c = acc.Id,Project__c = deals[1].Id));
		insert pbiList;
		
		Account_DealAwareness_total controller = new Account_DealAwareness_total();
		controller.accObj = acc;
		system.debug('======== controller.companyId ========= >>>> '+controller.companyId);
		system.debug('======== controller.companyName ========= >>>> '+controller.companyName);
		system.debug('======== controller.repLink ========= >>>> '+controller.repLink);
		
		// Test results
		system.debug('======== controller.dealCount ========= >>>> '+controller.dealCount);
		system.debug('======== controller.dealRelatedPartyCount ========= >>>> '+controller.dealRelatedPartyCount);
		system.debug('======== controller.potentialBuyerInvestorCount ========= >>>> '+controller.potentialBuyerInvestorCount);
		
	}
	
}