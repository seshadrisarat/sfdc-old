/**
ClassName        : SL_Test_AddRemoveWGMemberController
JIRA Ticket      : AMSEC-559 
CreatedOn        : 
LastModifiedOn   : 
CreatededBy      : Vishnu
ModifiedBy       : 
Description      : Unit Test code for functionality that adds/removes WG Member on Deal__c(Inv. Opp.)
*/
@isTest
private class SL_Test_AddRemoveWGMemberController {

    static ApexPages.StandardController objStandarController;
    @testSetup static void setup() {
        //Creating New Contact
        Contact objContact = new Contact();
        objContact.LastName = 'TestContact1';
        objContact.Salesforce_User__c = UserInfo.getUserId();
        insert objContact;
        
        //Creating new Industry Group Record
        Industry_Group__c objInductryGroup = new Industry_Group__c();
        objInductryGroup.Name = 'TestIndustry';
        insert objInductryGroup;
        
        //Creating new Deal Record
        Deal__c objDeal = new Deal__c();
        objDeal.Name = 'Test Deal';
        objDeal.Industry_Deal__c = objInductryGroup.Id;
        insert objDeal;
        
        objStandarController = new ApexPages.standardController(objDeal);
    }
    static testMethod void testAddMeMethod() 
    {
        Test.startTest();
                    
            SL_AddRemoveWGMemberController objExtension = new SL_AddRemoveWGMemberController(objStandarController);
            system.assertEquals(objExtension.isAddMe, true);
            objExtension.addMe();
           
        Test.stopTest();
    }
    static testMethod void testRemoveMeMethod() 
    {
        
        Test.startTest();
                        
            SL_AddRemoveWGMemberController objExtension = new SL_AddRemoveWGMemberController(objStandarController);
            objExtension.addMe();
            objExtension = new SL_AddRemoveWGMemberController(objStandarController);
            system.assertEquals(objExtension.isAddMe, false);
            objExtension.removeMe(); 
            
        Test.stopTest();
    }
    
    static testMethod void testAddMeMethodAgain() 
    {
        Test.startTest();
            SL_AddRemoveWGMemberController objExtension = new SL_AddRemoveWGMemberController(objStandarController);
            objExtension.addMe();
            objExtension = new SL_AddRemoveWGMemberController(objStandarController);
            objExtension.removeMe();
            objExtension = new SL_AddRemoveWGMemberController(objStandarController);
            system.assertEquals(objExtension.isAddMe, true);
            objExtension.addMe();
        Test.stopTest();
        
    }
}