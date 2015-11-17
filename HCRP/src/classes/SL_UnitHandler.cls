/**  
* \arg ClassName        : SL_UnitHandler
* \arg JIRATicket       : HCRP-38
* \arg CreatedOn        : 28/July/2015
* \arg LastModifiedOn   : -
* \arg CreatededBy      : Pankaj Ganwani
* \arg ModifiedBy       : -
* \arg Description      : This class serves as handler for SL_Unit trigger and is used to update the Replaced__c field on corresponding previous Lease record of updated Unit record.
*/
public without sharing class SL_UnitHandler 
{
    /* Start - Constructor */
    public SL_UnitHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    public  void onAfterUpdate(Map<Id, Unit__c> mapNewUnits, Map<Id, Unit__c> mapOldUnits)
    {
       replaceLeases(mapNewUnits, mapOldUnits);
    }
    
    private void replaceLeases(Map<Id, Unit__c> mapNewUnits, Map<Id, Unit__c> mapOldUnits)
    {
         // Find out the leases that are actually replaced.
        Set<Id> leasesToProcess = new Set<Id>();
        
        for(Unit__c newUnit : mapNewUnits.values())
        {
            Id oldLease = mapOldUnits.get(newUnit.Id).Current_Lease__c;
            Id newLease = newUnit.Current_Lease__c;
            
            if(oldLease != NULL && newLease != NULL && oldLease != newLease)
            {
             leasesToProcess.add(oldLease);
            }
        }
        
        // If the lease was already replaced no need to process that lease.
        List<Lease__c> leasesToUpdate = new List<Lease__c>();
        
        for(Lease__c l : [SELECT Id FROM Lease__c WHERE Id in : leasesToProcess AND Replaced__c = FALSE])
        {
            leasesToUpdate.add(new Lease__c(Id = l.Id, Replaced__c = TRUE));
        } 
       
        //Update the leases with Replaced__c = TRUE
        if(!leasesToUpdate.isEmpty())
            update leasesToUpdate;
    }
}