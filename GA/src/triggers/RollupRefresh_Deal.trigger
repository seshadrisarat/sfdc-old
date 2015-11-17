trigger RollupRefresh_Deal on Deal__c (after insert, after update, after delete, after undelete) {
    List<Deal__c> deals = new List<Deal__c>();
    if (Trigger.isDelete) {
        deals = Trigger.old;
    } else {
        deals = Trigger.new;
    }

    Map<Id, Account> accounts = new Map<Id, Account>();
    Map<Id, Employee__c> employees = new Map<Id, Employee__c>();
    List<Account> newAccounts = new List<Account>();
    List<Account> oldAccounts = new List<Account>();
    for (Deal__c d : deals) {
        Account newAccount;
        Account oldAccount;

        if (Trigger.isInsert) {
            newAccount = Utilities.rollupAccountStatistics(d);
        } else if (Trigger.isDelete) {
            oldAccount = Utilities.rollupAccountStatistics(d);
        } else if (Trigger.isUndelete) {
            newAccount = Utilities.rollupAccountStatistics(d);
        } else if (Trigger.isUpdate) {
            Deal__c oldDeal = Trigger.oldMap.get(d.Id);
            if (d.Deal_Size_MM__c != oldDeal.Deal_Size_MM__c || d.Source_Company__c != oldDeal.Source_Company__c || d.Competitive_Dynamic__c != oldDeal.Competitive_Dynamic__c) {
                newAccount = Utilities.rollupAccountStatistics(d);
                oldAccount = Utilities.rollupAccountStatistics(oldDeal);
                if (d.CreatedDate.date() > Date.today().addMonths(-12) && d.CreatedDate.date() <= Date.today()) {
                    if (newAccount != null) {
                        newAccount.Total_Intros_Referred_LTM__c = newAccount.Total_Intros_Referred__c;
                        newAccount.Total_Intros_Referred_Value_LTM__c = newAccount.Total_Intros_Referred_Value_MM__c;
                        newAccount.Total_Exclusives_Referred_LTM__c = newAccount.Total_Exclusives_Referred__c;
                        newAccount.Total_Exclusives_Referred_Value_LTM__c = newAccount.Total_Exclusives_Referred_Value_MM__c;
                    }
                    if (oldAccount != null) {
                        oldAccount.Total_Intros_Referred_LTM__c = oldAccount.Total_Intros_Referred__c;
                        oldAccount.Total_Intros_Referred_Value_LTM__c = oldAccount.Total_Intros_Referred_Value_MM__c;
                        oldAccount.Total_Exclusives_Referred_LTM__c = oldAccount.Total_Exclusives_Referred__c;
                        oldAccount.Total_Exclusives_Referred_Value_LTM__c = oldAccount.Total_Exclusives_Referred_Value_MM__c;
                    }
                }
            }
        }
        
        if (newAccount != null) {
            newAccounts.add(newAccount);
            accounts.put(newAccount.Id, null);
        }
        if (oldAccount != null) {
            oldAccounts.add(oldAccount);
            accounts.put(oldAccount.Id, null);
        }
    }

    if (!accounts.isEmpty()) {
        accounts = new Map<Id, Account>([SELECT Id, Total_Intros_Referred__c, Total_Intros_Referred_Value_MM__c, Total_Exclusives_Referred__c, Total_Exclusives_Referred_Value_MM__c, Total_Intros_Referred_LTM__c, Total_Intros_Referred_Value_LTM__c, Total_Exclusives_Referred_LTM__c, Total_Exclusives_Referred_Value_LTM__c FROM Account WHERE Id IN :accounts.keySet() AND IsDeleted=FALSE]);
        for (Account a : newAccounts) {
            accounts.put(a.Id, Utilities.combineAccountStatistics(accounts.get(a.Id), a, 1));
        }
        for (Account a : oldAccounts) {
            accounts.put(a.Id, Utilities.combineAccountStatistics(accounts.get(a.Id), a, -1));
        }
        update accounts.values();
    }


    // Update affected themes
    Map<Id, Theme__c> themes = new Map<Id, Theme__c>();
    for (Deal_Theme__c dt : [SELECT Theme__c FROM Deal_Theme__c WHERE Deal__c IN :deals]) {
        themes.put(dt.Theme__c, new Theme__c(
            Id = dt.Theme__c,
            Deals_Closed__c = 0,
            Companies__c = 0,
            Companies_Taken_to_IC__c = 0
        ));
    }
    
    Set<String> themeCompanySet = new Set<String>();
    for (Deal_Theme__c dt : [SELECT Theme__c, Deal__r.Status__c, Deal__r.Related_Company__c, Deal__r.Taken_to_IC__c FROM Deal_Theme__c WHERE Theme__c IN :themes.keySet() AND IsDeleted=FALSE]) {
        Theme__c t = themes.get(dt.Theme__c);

        if (dt.Deal__r.Status__c == 'Closed') {
            t.Deals_Closed__c++;
        }
        if (dt.Deal__r.Related_Company__c != null) {
    		if (!themeCompanySet.contains('' + t.Id + dt.Deal__r.Related_Company__c + '_companies')) {
                t.Companies__c++;
	            themeCompanySet.add('' + t.Id + dt.Deal__r.Related_Company__c + '_companies');
    		}
    		if (dt.Deal__r.Taken_to_IC__c) {
        		if (!themeCompanySet.contains('' + t.Id + dt.Deal__r.Related_Company__c + '_ic')) {
	                t.Companies_Taken_to_IC__c++;
    	            themeCompanySet.add('' + t.Id + dt.Deal__r.Related_Company__c + '_ic');
        		}        			
    		}
        }
    }
    
    if (!themes.isEmpty()) {
        Database.update(themes.values(), false);
    }


    if (!employees.isEmpty()) {
        update employees.values();
    }
}