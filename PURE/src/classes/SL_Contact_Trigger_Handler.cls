public without sharing class SL_Contact_Trigger_Handler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
     
    public SL_Contact_Trigger_Handler(Boolean isExecuting, Integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
         
    public void OnAfterUpdate(map<ID,Contact> oldContactMap, map<ID,Contact> newContactMap){
		updateAccountWithPrimaryContactInfo(newContactMap);
	}

	public void onAfterInsert(map<ID,Contact> newContactMap){
		updateAccountWithPrimaryContactInfo(newContactMap);
	}

	public void onAfterUndelete(map<ID, Contact> newContactMap){
		updateAccountWithPrimaryContactInfo(newContactMap);
	}

	private void updateAccountWithPrimaryContactInfo(map<ID,Contact> newContactMap){
		
		if(newContactMap == null){
			System.debug('~~~ newContactMap was empty');
			return;
		}

		List<Contact> contacts = newContactMap.values();
		List<Id> accountIDs = new List<Id>();

		for(Contact c : contacts){
			if(c.Primary__c == true){
				accountIDs.add(c.AccountId);
			}
		}

		Map<ID, Account> accountMap = new Map<ID, Account>([SELECT Id, Primary_Email__c, Phone
										  					FROM Account
										  					WHERE Id in :accountIDs]);

		if(accountMap.size() == 0)
			return;
			
		Set<Account> accountsToUpdate = new Set<Account>();
		for(Contact c : contacts){
			if(c.AccountId != null){
				Account acct = accountMap.get(c.AccountId);
				if(acct != null){
					if(acct.Primary_Email__c != c.Email){
						acct.Primary_Email__c = c.Email;

						if(c.HomePhone != null && acct.Phone != c.HomePhone){
							acct.Phone = c.HomePhone;
						} else if(c.MobilePhone != null && acct.Phone != c.HomePhone){
							acct.Phone = c.MobilePhone;
						} else if(c.Phone != null && acct.Phone != c.Phone){
							acct.Phone = c.Phone;
						}
						
						accountsToUpdate.add(acct);
					}
				}
			}
		}

		System.debug('~~~~ Accounts to update: ' + accountsToUpdate);
		if(accountsToUpdate.size() > 0)
			update new List<Account>(accountsToUpdate);
	}
}