public with sharing class TC_RequestUCCExt {
	
	public Account acc {get; set;}

	public TC_RequestUCCExt(ApexPages.StandardController sc) {
		acc = (Account) sc.getRecord();
	}


	public PageReference requestUCC () {
		try {
			Csc.updateUccRecord(acc.Id);
			ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.INFO, 'UCC Request Complete.'));
		} catch (Csc.NoUCCResultsException nrx) {
			acc.UCCs_Last_Checked_On__c = System.today();
			update acc;

			ApexPages.addMessages (nrx);
			System.debug(nrx);
		} catch (Exception e) {
			ApexPages.addMessages (e);
			System.debug(e);
		}
		return null;
	}
}