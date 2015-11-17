public class DealSharingRules
{
    public static boolean UpdateShare(  List<Id> DealToUpdate) 
    {
        system.debug('DealToUpdate>>>>>>>>>>>>>>>>'+DealToUpdate);
        Map<Id, Set<Id>> Map_DealId_SetUserId = new Map<Id, Set<Id>> ();
        for (Id itemId : DealToUpdate) Map_DealId_SetUserId.put(itemId, new Set<Id>());
        map<Id,set<Id>> dealToInactiveDealTeamMembers = new map<Id,set<Id>>();
        
        for(Project_Resource__c item :[ SELECT Id,Project__c, Banker__c, Banker__r.User_ID__c, Banker__r.User_ID__r.IsActive, Status__c
                                        FROM Project_Resource__c 
                                        WHERE Project__c IN : DealToUpdate])
        {
            if(item.Banker__r.User_ID__c != null && item.Banker__r.User_ID__r.IsActive) Map_DealId_SetUserId.get(item.Project__c).add(item.Banker__r.User_ID__c);
            if(item.Status__c == 'Inactive' && item.Banker__c != null && item.Banker__r.User_ID__c != null){
                if(dealToInactiveDealTeamMembers.containsKey(item.Project__c)){
                    dealToInactiveDealTeamMembers.get(item.Project__c).add(item.Banker__r.User_ID__c);
                }
                else{
                    dealToInactiveDealTeamMembers.put(item.Project__c, new set<Id>{item.Banker__r.User_ID__c});
                }
            }
        }
        map<Id,set<Id>> dealToUserIdDeletedShares = new map<Id,set<Id>>();
        Map<Id,Id> Map_ParentId_UserOwnerId = new Map<Id,Id>();
        List<Ibanking_Project__Share> sharesForDelete = new List<Ibanking_Project__Share>();
        for(Ibanking_Project__Share item : [
            SELECT Id, UserOrGroupId, ParentId,RowCause
            FROM Ibanking_Project__Share 
            WHERE ParentId IN :Map_DealId_SetUserId.KeySet() 
            AND (RowCause In ('Manual', 'Owner') OR ParentId IN :dealToInactiveDealTeamMembers.keyset() )]) 
        {
            if(dealToInactiveDealTeamMembers.containsKey(item.ParentId)
            && dealToInactiveDealTeamMembers.get(item.ParentId).contains(item.UserOrGroupId)
            && item.RowCause == 'Manual'){
                sharesForDelete.add(item);
            }
            if (item.RowCause == 'Owner') Map_ParentId_UserOwnerId.put(item.ParentId,item.UserOrGroupId); 
        }
        
        
        List<Ibanking_Project__Share> sharesForInsert = new List<Ibanking_Project__Share>();
        for(Id Deal_Id : Map_DealId_SetUserId.KeySet())
        {
            system.debug('Deal_Id-------------->'+Deal_Id);
            for(Id UserId : Map_DealId_SetUserId.get(Deal_Id))
            {
                system.debug('UserId-------------->'+UserId);
                if(Map_ParentId_UserOwnerId.get(Deal_Id) != UserId 
                && !(dealToInactiveDealTeamMembers.containsKey(Deal_Id) && dealToInactiveDealTeamMembers.get(Deal_Id).contains(UserId)))
                {
                    Ibanking_Project__Share itemShare = new Ibanking_Project__Share();
                    itemShare.UserOrGroupId = UserId;
                    itemShare.ParentId      = Deal_Id;
                    itemShare.AccessLevel   = 'Edit';
                    itemShare.RowCause      = 'Manual';
                    sharesForInsert.add(itemShare);
                }
            }
        }
        if(sharesForInsert.size() > 0) database.insert(sharesForInsert,false);
        if(sharesForDelete.size() > 0)delete sharesForDelete;
        return true;
    }
/*
    public static void Set_UpdateDealSharing_True(  List<Id> List_DealId) 
    {
        List<Ibanking_Project__c> List_Deal_To_UpdateDealSharing = new List<Ibanking_Project__c>();
        for(Ibanking_Project__c item :[ SELECT Id,Update_Deal_Sharing__c,Referral_Source__c
                                FROM Ibanking_Project__c
                                WHERE Id IN : List_DealId])
        {
            item.Update_Deal_Sharing__c = true;
            List_Deal_To_UpdateDealSharing.add(item);
        }
        system.debug('List_Deal_To_UpdateDealSharing------------>'+List_Deal_To_UpdateDealSharing);
        if(List_Deal_To_UpdateDealSharing.size() > 0) update List_Deal_To_UpdateDealSharing;
    }
*/
/*
    
    // for update only
    public static void shareFrom_EmployeeProfile(Map<Id, Employee_Profile__c> Trigger_oldMap, List<Employee_Profile__c> Trigger_old, List<Employee_Profile__c> Trigger_new, boolean trigger_isUpdate, boolean trigger_isDelete) {

        if (trigger_isDelete) {
            system.debug('|||||||||||||||||||||||||||||||||||||||||||||||||||||||||| DELETE ');
            // get employeeIds
            Set<Id> employeeIds = new Set<Id>();    for(Employee_Profile__c item : Trigger_old) { employeeIds.add(item.Id); }

            // get list of dealId-employee pairs
            List<Pair> pairList = new List<Pair>();
            Set<Id> dealIds = new Set<Id>();
            for(Project_Resource__c item :[SELECT Id, Project__c, Banker__c 
                                            FROM Project_Resource__c 
                                            WHERE Banker__c in :employeeIds])
            {
                pairList.add(new Pair(item.Project__c, Trigger_oldMap.get(item.Banker__c)));
                dealIds.add(item.Project__c);
            }
            
            // get shares for delete
            List<Ibanking_Project__Share> sharesForDelete = new List<Ibanking_Project__Share>();
            for(Ibanking_Project__Share item : [
                SELECT Id, ParentId, UserOrGroupId, Parent.OwnerId 
                FROM Ibanking_Project__Share 
                WHERE ParentId in :dealIds and RowCause = 'Manual']) 
            {
                for(Pair itemPair : pairList) {
                    system.debug('itemPair.dealId===' + itemPair.dealId);
                    system.debug('itemPair.employee.User_Id__c===' + itemPair.employee.User_Id__c);
                    if(itemPair.dealId == item.ParentId && itemPair.employee.User_Id__c == item.UserOrGroupId) {
                        sharesForDelete.add(item);
                        break;
                    }
                }
            }
            
            system.debug('sharesForDelete=====' + sharesForDelete);

            delete sharesForDelete;
        }


            



        if (trigger_isUpdate) {
            
            // get employeeIds whose User_ID__c was changed
            Set<Id> employeeIds = new Set<Id>();
            for (Employee_Profile__c epItem : Trigger_new)
                if (epItem.User_ID__c != Trigger_oldMap.get(epItem.Id).User_ID__c)
                    employeeIds.add(epItem.Id);
            
            
        }


        if (trigger_isUpdate) {
            Map<Id, Set<Id>> Map_EmployeeId_EmployeeParams = new Map<Id, Set<Id>>();
            Map<Id, Id> Map_oldUserId_EmployeeId = new Map<Id, Id>();
            Map<Id, Id> Map_newUserId_EmployeeId = new Map<Id, Id>();
            List<Id> Employee_Ids = new List<Id>();
            
            Id oldUser_Id;
            Id newUser_Id;
            for (Employee_Profile__c epItem : Trigger_new) {
                newUser_Id = epItem.User_ID__c;
                oldUser_Id = Trigger_oldMap.get(epItem.Id).User_ID__c;
                if (newUser_Id != oldUser_Id) {
                    Map_EmployeeId_EmployeeParams.put(epItem.Id, new Set<Id>());
                    Employee_Ids.add(epItem.Id);
                    Map_newUserId_EmployeeId.put(newUser_Id, epItem.Id);
                    Map_oldUserId_EmployeeId.put(oldUser_Id, epItem.Id);
                }
            }
            system.debug('Map_EmployeeId_EmployeeParams === >>>' + Map_EmployeeId_EmployeeParams);
            system.debug('Employee_Ids === >>>' + Employee_Ids);
            system.debug('Map_newUserId_EmployeeId === >>>' + Map_newUserId_EmployeeId);
            system.debug('Map_oldUserId_EmployeeId === >>>' + Map_oldUserId_EmployeeId);
            
            Map<Id, User> Map_UserId_User = new Map<Id, User>([
                SELECT ID, Name, isActive 
                FROM User 
                WHERE Id in :Map_oldUserId_EmployeeId.keySet() or Id in :Map_newUserId_EmployeeId.keySet()]);
            system.debug('Map_UserId_User===' + Map_UserId_User);
            
            system.debug('============ Map_EmployeeId_EmployeeParams.keySet() =======>>>>> '+Map_EmployeeId_EmployeeParams.keySet());
            List<Project_Resource__c> projectResourceList = [
                SELECT Id,Project__c,Banker__c 
                FROM Project_Resource__c 
                WHERE Banker__c in :Employee_Ids];
                //WHERE Banker__c in :Map_EmployeeId_EmployeeParams.keySet()];
            system.debug('projectResourceList===' + projectResourceList);
            
            List<Id> projectIdList = new List<Id>();
            for(Project_Resource__c item : projectResourceList) {
                Map_EmployeeId_EmployeeParams.get(item.Banker__c).add(item.Project__c);
                projectIdList.add(item.Project__c);
            } 
            system.debug('projectIdList===' + projectIdList);
            
            
            
            
            
            
            
            
            
            
            
            // deleting project shares for old user
            List<Ibanking_Project__Share> sharesForDelete = new List<Ibanking_Project__Share>();
            for(Ibanking_Project__Share item : [
                SELECT Id, UserOrGroupId, ParentId
                FROM Ibanking_Project__Share 
                WHERE (UserOrGroupId in :Map_oldUserId_EmployeeId.keySet() or UserOrGroupId in :Map_newUserId_EmployeeId.keySet()) 
                    and ParentId in :projectIdList
                    and RowCause      = 'Manual']) 
            {
                //RowCause != 'Owner' AND 
                if(item.UserOrGroupId != null && item.ParentId != null && Map_oldUserId_EmployeeId.containsKey(item.UserOrGroupId) && 
                Map_EmployeeId_EmployeeParams.containsKey(Map_oldUserId_EmployeeId.get(item.UserOrGroupId)) && 
                        Map_EmployeeId_EmployeeParams.get(Map_oldUserId_EmployeeId.get(item.UserOrGroupId)).contains(item.ParentId)) {
                    sharesForDelete.add(item);
                }
            }
            system.debug('sharesForDelete.size===' + sharesForDelete.size());
            if (sharesForDelete.size() > 0)delete sharesForDelete;
            
            
            
            
            List<Id> userIdList_ForInsert = new List<Id>();
            for(Id idItem : Map_newUserId_EmployeeId.keySet()) 
                if (Map_UserId_User.get(idItem).IsActive == true) 
                    userIdList_ForInsert.add(idItem);
        
            // creating project shares for new user
            List<Ibanking_Project__Share> sharesForInsert = new List<Ibanking_Project__Share>();
            for(Id new_UserId : userIdList_ForInsert) {
                for(Id projectId : Map_EmployeeId_EmployeeParams.get(Map_newUserId_EmployeeId.get(new_UserId))) {
                    Ibanking_Project__Share memberShare = new Ibanking_Project__Share();
                    memberShare.UserOrGroupId = new_UserId;
                    memberShare.ParentId      = projectId;
                    memberShare.AccessLevel   = 'Edit';
                    memberShare.RowCause      = 'Manual';
                    sharesForInsert.add(memberShare);
                }
            }
            system.debug('newUser_Id  ===>>>' + newUser_Id);
            system.debug('sharesForInsert.size  ===>>>' + sharesForInsert.size());
            system.debug('sharesForInsert  ===>>>' + sharesForInsert);
            upsert sharesForInsert;
        }
    }


















    class Pair {
        public Id dealId {get;set;}
        public Employee_Profile__c employee {get;set;}
        public Pair(Id p_dealId, Employee_Profile__c p_employee) {
            dealId = p_dealId;
            employee = p_employee;
        }
    }

    public static void shareFrom_ProjectResource(List<Project_Resource__c> Trigger_old, List<Project_Resource__c> Trigger_new, boolean trigger_isInsert, boolean trigger_isUpdate, boolean trigger_isDelete) {
        // DELETE OR UPDATE OF PROJECT RESOURCE - DELETING OF SHARES /
        if (trigger_isDelete || trigger_isUpdate) {

            // get employeeIds & dealIds
            Set<Id> employeeIds = new Set<Id>();
            Set<Id> dealIds = new Set<Id>();
            for (Project_Resource__c item : trigger_old) { 
                employeeIds.add(item.Banker__c);
                dealIds.add(item.Project__c); 
            }
            
            // get list of dealId-employee pairs
            List<Pair> pairList = new List<Pair>();
            for(Employee_Profile__c itemEP : [
                SELECT Id, User_Id__c 
                FROM Employee_Profile__c 
                WHERE Id in :employeeIds and User_Id__c != null])
            {
                for(Project_Resource__c itemPR : Trigger_old)
                    if (itemEP.Id == itemPR.Banker__c)
                        pairList.add(new Pair(itemPR.Project__c, itemEP));
            }
            
            // get shares for delete
            List<Ibanking_Project__Share> sharesForDelete = new List<Ibanking_Project__Share>();
            for(Ibanking_Project__Share item : [
                SELECT Id, ParentId, UserOrGroupId, Parent.OwnerId 
                FROM Ibanking_Project__Share 
                WHERE ParentId in :dealIds and RowCause = 'Manual']) 
            {
                for(Pair itemPair : pairList) {
                    if(itemPair.dealId == item.ParentId && itemPair.employee.User_Id__c == item.UserOrGroupId) {
                        sharesForDelete.add(item);
                        break;
                    }
                }
            }
            
            system.debug('sharesForDelete=====' + sharesForDelete);

            delete sharesForDelete;
        } // if (trigger_isDelete) {
             
            

        // INSERT OR UPDATE OF PROJECT RESOURCE - INSERTING SHARES /
        if (trigger_isInsert || trigger_isUpdate) {

            // get projectResourceIds
            Set<Id> projectResourceIds = new Set<Id>();
            for (Project_Resource__c item : trigger_new) { 
                projectResourceIds.add(item.Id);
            }
            
            // get shares for insert
            List<Ibanking_Project__Share> sharesForInsert = new List<Ibanking_Project__Share>();
            for (Project_Resource__c item : [
                SELECT Id, Project__c, Banker__r.User_Id__c, Banker__r.User_ID__r.IsActive
                FROM Project_Resource__c 
                WHERE Id in :projectResourceIds and Banker__r.User_Id__c != null]) 
            {
                if(item.Banker__r.User_Id__r.IsActive)
                {
                    Ibanking_Project__Share memberShare = new Ibanking_Project__Share();
                    memberShare.UserOrGroupId = item.Banker__r.User_Id__c;
                    memberShare.ParentId      = item.Project__c;
                    memberShare.AccessLevel   = 'Edit';
                    memberShare.RowCause      = 'Manual';
                    sharesForInsert.add(memberShare);
                }
            }
            
            system.debug('sharesForInsert=====' + sharesForInsert);
            
            insert sharesForInsert;
        } // if (trigger_isInsert) {
    }


    public static void shareFrom_Deal(Map<Id, Ibanking_Project__c> Trigger_oldMap) {
        List<Ibanking_Project__Share> sharesForDelete = 
            [SELECT Id FROM Ibanking_Project__Share WHERE ParentId in :Trigger_oldMap.keySet()];
        delete sharesForDelete;
    }
*/
}