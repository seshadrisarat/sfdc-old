/**  
* \arg ClassName      : SL_MonthEndBalanceHandler
* \arg JIRATicket     : OAKHILL-15
* \arg CreatedOn      : 22/OCT/2014
* \arg LastModifiedOn : 22/OCT/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as handler class for SL_MonthEndBalance trigger.
*/
public with sharing class SL_MonthEndBalanceHandler 
{
    /* Start - Constructor */
    public SL_MonthEndBalanceHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    /*!
      *  @MethodName: onAfterInsert
      *  @param None: New list of month end balace records
      *  @Description: This method will be called on after insert of month end balance record
    */
    public void onAfterInsert(List<Month_End_Balance__c> lstMonthEndBalance)
    {
        //calling function to update related account records
        updateRelatedAccounts(lstMonthEndBalance,null);
    }
    
    /*!
      *  @MethodName: onAfterUpdate
      *  @param None: new and old map of month end balance records 
      *  @Description: This method will be called on after update of month end balance record
    */
    public void onAfterUpdate(Map<Id,Month_End_Balance__c> mapNewIdToMonthEndBalance, Map<Id,Month_End_Balance__c> mapOldIdToMonthEndBalance)
    {
        //calling function to update related account records
        updateRelatedAccounts(mapNewIdToMonthEndBalance.values(),mapOldIdToMonthEndBalance);
    }
    
    /*!
      *  @MethodName: onAfterDelete
      *  @param None: new list of month end balance records
      *  @Description: This method will be called on after delete of month end balance record
    */
    public void onAfterDelete(List<Month_End_Balance__c> lstMonthEndBalance)
    {
        //calling function to update related account records
        updateRelatedAccounts(lstMonthEndBalance,null);
    }
    
    /*!
      *  @MethodName: onAfterUndelete
      *  @param None: new list of month end balance records
      *  @Description: This method will be called on after undelete of month end balance record
    */
    public void onAfterUndelete(List<Month_End_Balance__c> lstMonthEndBalance)
    {
        //calling function to update related account records
        updateRelatedAccounts(lstMonthEndBalance,null);
    }
    
    /*!
      *  @MethodName: updateRelatedAccounts
      *  @param None: list of month end balance records and old map of month end balance records
      *  @Description: This method will be called to update related account records
    */
    private void updateRelatedAccounts(List<Month_End_Balance__c> lstMonthEndBalance, Map<Id, Month_End_Balance__c> mapIdToMonthEndBalance)
    {
        Set<Id> setRelatedAccount = new Set<Id>();//set of related account records 
        Map<Id,Related_Account__c> mapIdToRelatedAccount = new Map<Id,Related_Account__c>();//map of related account id to related account to update the related account records
        Month_End_Balance__c objOldMonthEndBalance ;//variable to hold value of old version of month end balance record in case of update event
    
        //Iterating over month end balance object to collect the related account ids.
        for(Month_End_Balance__c objMonthEndBalance : lstMonthEndBalance)
        {
            if(Trigger.isUpdate)
                objOldMonthEndBalance = mapIdToMonthEndBalance.get(objMonthEndBalance.Id);//assigning the value to object if event is after update
            
            if(!Trigger.isUpdate || (objMonthEndBalance.Name!= objOldMonthEndBalance.Name || objMonthEndBalance.Commitment_Funded_c__c != objOldMonthEndBalance.Commitment_Funded_c__c || objMonthEndBalance.Net_Balance__c != objOldMonthEndBalance.Net_Balance__c))
            {                
            	setRelatedAccount.add(objMonthEndBalance.Related_Account__c);
            }
        }
        
        //Fetching the most recent month end balance record to map it with related account record
        for(Month_End_Balance__c objMonthEndBalance : [SELECT Name, Related_Account__c, Commitment_Funded_c__c, Net_Balance__c 
                                                       FROM Month_End_Balance__c 
                                                       WHERE Related_Account__c IN : setRelatedAccount ORDER BY Name, LastModifiedDate])
        {
            mapIdToRelatedAccount.put(objMonthEndBalance.Related_Account__c, new Related_Account__c(Id = objMonthEndBalance.Related_Account__c, Commitment_Funded__c = objMonthEndBalance.Commitment_Funded_c__c, Current_NAV__c = objMonthEndBalance.Net_Balance__c));
        }

        if(!mapIdToRelatedAccount.isEmpty())
            update mapIdToRelatedAccount.values();//updating related account records
        else
        {
            List<Related_Account__c> lstRelatedAccount = new List<Related_Account__c>();
            //Iterating over set of related account ids
            for(Id RelateAccountId : setRelatedAccount)
            {
                //setting the null to related account if there is no Month_End_Balance__c record corresponding to related account
                lstRelatedAccount.add(new Related_Account__c(Id = RelateAccountId, Commitment_Funded__c = null, Current_NAV__c = null));
            }
            update lstRelatedAccount;//updating the related account records
        }
    }
}