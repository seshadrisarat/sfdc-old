public class SL_Company_List_Handler
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
     
    public SL_Company_List_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
         
    public void OnBeforeInsert(list<Company_List__c> newCompany_Lists){ }
     
    public void OnAfterInsert(map<ID,Company_List__c> newMap)
    {
        doUpdate(newMap,true);
    }
     
    //@future public static void OnAfterInsertAsync(Set<ID> newCompany_ListIDs){ }
     
    public void OnBeforeUpdate(map<ID,Company_List__c> oldMap, map<ID,Company_List__c> newMap){ }
     
    public void OnAfterUpdate(map<ID,Company_List__c> oldMap, map<ID,Company_List__c> newMap)
    { 
        Map<Id,Company_List__c> mapToUpdate = new Map<Id,Company_List__c>();
        for(Company_List__c cl: newMap.values()){
            if(newMap.get(cl.Id).Banker_Name__c != oldMap.get(cl.Id).Banker_Name__c){
                mapToUpdate.put(cl.Id,cl);
            }
        }
        if(!mapToUpdate.isEmpty()){
            doUpdate(mapToUpdate,false);
        }
    }
     
    //@future public static void OnAfterUpdateAsync(Set<ID> updatedCompany_ListIDs){ }
     
    public void OnBeforeDelete(map<ID,Company_List__c> oldCompany_ListMap){ }
     
    public void OnAfterDelete(map<ID,Company_List__c> oldCompany_ListMap){ }
     
    //@future public static void OnAfterDeleteAsync(Set<ID> deletedCompany_ListIDs){ }
     
    public void OnUndelete(list<Company_List__c> restoredCompany_Lists){ }
 
    public void OnAfterUndelete(list<Company_List__c> restoredCompany_Lists){ }
                
    
    private void doUpdate(Map<Id,Company_List__c> newMap,Boolean isInsert)
    {
        List<Company_List__c> compList = [SELECT Id, OwnerId, CreatedById, CreatedBy.IsActive, 
                                                 Banker_Name__r.User_Id__c, Banker_Name__r.User_Id__r.IsActive,
                                                 (SELECT Id, Banker__c FROM Prospect_Members__r)
                                          FROM Company_List__c 
                                          WHERE Id IN : newMap.keySet()];
        List<sObject> toUpdate = new List<sObject>();
        List<Company_List__Share> clShares = new List<Company_List__Share>();
        Company_List__Share ownerShr;
        
        for(Company_List__c cl : compList)
        {
            // Set the ownership of the Company List.
            if((cl.Banker_Name__c != null) && (cl.Banker_Name__r.User_Id__c != null) && (cl.OwnerId != cl.Banker_Name__r.User_Id__c) && (cl.Banker_Name__r.User_Id__r.IsActive == true))
            {
                cl.OwnerId = cl.Banker_Name__r.User_Id__c;
                toUpdate.add(cl);
            }
            
            // Setup the sharing record with the created by user.
            if((isInsert) && (cl.CreatedById != null) && (cl.CreatedBy.IsActive == true)){
                ownerShr = new Company_List__Share();
                ownerShr.ParentId = cl.Id;
                ownerShr.UserOrGroupId = cl.CreatedById;
                ownerShr.AccessLevel = 'edit';
                ownerShr.RowCause = Schema.Company_List__Share.RowCause.Created_By_Edit__c;
                clShares.add(ownerShr);
            }
            
            // for each of the company list members, ensure that their banker fields match the Banker_Name__c field on company list.
            for(Company_List_Member__c clm : cl.Prospect_Members__r)
            {
                clm.Banker__c = cl.Banker_Name__c;
                toUpdate.add(clm);
            }
        }
        if(!toUpdate.isEmpty())
            update toUpdate;
        
        Database.SaveResult[] lsr = Database.insert(clShares,false);
        Integer i=0;
        for(Database.SaveResult sr : lsr)
        {
            if(!sr.isSuccess()){
                // Get the first save result error
                Database.Error err = sr.getErrors()[0];
                
                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default 
                // access level are not allowed. 
                // These sharing records are not required and thus an insert exception is 
                // acceptable. 
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                     &&  err.getMessage().contains('AccessLevel'))){
                    // Throw an error when the error is not related to trivial access level.
                    newMap.get(clShares[i].ParentId).addError('Unable to grant sharing access due to following exception: '+ err.getMessage());
                }
            }
            i++;
        } 
    }
}