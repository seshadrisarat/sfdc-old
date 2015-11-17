@isTest
private class Account_Custom_Page_test {
	private static testMethod void test1() {
		//Collecting & creating testing data
		Account company = new Account(Name = 'Test Company');
		insert company;
		Account_Custom_Page tested = new Account_Custom_Page();
		System.debug('======== Name of company ======== >>>> '+tested.curAccount.Name);
		
		//Create a Deal objects
		List<Ibanking_Project__c> deals = new List<Ibanking_Project__c>();
		deals.add(new Ibanking_Project__c(Client__c=company.Id,Name='Test Deal 1'));
		deals.add(new Ibanking_Project__c(Client__c=company.Id,Name='Test Deal 2'));
		deals.add(new Ibanking_Project__c(Client__c=company.Id,Name='Test Deal 3'));
		system.debug('======== Deals ======== >>>> '+deals);
		insert deals;
		
		//Create a Deal Relate Party objects
		List<Deal_Related_Parties__c> DRPs = new List<Deal_Related_Parties__c>();
		DRPs.add(new Deal_Related_Parties__c(Deal__c=deals[0].Id,Company__c=company.Id));
		DRPs.add(new Deal_Related_Parties__c(Deal__c=deals[1].Id,Company__c=company.Id));
		DRPs.add(new Deal_Related_Parties__c(Deal__c=deals[2].Id,Company__c=company.Id));
		system.debug('======== DRPs ======== >>>> '+DRPs);
		insert DRPs;
		
		//Create a Potential Buyer/Investor objects
		List<Potential_Buyer_Investor__c> PBIs = new List<Potential_Buyer_Investor__c>();
		PBIs.add(new Potential_Buyer_Investor__c(Project__c=deals[0].Id,TargetBuyer__c=company.Id));
		PBIs.add(new Potential_Buyer_Investor__c(Project__c=deals[1].Id,TargetBuyer__c=company.Id));
		PBIs.add(new Potential_Buyer_Investor__c(Project__c=deals[2].Id,TargetBuyer__c=company.Id));
		system.debug('======== PBIs ======== >>>> '+PBIs);
		insert PBIs;
		
		/* Call methods */
		//Custom tables
		List<Deal_Related_Parties__c> DRP_Table = tested.DRP_Table;
		system.debug('======== DRP_Table ======== >>>> '+DRP_Table);
		List<Potential_Buyer_Investor__c> PBI_Table = tested.PBI_Table;
		system.debug('======== PBI_Table ======== >>>> '+PBI_Table);
		List<Call_Log_Contact__c> callLogs = tested.getCallLogs();
		system.debug('======== Call Logs ======== >>>> '+callLogs);
		
		//Call methods, calcs numbers of records in lists
		System.debug('======== parentFinancialSponsors ========= >>>> '+tested.parentFinancialSponsors);
		System.debug('======== financialSponsors ========= >>>> '+tested.financialSponsors);
		System.debug('======== relContacts ========= >>>> '+tested.relContacts);
		System.debug('======== relationsheeps ========= >>>> '+tested.relationsheeps);
		System.debug('======== deals ========= >>>> '+tested.deals);
		System.debug('======== drp ========= >>>> '+tested.drp);
		System.debug('======== pbi ========= >>>> '+tested.pbi);
		System.debug('======== callLogsNum ========= >>>> '+tested.callLogsNum);
		System.debug('======== activityHist ========= >>>> '+tested.activityHist);
		System.debug('======== accountHistory ========= >>>> '+tested.accountHistory);
		
		//Call delete methods
		ApexPages.currentPage().getParameters().put('delId',DRPs[0].Id);
		tested.delDRP();
		ApexPages.currentPage().getParameters().put('delId',PBIs[0].Id);
		tested.delPBI();
	}
}