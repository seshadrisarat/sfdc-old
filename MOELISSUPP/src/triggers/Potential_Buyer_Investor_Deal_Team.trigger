trigger Potential_Buyer_Investor_Deal_Team on Potential_Buyer_Investor_Deal_Team__c (before delete, after insert, before update)
{
	List<Potential_Buyer_Investor_Deal_Team__c> List_PBI_DT = new List<Potential_Buyer_Investor_Deal_Team__c>();
	List<Potential_Buyer_Investor_Deal_Team__c> Trigger_list;
	if(trigger.isInsert || trigger.isUpdate) Trigger_list = Trigger.new;
	if(trigger.isDelete) Trigger_list = Trigger.old;
	Boolean isFireTrigger = false;
	Id oneEmployee_Id;
	Id secondEmployee_Id;
	for (Potential_Buyer_Investor_Deal_Team__c item : Trigger_list) 
	{
		if(trigger.isInsert || trigger.isUpdate) oneEmployee_Id = Trigger.newMap.get(item.Id).Banker__c;
		if(trigger.isDelete)	oneEmployee_Id = null;
		if(trigger.isDelete || trigger.isUpdate) secondEmployee_Id = Trigger.oldMap.get(item.Id).Banker__c;
		if(trigger.isInsert)	secondEmployee_Id = null;
		system.debug('oneEmployee_Id '+oneEmployee_Id +' ---secondEmployee_Id  '+secondEmployee_Id);
		if (oneEmployee_Id != secondEmployee_Id) 
		{	
			isFireTrigger = true;	
			List_PBI_DT.add(item);
		}
	}
	if (isFireTrigger) 
	{
		List<Id> List_PBIId = new List<Id>();
		for(Potential_Buyer_Investor_Deal_Team__c item : List_PBI_DT)
		{
			List_PBIId.add(item.Target_Buyer__c);
		}
		system.debug('List_PBIId ------------------->  '+List_PBIId);
		
		if(List_PBIId.size() > 0)
		{
			List<Schedule_Data__c> List_toInsert = new List<Schedule_Data__c>();
			for(Id itemId : List_PBIId)
			{
				Schedule_Data__c newSD = new Schedule_Data__c();
				newSD.Object_Id__c = itemId;
				newSD.Type__c = 'PBI';
				List_toInsert.add(newSD);
			}
			if(List_toInsert.size() > 0) insert List_toInsert;
			/*
			Batch_PBIShareUPD batch = new Batch_PBIShareUPD(List_PBIId);
			Database.executeBatch(batch, 100);
			*/
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*
    List<Employee_Profile__c> bankerList;
    List<Potential_Buyer_Investor__c> buyerInvestorList;
    List<Id> bankerIdList = new List<Id>();
    List<Id> BuyerIDList = new List<Id>();
    List<Id> BuyerInvestorIDList = new List<Id>();
  
    if (trigger.isInsert || trigger.isUpdate) { 
        for (Potential_Buyer_Investor_Deal_Team__c pr : trigger.new) {
            bankerIdList.add(pr.Banker__c);
            BuyerInvestorIDList.add(pr.Target_Buyer__c);
        }
        buyerInvestorList = [SELECT Id,Project__c FROM Potential_Buyer_Investor__c
            				WHERE Id in :BuyerInvestorIDList];
        for (Potential_Buyer_Investor__c el: buyerInvestorList) {
           	BuyerIDList.add(el.Project__c);
        }
    } 
    if (trigger.isDelete || trigger.isUpdate) {
        for (Potential_Buyer_Investor_Deal_Team__c pr : trigger.old) {
            bankerIdList.add(pr.Banker__c);
            BuyerInvestorIDList.add(pr.Target_Buyer__c);
        }
        buyerInvestorList = [SELECT Id,Project__c FROM Potential_Buyer_Investor__c
            				WHERE Id in :BuyerInvestorIDList];
        for (Potential_Buyer_Investor__c el: buyerInvestorList) {
           	BuyerIDList.add(el.Project__c);
        }
    }
    
    //system.debug('======== BuyerIDList.size() ============>>>>>>>'+BuyerIDList.size());
    //system.debug('======== BuyerIDList ============>>>>>>>'+BuyerIDList);
    List<Ibanking_Project__c> test = [SELECT id FROM Ibanking_Project__c WHERE Id in :BuyerIDList];
    //system.debug('======== List<Ibanking_Project__c> ============>>>>>>>'+test);
    
    //system.debug('=== trigger.old ===' + trigger.old);
    //system.debug('=== trigger.new ===' + trigger.new);
    //system.debug('=== bankerIdList.size ===' + bankerIdList.size());
    bankerList = [SELECT Id, User_Id__c,User_ID__r.IsActive 
			        FROM Employee_Profile__c 
        			WHERE Id in :bankerIdList];
    
    //system.debug('======== bankerList List: ' + bankerList);
    //system.debug('======== trigger.old List: ' + trigger.old);

    if (trigger.isUpdate) {

        //List<Ibanking_Project__Share> ipSharesForUsers;
        List<Potential_Buyer_Investor__Share> ipSharesForUsers;
        List<Id> userIdList = new List<Id>(); 
        for(Employee_Profile__c item : bankerList)  userIdList.add(item.User_ID__c);

     List<Id> ids = new List<Id>();
        for (Potential_Buyer_Investor_Deal_Team__c elem : trigger.old) {
        	ids.add(elem.Target_Buyer__c);
        }
        List<Potential_Buyer_Investor__c> tmp = [SELECT Id,Project__c FROM Potential_Buyer_Investor__c
        			WHERE Id in :ids];
        
        string sQuery;
        if (trigger.old.size()>0) {
            sQuery = '(ParentId = \''+tmp[0].Project__c+'\' and UserOrGroupId = \''+getBankerByProjResourceId(trigger.old.get(0).Banker__c).User_Id__c+'\')';
            //sQuery = '(ParentId = \''+trigger.old.get(0).Target_Buyer__r.Project__c+'\' and UserOrGroupId = \''+getBankerByProjResourceId(trigger.old.get(0).Banker__c).User_Id__c+'\')';
        }
        
        for (integer i = 1; i<trigger.old.size(); i++) {
            sQuery += ' or (ParentId = \''+tmp[i].Project__c+'\' and UserOrGroupId = \''+getBankerByProjResourceId(trigger.old.get(i).Banker__c).User_Id__c+'\')';
            //sQuery += ' or (ParentId = \''+trigger.old.get(i).Target_Buyer__r.Project__c+'\' and UserOrGroupId = \''+getBankerByProjResourceId(trigger.old.get(i).Banker__c).User_Id__c+'\')';
        }

        system.debug('Query str: Select id from Ibanking_Project__Share where '+sQuery);
        ipSharesForUsers = Database.query('Select id, UserOrGroupId, ParentId, Parent.OwnerId from Ibanking_Project__Share where '+sQuery);
        system.debug('Query res: '+ipSharesForUsers);

        List<Potential_Buyer_Investor__Share> ipSharesForDelete = new List<Potential_Buyer_Investor__Share>();
        // ID = ParentId(Deal), ID - UserOrGroupId(UserID)
        Map<ID,Map<ID,Potential_Buyer_Investor__Share>> mapIPSObjs = new Map<ID,Map<ID,Potential_Buyer_Investor__Share>>();
        Map<ID,Potential_Buyer_Investor__Share> mapSubIPS;
        
        for(Potential_Buyer_Investor__Share ipsItem : ipSharesForUsers) {
            system.debug('does it contains:' + mapIPSObjs.containsKey(ipsItem.ParentId));            
            if(mapIPSObjs.containsKey(ipsItem.ParentId)) {
                mapIPSObjs.get(ipsItem.ParentId).put(ipsItem.UserOrGroupId,ipsItem);
            } else {
                mapSubIPS = new Map<ID,Potential_Buyer_Investor__Share>();
                mapSubIPS.put(ipsItem.UserOrGroupId,ipsItem);
                mapIPSObjs.put(ipsItem.ParentId, mapSubIPS);
            }
        }
        
        Employee_Profile__c tmpEPBankerObj = null;
        map<ID,Potential_Buyer_Investor__Share> ipSharesForDeleteMap = new map<ID,Potential_Buyer_Investor__Share>();
        for(Potential_Buyer_Investor_Deal_Team__c pr : trigger.old) {
            tmpEPBankerObj = getBankerByProjResourceId(pr.Banker__c);
        	Potential_Buyer_Investor__c tmp_Pbi = [SELECT id,Project__c FROM Potential_Buyer_Investor__c
        					WHERE id = :pr.Target_Buyer__c LIMIT 1];

            if (pr.Banker__c!=null 
                && tmpEPBankerObj != null 
                && tmpEPBankerObj.User_Id__c != null
                && mapIPSObjs.containsKey(tmp_Pbi.Project__c)
                && mapIPSObjs.get(tmp_Pbi.Project__c).containsKey(tmpEPBankerObj.User_Id__c)
                && mapIPSObjs.get(tmp_Pbi.Project__c).get(tmpEPBankerObj.User_Id__c).Parent.OwnerId!= tmpEPBankerObj.User_Id__c

               ) {
                ipSharesForDeleteMap.put(mapIPSObjs.get(tmp_Pbi.Project__c).get(tmpEPBankerObj.User_Id__c).ID, mapIPSObjs.get(tmp_Pbi.Project__c).get(tmpEPBankerObj.User_Id__c));
            }
        }

        //system.debug('Deleting ipSharesForDelete ' + ipSharesForDeleteMap.size());
        //system.debug('Deleting ipSharesForDelete is: ' + ipSharesForDeleteMap);
        
        if(ipSharesForDeleteMap.size()>0){ 
            ipSharesForDelete = ipSharesForDeleteMap.values();
            //system.debug('Deleting ipSharesForDelete ' + ipSharesForDelete.size());
            delete ipSharesForDelete;
        }
    
    }
    
    if(trigger.isDelete) {
        Map<ID,ID> mapDeals = new Map<ID,ID>();
        List<Id> userIdList = new List<Id>(); 
        for(Employee_Profile__c item : bankerList)  userIdList.add(item.User_ID__c);

        List<Potential_Buyer_Investor__Share> ipSharesForUsers = [
        		SELECT Id, ParentId, UserOrGroupId, Parent.OwnerId 
            	FROM Potential_Buyer_Investor__Share 
            	WHERE UserOrGroupId in :userIdList and ParentId in :BuyerIDList and RowCause = 'Manual'];
        
        List<Potential_Buyer_Investor__Share> ipSharesForDelete = new List<Potential_Buyer_Investor__Share>();
        //system.debug('=============== ipSharesForDelete ===================>> '+ipSharesForDelete);
        // ID = ParentId(Deal), ID - UserOrGroupId(UserID)
        Map<ID,Map<ID,Potential_Buyer_Investor__Share>> mapIPSObjs = new Map<ID,Map<ID,Potential_Buyer_Investor__Share>>();
        Map<ID,Potential_Buyer_Investor__Share> mapSubIPS;
        
        for(Potential_Buyer_Investor__Share ipsItem : ipSharesForUsers) {
            //system.debug('does it contains:' + mapIPSObjs.containsKey(ipsItem.ParentId));            
            if(mapIPSObjs.containsKey(ipsItem.ParentId)) {
                mapIPSObjs.get(ipsItem.ParentId).put(ipsItem.UserOrGroupId,ipsItem);
            } else {
                mapSubIPS = new Map<ID,Potential_Buyer_Investor__Share>();
                mapSubIPS.put(ipsItem.UserOrGroupId,ipsItem);
                mapIPSObjs.put(ipsItem.ParentId, mapSubIPS);
            }
        }
        
        map<ID,Potential_Buyer_Investor__Share> ipSharesForDeleteMap = new map<ID,Potential_Buyer_Investor__Share>();
        Employee_Profile__c tmpEPBankerObj = null;
        for(Potential_Buyer_Investor_Deal_Team__c pr : trigger.old) {
        	//system.debug('============= pr ==============>>>>>> '+pr);
        	tmpEPBankerObj = getBankerByProjResourceId(pr.Banker__c);
        	Potential_Buyer_Investor__c tmpPbi = [SELECT id,Project__c FROM Potential_Buyer_Investor__c
        					WHERE id = :pr.Target_Buyer__c LIMIT 1];
            if (pr.Banker__c!=null 
                && tmpEPBankerObj != null 
                && tmpEPBankerObj.User_Id__c != null
                && mapIPSObjs.containsKey(tmpPbi.Project__c)
                && mapIPSObjs.get(tmpPbi.Project__c).containsKey(tmpEPBankerObj.User_Id__c)
               ) {
                ipSharesForDeleteMap.put(mapIPSObjs.get(tmpPbi.Project__c).get(tmpEPBankerObj.User_Id__c).ID, mapIPSObjs.get(tmpPbi.Project__c).get(tmpEPBankerObj.User_Id__c));
            }
        }

        //system.debug('========= ipSharesForDeleteMap.Size() =========>>>>>> ' + ipSharesForDeleteMap.size());
        if(ipSharesForDeleteMap.size()>0){
        	ipSharesForDelete = ipSharesForDeleteMap.values();
            //system.debug('Deleting ipSharesForDelete ' + ipSharesForDeleteMap.size());
            delete ipSharesForDelete;
        }
    }

    if((trigger.isInsert || trigger.isUpdate) && BuyerIDList.size()>0) {
        Map<ID,ID> mapDeals = new Map<ID,ID>();
		
		//system.debug('-------------- BuyerIDList -------------->>>>>> '+BuyerIDList);
        for(Ibanking_Project__c IPObj:[
        	SELECT i.OwnerId, i.Id FROM Ibanking_Project__c i WHERE id in :BuyerIDList])
		{
            mapDeals.put(IPObj.ID,IPObj.OwnerId);
        }
        
        List<Potential_Buyer_Investor__Share> ipSharesForInsert = new List<Potential_Buyer_Investor__Share>();
        Employee_Profile__c tmpEPBankerObj = null;
        for(Potential_Buyer_Investor_Deal_Team__c pr : trigger.new) {
            Potential_Buyer_Investor__Share memberShare = new Potential_Buyer_Investor__Share();
            tmpEPBankerObj = getBankerByProjResourceId(pr.Banker__c);
			
			List<Potential_Buyer_Investor__c> Pbi = [SELECT id,Project__c,Status__c FROM Potential_Buyer_Investor__c
							WHERE Id = :pr.Target_Buyer__c];
			Potential_Buyer_Investor__c tempPbi;
			if (Pbi.size() > 0) {
				tempPbi = Pbi[0];
			}
			//system.debug('------------ Pbi ------------- '+tempPbi);
			
            memberShare.ParentId = tempPbi.Project__c;
            memberShare.AccessLevel = 'Edit';
            memberShare.RowCause = 'Manual';//Schema.Ibanking_Project__Share.RowCause.Hiring_Manager_Access__c;
	            
            if (tempPbi.Project__c!=null 
                && pr.Banker__c!=null 
                && mapDeals.containsKey(tempPbi.Project__c)
                && tmpEPBankerObj!=null 
                && tmpEPBankerObj.User_Id__c!=null
                && mapDeals.get(tempPbi.Project__c)!=tmpEPBankerObj.User_Id__c
                && tempPbi.Status__c == 'Active') 
			{
                memberShare.UserOrGroupId = tmpEPBankerObj.User_Id__c;
                if(tmpEPBankerObj.User_Id__r.IsActive) ipSharesForInsert.add(memberShare);
            }
        }

        //system.debug('=================List of shares to be inserted=========: ' + ipSharesForInsert);
        if(ipSharesForInsert.size()>0){ 
            upsert ipSharesForInsert; 
        }
    }
  
    //private Ibanking_Project__Share getIPShareBy
  
    private Employee_Profile__c getBankerByProjResourceId(Id projResourceId) {
        for(Employee_Profile__c item : bankerList) {
            if (item.Id == projResourceId) {
                return item;
                break;
            }
        }
        return null;
    }
    */
}