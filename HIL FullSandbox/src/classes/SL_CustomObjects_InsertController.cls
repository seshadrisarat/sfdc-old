public class SL_CustomObjects_InsertController 
{
    private static Id idLoggedinUserId = UserInfo.getUserId();
    public SL_CustomObjects_InsertController()
    {
        
    }
    
    public Map <Id, Id> insertCustomObject(Set <Id> setClientId)
    {
        Set <Id> setRepCodeId = new Set <Id>();
        Map <Id, Id> mapClientIdToHoldId = new Map <Id, Id>();
        if(!setClientId.isEmpty())
        {
            for(Rep_Code_User__c objRepCodeUser : [SELECT User__c, Rep_Code__c FROM Rep_Code_User__c WHERE User__c =: idLoggedinUserId])
            {
                setRepCodeId.add(objRepCodeUser.Rep_Code__c);
            }
            
            if(!setRepCodeId.isEmpty())
            {
                for(Group_Member__c objGroupMember : [SELECT  Relationship_Group__c, 
                                                              Client_Prospect__c 
                                                      FROM Group_Member__c 
                                                      WHERE Client_Prospect__c IN: setClientId
                                                      AND Relationship_Group__r.Rep_Code__c IN: setRepCodeId
                                                      ORDER BY CREATEDDATE Desc LIMIT 1 ])
                {
                    mapClientIdToHoldId.put(objGroupMember.Client_Prospect__c,objGroupMember.Relationship_Group__c);
                }
            }
        }
        return mapClientIdToHoldId;
    }
}