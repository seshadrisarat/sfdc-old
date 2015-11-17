/**
* Test methods are in Test_Account.cls as part of Account_DealAwareness_total tests
**/
public without sharing class Account_DealAwareness_logic {
	
	public static Account getCurrAccount(Id id) {
		List<Account> tmp = [SELECT Id,Name FROM Account WHERE Id = :id Limit 1];
		Account res = new Account();
		if (tmp == null) {
			tmp = new List<Account>();
		}
		if (tmp.size() > 0) {
			res = tmp[0];
		}
		return res;
	}
	
	public static Integer getDealCount(Id id) {
		Integer res = [SELECT COUNT() FROM Ibanking_Project__c WHERE Client__c = :id];
		//List<Ibanking_Project__c> res = [SELECT id FROM Ibanking_Project__c WHERE Client__r.Id = :id];
		return res;
	}
	
	public static Integer getDealRelatedPartyCount(Id id) {
		Integer res = [SELECT COUNT() FROM Deal_Related_Parties__c WHERE Company__c = :id];
		//List<Deal_Related_Parties__c> res = [SELECT id FROM Deal_Related_Parties__c WHERE Company__r.Id = :id];
		return res;
	}
	
	public static Integer getPotentialBuyerInvestorCount(Id id) {
		Integer res = [SELECT COUNT() FROM Potential_Buyer_Investor__c WHERE TargetBuyer__c = :id];
		//List<Potential_Buyer_Investor__c> res = [SELECT id FROM Potential_Buyer_Investor__c WHERE TargetBuyer__r.Id = :id];
		return res;
	}
	
}