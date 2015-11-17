/*
modified: Vika 05/14/2010 - Task #10350
*/
trigger TB_Deal_counter on Potential_Buyer_Investor__c (after insert, after update, before delete) {
/*
	List<Ibanking_Project__c> tbList = new List<Ibanking_Project__c>();
	Map<Id, Ibanking_Project__c> ibankingProjectMap;
	List<Ibanking_Project__c> ibankingProjectList;
	Set<Id> targetBuyersIdSet;
	
	if(Trigger.isUpdate || Trigger.isDelete)
	{
		// fetching id's set 
	    targetBuyersIdSet = new Set<Id>();
	    for (Target_Buyers__c tb : Trigger.old) targetBuyersIdSet.add(tb.Project__c);
	
		// fetching map
		//ibankingProjectMap = new Map<Id, Ibanking_Project__c>([select ID, TB_Counter__c from Ibanking_Project__c where ID in :targetBuyersIdSet]);
		ibankingProjectList = [select ID, TB_Counter__c from Ibanking_Project__c where ID in :targetBuyersIdSet];
		
		for(integer i=0; i<trigger.old.size(); i++)
		{
			Target_Buyers__c itemTB = trigger.old[i];
			if(itemTB.Project__c!=null && (!Trigger.isUpdate || itemTB.Project__c!=trigger.new[i].Project__c))
			{
				//Ibanking_Project__c updProjectObj = ibankingProjectMap.get(itemTB.Project__c);
				Ibanking_Project__c updProjectObj = getDealByProjectId(itemTB.Project__c);
//				for(Ibanking_Project__c updProjectObj : [select ID, TB_Counter__c from Ibanking_Project__c where ID =: itemTB.Project__c limit 1])
				if (updProjectObj != null)
				{
					if(updProjectObj.TB_Counter__c==null || updProjectObj.TB_Counter__c<=0) updProjectObj.TB_Counter__c = 0;
					else updProjectObj.TB_Counter__c = updProjectObj.TB_Counter__c - 1;
					tbList.add(updProjectObj);
				}
				//update updProjectObj;
			}
		}
	}

	if(Trigger.isInsert || Trigger.isUpdate)
	{
		// fetching id's set
	   targetBuyersIdSet = new Set<Id>();
	   for (Target_Buyers__c tb : Trigger.new) targetBuyersIdSet.add(tb.Project__c);
	
		// fetching map
		//ibankingProjectMap = new Map<Id, Ibanking_Project__c>([select ID, TB_Counter__c from Ibanking_Project__c where ID in :targetBuyersIdSet]);
		ibankingProjectList = [select ID, TB_Counter__c from Ibanking_Project__c where ID in :targetBuyersIdSet];

		for(integer i=0; i<trigger.new.size(); i++)
		{
			Target_Buyers__c itemTB = trigger.new[i];
			if(itemTB.Project__c!=null && (!Trigger.isUpdate || itemTB.Project__c!=trigger.old[i].Project__c))
			{
				
				//Ibanking_Project__c updProjectObj = ibankingProjectMap.get(itemTB.Project__c);
				Ibanking_Project__c updProjectObj = getDealByProjectId(itemTB.Project__c);
				
				//for(Ibanking_Project__c updProjectObj : [select ID, TB_Counter__c from Ibanking_Project__c where ID =: itemTB.Project__c limit 1])
				if (updProjectObj != null)
				{
					if(updProjectObj.TB_Counter__c==null) updProjectObj.TB_Counter__c = 1;
					else updProjectObj.TB_Counter__c = updProjectObj.TB_Counter__c + 1;
					tbList.add(updProjectObj);
				}
				//update updProjectObj;
			}
		}
	}
	
	if(tbList.size()>0){ update tbList;}


	private Ibanking_Project__c getDealByProjectId(Id ipId) {
		Ibanking_Project__c result = null;
		for(Ibanking_Project__c item : ibankingProjectList) {
			if(item.Id == ipId) {
				result = item;
				break;
			}
		}
		return result;
	}
*/
}
















/*
// Eugen Kryvobok (10/07/09)
// old version of trigger before bulk improvement 
trigger TB_Deal_counter on Target_Buyers__c (after insert, after update, before delete) {

	List<Ibanking_Project__c> tbList = new List<Ibanking_Project__c>();
	
	if(Trigger.isUpdate || Trigger.isDelete)
	{
		for(integer i=0; i<trigger.old.size(); i++)
		{
			Target_Buyers__c itemTB = trigger.old[i];
			if(itemTB.Project__c!=null && (!Trigger.isUpdate || itemTB.Project__c!=trigger.new[i].Project__c))
			{
				for(Ibanking_Project__c updProjectObj : [select ID, TB_Counter__c from Ibanking_Project__c where ID =: itemTB.Project__c limit 1])
				{
					if(updProjectObj.TB_Counter__c==null || updProjectObj.TB_Counter__c<=0) updProjectObj.TB_Counter__c = 0;
					else updProjectObj.TB_Counter__c = updProjectObj.TB_Counter__c - 1;
					tbList.add(updProjectObj);
				}
				//update updProjectObj;
			}
		}
	}

	if(Trigger.isInsert || Trigger.isUpdate)
	{
		for(integer i=0; i<trigger.new.size(); i++)
		{
			Target_Buyers__c itemTB = trigger.new[i];
			if(itemTB.Project__c!=null && (!Trigger.isUpdate || itemTB.Project__c!=trigger.old[i].Project__c))
			{
				for(Ibanking_Project__c updProjectObj : [select ID, TB_Counter__c from Ibanking_Project__c where ID =: itemTB.Project__c limit 1])
				{
					if(updProjectObj.TB_Counter__c==null) updProjectObj.TB_Counter__c = 1;
					else updProjectObj.TB_Counter__c = updProjectObj.TB_Counter__c + 1;
					tbList.add(updProjectObj);
				}
				//update updProjectObj;
			}
		}
	}
	
	if(tbList.size()>0){ update tbList;}

}
*/