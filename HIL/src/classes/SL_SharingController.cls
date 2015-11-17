/* Author : Bryan Anderson */
public with sharing class SL_SharingController
{
    /**
     * Modifying the sharing attributes for a particular record.
     *
     * @param  ids  Set of ids to modify sharing rules. This will also be used to determine the sObject type
     * @param  userOrGroupId  user or group id to grant access to
     * @param  accessLevel  used to specify what access level should be given to the user or group specified
     * @return   Database.SaveResult
     */
    
    
    
    public static sObject[] modifySharing(sharingParams[] spList)
    {
        sObject[] sharingRecords;
        
        if(spList != null && !spList.isEmpty())
        {
            Id sObjId = spList[0].ParentId;
            
            Schema.SObjectType sObj = identifySObject(sObjId);
            
            String sObjName = sObj.getDescribe().getName();
            
            String sObjShareName = getShareObjName(sObjName);
            
            map<Id,Set<Id>> usrRecMap = new map<Id,Set<Id>>();
            Set<Id> pIds = new Set<Id>();
            
			for(sharingParams s : spList)
            {
                pIds.add(s.ParentId);
            }
            
            String query = 'Select Id,ParentId,UserOrGroupId From ' + sObjShareName + ' WHERE ParentId IN: pIds';
            
            sObject[] usrShares = Database.query(query);
            
            for(sObject s : usrShares)
            {
                if(usrRecMap.containsKey((Id)s.get('ParentId')))
                {
                    usrRecMap.get((Id)s.get('ParentId')).add((Id)s.get('UserOrGroupId'));
                }else
                {
                    usrRecMap.put((Id)s.get('ParentId'), new Set<Id>{(Id)s.get('UserOrGroupId')});
				}
            }
            
            Boolean isCustom = sObj.getDescribe().isCustom();
            
            sharingRecords = createSObjectList(spList,sObjShareName,sObjName,isCustom,usrRecMap);
        }
        
        return sharingRecords;
    }
    
    @TestVisible
    private static Schema.SObjectType identifySObject(Id sObjId)
    {
        Schema.SObjectType sObj = sObjId.getSobjectType();
        return sObj;
    }
    
    @TestVisible
    private static String getShareObjName(String sObjName)
    {
        String sObjShareName = '';
        
        if(sObjName.endsWith('__c'))
        {
            Integer index = sObjName.lastIndexOf('__c');
            sObjShareName = sObjName.substring(0,index) + '__Share';
        }else
        {
            sObjShareName = sObjName + 'Share';
        }
        
        return sObjShareName;
    }
    
    @TestVisible
    private static sObject[] createSObjectList(sharingParams[] spList, String sObjShareName,String stdObjName, Boolean isCustom, map<Id,Set<Id>> usrRecMap)
    {
        sObject[] sharingRecords = new sObject[]{};
            
        sObject shareSObj = Schema.getGlobalDescribe().get(sObjShareName).newSObject();
            
        for(sharingParams sp : spList)
        {
            if(!usrRecMap.get(sp.ParentId).contains(sp.UserOrGroupId))
            {
                shareSObj = shareSObj.clone();
                shareSObj.put(isCustom ? 'ParentId' : stdObjName + 'Id',sp.ParentId);
                shareSObj.put(isCustom ? 'AccessLevel' : stdObjName+'AccessLevel',sp.al);
                shareSObj.put('UserOrGroupId',sp.UserOrGroupId);
                
                sharingRecords.add(shareSObj);
            }
        }
        
        return sharingRecords;
    }
    
    public class sharingParams
    {
        Id ParentId;
        Id UserOrGroupId;
        String al;
        
        public sharingParams(Id ParentId, Id UserOrGroupId, String al)
        {
            this.ParentId = ParentId;
            this.UserOrGroupId = UserOrGroupId;
            this.al = al;
        }
    }
}