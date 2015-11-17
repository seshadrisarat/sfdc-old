/*
MOELIS-31:
Need to create a trigger on the Fund Commitment object. Trigger should be set for insert/update/delete. 
Trigger must support Bulk operations.
The purpose of this trigger is to rollup the commitment amounts for a particular fund for each sub account 
and display the value on the parent account record.
When a Fund commitment record is inserted/edited/ deleted, the trigger should summarize the values in the 
Fund_Commitment_c.Amount field for all Fund Commitment records where Fund_Commitmentc.Fundc is the same as 
the current record being modified AND where the value of Fund_Commitment_c.Investor.Parent is same as the current record. 
This will give the total of all Fund Commitments for that Fund for that parent account.
Once the summarized value is calculated, the trigger should place that value in the appropriate field in the Parent Account record. The appropriate field is determined by the name of the Fund. The mapping is as follows:
Fund Name --> Account Field
Moelis & Company Holdings LLC --> M_C_Holdings_Commitments__c
Moelis Capital Partners Co-Invest Program --> M_C_Coinvest_Commitments__c
Moelis Capital Partners Opportunity Fund I, LP --> MCP_Fund_1_Commitments__c
Moelis Capital Partners Opportunity Fund I-A, LP --> MCP_Fund_1A_Commitments__c
*/
trigger Fund_Commitment_Counter on Fund_Commitment__c (before delete, after insert, after update) 
{
	List<Fund_Commitment__c> triggerValue;
	if (trigger.isInsert || trigger.isUpdate)   triggerValue = Trigger.new;
	if (trigger.isDelete)	triggerValue = Trigger.old;
	
	Map<ID,ID> Map_FundCommitmentId_FundId = new Map<ID,ID>();
	Map<ID,ID> Map_InvestorId_FundCommitmentId = new Map<ID,ID>();
	Map<ID,ID> Map_FundCommitmentId_InvestorParentId = new Map<ID,ID>();
	
	for (Fund_Commitment__c Item : triggerValue) 
	{
		if (Item.Fund__c != null) Map_FundCommitmentId_FundId.put(Item.Id,Item.Fund__c);
		Map_InvestorId_FundCommitmentId.put(Item.Investor__c,Item.Id);
	}
	
	Set<Id> ListInvestorId = Map_InvestorId_FundCommitmentId.KeySet();
	
	//System.debug('Map_InvestorId_FundCommitmentId ---------->'+Map_InvestorId_FundCommitmentId);
	//System.debug('ListInvestorId ---------->'+ListInvestorId);
	if(ListInvestorId != null)
	{
		for(Account tmpAccount : [Select ParentId,Id From Account WHERE Id IN : ListInvestorId ])
		{
			if(tmpAccount.ParentId != null)Map_FundCommitmentId_InvestorParentId.put(Map_InvestorId_FundCommitmentId.get(tmpAccount.Id), tmpAccount.ParentId);
		}
	}
	//System.debug('Map_FundCommitmentId_FundId ---------->'+Map_FundCommitmentId_FundId);
	//System.debug('Map_FundCommitmentId_InvestorParentId ---------->'+Map_FundCommitmentId_InvestorParentId);
	
	//all Fund Commitments for that Fund for that parent account
	Map<Id,Decimal> Map_FundId_FundCommitmentSumm = new Map<Id,Decimal>();
	Map<Id,Decimal> Map_ParentId_FundCommitmentSumm = new Map<Id,Decimal>();
	Map<Id,String> Map_ParentId_FundName = new Map<Id,String>();
	Decimal Counter;
	if (Map_FundCommitmentId_InvestorParentId.values() != null && Map_FundCommitmentId_FundId.values() != null )
	{
		Counter = 0;
		for(Fund_Commitment__c tmpFundCommitment : [
			SELECT Id,Fund__c,Fund__r.Name,Investor__r.ParentId, Investor__c,Amount__c
			FROM Fund_Commitment__c 
			WHERE Investor__r.ParentId IN : Map_FundCommitmentId_InvestorParentId.values() OR Fund__c IN : Map_FundCommitmentId_FundId.values()
			ORDER BY Investor__r.ParentId,Fund__c])
		{
			for (Fund_Commitment__c trigger_Item : triggerValue) 
			{
				system.debug('tmpFundCommitment ------>'+tmpFundCommitment);
				system.debug('trigger_Item ------>'+trigger_Item);
				system.debug('tmpFundCommitment.Fund__c == Map_FundCommitmentId_FundId.get(trigger_Item.Id) --->'+tmpFundCommitment.Fund__c +'=='+ Map_FundCommitmentId_FundId.get(trigger_Item.Id));
				system.debug('tmpFundCommitment.Investor__r.ParentId == Map_FundCommitmentId_InvestorParentId.get(trigger_Item.Id) --->'+tmpFundCommitment.Investor__r.ParentId +' == '+Map_FundCommitmentId_InvestorParentId.get(trigger_Item.Id));
				if(Map_FundCommitmentId_FundId.get(trigger_Item.Id) != null &&	Map_FundCommitmentId_InvestorParentId.get(trigger_Item.Id) != null)
				{
					if(tmpFundCommitment.Fund__c == Map_FundCommitmentId_FundId.get(trigger_Item.Id) && tmpFundCommitment.Investor__r.ParentId == Map_FundCommitmentId_InvestorParentId.get(trigger_Item.Id) && tmpFundCommitment.Amount__c != null)
					{
			        	if (trigger.isDelete)
			        	{
			        		if (trigger_Item.Id != tmpFundCommitment.Id) Counter = Counter + tmpFundCommitment.Amount__c;
			        	}
			        	else Counter = Counter + tmpFundCommitment.Amount__c;
						Map_ParentId_FundCommitmentSumm.put(tmpFundCommitment.Investor__r.ParentId,Counter);
						Map_ParentId_FundName.put(tmpFundCommitment.Investor__r.ParentId,tmpFundCommitment.Fund__r.Name);
					} else Counter = 0;
					
				}
			}
			//Map_ParentId_FundCountItem.put(tmpFundCommitment.Investor__r.ParentId,CountItem);
			
		}
	}
	//system.debug('Map_ParentId_FundCommitmentSumm ------>'+Map_ParentId_FundCommitmentSumm);
	//system.debug('Map_ParentId_FundName ------>'+Map_ParentId_FundName);
	List<Account> List_AccountToUPD = new List<Account>();
	if(Map_FundCommitmentId_InvestorParentId != null && Map_FundCommitmentId_InvestorParentId.values() != null)
	{
		for(Account Account_from_InvestorParentId : [
			SELECT	Id, Name,M_C_Holdings_Commitments__c,
					M_C_Coinvest_Commitments__c,MCP_Fund_1_Commitments__c,MCP_Fund_1A_Commitments__c 
			FROM Account 
			WHERE Id IN : Map_FundCommitmentId_InvestorParentId.values()])
		{
			
			if (Map_FundId_FundCommitmentSumm != null && Map_ParentId_FundName != null && Map_ParentId_FundName.get(Account_from_InvestorParentId.Id) != null)
			{
				if(Map_ParentId_FundName.get(Account_from_InvestorParentId.Id) == 'Moelis & Company Holdings LLC') Account_from_InvestorParentId.M_C_Holdings_Commitments__c = Map_ParentId_FundCommitmentSumm.get(Account_from_InvestorParentId.Id);
				else if(Map_ParentId_FundName.get(Account_from_InvestorParentId.Id) == 'Moelis Capital Partners Co-Investment Program') Account_from_InvestorParentId.M_C_Coinvest_Commitments__c = Map_ParentId_FundCommitmentSumm.get(Account_from_InvestorParentId.Id);
				else if(Map_ParentId_FundName.get(Account_from_InvestorParentId.Id) == 'Moelis Capital Partners Opportunity Fund I, LP') Account_from_InvestorParentId.MCP_Fund_1_Commitments__c = Map_ParentId_FundCommitmentSumm.get(Account_from_InvestorParentId.Id);
				else if(Map_ParentId_FundName.get(Account_from_InvestorParentId.Id) == 'Moelis Capital Partners Opportunity Fund I-A, LP') Account_from_InvestorParentId.MCP_Fund_1A_Commitments__c = Map_ParentId_FundCommitmentSumm.get(Account_from_InvestorParentId.Id);
				List_AccountToUPD.add(Account_from_InvestorParentId);
			}
		}
	}
	if(List_AccountToUPD.size() > 0) upsert List_AccountToUPD;
   
}