public class HL_CampaignMemberHandler {
    @future  
    public static void SynchronizeParentCampaignMembers(Set<Id> campaignMembers){
    CampaignMember existingCampaignMember;
    List<Campaign> parentCampaigns;
    List<CampaignMember> parentCampaignMemberList, campaignMembersToInsert = New List<CampaignMember>(), campaignMembersToUpdate = new List<CampaignMember>();
    Set<Id> parentIds = new Set<Id>();    
    Map<Id, List<CampaignMember>> parentCampaignMembers = new Map<Id, List<CampaignMember>>();
    Map<String, Boolean> statusMap = new Map<String, Boolean>();
    //System.debug('Total Number of SOQL Queries allowed in this Apex code context: ' +  Limits.getLimitQueries());
    //System.debug('Total Number of records that can be queried  in this Apex code context: ' +  Limits.getLimitDmlRows()); 
    //System.debug('Total Number of DML statements allowed in this Apex code context: ' +  Limits.getLimitDmlStatements() ); 
    //System.debug('Total Number of CPU usage time (in ms) allowed in this Apex code context: ' +  Limits.getLimitCpuTime()); 

    //Store all the Parent Campaign IDs into a Set List
    for(CampaignMember cm : [Select Id, Campaign.ParentId From CampaignMember WHERE Id IN :campaignMembers])
    {
       if(cm.Campaign.ParentId != null)
       	 parentIds.add(cm.Campaign.ParentId);
    }
    
    if(parentIds.size() > 0)
    {
        //Get a List of Parent Campaigns with their Associated Campaign Members
        parentCampaigns = [SELECT Id, (SELECT Id, LeadId, ContactId, Campaign.ParentId, Status FROM CampaignMembers) FROM Campaign WHERE Id IN :parentIds AND ParentId != null];
    	
        If(parentCampaigns.size() > 0)
        {
            //Create a Map of Parent Campaigns with their Associated Campaign Members
            for (Campaign c : parentCampaigns)
                parentCampaignMembers.put(c.Id, c.CampaignMembers);
            
            //Find which Campaign Members we need to insert
            for (CampaignMember cm : [Select Id, CampaignId, LeadId, ContactId, Status, HasResponded, Campaign.ParentId From CampaignMember WHERE Id IN :campaignMembers]){
                if(statusMap.get(cm.Campaign.ParentId + '_' + cm.Status) == null){
                    statusMap.put(cm.Campaign.ParentId + '_' + cm.Status, cm.HasResponded);
                }     
                parentCampaignMemberList = parentCampaignMembers.get(cm.Campaign.ParentId);
               
                //Convert the Parent Campaign Member List to a Map
                Map<Id, CampaignMember> campaignContactMemberMap = new Map<Id, CampaignMember>();
                Map<Id, CampaignMember> campaignLeadMemberMap = New Map<Id, CampaignMember>();
                for(CampaignMember c : parentCampaignMemberList){
                    If(c.ContactId != null)
                        campaignContactMemberMap.put(c.ContactId, c);
                    Else
                        campaignLeadMemberMap.put(c.LeadId, c);
                }
                //Find if the Map Contains the Contact Id Being Inserted
                existingCampaignMember = campaignContactMemberMap.get(cm.ContactId);
                if(existingCampaignMember == null)
                    existingCampaignMember = campaignLeadMemberMap.get(cm.LeadId);
                
                If(existingCampaignMember == null){
                    campaignMembersToInsert.Add(New CampaignMember(CampaignId=cm.Campaign.ParentId, LeadId=cm.LeadId, ContactId=cm.ContactId, Status=cm.Status));            
                }
                Else{
                    //Check if the status needs to be updated
                    if(existingCampaignMember.Status != cm.Status){
                        existingCampaignMember.Status = cm.Status;             
                        campaignMembersToUpdate.Add(existingCampaignMember);
                    }
                }
            }
            
            //System.debug('1. Number of Queries used in this Apex code so far: ' + Limits.getQueries());
            //System.debug('2. Number of rows queried in this Apex code so far: ' + Limits.getDmlRows());
            //System.debug('3. Number of DML statements used so far: ' +  Limits.getDmlStatements());
            //System.debug('4. Amount of CPU time (in ms) used so far: ' + Limits.getCpuTime()); 
                
            if(campaignMembersToInsert.Size() > 0){
                //System.debug('Members To Insert: ' + campaignMembersToInsert.Size());
                //Insert missing CampaignMemberStatus Records
                if(statusMap.Size() > 0)
                    InsertMissingCampaignStatusRecords(statusMap, campaignMembersToInsert);
                //Insert new CampaignMember Records to the Parent Campaign
                insert campaignMembersToInsert;
            }
                
            if(campaignMembersToUpdate.Size() > 0){
                //Insert missing CampaignMemberStatus Records
                if(statusMap.Size() > 0)
                    InsertMissingCampaignStatusRecords(statusMap, campaignMembersToUpdate);
                //Update Campaign Member Status Records
                update campaignMembersToUpdate;  
             }
        }
    }
   }
    
    private static void InsertMissingCampaignStatusRecords(Map<String, Boolean> originalStatusMap, List<CampaignMember> campaignMembers){
        AggregateResult[] groupedResults;
        List<String> campaigns = new List<String>();
        List<CampaignMemberStatus> existingStatusList;
        Map<String,String> existingStatusMap = new Map<String,String>();
        List<CampaignMemberStatus> statusInserts = new List<CampaignMemberStatus>();
        Integer maxSort;
        
        //Create list of Campaigns
        for(CampaignMember cm : campaignMembers)
                campaigns.Add(cm.CampaignId);
       
        existingStatusList = [SELECT Id, CampaignId, HasResponded, Label, SortOrder FROM CampaignMemberStatus WHERE CampaignId In:campaigns];
        //Find the Max SortOrder for creating a map by CampaignId so that we do not duplicate the Sort Order
        groupedResults = [Select CampaignId, MAX(SortOrder) maxSort FROM CampaignMemberStatus WHERE CampaignId In:campaigns GROUP BY CampaignId];
        
        //Store the Sort Order into a Map
        Map<String,Integer> campaignMaxSortOrders = new Map<String, Integer>();
        for(AggregateResult ar : groupedResults)
        {
            if(ar.get('maxSort') != null)
                campaignMaxSortOrders.put(String.valueOf(ar.get('CampaignId')), Integer.valueOf(ar.get('maxSort')));      
        }
        
        //Create Map of Existing Statuses with Campaign Ids
        for(CampaignMemberStatus cms : existingStatusList)
            existingStatusMap.put(cms.CampaignId + '_' + cms.Label, cms.Id);

        for(CampaignMember cm : campaignMembers){
            if(existingStatusMap.get(cm.CampaignId + '_' + cm.Status) == null){
                if(campaignMaxSortOrders.get(cm.CampaignId) != null){
                    maxSort = campaignMaxSortOrders.get(cm.CampaignId);
                    campaignMaxSortOrders.put(cm.CampaignId, maxSort + 1);
                }
                else
                {
                    maxSort = 0;
                    campaignMaxSortOrders.put(cm.CampaignId, 0);
                }                   
                statusInserts.Add(New CampaignMemberStatus(CampaignId = cm.CampaignId, Label = cm.Status, SortOrder=maxSort+1, HasResponded = originalStatusMap.Get(cm.CampaignId + '_' + cm.Status)));
            }   
        }

        if(statusInserts.Size() > 0)
            insert statusInserts;
    }
}