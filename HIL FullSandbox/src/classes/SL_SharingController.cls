/* Author : Bryan Anderson */
public without sharing class SL_SharingController
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
            Schema.DescribeSObjectResult res = sObj.getDescribe();
            
            String sObjName = res.getName();
            Boolean isCustom = res.isCustom();

            
            String sObjShareName = getShareObjName(sObjName);
            
            map<Id,Set<Id>> usrRecMap = new map<Id,Set<Id>>();
            Set<Id> pIds = new Set<Id>();
            
			for(sharingParams s : spList)
            {
                pIds.add(s.ParentId);
            }

            String pIdStr = isCustom ? 'ParentId' : sObjName + 'Id';
            
            String query = 'Select Id,'+ pIdStr +',UserOrGroupId From ' + sObjShareName + ' WHERE ' + pIdStr + ' IN: pIds';

            System.debug(query);
            
            sObject[] usrShares = Database.query(query);
            
            for(sObject s : usrShares)
            {
                if(usrRecMap.containsKey((Id)s.get(pIdStr)))
                {
                    usrRecMap.get((Id)s.get(pIdStr)).add((Id)s.get('UserOrGroupId'));
                }else
                {
                    usrRecMap.put((Id)s.get(pIdStr), new Set<Id>{(Id)s.get('UserOrGroupId')});
				}
            }
            
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
            if((usrRecMap.get(sp.ParentId) != null && !usrRecMap.get(sp.ParentId).contains(sp.UserOrGroupId)) || (usrRecMap == null || usrRecMap.isEmpty()))
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