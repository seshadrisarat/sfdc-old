/*
 * Prototype class to ultimately run by Anon Exec
 */
public with sharing class NU_AnonRetrofitQP {

	public void execute() {
		Set<String> emailTypes = new Set <String> {NU.EMAIL_IN};
		Set<String> results = new Set <String> {NU.SPOKE_TO_DM, NU.SPOKE_TO_INFLUENCER};
		Set<String> status = new Set <String> {NU.QUALIFIED_PROSPECT, NU.CONTACT};
		DateTime LAUNCH = Date.valueOf('2011-05-22T23:59:59Z');
		
		Map<ID,Account> accounts = new Map<ID, Account>([SELECT LastModifiedDate, NU_Contacted_Within_90_Days__c, QualifiedProspectDate__c 
									FROM Account 
									WHERE (LastModifiedDate > :LAUNCH) 
									AND (Prospect_Status__c IN :status)
									AND (NU_Contacted_Within_90_Days__c = FALSE) ]);
																		
		List <Task> tasks = [SELECT AccountId, LastModifiedDate, Type, Result__c FROM Task WHERE (AccountId IN :accounts.keyset())];

		List<Account> updates = new List<Account>();

		for (Task t : tasks) 
		{ 
			
			Boolean isMatch = ((NU.OUTBOUND_CALL == t.Type) && (results.contains(t.Result__c)));		
			isMatch = isMatch || (NU.INBOUND_CALL == t.Type);					 
			isMatch = isMatch || (emailTypes.contains(t.Type)) ;				

			if (isMatch) {
				Account a = accounts.get(t.AccountId);
				Date aDate = a.QualifiedProspectDate__c;
				Date tDate = t.LastModifiedDate.date(); 
				if ((aDate == NULL) || (tDate>aDate)) {
					a.QualifiedProspectDate__c = tDate;
					a.NU_Contacted_Within_90_Days__c = TRUE;
					updates.add(a);
				} else if (a.NU_Contacted_Within_90_Days__c == FALSE)  {
					a.NU_Contacted_Within_90_Days__c = TRUE;
					updates.add(a);
				}
			}
		}
		
		update updates;				
	}			
	
	/*
	public void execute() {
		Set<String> emailTypes = new Set <String> {NU.EMAIL_IN};
		Set<String> results = new Set <String> {NU.SPOKE_TO_DM, NU.SPOKE_TO_INFLUENCER};
		Set<String> status = new Set <String> {NU.QUALIFIED_PROSPECT, NU.CONTACT};
		
		DateTime LAUNCH = Date.valueOf('2011-05-22T23:59:59Z');

		List<Account> accounts = [	SELECT LastModifiedDate, NU_Contacted_Within_90_Days__c, QualifiedProspectDate__c 
									FROM Account 
									WHERE (LastModifiedDate > :LAUNCH) 
									AND (Prospect_Status__c IN :status)
									AND (NU_Contacted_Within_90_Days__c = FALSE) ];

		for (Account a : accounts) 
		{
			a.QualifiedProspectDate__c = a.LastModifiedDate.date();
			List <Task> aTasks = [SELECT LastModifiedDate, Type, Result__c FROM Task WHERE (AccountId = :a.Id) ORDER BY LastModifiedDate LIMIT 100];

			for (Task t : aTasks) 
			{
				Boolean isMatch = ((NU.OUTBOUND_CALL == t.Type) && (results.contains(t.Result__c)));		
				isMatch = isMatch || (NU.INBOUND_CALL == t.Type);					 
				isMatch = isMatch || (emailTypes.contains(t.Type)) ;				
				if (isMatch) // last one wins
				{
					if (NU.QUALIFIED_PROSPECT == a.Prospect_Status__c)
					{
						a.QualifiedProspectDate__c = t.LastModifiedDate.date();
						a.NU_Contacted_Within_90_Days__c = true; // checked
					} else {
						a.ContactLastContactDate__c = t.LastModifiedDate.date();			
						a.NU_Contacted_Within_90_Days__c = true; // checked
					}
				}
			}
		}
		
		update accounts;

	}
	*/
}