/**
* Test methods are in Test_Account.cls
**/
public with sharing class Account_DealAwareness_total {
	
	public String repLink {
		get {
			String str = '';
			Report_link__c lnk = Report_link__c.getInstance();
			if (lnk != null) {
				str = lnk.url__c;
			}
			return str;
		}
	}
	
	public Account_DealAwareness_total(){} //For testing

	public Account_DealAwareness_total(ApexPages.StandardController controller) {
		this.accObj = (Account)controller.getRecord();
	}
	
	public Account accObj {
		get {
			if (accObj == null) {
				accObj = new Account();
			}
			return accObj;
		}
		set;
	}
	
	private Id companyId_p = null;
	public Id companyId {
		get {
			if (companyId_p == null) {
				companyId_p = accObj.Id;
			}
			return companyId_p;
		}
	}
	
	private String companyName_p = null;
	public String companyName{
		get {
			if (companyName_p == null) {
				Account tmp = Account_DealAwareness_logic.getCurrAccount(companyId);
				companyName_p = tmp.Name;
			}
			return companyName_p;
		}
	}
	
	public Integer dealCount{
		get {
			Integer res = Account_DealAwareness_logic.getDealCount(companyId);
			return res;
		}
	}

	public Integer dealRelatedPartyCount{
		get {
			Integer res = Account_DealAwareness_logic.getDealRelatedPartyCount(companyId);
			return res;
		}
	}

	public Integer potentialBuyerInvestorCount{
		get {
			Integer res = Account_DealAwareness_logic.getPotentialBuyerInvestorCount(companyId);
			return res;
		}
	}
}