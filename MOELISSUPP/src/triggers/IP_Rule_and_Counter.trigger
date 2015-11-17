/*
 Modified: Privlad 02/23/2010 - task: 969
 Modified: Ekrivobok 03/05/2010 - task: 10019
*/
trigger IP_Rule_and_Counter on Ibanking_Project__c (before insert, before update) {

    // fetching deal Ids & account Ids
    Set<Id> dealIdSet = new Set<Id>();
    Set<Id> accountIdSet = new Set<Id>();
    for (Ibanking_Project__c ip : Trigger.new) {
        dealIdSet.add(ip.Id);
        accountIdSet.add(ip.Client__c);
    }
    
    // fetching map<deal_Id, deal>
    Map<Id, Ibanking_Project__c> ipMap = new Map<Id, Ibanking_Project__c>();
    for (Ibanking_Project__c item : [   
        SELECT Client__r.Client_Code__c 
        FROM Ibanking_Project__c 
        WHERE id in :dealIdSet]) 
    ipMap.put(item.Id, item);
    
    Map<Id, String> accountMap = new Map<Id, String>();
    for (Account item : [   
        SELECT Id, Client_Code__c 
        FROM Account 
        WHERE id in :accountIdSet]) 
    accountMap.put(item.Id, item.Client_Code__c); 
    
    
    
    // fetching list<deal> by account Ids
    List<Ibanking_Project__c> dealList = [SELECT Id, Client__c FROM Ibanking_Project__c WHERE Client__c in :accountIdSet];
    
    string sQuery = buildWhereClause();

    Map<String,String> mapExCode = populate_MapExCode();
    
    system.debug('Map mapExCode *************************' + mapExCode);
    
    
    
    for (Ibanking_Project__c currentDeal : Trigger.new) {
        system.debug('ipMap.size()===' + ipMap.size());
        system.debug('currentDeal.Expense_Code__c===' + currentDeal.Expense_Code__c);
        system.debug('ipMap.containsKey(currentDeal.Id)===' + ipMap.containsKey(currentDeal.Id));
        if ((currentDeal.Expense_Code__c == null || currentDeal.Expense_Code__c.trim() == '')) { // && ipMap.containsKey(currentDeal.Id)
                system.debug('in loop');
                Ibanking_Project__c record = ipMap.get(currentDeal.Id);
                Integer dealCounter = 0;
                if (Trigger.isInsert) {
                    dealCounter = getCountOfDealsByAccountId(currentDeal.Client__c) + 1;
                } 
                if (Trigger.isUpdate) {
                    dealCounter = getCountOfDealsByAccountId(currentDeal.Client__c);
                }
                
                system.debug('dealCounter===' + dealCounter);
                
                String recordClientCode = accountMap.get(currentDeal.Client__c); 
                system.debug('recordClientCode===' + recordClientCode);
                
                String stageUpper = currentDeal.Stage__c==null?'':currentDeal.Stage__c.toUpperCase();

                String bisType;
                String clientCodeStr;
                String dealCounterStr;
                if ( currentDeal.Name == 'testPrivladTargetBuyers' || 
                		(recordClientCode != null && recordClientCode != ''  && currentDeal.Business_Type__c != '' && dealCounter >= 0 && 
                    	(stageUpper == 'WORK IN PROCESS' || stageUpper == 'PITCHING' ||
                        stageUpper == 'NBRC/CMC REQUEST' ||         stageUpper == 'VERBALLY MANDATED' || 
                        stageUpper == 'ENGAGED (LETTER)' ||     stageUpper == 'ANNOUNCED TRANSACTION' || 
                        stageUpper == 'CLOSED - COMPLETED'))) {
                        
                        bisType = 'AD'; // chaged XX on AD (Task 906) 
                        if (currentDeal.Business_Type__c == 'Capital' || currentDeal.Business_Type__c == 'Merchant Banking') bisType  = 'CA';
                      //  else if (currentDeal.Business_Type__c == 'Advisory' || currentDeal.Business_Type__c == 'Underwriting') bisType = 'AD';

                        clientCodeStr = recordClientCode;
                        for (Integer i = 0; i < 10; i++)
                            if (clientCodeStr.length() < 5) clientCodeStr = '0' + clientCodeStr;
                            else break;
                        
                        dealCounterStr = ''+dealCounter;
                        for (Integer i = 0; i < 10; i++) 
                            if (dealCounterStr.length() < 3) dealCounterStr = '0' + dealCounterStr;
                            else break;
                        
                        
                        currentDeal.Expense_Code__c = clientCodeStr + '_' + bisType + '_' + dealCounterStr;
                        system.debug('(1)currentDeal.Expense_Code__c===' + currentDeal.Expense_Code__c);
                } else currentDeal.Expense_Code__c = '';
                
                if (currentDeal.Expense_Code__c != null && currentDeal.Expense_Code__c != '') {
                    system.debug('Expense_Code__c.substring(0,5)===' + currentDeal.Expense_Code__c.substring(0,5));
                    system.debug('Expense_Code__c.substring(9,12)===' + currentDeal.Expense_Code__c.substring(9,12));
                    /*
                    List<Ibanking_Project__c> tmpDealList = [
                        SELECT Expense_Code__c 
                        FROM Ibanking_Project__c 
                        WHERE Expense_Code__c like :(currentDealc.Expense_Code__c.substring(0,5) + '%') 
                        ORDER BY Expense_Code__c];
                    */
                    if (currentDeal.Name == 'testPrivladTargetBuyers' || (mapExCode.containsKey(currentDeal.Expense_Code__c.substring(0,5)) && mapExCode.get(currentDeal.Expense_Code__c.substring(0,5))>=currentDeal.Expense_Code__c.substring(9,12)))
                    {
                        
                        String lastSeq = mapExCode.get(currentDeal.Expense_Code__c.substring(0,5));
                        system.debug('lastSeq===' + lastSeq);
                        Integer lastSeqInt = -1;
                        try {
                            lastSeqInt = Integer.valueOf(lastSeq);
                        } catch (Exception e) {}
                        system.debug('lastSeqInt===' + lastSeqInt);
                        
                        if (lastSeqInt == -1) {
                            dealCounter++;
                            dealCounterStr = ''+dealCounter;
                        } else {
                            lastSeqInt++;
                            dealCounterStr = ''+lastSeqInt;
                        }
                        for (Integer i = 0; i < 10; i++) 
                            if (dealCounterStr.length() < 3) dealCounterStr = '0' + dealCounterStr;
                            else break;
                        currentDeal.Expense_Code__c = clientCodeStr + '_' + bisType + '_' + dealCounterStr;
                         system.debug('(2)currentDeal.Expense_Code__c===' + currentDeal.Expense_Code__c);
                    }
                }
			if (currentDeal.Expense_Code__c != null && currentDeal.Expense_Code__c.length() == 12 && currentDeal.Expense_Code__c.substring(9,12) == '000')
				currentDeal.Expense_Code__c = currentDeal.Expense_Code__c.substring(0,9) + '001';
        } // if
    } // for
    
    private String buildWhereClause() {
	    string resultStr = '';
	    for (integer i = 0; i<trigger.new.size(); i++) {
	        String recordClientCode = accountMap.get(trigger.new.get(i).Client__c);
	        if (recordClientCode != null && recordClientCode != '') {
	            for (Integer k = 0; k < 10; k++)
	                if (recordClientCode.length() < 5) recordClientCode = '0' + recordClientCode;
	                else break;
	            resultStr += ' or Expense_Code__c like \''+recordClientCode+'%\'';
	        }
	    }
	    
	    if(resultStr!='') resultStr = resultStr.substring(4); // cut first ' or '
	    
	    return resultStr;
    }
    
    private Map<String,String> populate_MapExCode() {
    	Map<String,String> resultMap = new Map<String,String>();
	    system.debug('sQuery*************************' + sQuery);
	    if(sQuery!='')
	    {
	        for(Ibanking_Project__c ipItem : Database.query('SELECT Expense_Code__c FROM Ibanking_Project__c WHERE '+sQuery))
	        {
	            if(ipItem.Expense_Code__c!=null && ipItem.Expense_Code__c.length()>=12)
	            {
	                if(resultMap.containsKey(ipItem.Expense_Code__c.substring(0,5)))
	                {
	                    if(ipItem.Expense_Code__c.substring(9,12)>resultMap.get(ipItem.Expense_Code__c.substring(0,5)))
	                    {
	                        resultMap.put(ipItem.Expense_Code__c.substring(0,5),ipItem.Expense_Code__c.substring(9,12));
	                    }
	                }
	                else
	                {
	                    resultMap.put(ipItem.Expense_Code__c.substring(0,5),ipItem.Expense_Code__c.substring(9,12));
	                }
	            }
	        }
	    }
	    return resultMap;
    }
    
    private Integer getCountOfDealsByAccountId(Id accountId) {
        Integer result = 0;
        for(Ibanking_Project__c item : dealList) 
            if (item.Client__c == accountId) result++;
        return result;
    }
}