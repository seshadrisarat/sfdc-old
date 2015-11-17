@isTest
public class Test_HL_DataFactory {
    public static List<Campaign> createChildCampaigns(Integer numCampaigns, Integer numChildrenPerCampaign){
        List<Campaign> campaigns = new List<Campaign>();
        
        //Create Master Campaign
        Campaign master = new Campaign(Name='TestCampaign');
        insert master;
        
        for(Integer i=0;i<numCampaigns;i++){
            Campaign c = new Campaign(Name='TestCampaign_' + i,
                                     ParentId = master.Id);
            campaigns.add(c);
        }
        insert campaigns;
        
        List<Campaign> childCampaigns = new List<Campaign>();
        for(Integer j=0;j<numCampaigns;j++){
            Campaign parentC = campaigns[j];
            //For each Campaign just inserted, add child campaigns
            for(Integer k=0;k<numChildrenPerCampaign;k++){
                childCampaigns.add(new Campaign(Name='TestChildCampaign_' + k,
                                                ParentId=parentC.Id));
            }
        }
        
        //Insert the child campaigns
        insert childCampaigns;

        return childCampaigns;
    }
    
    public static List<Contact> createContacts(Integer numContacts){
        List<Contact> contacts = new List<Contact>();
        
        for(Integer i=0; i<numContacts;i++){
            Contact c = new Contact(FirstName='TestContact_' + i, LastName='TestContact_' + i);
            contacts.add(c);
        }
        insert contacts;
        return contacts;
    }
}