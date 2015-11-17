trigger AddContactToCampaign on Contact (after insert, after update) {
    List<CampaignMember> campaignMembers = new List<CampaignMember>();
    List<Contact> contacts = new List<Contact>();
    for (Contact c : Trigger.new) {
        if (c.Campaign__c != null) { 
            campaignMembers.add(new CampaignMember(
                ContactId = c.Id,
                CampaignId = c.Campaign__c
            ));
            contacts.add(new Contact(
                Id = c.Id,
                Campaign__c = null
            ));
        }
    }
    
    if (!campaignMembers.isEmpty()) {
        Database.insert(campaignMembers, false);
    }
    
    if (!contacts.isEmpty()) {
        update contacts;
    }
}