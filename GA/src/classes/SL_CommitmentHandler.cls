/**
*  Class Name   : SL_CommitmentHandler
*  CreatedOn      : 30/04/2015
*  ModifiedBy     : Sandeep
*  ModifiedDate   : 15/05/15
*  Description    : This is the handler class for commitment trigger 
*/

public with sharing class SL_CommitmentHandler 
{
    /*
        * MethodName   : onAfterInsert
        * param        : map<Id, Commitment__c> mapNewCommitment
        * Description  : call after Insert
    */
    public void onAfterInsert(map<Id, Commitment__c> mapNewCommitment)
    {
        rollupCommitment_Amount(mapNewCommitment, null);
    }

    /*
        * MethodName   : onAfterUpdate
        * param        : map<Id, Commitment__c> mapNewCommitment, map<Id, Commitment__c> mapOldCommitment
        * Description  : call after update
    */
    public void onAfterUpdate(map<Id, Commitment__c> mapNewCommitment, map<Id, Commitment__c> mapOldCommitment)
    {
        rollupCommitment_Amount(mapNewCommitment, mapOldCommitment);
    }
    /*
        * MethodName   : onAfterDelete
        * param        : map<Id, Commitment__c> mapOldCommitment
        * Description  : call after delete
    */
    public void onAfterDelete(map<Id, Commitment__c> mapOldCommitment)
    {
        rollupCommitment_Amount(mapOldCommitment, null);
    }
    /*
        * MethodName   : rollupCommitment_Amount
        * param        : map<Id, Commitment__c> mapNewCommitment, map<Id, Commitment__c> mapOldCommitment
        * Description  : calculate the Account commitment rollup Amount
    */
    private void rollupCommitment_Amount(map<Id, Commitment__c> mapNewCommitment, map<Id, Commitment__c> mapOldCommitment)
    {
        set<Id> setInvestorEntityId = new set<Id>();//set to store the InvestorEntity id
        set<Id> setNewInvestorEntityId = new set<Id>();
        set<Id> setAccountId = new set<Id>();//set to store the InvestorEntity id
        List<Account> lstAccount = new list<Account>();//list to update the Account
        map<Id, decimal> mapAccountIdToCommitmentAmount = new map<Id, decimal>();//map to hold the Account to related Commitment rollup values
        map<Id, decimal> mapInvestorEntityIdToTotal = new map<Id, decimal>();
        List<RecordType> lstRecordType = [SELECT Id  FROM RecordType where SobjectType ='Investor_Entity__c' AND DeveloperName = 'Co_Investor' ];
        //iterate over new map and get the Investor entity values
        for(Commitment__c objCommitment : mapNewCommitment.values())
        {
            if(!Trigger.isUpdate || (Trigger.isUpdate && (objCommitment.Amount__c != mapOldCommitment.get(objCommitment.Id).Amount__c || 
                                                            objCommitment.Status__c != mapOldCommitment.get(objCommitment.Id).Status__c)))
            {
                setInvestorEntityId.add(objCommitment.Investor_Entity__c);
            }
        }
        
        for(Investor_Entity__c objInvestorEntity : [SELECT Id, 
                                                           Account__c 
                                                      FROM Investor_Entity__c 
                                                     WHERE Id IN : setInvestorEntityId 
                                                       AND Account__c != null])
        {
        	setAccountId.add(objInvestorEntity.Account__c);
        }
        for(Investor_Entity__c objInvestorEntity : [SELECT Id,
                                                           RecordTypeId
                                                      FROM Investor_Entity__c 
                                                     WHERE Account__c IN :setAccountId 
                                                     AND RecordTypeId <>: lstRecordType[0].Id])
        {
        	setNewInvestorEntityId.add(objInvestorEntity.Id);
        }
        for(AggregateResult objCommitment :[SELECT Investor_Entity__c, 
                                                   SUM(Amount__c) total 
                                              FROM Commitment__c 
                                             WHERE Investor_Entity__c 
                                               IN: setNewInvestorEntityId 
                                               AND Amount__c != null 
                                               AND Status__c = 'Active'
                                          GROUP BY Investor_Entity__c ])
        {
            mapInvestorEntityIdToTotal.put((Id)objCommitment.get('Investor_Entity__c'), (Decimal)objCommitment.get('total'));
        }
        for(Investor_Entity__c objInvestorEntity : [SELECT Id, 
                                                           Account__c 
                                                      FROM Investor_Entity__c 
                                                     WHERE Id IN : setNewInvestorEntityId])
        {
            double dobTotal = mapInvestorEntityIdToTotal.containsKey(objInvestorEntity.Id) ? mapInvestorEntityIdToTotal.get(objInvestorEntity.Id) : 0;
            if(!mapAccountIdToCommitmentAmount.containsKey(objInvestorEntity.Account__c))
                mapAccountIdToCommitmentAmount.put(objInvestorEntity.Account__c, dobTotal);
            else
                mapAccountIdToCommitmentAmount.put(objInvestorEntity.Account__c, mapAccountIdToCommitmentAmount.get(objInvestorEntity.Account__c) + (dobTotal));
        }
        //iterate over the map and Add into the list of Account for update
        for(Id objAccountId : mapAccountIdToCommitmentAmount.keySet())
        {
            lstAccount.add(new Account (Id = objAccountId,Commitment_Amount_Rolled_Up__c = mapAccountIdToCommitmentAmount.get(objAccountId)));
        }
        //update the Accounts
        if(!lstAccount.isEmpty())
            update lstAccount;
    }
}