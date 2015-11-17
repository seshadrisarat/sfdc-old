@isTest(SeeAllData=true)
private class UtilsDeeperClone_test {

    private static Integer expectedAEWmailings = 1;
    private static Integer expectedFundCommunications = 1;
    private static Integer expectedFundCommunicationRecipients = 1;
    
    static testMethod void testCloneWithoutChatterAEWMailings()
    {
    
        Boolean withChatter = false;

        List<AEW_Mailing__c> AEWMailings = UtilsTest.createAEWMailings(expectedAEWmailings);
        List<Fund_Communication__c> FundCommunications = UtilsTest.createFundCommunications(expectedFundCommunications, null , AEWMailings[0].Id);
        List<Fund_Communication_Recipient__c> FundCommunicationRecipients = UtilsTest.createFundCommunicationRecipients(expectedFundCommunicationRecipients, null, FundCommunications[0].Id);
                        
        System.assertEquals(expectedAEWmailings, AEWMailings.size(),
            'expected ' + expectedAEWmailings + 'AEWMailings');
            
        System.assertEquals(expectedFundCommunications, FundCommunications.size(),
            'expected ' + expectedFundCommunications + 'FundCommunications');
            
        System.assertEquals(expectedFundCommunicationRecipients, FundCommunicationRecipients.size(),
            'expected ' + expectedFundCommunicationRecipients + 'FundCommunicationRecipients');

        Test.startTest();
        Id clonedId = UtilsDeeperClone.clone(AEWMailings[0].Id, withChatter);
        Test.stopTest();
        List<FeedItem> chatterFeeds = [SELECT Id FROM FeedItem WHERE ParentId = :clonedId];
        List<AEW_Mailing__c> clonedAEWMailings = [SELECT Id FROM AEW_Mailing__c WHERE Id = :clonedId];
        List<Fund_Communication__c> clonedFundCommunications = [SELECT Id FROM Fund_Communication__c WHERE AEW_Mailing__c = :clonedId];
        List<Fund_Communication_Recipient__c> clonedFundCommunicationRecipients = [SELECT Id FROM Fund_Communication_Recipient__c WHERE Fund_Communication__r.AEW_Mailing__c = :clonedId];

        System.assertEquals(withChatter, !chatterFeeds.isEmpty(),
            'expected chatter? ' + withChatter + ' ' + chatterFeeds.size());
            
        System.assertEquals(expectedAEWmailings, clonedAEWMailings.size(),
            'expected ' + expectedAEWmailings + 'cloned AEWMailings');
            
        System.assertEquals(expectedFundCommunications, clonedFundCommunications.size(),
            'expected ' + expectedFundCommunications + 'cloned FundCommunications');
            
        System.assertEquals(expectedFundCommunicationRecipients, clonedFundCommunicationRecipients.size(),
            'expected ' + expectedFundCommunicationRecipients + 'cloned FundCommunicationRecipients');
    }
    
        static testMethod void testCloneWithChatterAEWMailings()
    {
    
        Boolean withChatter = true;

        List<AEW_Mailing__c> AEWMailings = UtilsTest.createAEWMailings(expectedAEWmailings);
        List<Fund_Communication__c> FundCommunications = UtilsTest.createFundCommunications(expectedFundCommunications, null , AEWMailings[0].Id);
        List<Fund_Communication_Recipient__c> FundCommunicationRecipients = UtilsTest.createFundCommunicationRecipients(expectedFundCommunicationRecipients, null, FundCommunications[0].Id);
                        
        System.assertEquals(expectedAEWmailings, AEWMailings.size(),
            'expected ' + expectedAEWmailings + 'AEWMailings');
            
        System.assertEquals(expectedFundCommunications, FundCommunications.size(),
            'expected ' + expectedFundCommunications + 'FundCommunications');
            
        System.assertEquals(expectedFundCommunicationRecipients, FundCommunicationRecipients.size(),
            'expected ' + expectedFundCommunicationRecipients + 'FundCommunicationRecipients');

        Test.startTest();
        Id clonedId = UtilsDeeperClone.clone(AEWMailings[0].Id, withChatter);
        Test.stopTest();
        List<FeedItem> chatterFeeds = [SELECT Id FROM FeedItem WHERE ParentId = :clonedId];
        List<AEW_Mailing__c> clonedAEWMailings = [SELECT Id FROM AEW_Mailing__c WHERE Id = :clonedId];
        List<Fund_Communication__c> clonedFundCommunications = [SELECT Id FROM Fund_Communication__c WHERE AEW_Mailing__c = :clonedId];
        List<Fund_Communication_Recipient__c> clonedFundCommunicationRecipients = [SELECT Id FROM Fund_Communication_Recipient__c WHERE Fund_Communication__r.AEW_Mailing__c = :clonedId];
        
        System.assertEquals(withChatter, !chatterFeeds.isEmpty(),
            'expected chatter? ' + withChatter + ' ' + chatterFeeds.size());
        
        System.assertEquals(expectedAEWmailings, clonedAEWMailings.size(),
            'expected ' + expectedAEWmailings + 'cloned AEWMailings');
            
        System.assertEquals(expectedFundCommunications, clonedFundCommunications.size(),
            'expected ' + expectedFundCommunications + 'cloned FundCommunications');
            
        System.assertEquals(expectedFundCommunicationRecipients, clonedFundCommunicationRecipients.size(),
            'expected ' + expectedFundCommunicationRecipients + 'cloned FundCommunicationRecipients');
    }

}