@isTest
public class Utility_CommonTest {
    static testMethod void testInvRelLoad(){
        list<Inverse_Relationship__c> retList = TestDataFactory.createTestInverseRelationships();
        upsert retList;
        
        map<String, String> invRelMap = Utility_Common.inverseRelationshipMap;
        
        system.assertEquals(retList.get(0).Relationship_Inverse__c, invRelMap.get(retList.get(0).Relationship__c));
    }
}