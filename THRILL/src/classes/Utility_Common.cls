/**
* Utility_Common - class intended to contain shared reusable code
*/
public with sharing class Utility_Common {
    public static map<String, String> inverseRelationshipMap {
        get{
            if (inverseRelationshipMap==null){
                inverseRelationshipMap = new map<String,String>();
                list<Inverse_Relationship__c> invRelList = Inverse_Relationship__c.getAll().values();
                for (Inverse_Relationship__c currInvRel : invRelList){
                    inverseRelationshipMap.put(currInvRel.Relationship__c, currInvRel.Relationship_Inverse__c);
                }
            }
            return inverseRelationshipMap;
        }
        set;
    }


}