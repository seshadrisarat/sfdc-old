/**
* \arg ClassName        : SL_AffiliationHandler
* \arg JIRATicket       : PWP-212
* \arg CreatedOn        : 1/Sept/2015
* \arg LastModifiedOn   : 1/Sept/2015
* \arg CreatededBy      : Nrusingh 
* \arg ModifiedBy       : Nrusingh
* \arg Description      : Handler class for SL_Affiliation trigger
*/
public with sharing class SL_AffiliationHandler   
{ 
    /**
        @MethodName : onBeforeInsert
        @Param      : new list of Affiliation__c records  
        @Description: This method called on before insert of Affiliation__c records.
    **/
    public void onBeforeInsert(List<Affiliation__c> lstAffiliationNew) 
    {
       updateFrom_To_Affiliations(lstAffiliationNew,null); 
    }
    
    /**
        @MethodName : onAfterInsert
        @Param      : new map of Affiliation__c records  
        @Description: This method called on after insert of Affiliation__c records.
    **/
    public void onAfterInsert(Map<Id, Affiliation__c> mapIdToAffiliationNew)
    {
        createInverseAffiliations(mapIdToAffiliationNew);
    }
    /* End */
    
    /**
        @MethodName : onBeforeUpdate
        @Param      : old map of Affiliation__c records and new map of Affiliation__c records 
        @Description: This method called on after update of Affiliation__c record.
    **/
    public void onBeforeUpdate(Map<Id, Affiliation__c> mapIdToAffiliationNew, Map<Id, Affiliation__c> mapIdToAffiliationOld)
    {
        updateFrom_To_Affiliations(mapIdToAffiliationNew.values(),mapIdToAffiliationOld);
    }
    /* End */
    
    /**
        @MethodName : onAfterDelete
        @Param      : old map of Affiliation__c records 
        @Description: This method called on after delete of Affiliation__c record.
    **/
    public void onAfterDelete(Map<Id, Affiliation__c> mapIdToAffiliationOld)
    {
           deleteAffs(mapIdToAffiliationOld);
    }
    /* End */
	
	/**
        @MethodName : onAfterDelete
        @Param      : old map of Affiliation__c records 
        @Description: This method called on after delete of Affiliation__c record.
    **/
    public void onAfterUnDelete(Map<Id, Affiliation__c> mapIdToAffiliationNew)
    {
        unDeleteAffs(mapIdToAffiliationNew);
    }
    /* End */
    
    /**
        @MethodName : updateFrom_To_Affiliations
        @Param      : lstAffiliationNew, mapOld
        @Description: This method called to update the from account based on the from contact and to account based on the to contact
    **/
    private void updateFrom_To_Affiliations(List<Affiliation__c> lstAffiliationNew, Map <Id, Affiliation__c> mapOld)
    {
        Set<Id> setFromContact = new Set <Id> ();
        Set <Id> setToContact = new Set <Id> ();
        Map <Id,Id> mapFromContactIdToFromAccId = new Map <Id,Id>();
        Map <Id,Id> mapToContactIdToAccId = new Map <Id,Id>();
        
        for(Affiliation__c objAffiliation : lstAffiliationNew)
        {
            if(objAffiliation.Contact__c != null)
                setFromContact.add(objAffiliation.Contact__c);
            
            if(objAffiliation.To_Contact__c != null)
                setToContact.add(objAffiliation.To_Contact__c);
        }
        if(!setFromContact.isEmpty())
        {
            for(Contact objCon : [SELECT Id, AccountId FROM Contact WHERE Id IN:setFromContact ])
            {
                mapFromContactIdToFromAccId.put(objCon.Id, objCon.AccountId);
            }
        }
        if(!setToContact.isEmpty())
        {
            for(Contact objCon : [SELECT Id, AccountId FROM Contact WHERE Id IN:setToContact ])
            {
                mapToContactIdToAccId.put(objCon.Id, objCon.AccountId);
            }
        }
        for(Affiliation__c objAffiliation : lstAffiliationNew)
        {
            Affiliation__c objOldAff;
            if(trigger.isUpdate && !mapOld.isEmpty() && mapOld != null)
                    objOldAff = mapOld.get(objAffiliation.Id);
            
            
            if(trigger.isInsert || (trigger.isUpdate && (objAffiliation.Company__c != objOldAff.Company__c || objAffiliation.To_Company__c != objOldAff.To_Company__c 
            || objAffiliation.Contact__c != objOldAff.Contact__c || objAffiliation.To_Contact__c != objOldAff.To_Contact__c)))
            {
                if(objAffiliation.Company__c == null && objAffiliation.Contact__c != null
                && mapFromContactIdToFromAccId.containsKey(objAffiliation.Contact__c))
                {
                    objAffiliation.Company__c = mapFromContactIdToFromAccId.get(objAffiliation.Contact__c);
                }
                    
                if(objAffiliation.To_Company__c == null && objAffiliation.To_Contact__c != null
                && mapToContactIdToAccId.containsKey(objAffiliation.To_Contact__c))
                {
                    objAffiliation.To_Company__c = mapToContactIdToAccId.get(objAffiliation.To_Contact__c);
                }
            }
        }
    }
    
    /**
        @MethodName : createInverseAffiliations
        @Param      : Map<Id, Affiliation__c> mapIdToAffiliationNew
        @Description: This method called to create inverse affiliations and update the context affiliations
    **/
    private void createInverseAffiliations(Map<Id, Affiliation__c> mapIdToAffiliationNew)
    {
       
        List <Affiliation__c> lstInverAffiliations = new List <Affiliation__c>();
        Map<Id,Affiliation__c> MapAffliationIdToAffliation = new map<Id,Affiliation__c>(); 
        List <Affiliation__c> lstAffToUpdateRelatedAffField = new List <Affiliation__c>();
        Map <Id, Affiliation__c> mapAffIdToInverseAff = new Map <Id,Affiliation__c >();
        
        for(Affiliation__c objAffiliation : mapIdToAffiliationNew.values())
        {
            if((objAffiliation.Company__c != null && objAffiliation.To_Company__c != null ) || (objAffiliation.Contact__c != null  && objAffiliation.To_Contact__c
             != null))
            {
                Affiliation__c objInverseAffiliation = createNewAff(objAffiliation);
                lstInverAffiliations.add(objInverseAffiliation);
                mapAffIdToInverseAff.put(objInverseAffiliation.Related_Affiliaton__c,objInverseAffiliation);
            }
        }
        
        
        if(!lstInverAffiliations.isEmpty()){
            Database.insert(lstInverAffiliations, false);
       }
       
       for(Affiliation__c objAff : [SELECT Id, Related_Affiliaton__c,RelatedId__c,Affiliation_Notes__c,Company__c,Contact__c,End_Date__c,Role__c,Start_Date__c,Status__c,To_Company__c,To_Contact__c     FROM 
                                   Affiliation__c WHERE Id IN: mapIdToAffiliationNew.keySet()])
       {
           if(mapAffIdToInverseAff.containsKey(objAff.Id))
            {
                // Getting inverse Aff Id
                Id inverseAffId = mapAffIdToInverseAff.get(objAff.Id).Id;
                
                // Updating Aff Related_Affiliaton__c with it's inverse connection record Which was created.
                objAff.Related_Affiliaton__c = inverseAffId;
                objAff.RelatedId__c = inverseAffId;
                lstAffToUpdateRelatedAffField.add(objAff);
            }   
       }
       
       if(!lstAffToUpdateRelatedAffField.isEmpty())
       {
            Database.update(lstAffToUpdateRelatedAffField, false);
       }
    }
    
    
    private Affiliation__c createNewAff(Affiliation__c objAffiliation)
    {
        Affiliation__c objInverseAffiliation = new Affiliation__c(Affiliation_Notes__c = objAffiliation.Affiliation_Notes__c,
                                                                  Company__c = objAffiliation.To_Company__c,
                                                                  Contact__c = objAffiliation.To_Contact__c,
                                                                  End_Date__c = objAffiliation.End_Date__c,
                                                                  Related_Affiliaton__c = objAffiliation.Id,
                                                                  RelatedId__c = objAffiliation.Id,
                                                                  Role__c = objAffiliation.Role__c,
                                                                  Start_Date__c = objAffiliation.Start_Date__c,
                                                                  Status__c = objAffiliation.Status__c,
                                                                  To_Company__c = objAffiliation.Company__c,
                                                                  To_Contact__c = objAffiliation.Contact__c
                                                                );  
        return objInverseAffiliation;
    }
    
    
    
    
    /**
        @MethodName : onAfterUpdate
        @Param      : old and new map of Affiliation__c records 
        @Description: This method called on after Update of Affiliation__c record.
    **/
    public void onAfterUpdate(Map<Id, Affiliation__c> mapIdToAffiliationOld, Map<Id, Affiliation__c> mapIdToAffiliationNew)
    {
        updateAffiliations(mapIdToAffiliationOld, mapIdToAffiliationNew);
    }
    /* End */
    
    private void updateAffiliations(Map<Id, Affiliation__c> mapIdToAffiliationOld, Map<Id, Affiliation__c> mapIdToAffiliationNew)
    {
        Map <Id, Id> mapUpdatedAffIdToItsInverseAffId = new Map <Id, Id>();
        Set<Id> setFilterdAffId = new Set<Id>();
        Map <Id, Affiliation__c>mapInverseAffIdToInverseAff = new Map <Id, Affiliation__c>();
        Map <Id, Affiliation__c> mapAffToBeCreated = new Map <Id, Affiliation__c>();
        Map <Id, Affiliation__c>mapAffsToUpdate = new Map <Id, Affiliation__c>();
        
        for(Affiliation__c objAff : mapIdToAffiliationNew.values())
        {
            // Checking whether From_Account__c or To_Account__c is updated for Connection to create inverse connection
            Affiliation__c objOldAff;
            if(!mapIdToAffiliationOld.isEmpty())
                objOldAff = mapIdToAffiliationOld.get(objAff.Id);
            
            
            if(objAff.Company__c != objOldAff.Company__c || objAff.To_Company__c != objOldAff.To_Company__c 
            || objAff.Contact__c != objOldAff.Contact__c || objAff.To_Contact__c != objOldAff.To_Contact__c 
            ||objAff.Status__c != objOldAff.Status__c 
            ||objAff.Affiliation_Notes__c != objOldAff.Affiliation_Notes__c 
            || objAff.End_Date__c != objOldAff.End_Date__c
            || objAff.Role__c != objOldAff.Role__c
            || objAff.Start_Date__c != objOldAff.Start_Date__c
            )
            {
                setFilterdAffId.add(objAff.Id);
                if(objAff.Related_Affiliaton__c != null)    
                    mapUpdatedAffIdToItsInverseAffId.put(objAff.Id,objAff.Related_Affiliaton__c);
            }
        }
        
        // Querying inverse connection records to update
        if(!mapUpdatedAffIdToItsInverseAffId.isEmpty())
        {
            for(Affiliation__c objAff : [Select Company__c, 
                                               To_Company__c,
                                               Affiliation_Notes__c,
                                               End_Date__c,
                                               Role__c,
                                               Start_Date__c,
                                               RelatedId__c,
                                               Contact__c, 
                                               To_Contact__c,
                                               Status__c,
                                               Related_Affiliaton__c
                                         from Affiliation__c
                                         where Id IN:mapUpdatedAffIdToItsInverseAffId.values()])
            {
                mapInverseAffIdToInverseAff.put(objAff.Id,objAff);
            }
        }
        
        if(!setFilterdAffId.isEmpty())
        {
           for(Affiliation__c objAff : [Select Company__c, 
                                               To_Company__c,
                                               Affiliation_Notes__c,
                                               End_Date__c,
                                               Role__c,
                                               Start_Date__c,
                                               RelatedId__c,
                                               Contact__c, 
                                               To_Contact__c,
                                               Status__c,
                                               Related_Affiliaton__c
                                       from Affiliation__c
                                       where Id IN:setFilterdAffId])
            {
                if(((objAff.Company__c != null && objAff.To_Company__c != null) 
                || (objAff.Contact__c != null && objAff.To_Contact__c != null))
                && mapUpdatedAffIdToItsInverseAffId.containsKey(objAff.Id))
                {
                    Affiliation__c objInvAffToUpdateWithUpdateAff = mapInverseAffIdToInverseAff.get(mapUpdatedAffIdToItsInverseAffId.get(objAff.Id));
                    objInvAffToUpdateWithUpdateAff.Company__c = objAff.To_Company__c;
                    objInvAffToUpdateWithUpdateAff.To_Company__c = objAff.Company__c;
                    objInvAffToUpdateWithUpdateAff.Contact__c = objAff.To_Contact__c;
                    objInvAffToUpdateWithUpdateAff.To_Contact__c = objAff.Contact__c;
                    objInvAffToUpdateWithUpdateAff.Status__c = objAff.Status__c;
                    objInvAffToUpdateWithUpdateAff.Affiliation_Notes__c = objAff.Affiliation_Notes__c;
                    objInvAffToUpdateWithUpdateAff.End_Date__c = objAff.End_Date__c;
                    objInvAffToUpdateWithUpdateAff.Role__c = objAff.Role__c;
                    objInvAffToUpdateWithUpdateAff.Start_Date__c = objAff.Start_Date__c;
                    
                    mapAffsToUpdate.put(objInvAffToUpdateWithUpdateAff.Id,objInvAffToUpdateWithUpdateAff);
                }
                // Checking if from and to account is not null and if there is no inverse aff for updated aff creating new inverse aff.
                else if(((objAff.Company__c != null && objAff.To_Company__c != null) || 
                (objAff.Contact__c != null && objAff.To_Contact__c != null)) && !mapUpdatedAffIdToItsInverseAffId.containsKey(objAff.Id))
                    mapAffToBeCreated.put(objAff.Id,objAff);
            } 
        }
        if(!mapAffsToUpdate.isEmpty())
            Database.update(mapAffsToUpdate.values(),false);
        if(!mapAffToBeCreated.isEmpty())    
            OnAfterInsert(mapAffToBeCreated);
    }
    
    
    /**
        @MethodName : deleteAffs
        @Param      : Map<Id, Affiliation__c> mapIdToAffiliationOld
        @Description: This method called on after delete of Affiliation__c record.
    **/
    
    private void deleteAffs(Map<Id, Affiliation__c> mapIdToAffiliationOld)
    {
         Set<ID> setInverseAffIds = new Set<ID>(); // Set used to store Inverse Connections for deleted connections
        
        // Iterating through deleted Affs
        for(Affiliation__c objAff : mapIdToAffiliationOld.values())
        {
            // Adding inverse affs into a set.
            setInverseAffIds.add(objAff.Related_Affiliaton__c);
        }
        // Deleting inverse connections for deleted connections..
        if(setInverseAffIds.size()>0)
            Database.delete(Database.query('select id from Affiliation__c where id=:setInverseAffIds'), false);
    }
    
    /**
        @MethodName : unDeleteAffs
        @Param      : Map<Id, Affiliation__c> mapIdToAffiliationNew
        @Description: This method called on after undelete of Affiliation__c record.
    **/
    private void unDeleteAffs(Map<Id, Affiliation__c> mapIdToAffiliationNew)
    {
        List <Affiliation__c> lstAffiliationsToBeUndeleted = new List <Affiliation__c>();
        for(Affiliation__c objAffiliation : mapIdToAffiliationNew.values())
        {
             Affiliation__c objInverseAffiliation = new Affiliation__c(Id = objAffiliation.RelatedId__c );
             lstAffiliationsToBeUndeleted.add(objInverseAffiliation);
        }
        if(!lstAffiliationsToBeUndeleted.isEmpty())
            undelete lstAffiliationsToBeUndeleted;
    }
}