public with sharing class LookupPopupController {
	public String query {get;set;}
	public List<Account> accounts {get;set;}

	public PageReference runQuery()
	{
		List<List<Account>> searchResults=[FIND :query IN ALL FIELDS RETURNING Account (id, name, billingstreet, billingcity, billingpostalcode)];
		accounts=searchResults[0];
		return null;
	}
}