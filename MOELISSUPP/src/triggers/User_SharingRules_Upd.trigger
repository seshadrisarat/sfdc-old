trigger User_SharingRules_Upd on User (after update) {
    /*
    List<Id> List_userIdsForSharingRulesUpdate = new List<Id>();
    
    for (Id idItem : Trigger.newMap.keySet())
        if (Trigger.newMap.get(idItem).IsActive != Trigger.oldMap.get(idItem).IsActive && 
            Trigger.newMap.get(idItem).IsActive == true) 
                List_userIdsForSharingRulesUpdate.add(idItem);

    List<Employee_Profile__c> employeeProfileForUpdate = new List<Employee_Profile__c>();
    
    for(Employee_Profile__c item : [
        SELECT id, User_ID__c 
        FROM Employee_Profile__c 
        WHERE User_ID__c in :List_userIdsForSharingRulesUpdate]) 
    {
        item.User_Active_Update__c = true;
        employeeProfileForUpdate.add(item);
    }
    
    //update employeeProfileForUpdate;
    User_Active_Class con = new User_Active_Class();
    con.updateEmployeeProfiles(employeeProfileForUpdate);
    */
}



/* // previous version
trigger User_SharingRules_Upd on User (after update) {
    
    List<Id> List_userIdsForSharingRulesUpdate = new List<Id>();
    
    for (Id idItem : Trigger.newMap.keySet())
        if (Trigger.newMap.get(idItem).IsActive != Trigger.oldMap.get(idItem).IsActive && 
            Trigger.newMap.get(idItem).IsActive == true) 
                List_userIdsForSharingRulesUpdate.add(idItem);
    
    Map<Id, Id> Map_EmployeeProfileId_UserId = new Map<Id, Id>();

    for(Employee_Profile__c item : [
        SELECT id, User_ID__c 
        FROM Employee_Profile__c 
        WHERE User_ID__c in :List_userIdsForSharingRulesUpdate])
    Map_EmployeeProfileId_UserId.put(item.Id, item.User_ID__c);
    
    
    Map<Id, Set<Id>> Map_UserId_DealIdSet = new Map<Id, Set<Id>>();

    Id userId;
    for(Project_Resource__c item : [
        SELECT Project__c, Banker__c 
        FROM Project_Resource__c 
        WHERE Banker__c in :Map_EmployeeProfileId_UserId.keySet()]) 
    {
        userId = Map_EmployeeProfileId_UserId.get(item.Banker__c);
        if (Map_UserId_DealIdSet.containsKey(userId) == false)
            Map_UserId_DealIdSet.put(userId, new Set<Id>());
        Map_UserId_DealIdSet.get(userId).add(item.Project__c);
    }
    
    for(Ibanking_Project__Share item : [
        SELECT ParentId, UserOrGroupId 
        FROM Ibanking_Project__Share 
        WHERE UserOrGroupId in :Map_UserId_DealIdSet.keySet()]) 
    {
        Map_UserId_DealIdSet.get(item.UserOrGroupId).remove(item.ParentId);
    }
    

    List<Ibanking_Project__Share> sharingRulesForInsert = new List<Ibanking_Project__Share>();
    for(Id user_Id : Map_UserId_DealIdSet.keySet()) {
        for(Id deal_Id : Map_UserId_DealIdSet.get(user_Id)) {
            Ibanking_Project__Share memberShare = new Ibanking_Project__Share();
            memberShare.UserOrGroupId = user_Id;
            memberShare.ParentId      = deal_Id;
            memberShare.AccessLevel   = 'Edit';
            memberShare.RowCause      = 'Manual';
            sharingRulesForInsert.add(memberShare);
        }
    }


    //User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    //System.runAs ( thisUser ) {
//      insert sharingRulesForInsert;
    //}
        
    Database.SaveResult[] lsr = Database.insert(sharingRulesForInsert,false);
    
    for(Database.SaveResult sr:lsr){
        if(!sr.isSuccess()) {
            Database.Error err = sr.getErrors()[0];
            system.debug('err===' + err);
        }
    }       
}
*/