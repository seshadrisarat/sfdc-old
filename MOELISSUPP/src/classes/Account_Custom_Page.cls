/**
* Test methods are in Test_Account.cls
**/
public without sharing class Account_Custom_Page {
    
    private final Account curAccount_p;
    public Account curAccount {
    	get {
    		Account res = new Account();
    		List<Account> tmp = [SELECT Id,Name FROM Account WHERE Id = :curAccount_p.Id];
    		if (tmp.size() > 0) {
    			res = tmp[0];
    		}
    		return res;
    	}
    }

    public Account_Custom_Page(ApexPages.StandardController stdController) {
        curAccount_p = (Account)stdController.getRecord();
    }

	public Account_Custom_Page() {
		String accountId = System.currentPageReference().getParameters().get('id');
		List<Account> tmp = [SELECT Id FROM Account Limit 1];
		if (tmp.size() > 0) {
			curAccount_p = tmp[0];
		} else {
			curAccount_p = new Account();
		}
	}
	
	public void delRecord() {
		Id delId = ApexPages.currentPage().getParameters().get('delId');
		Id accId = ApexPages.currentPage().getParameters().get('accId');
		List<Call_Log_Contact__c> toDel = [SELECT Id
											FROM Call_Log_Contact__c
											WHERE Call_Log__r.Id = :delId
											AND Contact__r.AccountId = :accId];
		if (toDel.size() > 0) {
			delete toDel;
		}
	}
	
	public void delDRP() {
		Id delid = ApexPages.currentPage().getParameters().get('delId');
		List<Deal_Related_Parties__c> delList;
		delList = [SELECT Id FROM Deal_Related_Parties__c WHERE Id = :delId];
		if (delList.size() > 0) {
			delete delList;
		}
	}
	
	public List<Deal_Related_Parties__c> DRP_Table {
		get {
			List<Deal_Related_Parties__c> res;
			String queryStr = '';
			String fields = 'Id,Name,Deal__r.Name,Deal__r.Id,Role__c,Party__c,Project_Code__c,Company__r.Id,Company__r.Name,Industry__c,Subsector__c,Deal_Status__c,Deal__r.Client__r.Name,Deal__r.Client__r.Id';
			queryStr = 'SELECT '+fields+' FROM Deal_Related_Parties__c WHERE Company__r.Id = \''+curAccount.Id+'\' ORDER BY Deal__r.Name';
			res = database.query(queryStr);
			return res;
		}
	}
	
	public void delPBI() {
		Id delid = ApexPages.currentPage().getParameters().get('delId');
		List<Deal_Related_Parties__c> delList;
		delList = [SELECT Id FROM Deal_Related_Parties__c WHERE Id = :delId];
		if (delList.size() > 0) {
			delete delList;
		}
	}
	
	public List<Potential_Buyer_Investor__c> PBI_Table {
		get {
			List<Potential_Buyer_Investor__c> res;
			String queryStr = '';
			String fields = 'Id,Name,Project__r.Client__r.Name,Project__r.Client__r.Id,Client__c,Industry__c,Sub_Sector__c,Product_Type__c,Deal_Status__c';
			queryStr = 'SELECT '+fields+' FROM Potential_Buyer_Investor__c WHERE TargetBuyer__r.Id = \''+curAccount.Id+'\' ORDER BY Project__r.Name';
			res = database.query(queryStr);
			return res;
		}
	}
	
	public List<Call_Log_Contact__c> getCallLogs() {
		List<Call_Log_Contact__c> result = new List<Call_Log_Contact__c>();
		List<Call_Log_Contact__c> callLogContactList = [
			SELECT Id, Call_Log__c, Call_Log__r.Organizer__r.Name, Call_Log__r.Subject__c, Call_Log__r.Date__c, Call_Log__r.Type__c, Call_Log__r.Name, Contact__c, Contact__r.Name, Contact__r.AccountId, Contact__r.Title, Contact__r.Phone, Contact__r.Email
			FROM Call_Log_Contact__c 
			WHERE Contact__c IN (SELECT Id FROM Contact WHERE AccountId = :curAccount.Id) AND Call_Log__c IN (SELECT ParentId FROM Call_Log__Share  WHERE UserOrGroupId =:UserInfo.getUserId())
			ORDER BY Call_Log__r.Organizer__r.Name, Contact__r.Name];

		Map<Id, Set<Id>> Map_contactId_callLogIdSet = new Map<Id, Set<Id>>();
		for(Call_Log_Contact__c item : callLogContactList) {
			if(Map_contactId_callLogIdSet.containsKey(item.Contact__r.AccountId)) {
				if (!Map_contactId_callLogIdSet.get(item.Contact__r.AccountId).contains(item.Call_Log__c)) {
					Map_contactId_callLogIdSet.get(item.Contact__r.AccountId).add(item.Call_Log__c);
					result.add(item);
				}
			} else {
				Map_contactId_callLogIdSet.put(item.Contact__r.AccountId, new Set<Id>());
				Map_contactId_callLogIdSet.get(item.Contact__r.AccountId).add(item.Call_Log__c);
				result.add(item);
			}
			system.debug('curItem===' + item);
			system.debug('Map_contactId_callLogIdSet===' + Map_contactId_callLogIdSet);
			system.debug('result===' + result);
		}   
		system.debug('result===' + result);
		system.debug('result.size()===' + result.size());
		return result;
	}
	
	public Integer parentFinancialSponsors {
		get {
			List<Financial_Sponsors__c> tmp;
			tmp = [SELECT Id FROM Financial_Sponsors__c WHERE Company_Name__c = :curAccount.Id];
			return tmp.size();
		}
	}

	public Integer financialSponsors {
		get {
			List<Deal_Related_Parties__c> tmp;
			tmp = [SELECT Id FROM Deal_Related_Parties__c WHERE Company__c = :curAccount.Id AND Role__c = 'Financial Sponsor'];
			return tmp.size();
		}
	}

	public Integer relContacts {
		get {
			List<Contact> tmp;
			tmp = [SELECT Id FROM Contact WHERE Account.Id = :curAccount.Id];
			return tmp.size();
		}
	}
	
	public Integer relationsheeps {
		get {
			List<Employee_Relationships__c> tmp;
			tmp = [SELECT Id FROM Employee_Relationships__c WHERE Company_relationship__c = :curAccount.Id];
			return tmp.size();
		}
	}
	
	public Integer deals {
		get {
			List<Ibanking_Project__c> tmp;
			tmp = [SELECT Id FROM Ibanking_Project__c WHERE Client__c = :curAccount.Id];
			return tmp.size();
		}
	}
	
	public Integer drp {
		get {
			List<Deal_Related_Parties__c> tmp;
			tmp = [SELECT Id FROM Deal_Related_Parties__c WHERE Company__c = :curAccount.Id];
			return tmp.size();
		}
	}
	
	public Integer pbi {
		get {
			List<Potential_Buyer_Investor__c> tmp;
			tmp = [SELECT Id FROM Potential_Buyer_Investor__c WHERE TargetBuyer__c = :curAccount.Id];
			return tmp.size();
		}
	}
	
	public Integer callLogsNum {
		get {
			List<Call_Log_Contact__c> tmp = [
			SELECT Id FROM Call_Log_Contact__c 
			WHERE Contact__c IN (SELECT Id FROM Contact WHERE AccountId = :curAccount.Id) AND Call_Log__c IN (SELECT ParentId FROM Call_Log__Share  WHERE UserOrGroupId =:UserInfo.getUserId())];
			return tmp.size();
		}
	}

	public Integer activityHist {
		get {
			Integer count = 0;
			List<Account> tmp;
			tmp = [SELECT Id,(SELECT Id FROM ActivityHistories WHERE AccountId = :curAccount.Id) FROM Account WHERE Id = :curAccount.Id];
			for (Account record:tmp) {
				for (ActivityHistory item:record.ActivityHistories) {
					if (item != null) {
						count ++;
					}
				}
			}
			return count;
		}
	}

	public Integer accountHistory {
		get {
			List<AccountHistory> tmp;
			tmp = [SELECT Id FROM AccountHistory where AccountId = :curAccount.Id];
			return tmp.size();
		}
	}
	
}