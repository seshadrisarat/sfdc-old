trigger updateLastActionDate on Action_Result__c (before insert) {

    for(Action_Result__c ar : Trigger.new){
        if(ar.Lead__c != null && ar.Campaign__c != null){
           List<CampaignMember> campaignMembers = [SELECT Last_Action__c, Attempts__c FROM CampaignMember WHERE LeadID = :ar.Lead__c AND CampaignId = :ar.Campaign__c];
           if(campaignMembers.size() > 0){
               for(CampaignMember cm : campaignMembers){
                   cm.Last_Action__c = ar.Action_Result_Date_Time__c;
                   if(cm.Attempts__c != null){
                       cm.Attempts__c++;
                   }else{
                       cm.Attempts__c = 1;
                   }
               }
               update campaignMembers;
           }
           
        }else if(ar.Contact__c != null && ar.Campaign__c != null){
           List<CampaignMember> campaignMembers = [SELECT Last_Action__c, Attempts__c FROM CampaignMember WHERE ContactID = :ar.Contact__c AND CampaignId = :ar.Campaign__c];
           if(campaignMembers.size() > 0){
               for(CampaignMember cm : campaignMembers){
                   cm.Last_Action__c = ar.Action_Result_Date_Time__c;
                   if(cm.Attempts__c != null){
                       cm.Attempts__c++;
                   }else{
                       cm.Attempts__c = 1;
                   }
               }
               update campaignMembers;
           }
           
        }
    }

}