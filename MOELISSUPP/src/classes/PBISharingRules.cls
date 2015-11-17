public class PBISharingRules 
{
    public static boolean UpdateShare(  List<Id> PBIToUpdate)
    {
        Map<Id, Set<Id>> Map_PBIId_SetUserId = new Map<Id, Set<Id>> ();
        system.debug('PBIToUpdate -------------------------->'+PBIToUpdate);
        for (Id itemId : PBIToUpdate) Map_PBIId_SetUserId.put(itemId, new Set<Id>());
        for(Potential_Buyer_Investor_Deal_Team__c item :[   SELECT Id,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c, Target_Buyer__c
                                        FROM Potential_Buyer_Investor_Deal_Team__c
                                        WHERE Target_Buyer__c IN : PBIToUpdate])
        {
            system.debug('item.Banker__r.User_ID__r.IsActive---------------->'+item.Banker__r.User_ID__r.IsActive);
            if(item.Banker__r.User_ID__c != null && item.Banker__r.User_ID__r.IsActive)Map_PBIId_SetUserId.get(item.Target_Buyer__c).add(item.Banker__r.User_ID__c);
        }
        /* The sharing rules for the Deal Team Membership will need to be amended to apply to related PBI as well. */
        Map<Id,Set<Id>> Map_DealId_SetPBIID = new Map<Id,Set<Id>>();
        for(Potential_Buyer_Investor__c item :[ SELECT Id,Project__c
                                        FROM Potential_Buyer_Investor__c
                                        WHERE Id IN :PBIToUpdate])
        {
            if (Map_DealId_SetPBIID.containsKey(item.Project__c))   Map_DealId_SetPBIID.get(item.Project__c).add(item.Id);
            else 
            {
                Set<ID> tmp1 = new Set<ID>();
                tmp1.add(item.Id);
                Map_DealId_SetPBIID.put(item.Project__c,tmp1);
            }
        }
        for(Project_Resource__c item :[ SELECT Id,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c, Project__c
                                        FROM Project_Resource__c
                                        WHERE Project__c IN : Map_DealId_SetPBIID.keySet()])
        {
            //system.debug('PBI: item.Banker__r.User_ID__r.IsActive---------------->'+item.Banker__r.User_ID__r.IsActive);
            if(item.Banker__r.User_ID__c != null && item.Banker__r.User_ID__r.IsActive )
            {
                for(Id PBI_Id : Map_DealId_SetPBIID.get(item.Project__c))   Map_PBIId_SetUserId.get(PBI_Id).add(item.Banker__r.User_ID__c);
            }
        }
        
        Map<Id,Id> Map_ParentId_UserOwnerId = new Map<Id,Id>();
        List<Potential_Buyer_Investor__Share> sharesForDelete = new List<Potential_Buyer_Investor__Share>();
        for(Potential_Buyer_Investor__Share item : [
            SELECT Id, UserOrGroupId, ParentId,RowCause
            FROM Potential_Buyer_Investor__Share 
            WHERE ParentId IN :Map_PBIId_SetUserId.KeySet() AND (RowCause = 'Manual' OR RowCause = 'Owner')]) 
        {
            if (item.RowCause == 'Manual') sharesForDelete.add(item);
            if (item.RowCause == 'Owner') Map_ParentId_UserOwnerId.put(item.ParentId,item.UserOrGroupId); 
        }
        system.debug('sharesForDelete===' + sharesForDelete);
        if(sharesForDelete.size() > 0)delete sharesForDelete;
        
        List<Potential_Buyer_Investor__Share> sharesForInsert = new List<Potential_Buyer_Investor__Share>();
        for(Id PBI_Id : Map_PBIId_SetUserId.KeySet())
        {
            for(Id UserId : Map_PBIId_SetUserId.get(PBI_Id))
            {
                if(Map_ParentId_UserOwnerId.get(PBI_Id) != UserId)
                {
                    system.debug('PBI_Id === ' + PBI_Id+' UserId = '+UserId);
                    Potential_Buyer_Investor__Share itemShare = new Potential_Buyer_Investor__Share();
                    itemShare.UserOrGroupId = UserId;
                    itemShare.ParentId      = PBI_Id;
                    itemShare.AccessLevel   = 'Edit';
                    itemShare.RowCause      = 'Manual';
                    sharesForInsert.add(itemShare);
                }
            }
        }
        system.debug('sharesForInsert===' + sharesForInsert);
        if(sharesForInsert.size() > 0) insert sharesForInsert;
        return true;
    }
/*
    public static void Set_UpdatePBISharing_True(List<Id> List_PBIId) 
    {
        system.debug('List_PBIId------------>'+List_PBIId);
        List<Potential_Buyer_Investor__c> List_CallLog_To_UpdatePBISharing = new List<Potential_Buyer_Investor__c>();
        for(Potential_Buyer_Investor__c item :[ SELECT Id,Update_PBI_Sharing__c
                                FROM Potential_Buyer_Investor__c
                                WHERE Id IN : List_PBIId])
        {
            item.Update_PBI_Sharing__c = true;
            List_CallLog_To_UpdatePBISharing.add(item);
        }
        //system.debug('List_CallLog_To_UpdateCallLogSharing------------>'+List_CallLog_To_UpdateCallLogSharing);
        if(List_CallLog_To_UpdatePBISharing.size() > 0) update List_CallLog_To_UpdatePBISharing;    
    }
*/
}