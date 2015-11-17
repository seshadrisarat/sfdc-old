trigger IP_Deal_Counter on Ibanking_Project__c (before insert, before update) {
/*
    Map<ID, Account> lAccForUpd = new Map<ID,Account>();
    List<ID> clienIDs = new List<ID>();
    
    for(integer i=0; i<trigger.new.size(); i++) {   
        // fetching the new & old deals
        Ibanking_Project__c newDeal = (Ibanking_Project__c) Trigger.new[i];
        if(newDeal.Client__c!=null && newDeal.Stage__c=='Expense Code Request' && ''+newDeal.Client__c!='' && (newDeal.Expense_Code__c==null ||  (''+newDeal.Expense_Code__c).trim()=='')) {
           clienIDs.add(newDeal.Client__c);
        }
    }
    
    System.Debug('clienIDs.size===' + clienIDs.size());
    if(clienIDs.size() > 0) {
        List<Account> accountList = [select ID, Deal_Counter__c from Account where ID in :clienIDs];
        
        for(Account AccObj : accountList) {     
            if(AccObj.Deal_Counter__c!=null) AccObj.Deal_Counter__c = AccObj.Deal_Counter__c + 1;
            else AccObj.Deal_Counter__c = 1;
            lAccForUpd.put(AccObj.ID,AccObj);
        }
        
        if(lAccForUpd.size()>0) {
            List<Account> AccObjs = new List<Account>();
            AccObjs = lAccForUpd.values();
            update AccObjs;
        }
    }       
    
    system.debug('End of IP_Deal_Counter...');
    */
}