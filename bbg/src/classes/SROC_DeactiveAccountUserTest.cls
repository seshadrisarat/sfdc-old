@isTest
private class SROC_DeactiveAccountUserTest 
{ 
    static testMethod void myUnitTest() 
    {
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Owner').getRecordTypeId();
        Id dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Account objAccount1 = new Account(firstname = 'John',lastname= 'Lily', ShippingCity = 'USA',RecordtypeId = devRecordTypeId, brand__c='BC');
        insert objAccount1;
        Account objAccount2 = new Account(Name ='Test Account-01', ShippingCity = 'USA',RecordtypeId = dealerRecordTypeId, brand__c='BC');  
        insert objAccount2;
        Boat__c objBoat = new Boat__c(Name='SERF0617D154', Dealer__c = objAccount2.Id);
        insert objBoat;
        List<Owner_Boat_Relationship__c> lstOwnerBoatRelation = new List<Owner_Boat_Relationship__c>();
        for(Integer i = 0 ; i < 10 ; i++);
        {
            lstOwnerBoatRelation.add(new Owner_Boat_Relationship__c(Status__c='Active' , 
                                                                    SROC_Community_Status__c = 'Claimed', 
                                                                    HIN_Number__c = objBoat.Id, 
                                                                    Owner__c = objAccount1.Id)); 
        }
        insert lstOwnerBoatRelation;
        
        delete lstOwnerBoatRelation;
        
        update objAccount1;
    }
}