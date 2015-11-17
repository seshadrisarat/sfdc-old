@isTest
public class Test_HL_CampaignMemberInsertUpdate {
    @isTest public static void TestInsertWithOneCampaignMember(){
        //Test data setup
        //Create one campaign with one child campaign by calling our utility method
        Campaign[] campaigns = Test_HL_DataFactory.createChildCampaigns(1,1);       
        Contact testContact = Test_HL_DataFactory.createContacts(1)[0];
        CampaignMember cmToInsert = New CampaignMember(CampaignId = campaigns[0].Id, ContactId = testContact.Id);
        
        //Perform test
        Test.startTest();
        Database.SaveResult result = Database.insert(cmToInsert);
        Test.stopTest();
        
        //Verify the Campaign Member was Inserted into the Parent
        List<CampaignMember> cm = [SELECT Id FROM CampaignMember WHERE CampaignId=:campaigns[0].ParentId AND ContactId=:cmToInsert.ContactId];
        System.Assert(result.isSuccess());
        System.Assert(cm.size() == 1);
    }
    
    @isTest public static void TestInsertWithMultipleCampaignMembers(){
        //Test data setup
        //Create one campaign with one child campaign by calling our utility method
        Integer newMembers = 2;
        Campaign[] campaigns = Test_HL_DataFactory.createChildCampaigns(1,1);       
        List<Contact> testContacts = Test_HL_DataFactory.createContacts(newMembers);
        List<CampaignMember> cmToInsert = New List<CampaignMember>();
        for(Contact c:testContacts)
            cmToInsert.Add(New CampaignMember(CampaignId = campaigns[0].Id, ContactId = c.Id, Status='Sent'));

        //Perform test
        Test.startTest();
        List<Database.SaveResult> results = Database.insert(cmToInsert);
        Test.stopTest();
        
        //Verify the Campaign Members were Inserted into the Parent
        List<CampaignMember> cm = [SELECT Id FROM CampaignMember WHERE CampaignId=:campaigns[0].ParentId];
        System.Assert(cm.size() == newMembers);
    }
}